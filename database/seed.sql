-- ============================================================================
-- COLLEGE INTERNSHIP MANAGEMENT SYSTEM (ADBMS PROJECT)
-- File: /database/seed.sql
-- Description: Comprehensive Realistic Seed Data (16 Students, 8 Companies, 22 Internships, 45 Applications, 18 Interviews, Evaluations, Feedbacks)
-- Passwords: All hashed with bcrypt ($2b$12$)
--   Admin: Admin@123
--   Faculty: Faculty@123
--   Student: Student@123
-- Database System: MySQL 8.0+
-- ============================================================================

USE internship_db;

-- Clear previous data
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE audit_log;
TRUNCATE TABLE company_ratings;
TRUNCATE TABLE system_feedback;
TRUNCATE TABLE faculty_feedback;
TRUNCATE TABLE company_feedback;
TRUNCATE TABLE student_feedback;
TRUNCATE TABLE evaluations;
TRUNCATE TABLE interviews;
TRUNCATE TABLE applications;
TRUNCATE TABLE internships;
TRUNCATE TABLE companies;
TRUNCATE TABLE faculty;
TRUNCATE TABLE students;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------------------------------------------------------
-- 1. USERS
-- ----------------------------------------------------------------------------
INSERT INTO users (user_id, email, password_hash, role, is_verified, is_active) VALUES
-- Admin
(1, 'admin@college.edu', '$2b$12$6GhbKOsv0TywFqR8nd0pGuQL0BWwX1ToGTNhr9vWzolWuCJilVCfe', 'admin', 1, 1),

-- Faculty (user_id 2 to 5)
(2, 'dr.smith@college.edu', '$2b$12$SE39a1Q9pZ4v3XB1vn7B0.ZQcs5bZWU56bp4mZioezdYeUMZnaKsy', 'faculty', 1, 1),
(3, 'prof.johnson@college.edu', '$2b$12$SE39a1Q9pZ4v3XB1vn7B0.ZQcs5bZWU56bp4mZioezdYeUMZnaKsy', 'faculty', 1, 1),
(4, 'dr.williams@college.edu', '$2b$12$SE39a1Q9pZ4v3XB1vn7B0.ZQcs5bZWU56bp4mZioezdYeUMZnaKsy', 'faculty', 1, 1),
(5, 'prof.davis@college.edu', '$2b$12$SE39a1Q9pZ4v3XB1vn7B0.ZQcs5bZWU56bp4mZioezdYeUMZnaKsy', 'faculty', 1, 1),

-- Students (user_id 6 to 21)
(6, 'alex.turner@student.edu', '$2b$12$4qG9Zv9cNHLkuxWR.KdOCe1K79pNQpVY0/8S.ABfvxVllAm1ex1oO', 'student', 1, 1),
(7, 'sophia.chen@student.edu', '$2b$12$4qG9Zv9cNHLkuxWR.KdOCe1K79pNQpVY0/8S.ABfvxVllAm1ex1oO', 'student', 1, 1),
(8, 'marcus.vance@student.edu', '$2b$12$4qG9Zv9cNHLkuxWR.KdOCe1K79pNQpVY0/8S.ABfvxVllAm1ex1oO', 'student', 1, 1),
(9, 'emily.watson@student.edu', '$2b$12$4qG9Zv9cNHLkuxWR.KdOCe1K79pNQpVY0/8S.ABfvxVllAm1ex1oO', 'student', 1, 1),
(10, 'liam.miller@student.edu', '$2b$12$4qG9Zv9cNHLkuxWR.KdOCe1K79pNQpVY0/8S.ABfvxVllAm1ex1oO', 'student', 1, 1),
(11, 'olivia.taylor@student.edu', '$2b$12$4qG9Zv9cNHLkuxWR.KdOCe1K79pNQpVY0/8S.ABfvxVllAm1ex1oO', 'student', 1, 1),
(12, 'noah.anderson@student.edu', '$2b$12$4qG9Zv9cNHLkuxWR.KdOCe1K79pNQpVY0/8S.ABfvxVllAm1ex1oO', 'student', 1, 1),
(13, 'ava.thomas@student.edu', '$2b$12$4qG9Zv9cNHLkuxWR.KdOCe1K79pNQpVY0/8S.ABfvxVllAm1ex1oO', 'student', 1, 1),
(14, 'ethan.jackson@student.edu', '$2b$12$4qG9Zv9cNHLkuxWR.KdOCe1K79pNQpVY0/8S.ABfvxVllAm1ex1oO', 'student', 1, 1),
(15, 'isabella.white@student.edu', '$2b$12$4qG9Zv9cNHLkuxWR.KdOCe1K79pNQpVY0/8S.ABfvxVllAm1ex1oO', 'student', 1, 1),
(16, 'lucas.harris@student.edu', '$2b$12$4qG9Zv9cNHLkuxWR.KdOCe1K79pNQpVY0/8S.ABfvxVllAm1ex1oO', 'student', 1, 1),
(17, 'mia.martin@student.edu', '$2b$12$4qG9Zv9cNHLkuxWR.KdOCe1K79pNQpVY0/8S.ABfvxVllAm1ex1oO', 'student', 1, 1),
(18, 'benjamin.garcia@student.edu', '$2b$12$4qG9Zv9cNHLkuxWR.KdOCe1K79pNQpVY0/8S.ABfvxVllAm1ex1oO', 'student', 1, 1),
(19, 'charlotte.martinez@student.edu', '$2b$12$4qG9Zv9cNHLkuxWR.KdOCe1K79pNQpVY0/8S.ABfvxVllAm1ex1oO', 'student', 1, 1),
(20, 'daniel.robinson@student.edu', '$2b$12$4qG9Zv9cNHLkuxWR.KdOCe1K79pNQpVY0/8S.ABfvxVllAm1ex1oO', 'student', 1, 1),
(21, 'zoey.clark@student.edu', '$2b$12$4qG9Zv9cNHLkuxWR.KdOCe1K79pNQpVY0/8S.ABfvxVllAm1ex1oO', 'student', 0, 1); -- Unverified test user

-- ----------------------------------------------------------------------------
-- 2. FACULTY
-- ----------------------------------------------------------------------------
INSERT INTO faculty (faculty_id, user_id, name, department, phone, is_active) VALUES
(1, 2, 'Dr. Robert Smith', 'Computer Science & Engineering', '+15550100002', 1),
(2, 3, 'Prof. Sarah Johnson', 'Information Technology', '+15550100003', 1),
(3, 4, 'Dr. Michael Williams', 'Data Science & AI', '+15550100004', 1),
(4, 5, 'Prof. Amanda Davis', 'Electronics & Communication', '+15550100005', 1);

-- ----------------------------------------------------------------------------
-- 3. STUDENTS
-- ----------------------------------------------------------------------------
INSERT INTO students (student_id, user_id, name, phone, department, gpa, resume_path, is_active) VALUES
(1, 6, 'Alex Turner', '+15550190006', 'Computer Science & Engineering', 3.85, 'app/static/uploads/resumes/alex_turner_resume.pdf', 1),
(2, 7, 'Sophia Chen', '+15550190007', 'Computer Science & Engineering', 3.92, 'app/static/uploads/resumes/sophia_chen_resume.pdf', 1),
(3, 8, 'Marcus Vance', '+15550190008', 'Information Technology', 3.45, 'app/static/uploads/resumes/marcus_vance_resume.pdf', 1),
(4, 9, 'Emily Watson', '+15550190009', 'Data Science & AI', 3.78, 'app/static/uploads/resumes/emily_watson_resume.pdf', 1),
(5, 10, 'Liam Miller', '+15550190010', 'Computer Science & Engineering', 3.60, 'app/static/uploads/resumes/liam_miller_resume.pdf', 1),
(6, 11, 'Olivia Taylor', '+15550190011', 'Electronics & Communication', 3.55, 'app/static/uploads/resumes/olivia_taylor_resume.pdf', 1),
(7, 12, 'Noah Anderson', '+15550190012', 'Information Technology', 3.20, 'app/static/uploads/resumes/noah_anderson_resume.pdf', 1),
(8, 13, 'Ava Thomas', '+15550190013', 'Data Science & AI', 3.95, 'app/static/uploads/resumes/ava_thomas_resume.pdf', 1),
(9, 14, 'Ethan Jackson', '+15550190014', 'Computer Science & Engineering', 3.10, 'app/static/uploads/resumes/ethan_jackson_resume.pdf', 1),
(10, 15, 'Isabella White', '+15550190015', 'Electronics & Communication', 3.68, 'app/static/uploads/resumes/isabella_white_resume.pdf', 1),
(11, 16, 'Lucas Harris', '+15550190016', 'Information Technology', 3.35, 'app/static/uploads/resumes/lucas_harris_resume.pdf', 1),
(12, 17, 'Mia Martin', '+15550190017', 'Data Science & AI', 3.88, 'app/static/uploads/resumes/mia_martin_resume.pdf', 1),
(13, 18, 'Benjamin Garcia', '+15550190018', 'Computer Science & Engineering', 3.70, 'app/static/uploads/resumes/benjamin_garcia_resume.pdf', 1),
(14, 19, 'Charlotte Martinez', '+15550190019', 'Electronics & Communication', 3.40, 'app/static/uploads/resumes/charlotte_martinez_resume.pdf', 1),
(15, 20, 'Daniel Robinson', '+15550190020', 'Information Technology', 2.95, 'app/static/uploads/resumes/daniel_robinson_resume.pdf', 1),
(16, 21, 'Zoey Clark', '+15550190021', 'Computer Science & Engineering', 3.50, NULL, 1); -- Missing resume test

-- ----------------------------------------------------------------------------
-- 4. COMPANIES
-- ----------------------------------------------------------------------------
INSERT INTO companies (company_id, name, registration_number, location, contact_person, contact_email, contact_phone, created_by, is_archived) VALUES
(1, 'TechCorp Systems Inc.', 'REG-TC-10091', 'San Francisco, CA', 'Sarah Jenkins', 'hr@techcorp.com', '+15550180001', 1, 0),
(2, 'CloudSys Technologies', 'REG-CS-20482', 'Seattle, WA', 'David Miller', 'careers@cloudsys.com', '+15550180002', 2, 0),
(3, 'DataSphere Analytics', 'REG-DS-30193', 'New York, NY', 'Elena Rostova', 'talent@datasphere.io', '+15550180003', 3, 0),
(4, 'CyberShield Security', 'REG-CY-40824', 'Austin, TX', 'Michael Chang', 'jobs@cybershield.net', '+15550180004', 1, 0),
(5, 'InnovateTech Solutions', 'REG-IT-50115', 'Boston, MA', 'Rachel Green', 'recruiting@innovatetech.com', '+15550180005', 4, 0),
(6, 'BioHealth Informatics', 'REG-BH-60296', 'San Diego, CA', 'Dr. James Wilson', 'careers@biohealth.org', '+15550180006', 3, 0),
(7, 'AutoDrive Robotics', 'REG-AD-70337', 'Detroit, MI', 'Karen Vance', 'hr@autodrive.com', '+15550180007', 4, 0),
(8, 'FinEdge Solutions', 'REG-FE-80418', 'Chicago, IL', 'Thomas Wright', 'jobs@finedge.com', '+15550180008', 2, 0);

-- ----------------------------------------------------------------------------
-- 5. INTERNSHIPS
-- ----------------------------------------------------------------------------
INSERT INTO internships (internship_id, company_id, posted_by, approved_by, title, description, domain, duration_weeks, stipend, start_date, end_date, application_deadline, status) VALUES
(1, 1, 1, 1, 'Full-Stack Web Development Intern', 'Build modern responsive web applications using React, Python Flask, and MySQL.', 'Software Engineering', 12, 2500.00, '2026-11-01', '2027-01-24', '2026-10-25 23:59:59', 'open'),
(2, 1, 1, 1, 'Backend Systems Engineer Intern', 'Design and optimize scalable distributed microservices in Python and Go.', 'Software Engineering', 16, 2800.00, '2026-11-15', '2027-03-05', '2026-10-28 23:59:59', 'open'),
(3, 2, 2, 1, 'Cloud Infrastructure & DevOps Intern', 'Automate cloud infrastructure deployment using AWS, Docker, and Kubernetes.', 'Cloud & DevOps', 12, 2600.00, '2026-11-01', '2027-01-24', '2026-10-20 23:59:59', 'open'),
(4, 2, 2, 1, 'Site Reliability Engineering Intern', 'Monitor system telemetry, optimize database performance, and write automation scripts.', 'Cloud & DevOps', 14, 2700.00, '2026-11-10', '2027-02-16', '2026-10-30 23:59:59', 'open'),
(5, 3, 3, 1, 'Machine Learning Engineer Intern', 'Develop predictive models, sentiment analysis, and deep neural network pipelines.', 'Data Science & AI', 16, 3200.00, '2026-11-01', '2027-02-20', '2026-10-22 23:59:59', 'open'),
(6, 3, 3, 1, 'Data Analyst Intern', 'Extract, transform, and visualize large enterprise datasets using SQL, Python, and Tableau.', 'Data Analytics', 10, 2200.00, '2026-11-05', '2027-01-14', '2026-10-26 23:59:59', 'open'),
(7, 4, 1, 1, 'Cybersecurity Operations Analyst Intern', 'Perform network vulnerability assessments, threat analysis, and incident response.', 'Cyber Security', 12, 2400.00, '2026-11-15', '2027-02-07', '2026-11-01 23:59:59', 'open'),
(8, 4, 1, 1, 'Application Security Tester Intern', 'Conduct penetration testing, code security audits, and OWASP vulnerability mitigations.', 'Cyber Security', 14, 2600.00, '2026-11-20', '2027-02-26', '2026-11-05 23:59:59', 'open'),
(9, 5, 2, 1, 'Mobile App Developer Intern (iOS/Android)', 'Develop cross-platform mobile apps with Flutter and RESTful API integrations.', 'Mobile Development', 12, 2300.00, '2026-11-01', '2027-01-24', '2026-10-24 23:59:59', 'open'),
(10, 5, 2, 1, 'UI/UX & Frontend Design Intern', 'Create wireframes, user personas, interactive prototypes, and modern CSS layouts.', 'UI/UX Design', 8, 1800.00, '2026-11-01', '2026-12-26', '2026-10-25 23:59:59', 'open'),
(11, 6, 3, 1, 'Bioinformatics Data Scientist Intern', 'Analyze genomic sequence data and protein structures using Python and R pipelines.', 'Bioinformatics', 16, 3000.00, '2026-11-15', '2027-03-05', '2026-11-02 23:59:59', 'open'),
(12, 6, 3, 1, 'Healthcare Software Developer Intern', 'Implement HIPAA-compliant web interfaces and electronic health record software integrations.', 'Software Engineering', 12, 2400.00, '2026-11-10', '2027-02-02', '2026-10-29 23:59:59', 'open'),
(13, 7, 4, 1, 'Embedded Systems & Robotics Engineer', 'Develop firmware in C/C++ for microcontrollers and autonomous vehicle sensors.', 'Embedded Systems', 14, 2900.00, '2026-11-01', '2027-02-07', '2026-10-27 23:59:59', 'open'),
(14, 7, 4, 1, 'Computer Vision Intern', 'Build object detection and lane segmentation models using OpenCV and PyTorch.', 'Data Science & AI', 12, 3100.00, '2026-11-12', '2027-02-04', '2026-10-31 23:59:59', 'open'),
(15, 8, 2, 1, 'Fintech Software Engineering Intern', 'Build high-frequency trading API integrations and payment gateway services.', 'Fintech', 12, 2950.00, '2026-11-05', '2027-01-28', '2026-10-27 23:59:59', 'open'),
(16, 8, 2, 1, 'Financial Quantitative Analyst Intern', 'Build quantitative risk modeling, financial forecasting, and time series algorithms.', 'Fintech', 16, 3300.00, '2026-11-15', '2027-03-05', '2026-11-01 23:59:59', 'open'),
(17, 1, 1, NULL, 'Blockchain Smart Contract Intern', 'Develop smart contracts in Solidity for decentralized financial applications.', 'Software Engineering', 12, 2700.00, '2026-12-01', '2027-02-23', '2026-11-15 23:59:59', 'pending_approval'),
(18, 3, 3, NULL, 'Natural Language Processing Intern', 'Train large language model embeddings for corporate document summarization.', 'Data Science & AI', 14, 3400.00, '2026-12-01', '2027-03-08', '2026-11-18 23:59:59', 'pending_approval'),
(19, 4, 1, 1, 'Network Security Research Intern', 'Analyze network protocol security and simulate DDoS attack mitigation.', 'Cyber Security', 10, 2100.00, '2026-11-01', '2027-01-10', '2026-10-25 23:59:59', 'closed'),
(20, 5, 2, 1, 'Legacy Systems Migration Intern', 'Refactor monolithic codebases into modern REST microservices.', 'Software Engineering', 12, 2000.00, '2026-11-15', '2027-02-10', '2026-11-01 23:59:59', 'closed'),
(21, 2, 2, 1, 'Quantum Computing Research Intern', 'Experiment with quantum algorithms on IBM Qiskit framework.', 'Research', 16, 3500.00, '2026-12-15', '2027-04-05', '2026-11-30 23:59:59', 'open'),
(22, 7, 4, 1, 'IoT Telemetry Engineer Intern', 'Implement MQTT messaging protocols for industrial sensor monitoring.', 'Embedded Systems', 12, 2500.00, '2026-11-20', '2027-02-12', '2026-11-05 23:59:59', 'open');

-- ----------------------------------------------------------------------------
-- 6. APPLICATIONS (45 Applications)
-- ----------------------------------------------------------------------------
INSERT INTO applications (application_id, student_id, internship_id, resume_path, cover_letter, qualifications, status, applied_at) VALUES
(1, 1, 1, 'app/static/uploads/resumes/alex_turner_resume.pdf', 'I am passionate about full-stack web development and modern frameworks.', 'B.Tech CSE, 3.85 GPA, Python/Flask/React expert', 'accepted', '2026-10-01 10:15:00'),
(2, 1, 2, 'app/static/uploads/resumes/alex_turner_resume.pdf', 'Eager to contribute to scalable backend distributed systems.', 'B.Tech CSE, 3.85 GPA, C++, Go, Python', 'shortlisted', '2026-10-02 11:30:00'),
(3, 2, 1, 'app/static/uploads/resumes/sophia_chen_resume.pdf', 'Experienced in building enterprise web tools and SQL optimization.', 'B.Tech CSE, 3.92 GPA, React, MySQL, Django', 'shortlisted', '2026-10-01 14:20:00'),
(4, 2, 5, 'app/static/uploads/resumes/sophia_chen_resume.pdf', 'Fascinated by neural networks and machine learning pipelines.', 'B.Tech CSE, 3.92 GPA, PyTorch, Scikit-learn', 'accepted', '2026-10-02 09:00:00'),
(5, 3, 3, 'app/static/uploads/resumes/marcus_vance_resume.pdf', 'Motivated to gain hands-on experience in cloud orchestration and Docker.', 'B.Tech IT, 3.45 GPA, AWS Cloud Practitioner', 'shortlisted', '2026-10-03 16:45:00'),
(6, 3, 6, 'app/static/uploads/resumes/marcus_vance_resume.pdf', 'Looking forward to analyzing large datasets using SQL and PowerBI.', 'B.Tech IT, 3.45 GPA, SQL, Tableau', 'pending', '2026-10-04 12:10:00'),
(7, 4, 5, 'app/static/uploads/resumes/emily_watson_resume.pdf', 'Specialized in deep learning and natural language processing.', 'B.Tech Data Science, 3.78 GPA, Python, TensorFlow', 'shortlisted', '2026-10-01 15:00:00'),
(8, 4, 6, 'app/static/uploads/resumes/emily_watson_resume.pdf', 'Proficient in statistical data modeling and ETL workflows.', 'B.Tech Data Science, 3.78 GPA, R, SQL, pandas', 'accepted', '2026-10-02 10:00:00'),
(9, 5, 1, 'app/static/uploads/resumes/liam_miller_resume.pdf', 'Experienced in frontend web design and modern JS frameworks.', 'B.Tech CSE, 3.60 GPA, JavaScript, HTML/CSS', 'pending', '2026-10-03 11:15:00'),
(10, 5, 4, 'app/static/uploads/resumes/liam_miller_resume.pdf', 'Interested in site reliability and database administration.', 'B.Tech CSE, 3.60 GPA, Linux, Bash, MySQL', 'shortlisted', '2026-10-04 13:40:00'),
(11, 6, 13, 'app/static/uploads/resumes/olivia_taylor_resume.pdf', 'Hands-on experience with ARM microcontrollers and C++ programming.', 'B.Tech ECE, 3.55 GPA, C/C++, RTOS, Proteus', 'accepted', '2026-10-02 08:30:00'),
(12, 6, 14, 'app/static/uploads/resumes/olivia_taylor_resume.pdf', 'Focused on computer vision for autonomous vehicle navigation.', 'B.Tech ECE, 3.55 GPA, OpenCV, Python', 'shortlisted', '2026-10-03 14:00:00'),
(13, 7, 3, 'app/static/uploads/resumes/noah_anderson_resume.pdf', 'Keen interest in DevOps pipelines and CI/CD automation.', 'B.Tech IT, 3.20 GPA, Git, Jenkins, Docker', 'rejected', '2026-10-02 17:00:00'),
(14, 7, 9, 'app/static/uploads/resumes/noah_anderson_resume.pdf', 'Developed cross-platform mobile apps for Android.', 'B.Tech IT, 3.20 GPA, Flutter, Dart', 'pending', '2026-10-04 15:20:00'),
(15, 8, 5, 'app/static/uploads/resumes/ava_thomas_resume.pdf', 'Top academic performer with research papers in ML algorithms.', 'B.Tech Data Science, 3.95 GPA, PyTorch, Keras', 'accepted', '2026-10-01 09:10:00'),
(16, 8, 11, 'app/static/uploads/resumes/ava_thomas_resume.pdf', 'Applying data science tools to genomic dataset analysis.', 'B.Tech Data Science, 3.95 GPA, BioPython, R', 'shortlisted', '2026-10-03 10:30:00'),
(17, 9, 7, 'app/static/uploads/resumes/ethan_jackson_resume.pdf', 'Passionate about ethical hacking and network security.', 'B.Tech CSE, 3.10 GPA, Wireshark, Metasploit', 'shortlisted', '2026-10-02 16:15:00'),
(18, 9, 8, 'app/static/uploads/resumes/ethan_jackson_resume.pdf', 'Conducted security penetration tests on local web applications.', 'B.Tech CSE, 3.10 GPA, OWASP Top 10, Burp Suite', 'pending', '2026-10-04 09:45:00'),
(19, 10, 13, 'app/static/uploads/resumes/isabella_white_resume.pdf', 'Strong background in circuit design and embedded software.', 'B.Tech ECE, 3.68 GPA, Verilog, C, Embedded Systems', 'shortlisted', '2026-10-02 12:00:00'),
(20, 10, 22, 'app/static/uploads/resumes/isabella_white_resume.pdf', 'Interested in industrial IoT telemetry protocols.', 'B.Tech ECE, 3.68 GPA, MQTT, ESP32, C++', 'pending', '2026-10-03 18:30:00'),
(21, 11, 15, 'app/static/uploads/resumes/lucas_harris_resume.pdf', 'Building high performance financial APIs and database backend.', 'B.Tech IT, 3.35 GPA, Java Spring Boot, MySQL', 'shortlisted', '2026-10-03 14:10:00'),
(22, 11, 2, 'app/static/uploads/resumes/lucas_harris_resume.pdf', 'Backend microservices developer with strong SQL foundation.', 'B.Tech IT, 3.35 GPA, Python, Flask', 'rejected', '2026-10-04 11:00:00'),
(23, 12, 16, 'app/static/uploads/resumes/mia_martin_resume.pdf', 'Specialized in quantitative finance algorithms and time series.', 'B.Tech Data Science, 3.88 GPA, Python, pandas, NumPy', 'accepted', '2026-10-01 13:45:00'),
(24, 12, 5, 'app/static/uploads/resumes/mia_martin_resume.pdf', 'Interested in machine learning applications for financial forecasting.', 'B.Tech Data Science, 3.88 GPA, PyTorch', 'withdrawn', '2026-10-02 16:50:00'),
(25, 13, 1, 'app/static/uploads/resumes/benjamin_garcia_resume.pdf', 'Full stack developer with multiple published web projects.', 'B.Tech CSE, 3.70 GPA, Vue.js, Node.js, Express', 'shortlisted', '2026-10-02 10:20:00'),
(26, 13, 15, 'app/static/uploads/resumes/benjamin_garcia_resume.pdf', 'Experience in developing payment engine microservices.', 'B.Tech CSE, 3.70 GPA, Go, PostgreSQL', 'accepted', '2026-10-03 15:30:00'),
(27, 14, 10, 'app/static/uploads/resumes/charlotte_martinez_resume.pdf', 'UI/UX enthusiast with Figma prototyping experience.', 'B.Tech ECE, 3.40 GPA, Figma, HTML, Tailwind CSS', 'accepted', '2026-10-02 11:00:00'),
(28, 14, 9, 'app/static/uploads/resumes/charlotte_martinez_resume.pdf', 'Mobile app design and frontend integration.', 'B.Tech ECE, 3.40 GPA, React Native', 'pending', '2026-10-04 14:15:00'),
(29, 15, 6, 'app/static/uploads/resumes/daniel_robinson_resume.pdf', 'Data entry, SQL query writing, and business reporting.', 'B.Tech IT, 2.95 GPA, Excel, SQL', 'rejected', '2026-10-03 12:40:00'),
(30, 15, 10, 'app/static/uploads/resumes/daniel_robinson_resume.pdf', 'Frontend web developer focusing on basic HTML/CSS.', 'B.Tech IT, 2.95 GPA, HTML5, CSS3', 'pending', '2026-10-04 16:00:00'),
(31, 1, 7, 'app/static/uploads/resumes/alex_turner_resume.pdf', 'Secondary application for security developer role.', 'B.Tech CSE, 3.85 GPA, Python, Linux', 'pending', '2026-10-04 17:30:00'),
(32, 2, 2, 'app/static/uploads/resumes/sophia_chen_resume.pdf', 'Backend microservices focus.', 'B.Tech CSE, 3.92 GPA, Python', 'pending', '2026-10-04 18:00:00'),
(33, 4, 11, 'app/static/uploads/resumes/emily_watson_resume.pdf', 'Data science in healthcare.', 'B.Tech Data Science, 3.78 GPA, Python', 'pending', '2026-10-04 18:30:00'),
(34, 5, 3, 'app/static/uploads/resumes/liam_miller_resume.pdf', 'Cloud engineering app.', 'B.Tech CSE, 3.60 GPA, Docker', 'pending', '2026-10-04 19:00:00'),
(35, 6, 22, 'app/static/uploads/resumes/olivia_taylor_resume.pdf', 'IoT monitoring.', 'B.Tech ECE, 3.55 GPA, C++', 'pending', '2026-10-04 19:30:00'),
(36, 8, 6, 'app/static/uploads/resumes/ava_thomas_resume.pdf', 'Analytics track.', 'B.Tech Data Science, 3.95 GPA, SQL', 'pending', '2026-10-04 20:00:00'),
(37, 9, 12, 'app/static/uploads/resumes/ethan_jackson_resume.pdf', 'Penetration testing.', 'B.Tech CSE, 3.10 GPA, Linux', 'pending', '2026-10-04 20:30:00'),
(38, 10, 14, 'app/static/uploads/resumes/isabella_white_resume.pdf', 'Computer vision application.', 'B.Tech ECE, 3.68 GPA, OpenCV', 'pending', '2026-10-04 21:00:00'),
(39, 11, 1, 'app/static/uploads/resumes/lucas_harris_resume.pdf', 'Full stack role.', 'B.Tech IT, 3.35 GPA, Web Dev', 'pending', '2026-10-04 21:30:00'),
(40, 12, 15, 'app/static/uploads/resumes/mia_martin_resume.pdf', 'Fintech engineering.', 'B.Tech Data Science, 3.88 GPA, Python', 'pending', '2026-10-04 22:00:00'),
(41, 13, 2, 'app/static/uploads/resumes/benjamin_garcia_resume.pdf', 'Distributed systems.', 'B.Tech CSE, 3.70 GPA, Go', 'pending', '2026-10-04 22:30:00'),
(42, 14, 1, 'app/static/uploads/resumes/charlotte_martinez_resume.pdf', 'Frontend web developer.', 'B.Tech ECE, 3.40 GPA, HTML', 'pending', '2026-10-04 23:00:00'),
(43, 3, 4, 'app/static/uploads/resumes/marcus_vance_resume.pdf', 'SRE application.', 'B.Tech IT, 3.45 GPA, Linux', 'pending', '2026-10-04 23:15:00'),
(44, 7, 7, 'app/static/uploads/resumes/noah_anderson_resume.pdf', 'Security analyst application.', 'B.Tech IT, 3.20 GPA, Networking', 'pending', '2026-10-04 23:30:00'),
(45, 15, 9, 'app/static/uploads/resumes/daniel_robinson_resume.pdf', 'Mobile app track.', 'B.Tech IT, 2.95 GPA, Java', 'pending', '2026-10-04 23:45:00');

-- ----------------------------------------------------------------------------
-- 7. INTERVIEWS (18 Interviews)
-- Note: Datetimes set to realistic dates relative to application deadlines
-- ----------------------------------------------------------------------------
INSERT INTO interviews (interview_id, application_id, interviewer_name, interviewer_email, interview_datetime, mode, result, comments) VALUES
(1, 1, 'Sarah Jenkins', 'hr@techcorp.com', '2026-10-15 10:00:00', 'online', 'passed', 'Exceptional problem solving skills in Python and SQL schema design.'),
(2, 2, 'Dave Roberts', 'tech@techcorp.com', '2026-10-18 14:00:00', 'online', 'scheduled', 'Technical round on distributed systems and concurrency.'),
(3, 3, 'Sarah Jenkins', 'hr@techcorp.com', '2026-10-16 11:30:00', 'online', 'passed', 'Strong understanding of React state management and REST API design.'),
(4, 4, 'Elena Rostova', 'talent@datasphere.io', '2026-10-12 15:00:00', 'online', 'passed', 'Outstanding performance in deep learning live coding test.'),
(5, 5, 'David Miller', 'careers@cloudsys.com', '2026-10-14 09:30:00', 'online', 'scheduled', 'Docker containerization and AWS infrastructure interview.'),
(6, 7, 'Elena Rostova', 'talent@datasphere.io', '2026-10-14 16:00:00', 'online', 'passed', 'Solid knowledge of NLP transformer models and feature extraction.'),
(7, 8, 'Elena Rostova', 'talent@datasphere.io', '2026-10-13 13:00:00', 'online', 'passed', 'Great SQL query optimization and dataset visualization demonstration.'),
(8, 10, 'David Miller', 'careers@cloudsys.com', '2026-10-19 10:00:00', 'online', 'scheduled', 'Linux shell scripting and system telemetry test.'),
(9, 11, 'Karen Vance', 'hr@autodrive.com', '2026-10-10 11:00:00', 'in_person', 'passed', 'Excellent microcontroller architecture knowledge and C++ test score.'),
(10, 12, 'Karen Vance', 'hr@autodrive.com', '2026-10-17 14:30:00', 'online', 'scheduled', 'Computer vision and lane tracking model evaluation.'),
(11, 13, 'David Miller', 'careers@cloudsys.com', '2026-10-16 10:00:00', 'online', 'failed', 'Candidate lacked sufficient hands-on experience with Kubernetes orchestration.'),
(12, 15, 'Elena Rostova', 'talent@datasphere.io', '2026-10-17 14:00:00', 'online', 'passed', 'Top candidate with strong research foundation and machine learning background.'),
(13, 16, 'Dr. James Wilson', 'careers@biohealth.org', '2026-10-21 11:00:00', 'online', 'scheduled', 'Bioinformatics pipeline and genomic data analysis interview.'),
(14, 17, 'Michael Chang', 'jobs@cybershield.net', '2026-10-22 15:00:00', 'online', 'scheduled', 'Network threat analysis and Wireshark log assessment.'),
(15, 19, 'Karen Vance', 'hr@autodrive.com', '2026-10-20 10:30:00', 'in_person', 'scheduled', 'Hardware lab test and embedded system debug challenge.'),
(16, 21, 'Thomas Wright', 'jobs@finedge.com', '2026-10-20 16:00:00', 'online', 'scheduled', 'Financial trading API design and Java concurrency test.'),
(17, 23, 'Thomas Wright', 'jobs@finedge.com', '2026-10-11 11:00:00', 'online', 'passed', 'Impressive quantitative modeling and time series analysis capability.'),
(18, 26, 'Thomas Wright', 'jobs@finedge.com', '2026-10-12 14:00:00', 'online', 'passed', 'Clean architecture principles and payment gateway integration test.');

-- ----------------------------------------------------------------------------
-- 8. EVALUATIONS (12 Faculty Evaluations)
-- ----------------------------------------------------------------------------
INSERT INTO evaluations (evaluation_id, application_id, evaluator_id, technical_score, communication_score, overall_rating, comments, is_archived) VALUES
(1, 1, 1, 5, 5, 5, 'Alex performed exceptionally well during the full-stack web project. Highly recommended.', 0),
(2, 4, 3, 5, 4, 5, 'Sophia demonstrated advanced deep learning knowledge and clean modular code architecture.', 0),
(3, 8, 3, 4, 5, 4, 'Emily executed statistical analysis pipelines with high precision and strong communication.', 0),
(4, 11, 4, 5, 4, 5, 'Olivia excelled in microcontroller programming and hardware interface testing.', 0),
(5, 15, 3, 5, 5, 5, 'Ava produced publishable machine learning models during the internship tenure.', 0),
(6, 23, 2, 5, 4, 5, 'Mia showcased superior quantitative modeling skills and financial data comprehension.', 0),
(7, 26, 1, 4, 5, 4, 'Benjamin integrated secure payment endpoints with zero critical security flaws.', 0),
(8, 27, 2, 4, 4, 4, 'Charlotte created intuitive Figma UI wireframes and responsive frontend templates.', 0),
(9, 3, 1, 4, 4, 4, 'Sophia showed strong web design foundation and database query optimization capabilities.', 0),
(10, 7, 3, 4, 4, 4, 'Emily demonstrated thorough understanding of natural language preprocessing steps.', 0),
(11, 12, 4, 4, 4, '4', 'Olivia built reliable computer vision detection loops with good frame rates.', 0),
(12, 19, 4, 4, 3, 4, 'Isabella completed embedded board debugging with solid technical rigor.', 0);

-- ----------------------------------------------------------------------------
-- 9. STUDENT FEEDBACK (10 Records)
-- ----------------------------------------------------------------------------
INSERT INTO student_feedback (student_feedback_id, application_id, company_culture, mentorship, technical_learning, work_environment, overall, comments) VALUES
(1, 1, 5, 5, 5, 5, 5, 'TechCorp provided an amazing learning environment with supportive engineering mentors.'),
(2, 4, 5, 4, 5, 5, 5, 'DataSphere gave me direct exposure to production ML pipelines and GPU clusters.'),
(3, 8, 4, 5, 4, 4, 4, 'Great team culture and valuable guidance on SQL query tuning and data warehousing.'),
(4, 11, 5, 4, 5, 4, 5, 'AutoDrive has world-class robotics hardware labs. Highly recommend for ECE students.'),
(5, 15, 5, 5, 5, 5, 5, 'Challenging research projects and inspiring senior data science team.'),
(6, 23, 4, 4, 5, 4, 4, 'FinEdge offered excellent quantitative finance experience and market data analysis.'),
(7, 26, 4, 5, 4, 5, 4, 'Very professional software engineering environment with high coding standards.'),
(8, 27, 5, 4, 4, 5, 4, 'InnovateTech allowed me to lead the UI redesign for their core customer dashboard.'),
(9, 3, 4, 4, 4, 4, 4, 'Good web engineering exposure and friendly code review sessions.'),
(10, 7, 5, 4, 5, 4, 5, 'Deep learning team was encouraging and answered all technical questions.');

-- ----------------------------------------------------------------------------
-- 10. COMPANY FEEDBACK (10 Records)
-- ----------------------------------------------------------------------------
INSERT INTO company_feedback (company_feedback_id, application_id, technical_skills, soft_skills, punctuality, responsibility, teamwork, learning_ability, likely_to_hire_fulltime, comments) VALUES
(1, 1, 5, 5, 5, 5, 5, 5, 1, 'Alex is a top-tier software developer. We intend to extend a full-time job offer upon graduation.'),
(2, 4, 5, 4, 5, 5, 4, 5, 1, 'Sophia exceeded our expectations in machine learning model development.'),
(3, 8, 4, 5, 5, 4, 5, 4, 1, 'Emily communicated insights clearly to stakeholders and mastered our ETL tools quickly.'),
(4, 11, 5, 4, 5, 5, 4, 5, 1, 'Olivia displayed deep firmware programming skill and great discipline.'),
(5, 15, 5, 5, 5, 5, 5, 5, 1, 'Ava is an outstanding AI researcher who solved complex data pipeline bottlenecks.'),
(6, 23, 5, 4, 4, 5, 4, 5, 1, 'Mia delivered quantitative finance algorithms ahead of schedule with great accuracy.'),
(7, 26, 4, 5, 5, 4, 5, 4, 1, 'Benjamin is a reliable engineer with high code quality and strong teamwork.'),
(8, 27, 4, 4, 5, 4, 4, 4, 1, 'Charlotte designed clean user interfaces that received unanimous approval from product managers.'),
(9, 3, 4, 4, 5, 4, 4, 4, 0, 'Sophia is technically strong and worked well with the frontend squad.'),
(10, 7, 4, 4, 4, 4, 4, 4, 1, 'Emily displayed consistent learning ability and adaptability.');

-- ----------------------------------------------------------------------------
-- 11. FACULTY FEEDBACK (8 Records)
-- ----------------------------------------------------------------------------
INSERT INTO faculty_feedback (faculty_feedback_id, internship_id, faculty_id, suitability_for_course, learning_outcomes, quality_rating, suggestions) VALUES
(1, 1, 1, 5, 5, 5, 'Directly aligns with Senior CSE Web Development curriculum and DB capstone goals.'),
(2, 5, 3, 5, 5, 5, 'Provides state-of-the-art exposure to industry machine learning frameworks.'),
(3, 3, 2, 4, 4, 4, 'Excellent DevOps infrastructure learning opportunity for IT department students.'),
(4, 13, 4, 5, 5, 5, 'Highly relevant to Embedded Systems and Real-Time OS course requirements.'),
(5, 15, 2, 4, 5, 4, 'Great combination of software engineering and financial domain algorithms.'),
(6, 6, 3, 4, 4, 4, 'Good practical application of SQL querying and data visualization.'),
(7, 7, 1, 5, 4, 5, 'Comprehensive coverage of network security standards and vulnerability scanning.'),
(8, 10, 2, 4, 4, 4, 'Provides solid UI design experience and design system creation.');

-- ----------------------------------------------------------------------------
-- 12. SYSTEM FEEDBACK (10 Records)
-- ----------------------------------------------------------------------------
INSERT INTO system_feedback (feedback_id, user_id, type, description, status, created_at) VALUES
(1, 6, 'feature', 'Please add email notification when interview is scheduled.', 'planned', '2026-10-02 09:30:00'),
(2, 7, 'feature', 'Option to upload multiple certificates along with resume.', 'in_review', '2026-10-02 14:15:00'),
(3, 8, 'bug', 'Filters clear when navigating back from internship detail page.', 'done', '2026-10-03 10:00:00'),
(4, 2, 'improvement', 'Add bulk approval button for internship postings in faculty view.', 'planned', '2026-10-03 11:45:00'),
(5, 9, 'feature', 'Dark mode support for student dashboard.', 'new', '2026-10-03 15:20:00'),
(6, 3, 'improvement', 'Export application list as CSV spreadsheet.', 'done', '2026-10-04 08:30:00'),
(7, 10, 'bug', 'Typo in interview confirmation modal title.', 'done', '2026-10-04 09:10:00'),
(8, 4, 'improvement', 'Show total candidate count badge next to internship tabs.', 'in_review', '2026-10-04 11:00:00'),
(9, 11, 'feature', 'Calendar integration for upcoming interview datetimes.', 'new', '2026-10-04 14:00:00'),
(10, 1, 'improvement', 'Add system performance analytics graph to admin dashboard.', 'in_review', '2026-10-04 16:30:00');

-- ----------------------------------------------------------------------------
-- 13. COMPANY RATINGS (15 Ratings by Students)
-- ----------------------------------------------------------------------------
INSERT INTO company_ratings (rating_id, student_id, company_id, rating, review) VALUES
(1, 1, 1, 5, 'TechCorp has outstanding mentors, competitive stipends, and great office culture.'),
(2, 2, 1, 5, 'Highly supportive engineering team and excellent learning opportunity.'),
(3, 2, 3, 5, 'DataSphere is the best place to gain real enterprise ML pipeline experience.'),
(4, 4, 3, 5, 'Amazing data science culture and access to GPU compute clusters.'),
(5, 6, 7, 5, 'AutoDrive robotics lab experience was unmatched for ECE hardware students.'),
(6, 8, 3, 5, 'DataSphere provides challenging projects and fantastic career growth.'),
(7, 12, 8, 4, 'FinEdge offered great exposure to quantitative finance and market data algorithms.'),
(8, 13, 8, 4, 'Solid engineering principles and professional team dynamics.'),
(9, 14, 5, 4, 'InnovateTech gave me creative freedom on UI design projects.'),
(10, 3, 2, 4, 'CloudSys provided good exposure to AWS and container orchestration.'),
(11, 5, 2, 4, 'Learned a lot about Linux administration and database performance.'),
(12, 7, 5, 4, 'Friendly team and great mobile app dev stack.'),
(13, 9, 4, 4, 'CyberShield security labs are well-equipped with real penetration tools.'),
(14, 10, 7, 5, 'Fascinating embedded systems projects for autonomous vehicles.'),
(15, 11, 8, 4, 'Fintech trading engine development was fast-paced and rewarding.');

-- ----------------------------------------------------------------------------
-- 14. INITIAL AUDIT LOG
-- ----------------------------------------------------------------------------
INSERT INTO audit_log (action_type, table_name, record_id, performed_by, new_values, timestamp) VALUES
('SYSTEM_INIT', 'users', 1, 'SYSTEM', '{"status": "Database Seed Completed"}', '2026-10-05 00:00:00'),
('INSERT', 'users', 1, 'SYSTEM', '{"email": "admin@college.edu", "role": "admin"}', '2026-10-05 00:01:00'),
('INSERT', 'users', 2, 'SYSTEM', '{"email": "dr.smith@college.edu", "role": "faculty"}', '2026-10-05 00:02:00'),
('INSERT', 'users', 6, 'SYSTEM', '{"email": "alex.turner@student.edu", "role": "student"}', '2026-10-05 00:03:00'),
('UPDATE_STATUS', 'internships', 1, 'ADMIN_1', '{"status": "open"}', '2026-10-05 01:00:00'),
('UPDATE_STATUS', 'internships', 5, 'ADMIN_1', '{"status": "open"}', '2026-10-05 01:05:00'),
('UPDATE_STATUS', 'applications', 1, 'FACULTY_1', '{"status": "accepted"}', '2026-10-05 02:00:00'),
('UPDATE_STATUS', 'applications', 4, 'FACULTY_3', '{"status": "accepted"}', '2026-10-05 02:15:00'),
('UPDATE_STATUS', 'applications', 8, 'FACULTY_3', '{"status": "accepted"}', '2026-10-05 02:30:00'),
('UPDATE_STATUS', 'applications', 11, 'FACULTY_4', '{"status": "accepted"}', '2026-10-05 02:45:00');
