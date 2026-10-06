from flask import Blueprint, render_template, request, redirect, url_for, flash, session
from app.db import execute_query
from app.auth import login_required, role_required

faculty_bp = Blueprint('faculty', __name__)

@faculty_bp.route('/faculty/applications')
@login_required
@role_required('faculty', 'admin')
def applications_list():
    status_filter = request.args.get('status', '').strip()
    role = session.get('role')
    faculty_id = session.get('role_id')

    if role == 'faculty':
        sql = "SELECT * FROM vw_faculty_application_review WHERE faculty_id = %s"
        params = [faculty_id]
    else:
        sql = "SELECT * FROM vw_faculty_application_review WHERE 1=1"
        params = []

    if status_filter:
        sql += " AND application_status = %s"
        params.append(status_filter)

    sql += " ORDER BY applied_at DESC"

    apps = execute_query(sql, params, fetchall=True) or []
    return render_template('applications_list.html', applications=apps, current_status=status_filter)

@faculty_bp.route('/faculty/applications/<int:application_id>/status', methods=['POST'])
@login_required
@role_required('faculty', 'admin')
def update_application_status(application_id):
    new_status = request.form.get('status')
    if new_status not in ['pending', 'shortlisted', 'rejected', 'accepted', 'withdrawn']:
        flash("Invalid status value.", "danger")
        return redirect(request.referrer or url_for('faculty.applications_list'))

    try:
        execute_query("UPDATE applications SET status = %s WHERE application_id = %s", (new_status, application_id))
        flash(f"Application #{application_id} status updated to '{new_status}'.", "success")
    except Exception as e:
        flash(f"Update error: {str(e)}", "danger")

    return redirect(request.referrer or url_for('faculty.applications_list'))

@faculty_bp.route('/faculty/interviews/schedule/<int:application_id>', methods=['GET', 'POST'])
@login_required
@role_required('faculty', 'admin')
def schedule_interview(application_id):
    if request.method == 'POST':
        interviewer_name = request.form.get('interviewer_name', '').strip()
        interviewer_email = request.form.get('interviewer_email', '').strip()
        interview_datetime = request.form.get('interview_datetime', '').strip()
        mode = request.form.get('mode', 'online')

        try:
            execute_query(
                "CALL sp_schedule_interview(%s, %s, %s, %s, %s, @out_id)",
                (application_id, interviewer_name, interviewer_email, interview_datetime, mode)
            )
            flash("Interview scheduled successfully! Triggers verified timing rules.", "success")
            return redirect(url_for('faculty.applications_list'))
        except Exception as e:
            flash(f"Interview scheduling error: {str(e)}", "danger")

    app_details = execute_query("SELECT * FROM vw_faculty_application_review WHERE application_id = %s", (application_id,), fetchone=True)
    return render_template('interview_form.html', app_details=app_details)

@faculty_bp.route('/faculty/evaluations/create/<int:application_id>', methods=['GET', 'POST'])
@login_required
@role_required('faculty', 'admin')
def create_evaluation(application_id):
    if request.method == 'POST':
        tech_score = int(request.form.get('technical_score', 5))
        comm_score = int(request.form.get('communication_score', 5))
        overall = int(request.form.get('overall_rating', 5))
        comments = request.form.get('comments', '').strip()
        evaluator_id = session.get('role_id') or 1

        try:
            execute_query(
                "CALL sp_create_evaluation(%s, %s, %s, %s, %s, %s, @out_id)",
                (application_id, evaluator_id, tech_score, comm_score, overall, comments)
            )
            flash("Student evaluation submitted successfully!", "success")
            return redirect(url_for('faculty.applications_list'))
        except Exception as e:
            flash(f"Evaluation error: {str(e)}", "danger")

    app_details = execute_query("SELECT * FROM vw_faculty_application_review WHERE application_id = %s", (application_id,), fetchone=True)
    return render_template('evaluation_form.html', app_details=app_details)
