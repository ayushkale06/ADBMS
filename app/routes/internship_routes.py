from flask import Blueprint, render_template, request, redirect, url_for, flash, session
from app.db import execute_query
from app.auth import login_required, role_required

internship_bp = Blueprint('internships', __name__)

@internship_bp.route('/internships')
@login_required
def list_internships():
    domain_filter = request.args.get('domain', '').strip()
    company_filter = request.args.get('company', '').strip()
    location_filter = request.args.get('location', '').strip()
    stipend_min = request.args.get('stipend_min', '').strip()
    search_q = request.args.get('q', '').strip()

    sql = """
        SELECT i.*, c.name AS company_name, c.location, f.name AS faculty_name
        FROM internships i
        JOIN companies c ON i.company_id = c.company_id
        JOIN faculty f ON i.posted_by = f.faculty_id
        WHERE i.status = 'open'
    """
    params = []

    if domain_filter:
        sql += " AND i.domain = %s"
        params.append(domain_filter)

    if company_filter:
        sql += " AND c.name LIKE %s"
        params.append(f"%{company_filter}%")

    if location_filter:
        sql += " AND c.location LIKE %s"
        params.append(f"%{location_filter}%")

    if stipend_min:
        try:
            sql += " AND i.stipend >= %s"
            params.append(float(stipend_min))
        except ValueError:
            pass

    if search_q:
        sql += " AND (i.title LIKE %s OR i.description LIKE %s OR i.domain LIKE %s)"
        params.extend([f"%{search_q}%", f"%{search_q}%", f"%{search_q}%"])

    sql += " ORDER BY i.created_at DESC"

    try:
        internships = execute_query(sql, params, fetchall=True) or []
        domains = execute_query("SELECT DISTINCT domain FROM internships WHERE status = 'open'", fetchall=True) or []
        companies = execute_query("SELECT DISTINCT name FROM companies WHERE is_archived = 0", fetchall=True) or []
        return render_template('internships_list.html',
                               internships=internships,
                               domains=domains,
                               companies=companies,
                               filters={
                                   'domain': domain_filter,
                                   'company': company_filter,
                                   'location': location_filter,
                                   'stipend_min': stipend_min,
                                   'q': search_q
                               })
    except Exception as e:
        flash(f"Error loading internships: {str(e)}", "danger")
        return render_template('internships_list.html', internships=[], domains=[], companies=[], filters={})

@internship_bp.route('/internships/<int:internship_id>')
@login_required
def detail(internship_id):
    try:
        internship = execute_query("""
            SELECT i.*, c.name AS company_name, c.location, c.contact_person, c.contact_email, f.name AS faculty_name
            FROM internships i
            JOIN companies c ON i.company_id = c.company_id
            JOIN faculty f ON i.posted_by = f.faculty_id
            WHERE i.internship_id = %s
        """, (internship_id,), fetchone=True)

        if not internship:
            flash("Internship position not found.", "warning")
            return redirect(url_for('internships.list_internships'))

        has_applied = False
        application_info = None

        if session.get('role') == 'student':
            student_id = session.get('role_id')
            application_info = execute_query(
                "SELECT * FROM applications WHERE student_id = %s AND internship_id = %s",
                (student_id, internship_id), fetchone=True
            )
            has_applied = application_info is not None

        return render_template('internship_detail.html',
                               internship=internship,
                               has_applied=has_applied,
                               application=application_info)
    except Exception as e:
        flash(f"Error loading internship details: {str(e)}", "danger")
        return redirect(url_for('internships.list_internships'))

@internship_bp.route('/internships/new', methods=['GET', 'POST'])
@login_required
@role_required('faculty', 'admin')
def create_internship():
    if request.method == 'POST':
        company_id = request.form.get('company_id')
        title = request.form.get('title', '').strip()
        description = request.form.get('description', '').strip()
        domain = request.form.get('domain', '').strip()
        duration_weeks = request.form.get('duration_weeks')
        stipend = request.form.get('stipend')
        start_date = request.form.get('start_date')
        end_date = request.form.get('end_date')
        deadline = request.form.get('application_deadline')

        posted_by = session.get('role_id')
        if session.get('role') == 'admin':
            # Default to first faculty if admin posts directly
            fac = execute_query("SELECT faculty_id FROM faculty LIMIT 1", fetchone=True)
            posted_by = fac['faculty_id'] if fac else 1

        try:
            execute_query(
                "CALL sp_post_internship(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, @out_id)",
                (company_id, posted_by, title, description, domain,
                 int(duration_weeks), float(stipend), start_date, end_date, deadline)
            )
            flash("Internship posted successfully! It is pending approval.", "success")
            return redirect(url_for('main.dashboard'))
        except Exception as e:
            flash(f"Error posting internship: {str(e)}", "danger")

    companies = execute_query("SELECT company_id, name FROM companies WHERE is_archived = 0", fetchall=True) or []
    return render_template('internship_form.html', companies=companies)

@internship_bp.route('/internships/<int:internship_id>/archive', methods=['POST'])
@login_required
@role_required('faculty', 'admin')
def archive_internship(internship_id):
    try:
        execute_query("CALL sp_archive_internship(%s)", (internship_id,))
        flash("Internship archived successfully.", "info")
    except Exception as e:
        flash(f"Archive error: {str(e)}", "danger")
    return redirect(url_for('main.dashboard'))
