from src.utils.sql_utils import read_sql_files

def initialize_silver_layer(conn, cur):
    silver_ddl_query = read_sql_files("/opt/airflow/project/sql/ddl/02_create_silver_tables.sql")
    cur.execute(silver_ddl_query)

    conn.commit()
    print("Silver layer initialized successfully.")

def load_silver_layer(conn, cur):
    try:
        silver_dml_query = read_sql_files("/opt/airflow/project/sql/dml/02_load_silver_tables.sql")

        cur.execute(silver_dml_query)

        # update metadata
        cur.execute("""
            UPDATE silver.pipeline_metadata
            SET last_batch_processed = (
                SELECT COALESCE(MAX(batch_number), 0)
                FROM bronze.nyc_payroll
            ),
            updated_at = NOW()
            WHERE pipeline_name = 'bronze_to_silver';
        """)

        conn.commit()
        print("Silver layer loaded incrementally.")

    except Exception as e:
        conn.rollback()
        print("Silver load failed:", e)