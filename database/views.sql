-- ============================================================================
-- COLLEGE INTERNSHIP MANAGEMENT SYSTEM (ADBMS PROJECT)
-- File: /database/views.sql
-- Description: Reporting Views for Admin, Faculty, and Student Dashboards
-- Database System: MySQL 8.0+
-- ============================================================================

USE internship_db;

-- ============================================================================
-- ADMIN REPORTING VIEWS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- View 1: vw_admin_placement_summary
-- Executive overview of placement statistics, totals, and average stipends.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_admin_placement_summary AS
SELECT
    (SELECT COUNT(*) FROM students WHERE is_active = 1) AS total_students,
    (SELECT COUNT(DISTINCT student_id) FROM applications WHERE status = 'accepted') AS placed_students,
    fn_calculate_placement_rate() AS placement_rate_percentage,
    (SELECT IFNULL(AVG(i.stipend), 0.00)
     FROM applications a
     JOIN internships i ON a.internship_id = i.internship_id
     WHERE a.status = 'accepted') AS avg_placed_stipend,
    (SELECT COUNT(*) FROM applications) AS total_applications;

-- ----------------------------------------------------------------------------
-- View 2: vw_admin_application_analytics
-- Breakdown of applications by status and overall acceptance rate.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_admin_application_analytics AS
SELECT
    COUNT(*) AS total_applications,
    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending_count,
    SUM(CASE WHEN status = 'shortlisted' THEN 1 ELSE 0 END) AS shortlisted_count,
    SUM(CASE WHEN status = 'accepted' THEN 1 ELSE 0 END) AS accepted_count,
    SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) AS rejected_count,
    SUM(CASE WHEN status = 'withdrawn' THEN 1 ELSE 0 END) AS withdrawn_count,
    ROUND((SUM(CASE WHEN status = 'accepted' THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0)) * 100.00, 2) AS acceptance_rate_percentage
FROM applications;

-- ----------------------------------------------------------------------------
-- View 3: vw_admin_student_performance
-- Top performing students, application frequency, and evaluation metrics.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_admin_student_performance AS
SELECT
    s.student_id,
    s.user_id,
    s.name AS student_name,
    s.department,
    s.gpa,
    COUNT(a.application_id) AS total_applications,
    SUM(CASE WHEN a.status = 'accepted' THEN 1 ELSE 0 END) AS accepted_offers,
    ROUND(AVG(e.overall_rating), 2) AS avg_faculty_evaluation,
    fn_get_student_placement_status(s.student_id) AS placement_status
FROM students s
LEFT JOIN applications a ON s.student_id = a.student_id
LEFT JOIN evaluations e ON a.application_id = e.application_id AND e.is_archived = 0
WHERE s.is_active = 1
GROUP BY s.student_id, s.user_id, s.name, s.department, s.gpa;

-- ----------------------------------------------------------------------------
-- View 4: vw_admin_company_stats
-- Company engagement, internship volume, and average student ratings.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_admin_company_stats AS
SELECT
    c.company_id,
    c.name AS company_name,
    c.registration_number,
    c.location,
    c.contact_person,
    c.contact_email,
    c.contact_phone,
    c.created_by,
    f.name AS created_by_faculty_name,
    f.department AS created_by_faculty_dept,
    c.is_archived,
    COUNT(DISTINCT i.internship_id) AS total_internships_posted,
    COUNT(DISTINCT a.application_id) AS total_applications_received,
    fn_calculate_company_avg_rating(c.company_id) AS avg_student_rating,
    ROUND(AVG(cf.technical_skills), 2) AS avg_intern_tech_rating
FROM companies c
LEFT JOIN faculty f ON c.created_by = f.faculty_id
LEFT JOIN internships i ON c.company_id = i.company_id
LEFT JOIN applications a ON i.internship_id = a.internship_id
LEFT JOIN company_feedback cf ON a.application_id = cf.application_id
GROUP BY c.company_id, c.name, c.registration_number, c.location, c.contact_person, c.contact_email, c.contact_phone, c.created_by, f.name, f.department, c.is_archived;

-- ----------------------------------------------------------------------------
-- View 4b: vw_company_applicant_details
-- Detailed view of all student applicants per company.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_company_applicant_details AS
SELECT
    c.company_id,
    c.name AS company_name,
    i.internship_id,
    i.title AS internship_title,
    s.student_id,
    s.name AS student_name,
    u.email AS student_email,
    s.department AS student_department,
    s.gpa AS student_gpa,
    a.application_id,
    a.resume_path,
    a.status AS application_status,
    a.applied_at,
    f.name AS posted_by_faculty_name
FROM companies c
JOIN internships i ON c.company_id = i.company_id
JOIN applications a ON i.internship_id = a.internship_id
JOIN students s ON a.student_id = s.student_id
JOIN users u ON s.user_id = u.user_id
JOIN faculty f ON i.posted_by = f.faculty_id;

-- ----------------------------------------------------------------------------
-- View 5: vw_admin_system_activity
-- System usage metrics, user registrations, and feedback activity.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_admin_system_activity AS
SELECT
    (SELECT COUNT(*) FROM users) AS total_users,
    (SELECT COUNT(*) FROM users WHERE role = 'admin') AS admin_count,
    (SELECT COUNT(*) FROM users WHERE role = 'faculty') AS faculty_count,
    (SELECT COUNT(*) FROM users WHERE role = 'student') AS student_count,
    (SELECT COUNT(*) FROM users WHERE is_verified = 1) AS verified_users,
    (SELECT COUNT(*) FROM users WHERE is_verified = 0) AS unverified_users,
    (SELECT COUNT(*) FROM system_feedback WHERE status = 'new') AS pending_system_feedback,
    (SELECT COUNT(*) FROM audit_log) AS total_audit_events;

-- ----------------------------------------------------------------------------
-- View 6: vw_admin_compliance_report
-- Identifies compliance policy violations and missing documents.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_admin_compliance_report AS
SELECT
    'Unverified User Account' AS violation_type,
    CONCAT('User ID ', u.user_id, ' (', u.email, ')') AS details,
    u.created_at AS flag_date
FROM users u
WHERE u.is_verified = 0

UNION ALL

SELECT
    'Student Missing Resume' AS violation_type,
    CONCAT('Student ID ', s.student_id, ' (', s.name, ')') AS details,
    s.created_at AS flag_date
FROM students s
WHERE s.resume_path IS NULL OR CHAR_LENGTH(TRIM(s.resume_path)) = 0

UNION ALL

SELECT
    'Expired Open Internship' AS violation_type,
    CONCAT('Internship ID ', i.internship_id, ' (', i.title, ')') AS details,
    i.application_deadline AS flag_date
FROM internships i
WHERE i.status = 'open' AND i.application_deadline < NOW();


-- ============================================================================
-- FACULTY REPORTING VIEWS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- View 7: vw_faculty_posted_internships
-- Overview of internships posted by faculty members with application counts.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_faculty_posted_internships AS
SELECT
    i.internship_id,
    i.posted_by AS faculty_id,
    f.name AS faculty_name,
    c.name AS company_name,
    c.is_archived AS company_is_archived,
    i.title,
    i.domain,
    i.duration_weeks,
    i.stipend,
    i.status,
    i.application_deadline,
    COUNT(a.application_id) AS total_applications,
    SUM(CASE WHEN a.status = 'pending' THEN 1 ELSE 0 END) AS pending_apps,
    SUM(CASE WHEN a.status = 'shortlisted' THEN 1 ELSE 0 END) AS shortlisted_apps,
    SUM(CASE WHEN a.status = 'accepted' THEN 1 ELSE 0 END) AS accepted_apps
FROM internships i
JOIN faculty f ON i.posted_by = f.faculty_id
JOIN companies c ON i.company_id = c.company_id
LEFT JOIN applications a ON i.internship_id = a.internship_id
GROUP BY i.internship_id, i.posted_by, f.name, c.name, c.is_archived, i.title, i.domain, i.duration_weeks, i.stipend, i.status, i.application_deadline;

-- ----------------------------------------------------------------------------
-- View 8: vw_faculty_application_review
-- Detailed review view for faculty to manage applicants.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_faculty_application_review AS
SELECT
    a.application_id,
    i.internship_id,
    i.posted_by AS faculty_id,
    i.title AS internship_title,
    c.name AS company_name,
    s.student_id,
    s.name AS student_name,
    s.department AS student_department,
    s.gpa AS student_gpa,
    a.resume_path,
    a.cover_letter,
    a.status AS application_status,
    a.applied_at
FROM applications a
JOIN internships i ON a.internship_id = i.internship_id
JOIN companies c ON i.company_id = c.company_id
JOIN students s ON a.student_id = s.student_id;

-- ----------------------------------------------------------------------------
-- View 9: vw_faculty_student_evaluations
-- Faculty evaluation summary of student performance.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_faculty_student_evaluations AS
SELECT
    e.evaluation_id,
    e.application_id,
    e.evaluator_id AS faculty_id,
    f.name AS evaluator_name,
    s.name AS student_name,
    i.title AS internship_title,
    e.technical_score,
    e.communication_score,
    e.overall_rating,
    e.comments,
    e.created_at
FROM evaluations e
JOIN faculty f ON e.evaluator_id = f.faculty_id
JOIN applications a ON e.application_id = a.application_id
JOIN students s ON a.student_id = s.student_id
JOIN internships i ON a.internship_id = i.internship_id
WHERE e.is_archived = 0;

-- ----------------------------------------------------------------------------
-- View 10: vw_faculty_interview_stats
-- Interview metrics for faculty members.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_faculty_interview_stats AS
SELECT
    i.posted_by AS faculty_id,
    COUNT(iv.interview_id) AS total_interviews,
    SUM(CASE WHEN iv.result = 'scheduled' THEN 1 ELSE 0 END) AS scheduled_count,
    SUM(CASE WHEN iv.result = 'passed' THEN 1 ELSE 0 END) AS passed_count,
    SUM(CASE WHEN iv.result = 'failed' THEN 1 ELSE 0 END) AS failed_count,
    SUM(CASE WHEN iv.result = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_count,
    ROUND((SUM(CASE WHEN iv.result = 'passed' THEN 1 ELSE 0 END) / NULLIF(COUNT(iv.interview_id), 0)) * 100.00, 2) AS pass_rate_percentage
FROM interviews iv
JOIN applications a ON iv.application_id = a.application_id
JOIN internships i ON a.internship_id = i.internship_id
GROUP BY i.posted_by;


-- ============================================================================
-- STUDENT REPORTING VIEWS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- View 11: vw_student_my_applications
-- Student application tracking dashboard.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_student_my_applications AS
SELECT
    a.application_id,
    s.user_id AS student_user_id,
    s.student_id,
    i.internship_id,
    i.title AS internship_title,
    c.name AS company_name,
    c.location,
    i.stipend,
    a.resume_path,
    a.status AS application_status,
    a.applied_at
FROM applications a
JOIN students s ON a.student_id = s.student_id
JOIN internships i ON a.internship_id = i.internship_id
JOIN companies c ON i.company_id = c.company_id;

-- ----------------------------------------------------------------------------
-- View 12: vw_student_interview_schedule
-- Student interview schedule and results view.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_student_interview_schedule AS
SELECT
    iv.interview_id,
    s.user_id AS student_user_id,
    s.student_id,
    i.title AS internship_title,
    c.name AS company_name,
    iv.interviewer_name,
    iv.interview_datetime,
    iv.mode,
    iv.result,
    iv.comments
FROM interviews iv
JOIN applications a ON iv.application_id = a.application_id
JOIN students s ON a.student_id = s.student_id
JOIN internships i ON a.internship_id = i.internship_id
JOIN companies c ON i.company_id = c.company_id;

-- ----------------------------------------------------------------------------
-- View 13: vw_student_placement_status
-- Student placement outcome and offer details.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_student_placement_status AS
SELECT
    s.user_id AS student_user_id,
    s.student_id,
    s.name AS student_name,
    s.department,
    s.gpa,
    fn_get_student_placement_status(s.student_id) AS placement_status,
    c.name AS placed_company,
    i.title AS placed_title,
    i.stipend AS placed_stipend
FROM students s
LEFT JOIN applications a ON s.student_id = a.student_id AND a.status = 'accepted'
LEFT JOIN internships i ON a.internship_id = i.internship_id
LEFT JOIN companies c ON i.company_id = c.company_id;
