# College Internship Management System (ADBMS Database Project)

A complete **College Internship Management System** built with a robust **MySQL 8.0** database (3NF relational schema, stored procedures, triggers, views, roles, scheduled events) and a lightweight **Python (Flask)** web application.

---

## 🌟 Tech Stack & Features

- **Database System**: MySQL 8.x (InnoDB engine, utf8mb4 encoding)
- **Backend Framework**: Python 3.11+ / Flask / `mysql-connector-python`
- **Security**: Passwords hashed with `bcrypt` (never plain text), MySQL Role-Based Access Control (RBAC), Flask Session Security
- **Frontend**: HTML5, CSS3, Bootstrap 5, FontAwesome Icons, Chart.js for data visualization
- **Data Validations**: RFC 5322 Email regex, International phone format, GPA range (0.0–4.0), mandatory PDF resume check (5MB max), start/end date checks, interview scheduling notice (>=24h and before application deadline).

---

## 📁 Repository Structure

```
ADBMS/
│
├── database/
│   ├── schema.sql           # Database creation, tables, PK/FK constraints, CHECK rules, indexes
│   ├── triggers.sql         # Validation triggers (PDF resume, 24h notice, deadline check, audit logging)
│   ├── procedures.sql       # Stored procedures (with transactions/handlers), functions & event scheduler
│   ├── views.sql            # Reporting views for Admin, Faculty, and Student dashboards
│   ├── roles.sql            # MySQL security roles (admin_role, faculty_role, student_role) & GRANTs
│   ├── seed.sql             # Realistic sample data (16 students, 8 companies, 22 internships, 45 apps, etc.)
│   ├── queries.sql          # Demo reporting queries, functions demonstration, EXPLAIN index examples
│   ├── test_validations.sql # Validation verification suite demonstrating database error responses
│   └── README.md            # Execution guide for MySQL Workbench & EER diagram instructions
│
├── app/
│   ├── __init__.py          # Flask application factory
│   ├── app.py               # Main Flask server entry point
│   ├── db.py                # MySQL connection pooling & query helper
│   ├── auth.py              # Bcrypt password hashing & session authentication decorators
│   ├── routes/              # Modular Flask route blueprints
│   │   ├── auth_routes.py   # Login, Logout, Student Registration
│   │   ├── main_routes.py   # Dashboards, CSV Export, System Feedback
│   │   ├── internship_routes.py # Search, Filter, Post, Archive Internships
│   │   ├── student_routes.py# Application submission, Resume PDF upload, Feedback
│   │   ├── faculty_routes.py# Application review, Shortlisting, Interviews, Evaluations
│   │   └── admin_routes.py  # User management, Company CRUD, Approvals, Reports
│   ├── templates/           # Jinja2 HTML layout templates per role
│   └── static/              # CSS, JS, and uploaded student PDF resumes
│
├── .env.example             # Database configuration template
├── .env                     # Local configuration file
├── requirements.txt         # Python dependencies
└── README.md                # Main documentation & setup guide
```

---

## 🚀 Setup & Execution Guide

### Step 1: Initialize MySQL Database (in MySQL Workbench)

1. Open **MySQL Workbench** and connect to your local MySQL 8.0 server instance (`localhost:3306`).
2. Go to **File > Open SQL Script...** (`Ctrl + O`).
3. Execute the SQL scripts in the **database/** directory in the exact order:
   ```bash
   1. database/schema.sql
   2. database/triggers.sql
   3. database/procedures.sql
   4. database/views.sql
   5. database/roles.sql
   6. database/seed.sql
   ```
4. Refresh the MySQL Workbench Schema panel to confirm `internship_db` is loaded.

---

### Step 2: Configure Environment Variables

Create or edit the `.env` file in the root folder with your local MySQL credentials:

```ini
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=internship_db
SECRET_KEY=super-secret-key-12345
UPLOAD_FOLDER=app/static/uploads/resumes
MAX_CONTENT_LENGTH=5242880
```

---

### Step 3: Install Python Dependencies & Launch App

1. Open PowerShell / Terminal in the project root folder:
   ```powershell
   python -m pip install -r requirements.txt
   ```
2. Start the Flask application:
   ```powershell
   python app/app.py
   ```
3. Open your web browser and navigate to:
   `http://localhost:5000`

---

## 🔑 Pre-Configured Demo Login Credentials

For testing and demonstration, use these sample accounts (or use the 1-Click Fill buttons on the login page):

| Role | Email Address | Password | Profile Name |
|---|---|---|---|
| **Admin** | `admin@college.edu` | `Admin@123` | Administrator |
| **Faculty** | `dr.smith@college.edu` | `Faculty@123` | Dr. Robert Smith |
| **Student** | `alex.turner@student.edu` | `Student@123` | Alex Turner |
| **Student** | `sophia.chen@student.edu` | `Student@123` | Sophia Chen |

---

## 📸 ADBMS Submission Screenshot Checklist

For your college assignment submission, capture screenshots of the following:

1. **EER Diagram**: Generated in MySQL Workbench (**Database > Reverse Engineer > internship_db**).
2. **Tables & Seed Data**: Run `SELECT COUNT(*) FROM students;`, `SELECT * FROM vw_admin_placement_summary;` in MySQL Workbench.
3. **Trigger Validation Error**: Run a failing query from `database/test_validations.sql` in Workbench (e.g. non-PDF resume or scheduling interview past deadline) showing the `SIGNAL SQLSTATE '45000'` error message box.
4. **Admin Dashboard**: Web UI at `http://localhost:5000` after logging in as `admin@college.edu` showing Placement Charts & System Activity.
5. **Faculty Dashboard**: Web UI after logging in as `dr.smith@college.edu` showing Posted Internships & Application Review buttons.
6. **Student Dashboard & Internship Application**: Web UI after logging in as `alex.turner@student.edu` showing Placement Banner, Applied Internships, and Resume PDF download.
7. **Analytical Reports Page**: Web UI at `http://localhost:5000/reports` showing placement rates, student performance table, and company statistics charts.
