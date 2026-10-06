from flask import Blueprint, render_template, request, redirect, url_for, flash, session
from app.db import execute_query
from app.auth import login_required, role_required

admin_bp = Blueprint('admin', __name__)

@admin_bp.route('/admin/users')
@login_required
@role_required('admin')
def manage_users():
    users = execute_query("""
        SELECT u.user_id, u.email, u.role, u.is_verified, u.is_active, u.created_at,
               COALESCE(s.name, f.name, 'Admin') AS display_name
        FROM users u
        LEFT JOIN students s ON u.user_id = s.user_id
        LEFT JOIN faculty f ON u.user_id = f.user_id
        ORDER BY u.created_at DESC
    """, fetchall=True) or []
    return render_template('users_list.html', users=users)

@admin_bp.route('/admin/users/<int:user_id>/toggle-status', methods=['POST'])
@login_required
@role_required('admin')
def toggle_user_status(user_id):
    try:
        user = execute_query("SELECT is_active FROM users WHERE user_id = %s", (user_id,), fetchone=True)
        if user:
            new_status = 0 if user['is_active'] else 1
            execute_query("UPDATE users SET is_active = %s WHERE user_id = %s", (new_status, user_id))
            execute_query("UPDATE students SET is_active = %s WHERE user_id = %s", (new_status, user_id))
            flash(f"User #{user_id} status updated.", "info")
    except Exception as e:
        flash(f"User toggle error: {str(e)}", "danger")
    return redirect(url_for('admin.manage_users'))

@admin_bp.route('/admin/users/<int:user_id>/verify', methods=['POST'])
@login_required
@role_required('admin')
def verify_user(user_id):
    try:
        execute_query("UPDATE users SET is_verified = 1 WHERE user_id = %s", (user_id,))
        flash(f"User #{user_id} email has been marked as verified.", "success")
    except Exception as e:
        flash(f"Verification error: {str(e)}", "danger")
    return redirect(url_for('admin.manage_users'))

@admin_bp.route('/admin/internships/<int:internship_id>/approve', methods=['POST'])
@login_required
@role_required('admin')
def approve_internship(internship_id):
    admin_id = session.get('user_id')
    try:
        execute_query("CALL sp_approve_internship(%s, %s)", (internship_id, admin_id))
        flash(f"Internship #{internship_id} approved! It is now live and open for student applications.", "success")
    except Exception as e:
        flash(f"Approval error: {str(e)}", "danger")
    return redirect(request.referrer or url_for('main.dashboard'))

@admin_bp.route('/admin/internships/<int:internship_id>/reject', methods=['POST'])
@login_required
@role_required('admin')
def reject_internship(internship_id):
    try:
        execute_query("UPDATE internships SET status = 'archived' WHERE internship_id = %s", (internship_id,))
        flash(f"Internship #{internship_id} rejected and archived.", "warning")
    except Exception as e:
        flash(f"Rejection error: {str(e)}", "danger")
    return redirect(request.referrer or url_for('main.dashboard'))

@admin_bp.route('/admin/companies/new', methods=['GET', 'POST'])
@login_required
@role_required('admin', 'faculty')
def create_company():
    if request.method == 'POST':
        name = request.form.get('name', '').strip()
        reg_num = request.form.get('registration_number', '').strip()
        location = request.form.get('location', '').strip()
        contact_person = request.form.get('contact_person', '').strip()
        contact_email = request.form.get('contact_email', '').strip()
        contact_phone = request.form.get('contact_phone', '').strip()

        try:
            execute_query(
                "CALL sp_create_company(%s, %s, %s, %s, %s, %s, @out_id)",
                (name, reg_num, location, contact_person, contact_email, contact_phone)
            )
            if session.get('role') == 'faculty':
                flash(f"Company '{name}' submitted successfully for Admin approval!", "success")
            else:
                flash(f"Company '{name}' registered successfully!", "success")
            return redirect(url_for('main.dashboard'))
        except Exception as e:
            flash(f"Company creation error: {str(e)}", "danger")

    return render_template('company_form.html')

@admin_bp.route('/admin/companies/<int:company_id>/archive', methods=['POST'])
@login_required
@role_required('admin')
def archive_company(company_id):
    try:
        execute_query("CALL sp_archive_company(%s)", (company_id,))
        flash(f"Company #{company_id} archived successfully.", "info")
    except Exception as e:
        flash(f"Archive error: {str(e)}", "danger")
    return redirect(url_for('main.dashboard'))

@admin_bp.route('/reports')
@login_required
def reports_page():
    placement_summary = execute_query("SELECT * FROM vw_admin_placement_summary", fetchone=True) or {}
    app_analytics = execute_query("SELECT * FROM vw_admin_application_analytics", fetchone=True) or {}
    student_perf = execute_query("SELECT * FROM vw_admin_student_performance ORDER BY gpa DESC", fetchall=True) or []
    company_stats = execute_query("SELECT * FROM vw_admin_company_stats ORDER BY total_applications_received DESC", fetchall=True) or []
    system_activity = execute_query("SELECT * FROM vw_admin_system_activity", fetchone=True) or {}
    compliance = execute_query("SELECT * FROM vw_admin_compliance_report", fetchall=True) or []

    return render_template('reports.html',
                           placement=placement_summary,
                           analytics=app_analytics,
                           student_perf=student_perf,
                           company_stats=company_stats,
                           system_activity=system_activity,
                           compliance=compliance)
