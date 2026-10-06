# MySQL Database Documentation & Execution Guide

This folder contains the complete SQL database scripts for the **College Internship Management System**.

## Script Execution Sequence

For proper setup, run the SQL scripts in **MySQL Workbench** or via the MySQL CLI in the exact following order:

```bash
1. schema.sql          # Drops/Creates database, tables, PKs/FKs, CHECK constraints & indexes
2. triggers.sql        # Creates business validation & audit triggers
3. procedures.sql      # Creates stored procedures, transactions, functions & scheduled event
4. views.sql           # Creates analytical reporting views for Admin, Faculty, and Students
5. roles.sql           # Sets up MySQL roles (admin_role, faculty_role, student_role) & GRANTs
6. seed.sql            # Loads realistic sample data (16 students, 8 companies, 22 internships, 45 apps, etc.)
7. queries.sql         # Demo queries for all reports, functions, and EXPLAIN index examples
8. test_validations.sql# Validation verification suite showing database constraints rejecting bad data
```

---

## Running Scripts in MySQL Workbench

1. Open **MySQL Workbench** and connect to your local MySQL 8.0 server instance (`localhost:3306`).
2. Go to **File > Open SQL Script...** (or press `Ctrl + O`).
3. Select `1. schema.sql` and click **Open**.
4. Click the **Lightning Bolt** icon (`Execute`) or press `Ctrl + Shift + Enter` to execute the script.
5. Repeat steps 2–4 for each script in order: `triggers.sql` → `procedures.sql` → `views.sql` → `roles.sql` → `seed.sql`.
6. Refresh the Schema Panel on the left side to verify all tables, views, stored procedures, and triggers appear under `internship_db`.

---

## How to Generate the EER Diagram in MySQL Workbench

To generate the full **Enhanced Entity-Relationship (EER) Diagram** for your ADBMS submission:

1. Open **MySQL Workbench**.
2. From the main menu bar, navigate to: **Database > Reverse Engineer...** (or press `Ctrl + R`).
3. In the **Stored Connection** dropdown, select your local connection and click **Next**.
4. Enter your MySQL password if prompted, then click **Next**.
5. On the **Select Schemata** page, check `internship_db` and click **Next**.
6. Click **Next** through the object retrieval step until you reach **Results**.
7. Click **Finish**.
8. MySQL Workbench will render the complete interactive **EER Diagram** with all tables, primary keys, foreign key relationships, and cardinalities!
9. Go to **File > Export > Export as Single Page PDF...** or **Export as PNG...** to save the diagram for your assignment submission.

---

## Database Features Summary (ADBMS Assessment Criteria)

| Feature | Implementation File | Details |
|---|---|---|
| **Database & Normalization** | `schema.sql` | InnoDB engine, 3NF schema, 14 tables, PKs, FKs with ON DELETE rules |
| **Validation Constraints** | `schema.sql` | CHECK constraints for RFC 5322 Email, International Phone, GPA 0-4, Stipend |
| **Validation Triggers** | `triggers.sql` | Application PDF resume check, Interview 24h notice & deadline check |
| **Audit Logging** | `triggers.sql` | Automatic JSON audit trail in `audit_log` table upon mutations |
| **Transactions & Handlers** | `procedures.sql` | `START TRANSACTION`, `COMMIT`, `ROLLBACK`, `DECLARE EXIT HANDLER FOR SQLEXCEPTION` |
| **Stored Functions** | `procedures.sql` | `fn_calculate_placement_rate()`, `fn_get_student_placement_status()`, `fn_calculate_company_avg_rating()` |
| **Scheduled Event** | `procedures.sql` | `event_auto_close_expired_internships` (hourly auto-close job) |
| **Reporting Views** | `views.sql` | 13 custom views covering Admin, Faculty, and Student analytics |
| **MySQL Roles & Grants** | `roles.sql` | Role-based database security (`admin_role`, `faculty_role`, `student_role`) |
| **Index Performance** | `queries.sql` | `EXPLAIN` analysis demonstrating composite and single-column index optimization |
