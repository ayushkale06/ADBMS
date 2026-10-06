from flask import Blueprint, render_template, request, redirect, url_for, flash, session
from app.db import execute_query
from app.auth import check_password, hash_password, validate_password_strength

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('email', '').strip().lower()
        password = request.form.get('password', '')

        if not email or not password:
            flash("Please enter both email and password.", "danger")
            return render_template('login.html', email=email)

        try:
            user = execute_query(
                "SELECT * FROM users WHERE email = %s",
                (email,),
                fetchone=True
            )

            if not user or not check_password(password, user['password_hash']):
                flash("Invalid email or password.", "danger")
                return render_template('login.html', email=email)

            if not user['is_active']:
                flash("Account is deactivated. Please contact administrator.", "danger")
                return render_template('login.html', email=email)

            if not user['is_verified']:
                flash("Account email is not verified. Please verify your account before logging in.", "warning")
                return render_template('login.html', email=email)

            # Retrieve profile details based on role
            profile_name = "User"
            role_id = None

            if user['role'] == 'student':
                student = execute_query("SELECT student_id, name FROM students WHERE user_id = %s", (user['user_id'],), fetchone=True)
                if student:
                    profile_name = student['name']
                    role_id = student['student_id']
            elif user['role'] == 'faculty':
                faculty = execute_query("SELECT faculty_id, name FROM faculty WHERE user_id = %s", (user['user_id'],), fetchone=True)
                if faculty:
                    profile_name = faculty['name']
                    role_id = faculty['faculty_id']
            elif user['role'] == 'admin':
                profile_name = "Administrator"
                role_id = user['user_id']

            session['user_id'] = user['user_id']
            session['email'] = user['email']
            session['role'] = user['role']
            session['name'] = profile_name
            session['role_id'] = role_id

            flash(f"Welcome back, {profile_name}!", "success")
            return redirect(url_for('main.dashboard'))

        except Exception as e:
            flash(f"Login error: {str(e)}", "danger")
            return render_template('login.html', email=email)

    return render_template('login.html')

@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name = request.form.get('name', '').strip()
        email = request.form.get('email', '').strip().lower()
        password = request.form.get('password', '')
        confirm_password = request.form.get('confirm_password', '')
        phone = request.form.get('phone', '').strip()
        department = request.form.get('department', '').strip()
        gpa_str = request.form.get('gpa', '0.00').strip()

        if not all([name, email, password, phone, department]):
            flash("All fields are required.", "danger")
            return render_template('register.html')

        if password != confirm_password:
            flash("Passwords do not match.", "danger")
            return render_template('register.html')

        valid_pwd, pwd_msg = validate_password_strength(password)
        if not valid_pwd:
            flash(pwd_msg, "danger")
            return render_template('register.html')

        try:
            gpa = float(gpa_str)
            if not (0.0 <= gpa <= 4.0):
                flash("GPA must be between 0.00 and 4.00.", "danger")
                return render_template('register.html')
        except ValueError:
            flash("Invalid GPA format.", "danger")
            return render_template('register.html')

        pwd_hash = hash_password(password)

        try:
            # Execute stored procedure sp_register_student
            # Note: stored procedure inserts user with is_verified = 1 for smooth testing
            res = execute_query(
                "CALL sp_register_student(%s, %s, %s, %s, %s, %s, %s, @student_id)",
                (email, pwd_hash, name, phone, department, gpa, None)
            )
            flash("Registration successful! You may now log in.", "success")
            return redirect(url_for('auth.login'))
        except Exception as e:
            flash(f"Registration failed: {str(e)}", "danger")
            return render_template('register.html')

    return render_template('register.html')

@auth_bp.route('/logout')
def logout():
    session.clear()
    flash("You have been logged out successfully.", "info")
    return redirect(url_for('auth.login'))
