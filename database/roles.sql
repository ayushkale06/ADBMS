-- ============================================================================
-- COLLEGE INTERNSHIP MANAGEMENT SYSTEM (ADBMS PROJECT)
-- File: /database/roles.sql
-- Description: MySQL Roles, Users, and Fine-Grained Security Privilege GRANTs
-- Database System: MySQL 8.0+
-- ============================================================================

USE internship_db;

-- ----------------------------------------------------------------------------
-- Create Database Roles
-- ----------------------------------------------------------------------------
DROP ROLE IF EXISTS 'admin_role'@'%';
DROP ROLE IF EXISTS 'faculty_role'@'%';
DROP ROLE IF EXISTS 'student_role'@'%';

CREATE ROLE 'admin_role'@'%';
CREATE ROLE 'faculty_role'@'%';
CREATE ROLE 'student_role'@'%';

-- ----------------------------------------------------------------------------
-- 1. ADMIN ROLE PRIVILEGES
-- Full CRUD access across all tables, execution of stored procedures and views.
-- ----------------------------------------------------------------------------
GRANT ALL PRIVILEGES ON internship_db.* TO 'admin_role'@'%';

-- ----------------------------------------------------------------------------
-- 2. FACULTY ROLE PRIVILEGES
-- Access to posted internships, application review, evaluations, and interviews.
-- ----------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE ON internship_db.internships TO 'faculty_role'@'%';
GRANT SELECT, UPDATE ON internship_db.applications TO 'faculty_role'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON internship_db.interviews TO 'faculty_role'@'%';
GRANT SELECT, INSERT, UPDATE ON internship_db.evaluations TO 'faculty_role'@'%';
GRANT SELECT, INSERT ON internship_db.faculty_feedback TO 'faculty_role'@'%';
GRANT SELECT ON internship_db.companies TO 'faculty_role'@'%';
GRANT SELECT ON internship_db.students TO 'faculty_role'@'%';
GRANT SELECT ON internship_db.company_feedback TO 'faculty_role'@'%';
GRANT SELECT ON internship_db.student_feedback TO 'faculty_role'@'%';

-- Grant execution of faculty procedures and views
GRANT EXECUTE ON PROCEDURE internship_db.sp_post_internship TO 'faculty_role'@'%';
GRANT EXECUTE ON PROCEDURE internship_db.sp_schedule_interview TO 'faculty_role'@'%';
GRANT EXECUTE ON PROCEDURE internship_db.sp_cancel_interview TO 'faculty_role'@'%';
GRANT EXECUTE ON PROCEDURE internship_db.sp_create_evaluation TO 'faculty_role'@'%';

GRANT SELECT ON internship_db.vw_faculty_posted_internships TO 'faculty_role'@'%';
GRANT SELECT ON internship_db.vw_faculty_application_review TO 'faculty_role'@'%';
GRANT SELECT ON internship_db.vw_faculty_student_evaluations TO 'faculty_role'@'%';
GRANT SELECT ON internship_db.vw_faculty_interview_stats TO 'faculty_role'@'%';

-- ----------------------------------------------------------------------------
-- 3. STUDENT ROLE PRIVILEGES
-- Access to search internships, apply, track applications, submit ratings/feedback.
-- ----------------------------------------------------------------------------
GRANT SELECT ON internship_db.internships TO 'student_role'@'%';
GRANT SELECT ON internship_db.companies TO 'student_role'@'%';
GRANT SELECT, INSERT, UPDATE ON internship_db.applications TO 'student_role'@'%';
GRANT SELECT ON internship_db.interviews TO 'student_role'@'%';
GRANT SELECT, INSERT, UPDATE ON internship_db.students TO 'student_role'@'%';
GRANT SELECT, INSERT ON internship_db.student_feedback TO 'student_role'@'%';
GRANT SELECT, INSERT ON internship_db.company_ratings TO 'student_role'@'%';
GRANT SELECT, INSERT ON internship_db.system_feedback TO 'student_role'@'%';

-- Grant execution of student procedures and views
GRANT EXECUTE ON PROCEDURE internship_db.sp_submit_application TO 'student_role'@'%';
GRANT EXECUTE ON PROCEDURE internship_db.sp_withdraw_application TO 'student_role'@'%';

GRANT SELECT ON internship_db.vw_student_my_applications TO 'student_role'@'%';
GRANT SELECT ON internship_db.vw_student_interview_schedule TO 'student_role'@'%';
GRANT SELECT ON internship_db.vw_student_placement_status TO 'student_role'@'%';


-- ----------------------------------------------------------------------------
-- Create Sample Database Users & Assign Roles
-- ----------------------------------------------------------------------------
DROP USER IF EXISTS 'db_admin'@'localhost';
DROP USER IF EXISTS 'db_faculty'@'localhost';
DROP USER IF EXISTS 'db_student'@'localhost';

CREATE USER 'db_admin'@'localhost' IDENTIFIED BY 'AdminPass@123';
CREATE USER 'db_faculty'@'localhost' IDENTIFIED BY 'FacultyPass@123';
CREATE USER 'db_student'@'localhost' IDENTIFIED BY 'StudentPass@123';

GRANT 'admin_role'@'%' TO 'db_admin'@'localhost';
GRANT 'faculty_role'@'%' TO 'db_faculty'@'localhost';
GRANT 'student_role'@'%' TO 'db_student'@'localhost';

SET DEFAULT ROLE ALL TO 'db_admin'@'localhost', 'db_faculty'@'localhost', 'db_student'@'localhost';

FLUSH PRIVILEGES;
