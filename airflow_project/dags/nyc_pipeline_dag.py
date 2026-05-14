import sys
import os
sys.path.append("/opt/airflow/project")

from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator

from database.postgresql import get_connection
from etl.bronze.load_bronze import load_bronze_layer
from etl.bronze.load_bronze import initialize_bronze_layer
from etl.silver.load_silver import load_silver_layer
from etl.silver.load_silver import initialize_silver_layer
from etl.gold.load_gold import load_gold_layer
from etl.gold.load_gold import initialize_gold_layer 


# -----------------------------
# Task functions
# -----------------------------

def run_bronze():
    conn = get_connection()
    cur = conn.cursor()

    try:
        initialize_bronze_layer(conn, cur)
        load_bronze_layer(conn, cur)

    finally:
        cur.close()
        conn.close()


def run_silver():
    conn = get_connection()
    cur = conn.cursor()

    try:
        initialize_silver_layer(conn, cur)
        load_silver_layer(conn, cur)

    finally:
        cur.close()
        conn.close()


def run_gold():
    conn = get_connection()
    cur = conn.cursor()

    try:
        initialize_gold_layer(conn, cur)
        load_gold_layer(conn, cur)

    finally:
        cur.close()
        conn.close()


# -----------------------------
# DAG Configuration
# -----------------------------

default_args = {
    "owner": "Rhizu",
    "depends_on_past": False,
}


with DAG(
    dag_id="nyc_payroll_pipeline",
    default_args=default_args,
    description="NYC Payroll ETL Pipeline using Bronze Silver Gold architecture",
    start_date=datetime(2026, 5, 14),
    schedule="@daily",
    catchup=False,
    tags=["NYC", "Payroll", "ETL"],
) as dag:

    bronze_task = PythonOperator(
        task_id="bronze_layer",
        python_callable=run_bronze
    )

    silver_task = PythonOperator(
        task_id="silver_layer",
        python_callable=run_silver
    )

    gold_task = PythonOperator(
        task_id="gold_layer",
        python_callable=run_gold
    )

    # Pipeline flow
    bronze_task >> silver_task >> gold_task