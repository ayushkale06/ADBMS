-- ============================================================================
-- COLLEGE INTERNSHIP MANAGEMENT SYSTEM (ADBMS PROJECT)
-- File: /database/test_validations.sql
-- Description: Validation Verification Suite (Demonstrates Database Rule Enforcement)
-- Database System: MySQL 8.0+
-- Run each statement individually in MySQL Workbench to verify expected failure errors.
-- ============================================================================

USE internship_db;

-- ----------------------------------------------------------------------------
-- TEST 1: Invalid Email Format (RFC 5322 REGEXP constraint failure)
-- Expected Result: Error 3819 (HY000): Check constraint 'chk_users_email' is violated.
-- ----------------------------------------------------------------------------
-- INSERT INTO users (email, password_hash, role, is_verified)
-- VALUES ('invalid-email-format-at-domain', '$2b$12$hash...', 'student', 1);

-- ----------------------------------------------------------------------------
-- TEST 2: Invalid Phone Number (Format REGEXP failure)
-- Expected Result: Error 3819 (HY000): Check constraint 'chk_students_phone' is violated.
-- ----------------------------------------------------------------------------
-- INSERT INTO students (user_id, name, phone, department, gpa, resume_path)
-- VALUES (1, 'Test Student', '123-ABC-INVALID', 'Computer Science', 3.50, 'app/static/uploads/resumes/test.pdf');

-- ----------------------------------------------------------------------------
-- TEST 3: Invalid GPA (Out of range 0.00 to 4.00)
-- Expected Result: Error 3819 (HY000): Check constraint 'chk_students_gpa' is violated.
-- ----------------------------------------------------------------------------
-- INSERT INTO students (user_id, name, phone, department, gpa, resume_path)
-- VALUES (1, 'Test Student', '+15550199999', 'Computer Science', 4.50, 'app/static/uploads/resumes/test.pdf');

-- ----------------------------------------------------------------------------
-- TEST 4: Application Submission with Non-PDF Resume (Trigger Validation Failure)
-- Expected Result: Error 1644 (45000): Application Rejected: Resume must be a valid PDF file (.pdf extension required).
-- ----------------------------------------------------------------------------
-- INSERT INTO applications (student_id, internship_id, resume_path, cover_letter, status)
-- VALUES (1, 1, 'app/static/uploads/resumes/my_resume.docx', 'Cover letter content...', 'pending');

-- ----------------------------------------------------------------------------
-- TEST 5: Application Submission with Empty / NULL Resume (Trigger Validation Failure)
-- Expected Result: Error 1644 (45000): Application Rejected: Resume file path is mandatory.
-- ----------------------------------------------------------------------------
-- INSERT INTO applications (student_id, internship_id, resume_path, cover_letter, status)
-- VALUES (1, 1, '', 'Cover letter content...', 'pending');

-- ----------------------------------------------------------------------------
-- TEST 6: Application Submission by Unverified User (Trigger Validation Failure)
-- Note: Student 16 (user_id 21, Zoey Clark) has is_verified = 0
-- Expected Result: Error 1644 (45000): Application Rejected: User email must be verified before submitting applications.
-- ----------------------------------------------------------------------------
-- INSERT INTO applications (student_id, internship_id, resume_path, cover_letter, status)
-- VALUES (16, 1, 'app/static/uploads/resumes/zoey_resume.pdf', 'Cover letter...', 'pending');

-- ----------------------------------------------------------------------------
-- TEST 7: Duplicate Application Submission (UNIQUE Constraint Failure)
-- Note: Student 1 has already applied for Internship 1.
-- Expected Result: Error 1062 (23000): Duplicate entry '1-1' for key 'applications.uk_student_internship'.
-- ----------------------------------------------------------------------------
-- INSERT INTO applications (student_id, internship_id, resume_path, cover_letter, status)
-- VALUES (1, 1, 'app/static/uploads/resumes/alex_turner_resume.pdf', 'Duplicate application attempt', 'pending');

-- ----------------------------------------------------------------------------
-- TEST 8: Internship Creation with Start Date After End Date (Trigger Validation Failure)
-- Expected Result: Error 1644 (45000): Internship Creation Failed: Start date must be strictly earlier than end date.
-- ----------------------------------------------------------------------------
-- INSERT INTO internships (company_id, posted_by, title, description, domain, duration_weeks, stipend, start_date, end_date, application_deadline, status)
-- VALUES (1, 1, 'Test Internship', 'Description', 'Software', 12, 2000.00, '2027-05-01', '2027-01-01', '2026-12-01 23:59:59', 'pending_approval');

-- ----------------------------------------------------------------------------
-- TEST 9: Interview Scheduling Less Than 24 Hours in Advance (Trigger Validation Failure)
-- Expected Result: Error 1644 (45000): Interview Scheduling Failed: Interview must be scheduled at least 24 hours in the future.
-- ----------------------------------------------------------------------------
-- INSERT INTO interviews (application_id, interviewer_name, interviewer_email, interview_datetime, mode, result)
-- VALUES (2, 'Interviewer Name', 'interviewer@techcorp.com', NOW() + INTERVAL 2 HOUR, 'online', 'scheduled');

-- ----------------------------------------------------------------------------
-- TEST 10: Interview Scheduling Past Internship Application Deadline (Trigger Validation Failure)
-- Note: Internship 1 application deadline is 2026-10-25 23:59:59.
-- Expected Result: Error 1644 (45000): Interview Scheduling Failed: Interview cannot be scheduled after the internship application deadline.
-- ----------------------------------------------------------------------------
-- INSERT INTO interviews (application_id, interviewer_name, interviewer_email, interview_datetime, mode, result)
-- VALUES (2, 'Interviewer Name', 'interviewer@techcorp.com', '2026-11-01 10:00:00', 'online', 'scheduled');

-- ----------------------------------------------------------------------------
-- TEST 11: Invalid Rating Score (CHECK Constraint Failure)
-- Expected Result: Error 3819 (HY000): Check constraint 'chk_cr_rating' is violated.
-- ----------------------------------------------------------------------------
-- INSERT INTO company_ratings (student_id, company_id, rating, review)
-- VALUES (1, 1, 6, 'Rating score 6 out of 5 is invalid.');
