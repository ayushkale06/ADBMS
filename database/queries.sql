-- ============================================================================
-- COLLEGE INTERNSHIP MANAGEMENT SYSTEM (ADBMS PROJECT)
-- File: /database/queries.sql
-- Description: Demo Queries for All Reports, Stored Functions, and EXPLAIN Index Examples
-- Database System: MySQL 8.0+
-- ============================================================================

USE internship_db;

-- ============================================================================
-- 1. ADMIN DASHBOARD & REPORT QUERIES
-- ============================================================================

-- 1.1 Placement Summary Overview
SELECT * FROM vw_admin_placement_summary;

-- 1.2 Application Analytics & Acceptance Rates
SELECT * FROM vw_admin_application_analytics;

-- 1.3 Top Student Performance Report (Ordered by GPA & Evaluation Rating)
SELECT * FROM vw_admin_student_performance
ORDER BY gpa DESC, avg_faculty_evaluation DESC;

-- 1.4 Company Engagement Statistics & Ratings
SELECT * FROM vw_admin_company_stats
ORDER BY total_applications_received DESC;

-- 1.5 System Activity & User Distribution
SELECT * FROM vw_admin_system_activity;

-- 1.6 Compliance & Document Verification Policy Violations Report
SELECT * FROM vw_admin_compliance_report;


-- ============================================================================
-- 2. FACULTY DASHBOARD & REPORT QUERIES
-- ============================================================================

-- 2.1 Posted Internships Summary for Faculty ID 1 (Dr. Robert Smith)
SELECT * FROM vw_faculty_posted_internships
WHERE faculty_id = 1;

-- 2.2 Applicant Review List for Faculty ID 3 (Dr. Michael Williams)
SELECT * FROM vw_faculty_application_review
WHERE faculty_id = 3
ORDER BY applied_at DESC;

-- 2.3 Student Performance Evaluations Summary for Faculty ID 3
SELECT * FROM vw_faculty_student_evaluations
WHERE faculty_id = 3;

-- 2.4 Interview Statistics for Faculty ID 1
SELECT * FROM vw_faculty_interview_stats
WHERE faculty_id = 1;


-- ============================================================================
-- 3. STUDENT DASHBOARD & REPORT QUERIES
-- ============================================================================

-- 3.1 Applications Tracking for Student User ID 6 (Alex Turner)
SELECT * FROM vw_student_my_applications
WHERE student_user_id = 6
ORDER BY applied_at DESC;

-- 3.2 Interview Schedule and Results for Student User ID 6
SELECT * FROM vw_student_interview_schedule
WHERE student_user_id = 6;

-- 3.3 Placement Outcome Status for Student User ID 6
SELECT * FROM vw_student_placement_status
WHERE student_user_id = 6;


-- ============================================================================
-- 4. DEMONSTRATION OF STORED FUNCTIONS
-- ============================================================================

-- 4.1 Calculate Global Placement Rate Percentage
SELECT fn_calculate_placement_rate() AS global_placement_rate_pct;

-- 4.2 Check Individual Placement Status for Student ID 1 and Student ID 3
SELECT
    student_id,
    name,
    fn_get_student_placement_status(student_id) AS placement_status
FROM students
WHERE student_id IN (1, 3, 7);

-- 4.3 Calculate Average Rating for Company ID 1 and Company ID 3
SELECT
    company_id,
    name,
    fn_calculate_company_avg_rating(company_id) AS avg_rating
FROM companies
WHERE company_id IN (1, 3, 7);


-- ============================================================================
-- 5. ADVANCED INDEX PERFORMANCE OPTIMIZATION (EXPLAIN EXAMPLES)
-- Demonstrating index usage (idx_internships_domain, idx_internships_stipend, idx_applications_student)
-- ============================================================================

-- 5.1 EXPLAIN: Filtering open internships by domain and stipend range using composite indexes
EXPLAIN SELECT
    internship_id, title, domain, stipend, duration_weeks, application_deadline
FROM internships
WHERE status = 'open'
  AND domain = 'Software Engineering'
  AND stipend >= 2000.00;

-- 5.2 EXPLAIN: Filtering applications by student_id and status using index idx_applications_student
EXPLAIN SELECT
    a.application_id, i.title, c.name AS company, a.status, a.applied_at
FROM applications a
JOIN internships i ON a.internship_id = i.internship_id
JOIN companies c ON i.company_id = c.company_id
WHERE a.student_id = 1 AND a.status = 'shortlisted';

-- 5.3 EXPLAIN: Searching companies by location using index idx_companies_location
EXPLAIN SELECT
    company_id, name, location, contact_email
FROM companies
WHERE is_archived = 0
  AND location LIKE 'San Francisco%';
