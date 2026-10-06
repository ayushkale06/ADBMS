import os
from flask import Blueprint, render_template, request, redirect, url_for, flash, session, current_app
from werkzeug.utils import secure_filename
from app.db import execute_query
from app.auth import login_required, role_required

student_bp = Blueprint('student', __name__)

ALLOWED_EXTENSIONS = {'pdf'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@student_bp.route('/apply/<int:internship_id>', methods=['GET', 'POST'])
@login_required
@role_required('student')
def apply_internship(internship_id):
    student_id = session.get('role_id')

    if request.method == 'POST':
        cover_letter = request.form.get('cover_letter', '').strip()
        qualifications = request.form.get('qualifications', '').strip()

        # Handle Resume File Upload
        resume_file = request.files.get('resume')
        resume_path = None

        # Check existing resume path
        existing_student = execute_query("SELECT resume_path FROM students WHERE student_id = %s", (student_id,), fetchone=True)

        if resume_file and resume_file.filename:
            if not allowed_file(resume_file.filename):
                flash("Invalid file format. Only PDF files (.pdf) are accepted.", "danger")
                return redirect(request.url)

            # Check size (< 5MB)
            resume_file.seek(0, os.SEEK_END)
            file_length = resume_file.tell()
            resume_file.seek(0)
            if file_length > 5 * 1024 * 1024:
                flash("File size exceeds 5MB limit. Please upload a smaller PDF.", "danger")
                return redirect(request.url)

            filename = secure_filename(f"student_{student_id}_{resume_file.filename}")
            upload_dir = os.path.join(current_app.root_path, 'static', 'uploads', 'resumes')
            os.makedirs(upload_dir, exist_ok=True)
            save_path = os.path.join(upload_dir, filename)
            resume_file.save(save_path)
            resume_path = f"app/static/uploads/resumes/{filename}"

            # Update student record resume path
            execute_query("UPDATE students SET resume_path = %s WHERE student_id = %s", (resume_path, student_id))
        elif existing_student and existing_student.get('resume_path'):
            resume_path = existing_student.get('resume_path')
        else:
            flash("Resume is mandatory for submitting applications.", "danger")
            return redirect(request.url)

        try:
            execute_query(
                "CALL sp_submit_application(%s, %s, %s, %s, %s, @app_id)",
                (student_id, internship_id, resume_path, cover_letter, qualifications)
            )
            flash("Application submitted successfully!", "success")
            return redirect(url_for('main.dashboard'))
        except Exception as e:
            flash(f"Application error: {str(e)}", "danger")

    internship = execute_query("SELECT i.*, c.name AS company_name FROM internships i JOIN companies c ON i.company_id = c.company_id WHERE i.internship_id = %s", (internship_id,), fetchone=True)
    student = execute_query("SELECT * FROM students WHERE student_id = %s", (student_id,), fetchone=True)

    return render_template('application_form.html', internship=internship, student=student)

@student_bp.route('/applications/<int:application_id>/withdraw', methods=['POST'])
@login_required
@role_required('student')
def withdraw_application(application_id):
    try:
        execute_query("CALL sp_withdraw_application(%s)", (application_id,))
        flash("Application withdrawn successfully.", "info")
    except Exception as e:
        flash(f"Withdrawal error: {str(e)}", "danger")
    return redirect(url_for('main.dashboard'))

@student_bp.route('/feedback/student/<int:application_id>', methods=['GET', 'POST'])
@login_required
@role_required('student')
def submit_student_feedback(application_id):
    if request.method == 'POST':
        culture = int(request.form.get('company_culture', 5))
        mentorship = int(request.form.get('mentorship', 5))
        tech = int(request.form.get('technical_learning', 5))
        env = int(request.form.get('work_environment', 5))
        overall = int(request.form.get('overall', 5))
        comments = request.form.get('comments', '').strip()
        rating = int(request.form.get('company_rating', 5))

        app_info = execute_query("SELECT student_id, i.company_id FROM applications a JOIN internships i ON a.internship_id = i.internship_id WHERE a.application_id = %s", (application_id,), fetchone=True)

        try:
            execute_query("""
                INSERT INTO student_feedback (application_id, company_culture, mentorship, technical_learning, work_environment, overall, comments)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (application_id, culture, mentorship, tech, env, overall, comments))

            if app_info:
                execute_query("""
                    INSERT INTO company_ratings (student_id, company_id, rating, review)
                    VALUES (%s, %s, %s, %s)
                    ON DUPLICATE KEY UPDATE rating = VALUES(rating), review = VALUES(review)
                """, (app_info['student_id'], app_info['company_id'], rating, comments))

            flash("Post-internship feedback and rating submitted successfully!", "success")
            return redirect(url_for('main.dashboard'))
        except Exception as e:
            flash(f"Feedback submission error: {str(e)}", "danger")

    return render_template('student_feedback_form.html', application_id=application_id)
