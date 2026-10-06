import csv
import io
from flask import Blueprint, render_template, session, redirect, url_for, flash, request, Response, send_file
from app.db import execute_query
from app.auth import login_required, role_required

main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def index():
    if 'user_id' in session:
        return redirect(url_for('main.dashboard'))
    return redirect(url_for('auth.login'))

@main_bp.route('/dashboard')
@login_required
def dashboard():
    role = session.get('role')
    user_id = session.get('user_id')
    role_id = session.get('role_id')

    if role == 'admin':
        placement_summary = execute_query("SELECT * FROM vw_admin_placement_summary", fetchone=True) or {}
        app_analytics = execute_query("SELECT * FROM vw_admin_application_analytics", fetchone=True) or {}
        system_activity = execute_query("SELECT * FROM vw_admin_system_activity", fetchone=True) or {}
        top_students = execute_query("SELECT * FROM vw_admin_student_performance ORDER BY gpa DESC LIMIT 5", fetchall=True) or []
        company_stats = execute_query("SELECT * FROM vw_admin_company_stats ORDER BY total_applications_received DESC LIMIT 5", fetchall=True) or []
        compliance_alerts = execute_query("SELECT * FROM vw_admin_compliance_report", fetchall=True) or []
        recent_audits = execute_query("SELECT * FROM audit_log ORDER BY timestamp DESC LIMIT 10", fetchall=True) or []
        pending_internships = execute_query("""
            SELECT i.*, c.name AS company_name, f.name AS faculty_name
            FROM internships i
            JOIN companies c ON i.company_id = c.company_id
            JOIN faculty f ON i.posted_by = f.faculty_id
            WHERE i.status = 'pending_approval'
            ORDER BY i.created_at DESC
        """, fetchall=True) or []

        return render_template('admin_dashboard.html',
                               placement=placement_summary,
                               analytics=app_analytics,
                               system=system_activity,
                               top_students=top_students,
                               companies=company_stats,
                               compliance=compliance_alerts,
                               audits=recent_audits,
                               pending_internships=pending_internships)

    elif role == 'faculty':
        posted_internships = execute_query(
            "SELECT * FROM vw_faculty_posted_internships WHERE faculty_id = %s",
            (role_id,), fetchall=True
        ) or []
        app_reviews = execute_query(
            "SELECT * FROM vw_faculty_application_review WHERE faculty_id = %s ORDER BY applied_at DESC LIMIT 8",
            (role_id,), fetchall=True
        ) or []
        evaluations = execute_query(
            "SELECT * FROM vw_faculty_student_evaluations WHERE faculty_id = %s LIMIT 5",
            (role_id,), fetchall=True
        ) or []
        interview_stats = execute_query(
            "SELECT * FROM vw_faculty_interview_stats WHERE faculty_id = %s",
            (role_id,), fetchone=True
        ) or {}

        return render_template('faculty_dashboard.html',
                               internships=posted_internships,
                               applications=app_reviews,
                               evaluations=evaluations,
                               interview_stats=interview_stats)

    elif role == 'student':
        my_apps = execute_query(
            "SELECT * FROM vw_student_my_applications WHERE student_user_id = %s ORDER BY applied_at DESC",
            (user_id,), fetchall=True
        ) or []
        interviews = execute_query(
            "SELECT * FROM vw_student_interview_schedule WHERE student_user_id = %s",
            (user_id,), fetchall=True
        ) or []
        placement_status = execute_query(
            "SELECT * FROM vw_student_placement_status WHERE student_user_id = %s",
            (user_id,), fetchone=True
        ) or {}
        recommended_internships = execute_query(
            "SELECT i.*, c.name AS company_name, c.location FROM internships i JOIN companies c ON i.company_id = c.company_id WHERE i.status = 'open' ORDER BY i.created_at DESC LIMIT 5",
            fetchall=True
        ) or []

        return render_template('student_dashboard.html',
                               applications=my_apps,
                               interviews=interviews,
                               placement=placement_status,
                               recommended=recommended_internships)

    return redirect(url_for('auth.login'))

@main_bp.route('/feedback/submit', methods=['GET', 'POST'])
@login_required
def submit_system_feedback():
    if request.method == 'POST':
        fb_type = request.form.get('type')
        description = request.form.get('description', '').strip()
        user_id = session.get('user_id')

        if not fb_type or not description:
            flash("Please specify feedback type and description.", "danger")
            return render_template('system_feedback_form.html')

        try:
            execute_query(
                "INSERT INTO system_feedback (user_id, type, description, status) VALUES (%s, %s, %s, 'new')",
                (user_id, fb_type, description)
            )
            flash("Thank you! Your system feedback has been submitted successfully.", "success")
            return redirect(url_for('main.dashboard'))
        except Exception as e:
            flash(f"Submission error: {str(e)}", "danger")

    return render_template('system_feedback_form.html')

@main_bp.route('/export/applications/csv')
@login_required
@role_required('admin', 'faculty')
def export_applications_csv():
    try:
        if session.get('role') == 'faculty':
            apps = execute_query(
                "SELECT * FROM vw_faculty_application_review WHERE faculty_id = %s",
                (session.get('role_id'),), fetchall=True
            )
        else:
            apps = execute_query("SELECT * FROM vw_faculty_application_review", fetchall=True)

        output = io.StringIO()
        writer = csv.writer(output)
        writer.writerow(['Application ID', 'Internship Title', 'Company Name', 'Student Name', 'Department', 'GPA', 'Status', 'Applied At'])

        for a in (apps or []):
            writer.writerow([
                a.get('application_id'),
                a.get('internship_title'),
                a.get('company_name'),
                a.get('student_name'),
                a.get('student_department'),
                a.get('student_gpa'),
                a.get('application_status'),
                a.get('applied_at')
            ])

        output.seek(0)
        return Response(
            output.getvalue(),
            mimetype="text/csv",
            headers={"Content-disposition": "attachment; filename=applications_report.csv"}
        )
    except Exception as e:
        flash(f"Export error: {str(e)}", "danger")
        return redirect(url_for('main.dashboard'))
