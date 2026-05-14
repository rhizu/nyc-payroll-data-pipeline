from src.utils.sql_utils import read_sql_files

def initialize_gold_layer(conn, cur):
    gold_ddl_query = read_sql_files("/opt/airflow/project/sql/ddl/03_create_gold_tables.sql")
    cur.execute(gold_ddl_query)

    conn.commit()
    print("Gold layer initialized successfully.")

def load_gold_layer(conn, cur):

    try:
        # 1. Get last processed batch
        cur.execute("""
            SELECT last_batch_processed
            FROM gold.pipeline_metadata
            WHERE pipeline_name = 'silver_to_gold'
        """)
        last_batch = cur.fetchone()[0]

        # 2. Run incremental load
        gold_dml_query = read_sql_files("/opt/airflow/project/sql/dml/03_load_gold_tables.sql")
        cur.execute(gold_dml_query, (last_batch,))

        # 3. Update metadata
        cur.execute("""
            UPDATE gold.pipeline_metadata
            SET last_batch_processed = (
                SELECT COALESCE(MAX(batch_number), %s)
                FROM silver.nyc_payroll
            ),
            updated_at = NOW()
            WHERE pipeline_name = 'silver_to_gold'
        """, (last_batch,))

        conn.commit()
        print("Gold layer loaded incrementally.")

    except Exception as e:
        conn.rollback()
        print("Gold load failed:", e)