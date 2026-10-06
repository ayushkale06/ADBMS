-- ============================================================================
-- COLLEGE INTERNSHIP MANAGEMENT SYSTEM (ADBMS PROJECT)
-- File: /database/schema.sql
-- Description: Drop/Create Database, Tables, Indexes, and Constraints
-- Database System: MySQL 8.0+ (InnoDB, utf8mb4)
-- ============================================================================

DROP DATABASE IF EXISTS internship_db;
CREATE DATABASE internship_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE internship_db;

-- ----------------------------------------------------------------------------
-- Table 1: users
-- Core authentication and user authorization table.
-- Roles: admin, faculty, student
-- ----------------------------------------------------------------------------
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'faculty', 'student') NOT NULL,
    is_verified TINYINT(1) NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_users_email CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active_verified ON users(is_active, is_verified);

-- ----------------------------------------------------------------------------
-- Table 2: students
-- Student profiles linked to users. Soft deletion controlled by is_active.
-- ----------------------------------------------------------------------------
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    department VARCHAR(100) NOT NULL,
    gpa DECIMAL(3,2) NOT NULL,
    resume_path VARCHAR(255) DEFAULT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_students_users FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT chk_students_gpa CHECK (gpa BETWEEN 0.00 AND 4.00),
    CONSTRAINT chk_students_phone CHECK (phone REGEXP '^\\+?[0-9]{10,15}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_students_dept ON students(department);
CREATE INDEX idx_students_gpa ON students(gpa);
CREATE INDEX idx_students_active ON students(is_active);

-- ----------------------------------------------------------------------------
-- Table 3: faculty
-- Faculty profiles linked to users.
-- ----------------------------------------------------------------------------
CREATE TABLE faculty (
    faculty_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_faculty_users FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT chk_faculty_phone CHECK (phone REGEXP '^\\+?[0-9]{10,15}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_faculty_dept ON faculty(department);

-- ----------------------------------------------------------------------------
-- Table 4: companies
-- Employer partner details. Archiving controlled by is_archived.
-- ----------------------------------------------------------------------------
CREATE TABLE companies (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    registration_number VARCHAR(50) NOT NULL UNIQUE,
    location VARCHAR(150) NOT NULL,
    contact_person VARCHAR(100) NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    is_archived TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_companies_email CHECK (contact_email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_companies_phone CHECK (contact_phone REGEXP '^\\+?[0-9]{10,15}$'),
    CONSTRAINT chk_companies_reg CHECK (registration_number REGEXP '^[-A-Za-z0-9_]{5,30}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_companies_location ON companies(location);
CREATE INDEX idx_companies_archived ON companies(is_archived);

-- ----------------------------------------------------------------------------
-- Table 5: internships
-- Posted internship positions. Requires faculty poster and optional admin approval.
-- ----------------------------------------------------------------------------
CREATE TABLE internships (
    internship_id INT AUTO_INCREMENT PRIMARY KEY,
    company_id INT NOT NULL,
    posted_by INT NOT NULL,
    approved_by INT DEFAULT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    domain VARCHAR(100) NOT NULL,
    duration_weeks INT NOT NULL,
    stipend DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    application_deadline DATETIME NOT NULL,
    status ENUM('pending_approval', 'open', 'closed', 'archived') NOT NULL DEFAULT 'pending_approval',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_internships_company FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_internships_posted_by FOREIGN KEY (posted_by) REFERENCES faculty(faculty_id) ON DELETE CASCADE,
    CONSTRAINT fk_internships_approved_by FOREIGN KEY (approved_by) REFERENCES users(user_id) ON DELETE SET NULL,
    CONSTRAINT chk_internships_duration CHECK (duration_weeks BETWEEN 4 AND 26),
    CONSTRAINT chk_internships_stipend CHECK (stipend >= 0.00),
    CONSTRAINT chk_internships_dates CHECK (start_date < end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_internships_domain ON internships(domain);
CREATE INDEX idx_internships_status ON internships(status);
CREATE INDEX idx_internships_stipend ON internships(stipend);
CREATE INDEX idx_internships_company ON internships(company_id);
CREATE INDEX idx_internships_deadline ON internships(application_deadline);

-- ----------------------------------------------------------------------------
-- Table 6: applications
-- Student internship applications. Unique constraint prevents duplicate applications.
-- ----------------------------------------------------------------------------
CREATE TABLE applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    internship_id INT NOT NULL,
    resume_path VARCHAR(255) NOT NULL,
    cover_letter TEXT DEFAULT NULL,
    qualifications TEXT DEFAULT NULL,
    status ENUM('pending', 'shortlisted', 'rejected', 'accepted', 'withdrawn') NOT NULL DEFAULT 'pending',
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_student_internship UNIQUE (student_id, internship_id),
    CONSTRAINT fk_applications_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_applications_internship FOREIGN KEY (internship_id) REFERENCES internships(internship_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_applications_student ON applications(student_id);
CREATE INDEX idx_applications_internship ON applications(internship_id);
CREATE INDEX idx_applications_status ON applications(status);

-- ----------------------------------------------------------------------------
-- Table 7: interviews
-- Scheduled interviews for shortlisted applications.
-- ----------------------------------------------------------------------------
CREATE TABLE interviews (
    interview_id INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL,
    interviewer_name VARCHAR(100) NOT NULL,
    interviewer_email VARCHAR(255) NOT NULL,
    interview_datetime DATETIME NOT NULL,
    mode ENUM('online', 'in_person', 'telephonic') NOT NULL DEFAULT 'online',
    result ENUM('scheduled', 'passed', 'failed', 'cancelled') NOT NULL DEFAULT 'scheduled',
    comments TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_interviews_app FOREIGN KEY (application_id) REFERENCES applications(application_id) ON DELETE CASCADE,
    CONSTRAINT chk_interviews_email CHECK (interviewer_email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_interviews_app ON interviews(application_id);
CREATE INDEX idx_interviews_datetime ON interviews(interview_datetime);
CREATE INDEX idx_interviews_result ON interviews(result);

-- ----------------------------------------------------------------------------
-- Table 8: evaluations
-- Faculty evaluation of student internship performance.
-- ----------------------------------------------------------------------------
CREATE TABLE evaluations (
    evaluation_id INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL,
    evaluator_id INT NOT NULL,
    technical_score INT NOT NULL,
    communication_score INT NOT NULL,
    overall_rating INT NOT NULL,
    comments TEXT DEFAULT NULL,
    is_archived TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_evaluations_app FOREIGN KEY (application_id) REFERENCES applications(application_id) ON DELETE CASCADE,
    CONSTRAINT fk_evaluations_evaluator FOREIGN KEY (evaluator_id) REFERENCES faculty(faculty_id) ON DELETE CASCADE,
    CONSTRAINT chk_eval_tech CHECK (technical_score BETWEEN 1 AND 5),
    CONSTRAINT chk_eval_comm CHECK (communication_score BETWEEN 1 AND 5),
    CONSTRAINT chk_eval_overall CHECK (overall_rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_evaluations_app ON evaluations(application_id);
CREATE INDEX idx_evaluations_evaluator ON evaluations(evaluator_id);

-- ----------------------------------------------------------------------------
-- Table 9: student_feedback
-- Student feedback on company, culture, and learning experience.
-- ----------------------------------------------------------------------------
CREATE TABLE student_feedback (
    student_feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL UNIQUE,
    company_culture INT NOT NULL,
    mentorship INT NOT NULL,
    technical_learning INT NOT NULL,
    work_environment INT NOT NULL,
    overall INT NOT NULL,
    comments TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sf_app FOREIGN KEY (application_id) REFERENCES applications(application_id) ON DELETE CASCADE,
    CONSTRAINT chk_sf_culture CHECK (company_culture BETWEEN 1 AND 5),
    CONSTRAINT chk_sf_mentor CHECK (mentorship BETWEEN 1 AND 5),
    CONSTRAINT chk_sf_tech CHECK (technical_learning BETWEEN 1 AND 5),
    CONSTRAINT chk_sf_env CHECK (work_environment BETWEEN 1 AND 5),
    CONSTRAINT chk_sf_overall CHECK (overall BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- Table 10: company_feedback
-- Employer feedback on student performance during internship.
-- ----------------------------------------------------------------------------
CREATE TABLE company_feedback (
    company_feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL UNIQUE,
    technical_skills INT NOT NULL,
    soft_skills INT NOT NULL,
    punctuality INT NOT NULL,
    responsibility INT NOT NULL,
    teamwork INT NOT NULL,
    learning_ability INT NOT NULL,
    likely_to_hire_fulltime TINYINT(1) NOT NULL DEFAULT 0,
    comments TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cf_app FOREIGN KEY (application_id) REFERENCES applications(application_id) ON DELETE CASCADE,
    CONSTRAINT chk_cf_tech CHECK (technical_skills BETWEEN 1 AND 5),
    CONSTRAINT chk_cf_soft CHECK (soft_skills BETWEEN 1 AND 5),
    CONSTRAINT chk_cf_punc CHECK (punctuality BETWEEN 1 AND 5),
    CONSTRAINT chk_cf_resp CHECK (responsibility BETWEEN 1 AND 5),
    CONSTRAINT chk_cf_team CHECK (teamwork BETWEEN 1 AND 5),
    CONSTRAINT chk_cf_learn CHECK (learning_ability BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- Table 11: faculty_feedback
-- Faculty assessment of internship suitability for course objectives.
-- ----------------------------------------------------------------------------
CREATE TABLE faculty_feedback (
    faculty_feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    internship_id INT NOT NULL,
    faculty_id INT NOT NULL,
    suitability_for_course INT NOT NULL,
    learning_outcomes INT NOT NULL,
    quality_rating INT NOT NULL,
    suggestions TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ff_internship FOREIGN KEY (internship_id) REFERENCES internships(internship_id) ON DELETE CASCADE,
    CONSTRAINT fk_ff_faculty FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id) ON DELETE CASCADE,
    CONSTRAINT chk_ff_suit CHECK (suitability_for_course BETWEEN 1 AND 5),
    CONSTRAINT chk_ff_outcomes CHECK (learning_outcomes BETWEEN 1 AND 5),
    CONSTRAINT chk_ff_quality CHECK (quality_rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- Table 12: system_feedback
-- System bugs, feature requests, and improvement suggestions from users.
-- ----------------------------------------------------------------------------
CREATE TABLE system_feedback (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    type ENUM('feature', 'bug', 'improvement') NOT NULL,
    description TEXT NOT NULL,
    status ENUM('new', 'in_review', 'planned', 'done') NOT NULL DEFAULT 'new',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sysfb_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- Table 13: company_ratings
-- Overall 1-5 star ratings given by students to companies.
-- ----------------------------------------------------------------------------
CREATE TABLE company_ratings (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    company_id INT NOT NULL,
    rating INT NOT NULL,
    review TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_student_company_rating UNIQUE (student_id, company_id),
    CONSTRAINT fk_cr_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_cr_company FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE CASCADE,
    CONSTRAINT chk_cr_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- Table 14: audit_log
-- Audit log tracking system actions, user updates, and data mutations.
-- ----------------------------------------------------------------------------
CREATE TABLE audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    action_type VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    performed_by VARCHAR(255) NOT NULL DEFAULT 'SYSTEM',
    old_values JSON DEFAULT NULL,
    new_values JSON DEFAULT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_audit_table ON audit_log(table_name);
CREATE INDEX idx_audit_timestamp ON audit_log(timestamp);
