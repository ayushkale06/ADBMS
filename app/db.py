import os
import mysql.connector
from mysql.connector import pooling, Error
from dotenv import load_dotenv

load_dotenv()

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", 3306))
DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "root")
DB_NAME = os.getenv("DB_NAME", "internship_db")

db_pool = None
working_credentials = None

def get_candidate_credentials():
    candidates = []
    # Primary user from .env
    candidates.append((DB_USER, DB_PASSWORD))
    # Fallback created by roles.sql
    candidates.append(("db_admin", "AdminPass@123"))
    # Common local root defaults
    candidates.append(("root", ""))
    candidates.append(("root", "root"))
    candidates.append(("root", "Admin@123"))
    return candidates

def init_db_pool():
    global db_pool, working_credentials

    for user, pwd in get_candidate_credentials():
        try:
            pool = pooling.MySQLConnectionPool(
                pool_name="internship_pool",
                pool_size=10,
                pool_reset_session=True,
                host=DB_HOST,
                port=DB_PORT,
                user=user,
                password=pwd,
                database=DB_NAME,
                autocommit=True
            )
            # Test connection from pool
            test_conn = pool.get_connection()
            test_conn.close()

            db_pool = pool
            working_credentials = (user, pwd)
            print(f"Connected to MySQL successfully using user '{user}'.")
            return
        except Error as err:
            if err.errno == 1045:
                continue # Try next credentials
            elif err.errno == 1049: # Unknown database, try connecting without database to create if needed
                print(f"Warning: Database '{DB_NAME}' not found. Ensure schema.sql has been executed.")
                break
            else:
                print(f"MySQL Pool Initialization Warning for user '{user}': {err}")

    print("Warning: Could not initialize MySQL Connection Pool with default candidate credentials.")

def get_db_connection():
    global db_pool, working_credentials
    if db_pool is None:
        init_db_pool()

    if db_pool:
        try:
            return db_pool.get_connection()
        except Error:
            pass

    # Direct fallback connection attempt
    for user, pwd in get_candidate_credentials():
        try:
            conn = mysql.connector.connect(
                host=DB_HOST,
                port=DB_PORT,
                user=user,
                password=pwd,
                database=DB_NAME,
                autocommit=True
            )
            working_credentials = (user, pwd)
            return conn
        except Error:
            continue

    return None

def execute_query(query, params=None, fetchone=False, fetchall=False, commit=False):
    conn = get_db_connection()
    if not conn:
        raise Exception("Database connection failed. Access denied for MySQL user. Update DB_PASSWORD in .env with your MySQL Workbench password.")

    cursor = None
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query, params or ())
        
        result = None
        if fetchone:
            result = cursor.fetchone()
        elif fetchall:
            result = cursor.fetchall()
        elif cursor.lastrowid:
            result = cursor.lastrowid
        else:
            result = cursor.rowcount

        if commit and not conn.autocommit:
            conn.commit()

        return result
    except Error as err:
        print(f"Database Query Error: {err}")
        raise err
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

def call_procedure(proc_name, params=None):
    conn = get_db_connection()
    if not conn:
        raise Exception("Database connection failed.")

    cursor = None
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.callproc(proc_name, params or ())
        results = []
        for result in cursor.stored_results():
            results.append(result.fetchall())
        return results
    except Error as err:
        print(f"Stored Procedure Error: {err}")
        raise err
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
