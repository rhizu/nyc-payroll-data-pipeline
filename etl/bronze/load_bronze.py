from src.utils.sql_utils import read_sql_files
import csv;

SOURCE_FILE = "/opt/airflow/project/data/nyc_payroll_data.csv"

# Create tables using DDL query

def initialize_bronze_layer(conn, cur):
    bronze_ddl_query = read_sql_files("/opt/airflow/project/sql/ddl/01_create_bronze_tables.sql")
    
    cur.execute(bronze_ddl_query)
    conn.commit()
    print("Bronze layer initialized successfully.")

# Load data using Incremental Load

def load_bronze_layer(conn, cur):
    try:

        # ====================================
        # CHECK IF FILE ALREADY PROCESSED
        # ====================================

        cur.execute("""
            SELECT 1
            FROM bronze.batch_log
            WHERE source_file = %s
            AND status = 'COMPLETED'
        """, (SOURCE_FILE,))

        already_loaded = cur.fetchone()

        if already_loaded:
            print(f"File already processed: {SOURCE_FILE}")
            return

        # 1. Start Batch

        cur.execute("INSERT INTO bronze.batch_log (source_file) VALUES (%s) RETURNING batch_number", (SOURCE_FILE,)
        )
        batch_number = cur.fetchone()[0]
        print(f"Started batch: {batch_number}")

        # 2. Read CSV and insert data

        bronze_dml_query = read_sql_files("/opt/airflow/project/sql/dml/01_load_bronze_tables.sql")
        row_count = 0
        
        with open("/opt/airflow/project/data/nyc_payroll_data.csv", "r", encoding="utf-8-sig", errors="replace") as file:
            rows = csv.DictReader(file)
            for row in rows:
                cur.execute(bronze_dml_query,
                    (
                        (
                        row['Fiscal Year'],
                        row['Agency Name'],
                        row['Last Name'],
                        row['First Name'],
                        row['Mid Init'],
                        row['Agency Start Date'],
                        row['Work Location Borough'],
                        row['Title Description'],
                        row['Leave Status as of June 30'],
                        row['Base Salary'],
                        row['Pay Basis'],
                        row['Regular Hours'],
                        row['Regular Gross Paid'],
                        row['OT Hours'],
                        row['Total OT Paid'],
                        row['Total Other Pay'],
                        batch_number
                    )))
                row_count += 1

        # 3. Complete Batch
        
        cur.execute("""
            UPDATE bronze.batch_log 
            SET status = 'COMPLETED', row_count = %s
            WHERE batch_number = %s;
        """, (row_count, batch_number))

        conn.commit()
        print(f"Batch {batch_number} completed with {row_count} rows: ")
    
    except Exception as e:
        conn.rollback()
        print("Error occurred: ", e)

        # mark batch as failed

        cur.execute("""
            UPDATE bronze.batch_log 
            SET status = 'FAILED'
            WHERE batch_number = %s;
    """, (batch_number,))
        
        conn.commit()



