import psycopg2

#Connect to Database

def get_connection():
    conn = psycopg2.connect(
    host = "postgres",
    database = "nyc_payroll_db",
    user = "airflow",
    password = "airflow",
    )
    print("Connection successful!")
    return conn