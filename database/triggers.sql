-- ============================================================================
-- COLLEGE INTERNSHIP MANAGEMENT SYSTEM (ADBMS PROJECT)
-- File: /database/triggers.sql
-- Description: Triggers for Business Rule Validation & Audit Logging
-- Database System: MySQL 8.0+
-- ============================================================================

USE internship_db;

DELIMITER $$

-- ----------------------------------------------------------------------------
-- Trigger 1: trg_validate_application_before_insert
-- Enforces:
-- 1. Student account must be active.
-- 2. User account must be email verified (is_verified = 1).
-- 3. Resume path must be non-null and end with '.pdf' (PDF format mandatory).
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_validate_application_before_insert$$
CREATE TRIGGER trg_validate_application_before_insert
BEFORE INSERT ON applications
FOR EACH ROW
BEGIN
    DECLARE v_is_active TINYINT(1);
    DECLARE v_is_verified TINYINT(1);
    DECLARE v_email VARCHAR(255);

    -- Check student and user status
    SELECT s.is_active, u.is_verified, u.email
    INTO v_is_active, v_is_verified, v_email
    FROM students s
    JOIN users u ON s.user_id = u.user_id
    WHERE s.student_id = NEW.student_id;

    IF v_is_active = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Application Rejected: Student account is deactivated.';
    END IF;

    IF v_is_verified = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Application Rejected: User email must be verified before submitting applications.';
    END IF;

    -- Validate Resume PDF requirement
    IF NEW.resume_path IS NULL OR CHAR_LENGTH(TRIM(NEW.resume_path)) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Application Rejected: Resume file path is mandatory.';
    END IF;

    IF LOWER(NEW.resume_path) NOT LIKE '%.pdf' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Application Rejected: Resume must be a valid PDF file (.pdf extension required).';
    END IF;
END$$

-- ----------------------------------------------------------------------------
-- Trigger 2: trg_validate_interview_before_insert
-- Enforces:
-- 1. Interview datetime must be at least 24 hours in the future.
-- 2. Interview datetime cannot be scheduled past the internship application deadline.
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_validate_interview_before_insert$$
CREATE TRIGGER trg_validate_interview_before_insert
BEFORE INSERT ON interviews
FOR EACH ROW
BEGIN
    DECLARE v_deadline DATETIME;
    DECLARE v_internship_title VARCHAR(150);

    -- Retrieve application deadline for the target internship
    SELECT i.application_deadline, i.title
    INTO v_deadline, v_internship_title
    FROM applications a
    JOIN internships i ON a.internship_id = i.internship_id
    WHERE a.application_id = NEW.application_id;

    -- Requirement: Must be scheduled at least 24 hours in advance
    IF NEW.interview_datetime < (NOW() + INTERVAL 24 HOUR) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Interview Scheduling Failed: Interview must be scheduled at least 24 hours in the future.';
    END IF;

    -- Requirement: Cannot schedule after application deadline
    IF NEW.interview_datetime > v_deadline THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Interview Scheduling Failed: Interview cannot be scheduled after the internship application deadline.';
    END IF;
END$$

-- ----------------------------------------------------------------------------
-- Trigger 3: trg_validate_interview_before_update
-- Re-validates timing rules upon interview reschedule.
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_validate_interview_before_update$$
CREATE TRIGGER trg_validate_interview_before_update
BEFORE UPDATE ON interviews
FOR EACH ROW
BEGIN
    DECLARE v_deadline DATETIME;

    IF NEW.interview_datetime <> OLD.interview_datetime THEN
        SELECT i.application_deadline
        INTO v_deadline
        FROM applications a
        JOIN internships i ON a.internship_id = i.internship_id
        WHERE a.application_id = NEW.application_id;

        IF NEW.interview_datetime < (NOW() + INTERVAL 24 HOUR) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Interview Reschedule Failed: New time must be at least 24 hours in the future.';
        END IF;

        IF NEW.interview_datetime > v_deadline THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Interview Reschedule Failed: New time cannot exceed internship application deadline.';
        END IF;
    END IF;
END$$

-- ----------------------------------------------------------------------------
-- Trigger 4: trg_validate_internship_before_insert
-- Enforces future start date for active postings and start_date < end_date.
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_validate_internship_before_insert$$
CREATE TRIGGER trg_validate_internship_before_insert
BEFORE INSERT ON internships
FOR EACH ROW
BEGIN
    IF NEW.start_date >= NEW.end_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Internship Creation Failed: Start date must be strictly earlier than end date.';
    END IF;

    IF NEW.status IN ('pending_approval', 'open') AND NEW.start_date < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Internship Creation Failed: Start date must be a future date.';
    END IF;
END$$

-- ----------------------------------------------------------------------------
-- Trigger 5: trg_audit_users_insert
-- Audit logging for user registration.
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_users_insert$$
CREATE TRIGGER trg_audit_users_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (action_type, table_name, record_id, performed_by, new_values)
    VALUES (
        'INSERT',
        'users',
        NEW.user_id,
        CONCAT('USER_', NEW.user_id),
        JSON_OBJECT('email', NEW.email, 'role', NEW.role, 'is_verified', NEW.is_verified)
    );
END$$

-- ----------------------------------------------------------------------------
-- Trigger 6: trg_audit_applications_update
-- Audit logging for application status changes.
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_applications_update$$
CREATE TRIGGER trg_audit_applications_update
AFTER UPDATE ON applications
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO audit_log (action_type, table_name, record_id, performed_by, old_values, new_values)
        VALUES (
            'UPDATE_STATUS',
            'applications',
            NEW.application_id,
            CONCAT('STUDENT_', NEW.student_id),
            JSON_OBJECT('status', OLD.status),
            JSON_OBJECT('status', NEW.status)
        );
    END IF;
END$$

DELIMITER ;
