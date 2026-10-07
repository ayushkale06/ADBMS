-- ============================================================================
-- COLLEGE INTERNSHIP MANAGEMENT SYSTEM (ADBMS PROJECT)
-- File: /database/procedures.sql
-- Description: Stored Procedures (with Transactions), Functions, and Event Scheduler
-- Database System: MySQL 8.0+
-- ============================================================================

USE internship_db;

DELIMITER $$

-- ============================================================================
-- STORED FUNCTIONS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Function 1: fn_calculate_placement_rate
-- Calculates overall percentage of active students who have an accepted internship.
-- ----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_calculate_placement_rate$$
CREATE FUNCTION fn_calculate_placement_rate()
RETURNS DECIMAL(5,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total_students INT DEFAULT 0;
    DECLARE v_placed_students INT DEFAULT 0;
    DECLARE v_rate DECIMAL(5,2) DEFAULT 0.00;

    SELECT COUNT(*) INTO v_total_students FROM students WHERE is_active = 1;

    IF v_total_students > 0 THEN
        SELECT COUNT(DISTINCT student_id) INTO v_placed_students
        FROM applications
        WHERE status = 'accepted';

        SET v_rate = (v_placed_students / v_total_students) * 100.00;
    END IF;

    RETURN v_rate;
END$$

-- ----------------------------------------------------------------------------
-- Function 2: fn_get_student_placement_status
-- Returns placement status for a specific student ('Placed', 'Pending', 'Unplaced').
-- ----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_get_student_placement_status$$
CREATE FUNCTION fn_get_student_placement_status(p_student_id INT)
RETURNS VARCHAR(20)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count_accepted INT DEFAULT 0;
    DECLARE v_count_apps INT DEFAULT 0;

    SELECT COUNT(*) INTO v_count_accepted
    FROM applications
    WHERE student_id = p_student_id AND status = 'accepted';

    IF v_count_accepted > 0 THEN
        RETURN 'Placed';
    END IF;

    SELECT COUNT(*) INTO v_count_apps
    FROM applications
    WHERE student_id = p_student_id AND status IN ('pending', 'shortlisted');

    IF v_count_apps > 0 THEN
        RETURN 'Pending';
    END IF;

    RETURN 'Unplaced';
END$$

-- ----------------------------------------------------------------------------
-- Function 3: fn_calculate_company_avg_rating
-- Returns average star rating for a target company.
-- ----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_calculate_company_avg_rating$$
CREATE FUNCTION fn_calculate_company_avg_rating(p_company_id INT)
RETURNS DECIMAL(3,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(3,2) DEFAULT 0.00;

    SELECT IFNULL(AVG(rating), 0.00) INTO v_avg
    FROM company_ratings
    WHERE company_id = p_company_id;

    RETURN v_avg;
END$$


-- ============================================================================
-- STORED PROCEDURES (WITH TRANSACTIONS & EXCEPTION HANDLERS)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Procedure 1: sp_register_student
-- Atomic transaction creating user account and student profile.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_register_student$$
CREATE PROCEDURE sp_register_student(
    IN p_email VARCHAR(255),
    IN p_password_hash VARCHAR(255),
    IN p_name VARCHAR(100),
    IN p_phone VARCHAR(20),
    IN p_department VARCHAR(100),
    IN p_gpa DECIMAL(3,2),
    IN p_resume_path VARCHAR(255),
    OUT p_student_id INT
)
BEGIN
    DECLARE v_new_user_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Insert User record
    INSERT INTO users (email, password_hash, role, is_verified, is_active)
    VALUES (p_email, p_password_hash, 'student', 1, 1);

    SET v_new_user_id = LAST_INSERT_ID();

    -- Insert Student profile
    INSERT INTO students (user_id, name, phone, department, gpa, resume_path, is_active)
    VALUES (v_new_user_id, p_name, p_phone, p_department, p_gpa, p_resume_path, 1);

    SET p_student_id = LAST_INSERT_ID();

    COMMIT;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 2: sp_deactivate_student (Soft Delete)
-- Deactivates student record and corresponding user account.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_deactivate_student$$
CREATE PROCEDURE sp_deactivate_student(
    IN p_student_id INT
)
BEGIN
    DECLARE v_user_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT user_id INTO v_user_id FROM students WHERE student_id = p_student_id;

    UPDATE students SET is_active = 0 WHERE student_id = p_student_id;
    UPDATE users SET is_active = 0 WHERE user_id = v_user_id;

    COMMIT;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 2b: sp_activate_student (Restore / Activate)
-- Activates student record and corresponding user account.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_activate_student$$
CREATE PROCEDURE sp_activate_student(
    IN p_student_id INT
)
BEGIN
    DECLARE v_user_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT user_id INTO v_user_id FROM students WHERE student_id = p_student_id;

    UPDATE students SET is_active = 1 WHERE student_id = p_student_id;
    UPDATE users SET is_active = 1 WHERE user_id = v_user_id;

    COMMIT;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 2c: sp_register_faculty
-- Atomic transaction creating user account and faculty profile.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_register_faculty$$
CREATE PROCEDURE sp_register_faculty(
    IN p_email VARCHAR(255),
    IN p_password_hash VARCHAR(255),
    IN p_name VARCHAR(100),
    IN p_department VARCHAR(100),
    IN p_phone VARCHAR(20),
    OUT p_faculty_id INT
)
BEGIN
    DECLARE v_new_user_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO users (email, password_hash, role, is_verified, is_active)
    VALUES (p_email, p_password_hash, 'faculty', 1, 1);

    SET v_new_user_id = LAST_INSERT_ID();

    INSERT INTO faculty (user_id, name, department, phone, is_active)
    VALUES (v_new_user_id, p_name, p_department, p_phone, 1);

    SET p_faculty_id = LAST_INSERT_ID();

    COMMIT;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 2d: sp_deactivate_faculty (Soft Delete)
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_deactivate_faculty$$
CREATE PROCEDURE sp_deactivate_faculty(
    IN p_faculty_id INT
)
BEGIN
    DECLARE v_user_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT user_id INTO v_user_id FROM faculty WHERE faculty_id = p_faculty_id;

    UPDATE faculty SET is_active = 0 WHERE faculty_id = p_faculty_id;
    UPDATE users SET is_active = 0 WHERE user_id = v_user_id;

    COMMIT;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 2e: sp_activate_faculty (Restore)
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_activate_faculty$$
CREATE PROCEDURE sp_activate_faculty(
    IN p_faculty_id INT
)
BEGIN
    DECLARE v_user_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT user_id INTO v_user_id FROM faculty WHERE faculty_id = p_faculty_id;

    UPDATE faculty SET is_active = 1 WHERE faculty_id = p_faculty_id;
    UPDATE users SET is_active = 1 WHERE user_id = v_user_id;

    COMMIT;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 3: sp_create_company
-- Inserts a new employer partner company with optional created_by faculty.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_create_company$$
CREATE PROCEDURE sp_create_company(
    IN p_name VARCHAR(150),
    IN p_registration_number VARCHAR(50),
    IN p_location VARCHAR(150),
    IN p_contact_person VARCHAR(100),
    IN p_contact_email VARCHAR(255),
    IN p_contact_phone VARCHAR(20),
    IN p_created_by INT,
    OUT p_company_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO companies (name, registration_number, location, contact_person, contact_email, contact_phone, created_by, is_archived)
    VALUES (p_name, p_registration_number, p_location, p_contact_person, p_contact_email, p_contact_phone, p_created_by, 0);

    SET p_company_id = LAST_INSERT_ID();

    COMMIT;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 4: sp_archive_company
-- Soft deletion / archiving of company.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_archive_company$$
CREATE PROCEDURE sp_archive_company(
    IN p_company_id INT
)
BEGIN
    UPDATE companies SET is_archived = 1 WHERE company_id = p_company_id;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 4b: sp_restore_company
-- Restores an archived company.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_restore_company$$
CREATE PROCEDURE sp_restore_company(
    IN p_company_id INT
)
BEGIN
    UPDATE companies SET is_archived = 0 WHERE company_id = p_company_id;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 5: sp_post_internship
-- Posts new internship position (status defaults to pending_approval).
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_post_internship$$
CREATE PROCEDURE sp_post_internship(
    IN p_company_id INT,
    IN p_posted_by INT,
    IN p_title VARCHAR(150),
    IN p_description TEXT,
    IN p_domain VARCHAR(100),
    IN p_duration_weeks INT,
    IN p_stipend DECIMAL(10,2),
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_application_deadline DATETIME,
    OUT p_internship_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO internships (
        company_id, posted_by, title, description, domain,
        duration_weeks, stipend, start_date, end_date, application_deadline, status
    ) VALUES (
        p_company_id, p_posted_by, p_title, p_description, p_domain,
        p_duration_weeks, p_stipend, p_start_date, p_end_date, p_application_deadline, 'pending_approval'
    );

    SET p_internship_id = LAST_INSERT_ID();

    COMMIT;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 6: sp_approve_internship
-- Admin approves an internship posting to make it 'open'.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_approve_internship$$
CREATE PROCEDURE sp_approve_internship(
    IN p_internship_id INT,
    IN p_admin_user_id INT
)
BEGIN
    UPDATE internships
    SET status = 'open', approved_by = p_admin_user_id
    WHERE internship_id = p_internship_id;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 7: sp_archive_internship
-- Archives an internship posting.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_archive_internship$$
CREATE PROCEDURE sp_archive_internship(
    IN p_internship_id INT
)
BEGIN
    UPDATE internships SET status = 'archived' WHERE internship_id = p_internship_id;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 8: sp_submit_application
-- Submits student internship application within a transaction. Triggers handle validations.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_submit_application$$
CREATE PROCEDURE sp_submit_application(
    IN p_student_id INT,
    IN p_internship_id INT,
    IN p_resume_path VARCHAR(255),
    IN p_cover_letter TEXT,
    IN p_qualifications TEXT,
    OUT p_application_id INT
)
BEGIN
    DECLARE v_status VARCHAR(50);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Verify internship is currently open
    SELECT status INTO v_status FROM internships WHERE internship_id = p_internship_id;

    IF v_status <> 'open' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Application Submission Failed: Internship is not open for applications.';
    END IF;

    INSERT INTO applications (student_id, internship_id, resume_path, cover_letter, qualifications, status)
    VALUES (p_student_id, p_internship_id, p_resume_path, p_cover_letter, p_qualifications, 'pending');

    SET p_application_id = LAST_INSERT_ID();

    COMMIT;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 9: sp_withdraw_application
-- Marks application as 'withdrawn' (soft application delete).
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_withdraw_application$$
CREATE PROCEDURE sp_withdraw_application(
    IN p_application_id INT
)
BEGIN
    UPDATE applications SET status = 'withdrawn' WHERE application_id = p_application_id;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 10: sp_schedule_interview
-- Schedules interview. Trigger validates datetime vs 24h & application deadline.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_schedule_interview$$
CREATE PROCEDURE sp_schedule_interview(
    IN p_application_id INT,
    IN p_interviewer_name VARCHAR(100),
    IN p_interviewer_email VARCHAR(255),
    IN p_interview_datetime DATETIME,
    IN p_mode VARCHAR(20),
    OUT p_interview_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO interviews (application_id, interviewer_name, interviewer_email, interview_datetime, mode, result)
    VALUES (p_application_id, p_interviewer_name, p_interviewer_email, p_interview_datetime, p_mode, 'scheduled');

    SET p_interview_id = LAST_INSERT_ID();

    COMMIT;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 11: sp_cancel_interview
-- Cancels scheduled interview.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_cancel_interview$$
CREATE PROCEDURE sp_cancel_interview(
    IN p_interview_id INT
)
BEGIN
    UPDATE interviews SET result = 'cancelled' WHERE interview_id = p_interview_id;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 12: sp_create_evaluation
-- Records faculty evaluation of student performance.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_create_evaluation$$
CREATE PROCEDURE sp_create_evaluation(
    IN p_application_id INT,
    IN p_evaluator_id INT,
    IN p_technical_score INT,
    IN p_communication_score INT,
    IN p_overall_rating INT,
    IN p_comments TEXT,
    OUT p_evaluation_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO evaluations (
        application_id, evaluator_id, technical_score, communication_score, overall_rating, comments, is_archived
    ) VALUES (
        p_application_id, p_evaluator_id, p_technical_score, p_communication_score, p_overall_rating, p_comments, 0
    );

    SET p_evaluation_id = LAST_INSERT_ID();

    COMMIT;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 13: sp_archive_evaluation
-- Archives an evaluation record.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_archive_evaluation$$
CREATE PROCEDURE sp_archive_evaluation(
    IN p_evaluation_id INT
)
BEGIN
    UPDATE evaluations SET is_archived = 1 WHERE evaluation_id = p_evaluation_id;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 14: sp_auto_close_expired_internships
-- Business Logic: Auto-closes open internships whose application deadline has passed.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_auto_close_expired_internships$$
CREATE PROCEDURE sp_auto_close_expired_internships()
BEGIN
    UPDATE internships
    SET status = 'closed'
    WHERE status = 'open' AND application_deadline < NOW();
END$$


-- ============================================================================
-- SCHEDULED EVENT / JOB
-- Auto-closes expired internships hourly.
-- ============================================================================

DROP EVENT IF EXISTS event_auto_close_expired_internships$$
CREATE EVENT event_auto_close_expired_internships
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL sp_auto_close_expired_internships();
END$$

DELIMITER ;
