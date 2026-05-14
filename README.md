# 🚀 NYC Payroll Data Pipeline & Analytics

An end-to-end data engineering project built on the New York City payroll dataset, focused on designing a scalable ETL pipeline and transforming raw data into actionable insights.

This project implements a modern data stack approach using a Medallion Architecture (Bronze → Silver → Gold) to ensure clean, reliable, and analytics-ready data.

## 🔧 What this project does
Ingests raw payroll data from CSV into the Bronze layer
Performs data cleaning, validation, and transformation in the Silver layer
Builds aggregated, business-ready datasets in the Gold layer
Enables analytical insights into workforce trends, salaries, and overtime patterns

## 🧱 Architecture Overview
<img width="1181" height="652" alt="image" src="https://github.com/user-attachments/assets/4ffbca2f-e0c0-49d1-abb6-f1fc34497830" />

- **Bronze Layer** → Raw, unprocessed data
- **Silver Layer** → Cleaned and structured data
- **Gold Layer** → Analytical tables and insights

## ⚙️ Tech Stack
- Python 
- SQL (PostgreSQL)
- Apache Airflow (for orchestration)
- Docker
- Data Modeling (Star Schema)

## Steps to R
Step 1 — Clone Repository
git clone https://github.com/rhizu/nyc-payroll-data-pipeline.git

Move into the project folder:

cd nyc-payroll-data-pipeline
Step 2 — Add Dataset

Download the NYC Payroll dataset and place it inside:

data/

Example:

data/nyc_payroll_data.csv
Step 3 — Start Docker Containers

Run:

docker-compose up -d

This starts:

PostgreSQL container
Airflow container(s)

Verify running containers:

docker ps
Step 4 — Access Airflow

Open browser:

http://localhost:8080

Default credentials:

Username: airflow
Password: airflow
Step 5 — Trigger the DAG

Inside Airflow:

Locate the DAG
Enable the DAG toggle
Click Trigger DAG

The pipeline executes in this order:

Bronze Layer
    ↓
Silver Layer
    ↓
Gold Layer
Step 6 — Verify PostgreSQL Tables

Connect to PostgreSQL container:

docker exec -it <postgres_container_name> psql -U postgres -d nyc_payroll_db

List schemas:

\dn

List tables:

\dt gold.*

Example query:

SELECT * FROM gold.fact_payroll LIMIT 10;
Step 7 — Connect Power BI

In Microsoft Power BI:

Get Data → PostgreSQL
Connect to:
Server: localhost
Port: 5432
Database: nyc_payroll_db

Load Gold layer tables for visualization.

## 📊 Key Insights Explored
- Overtime trends across agencies
- Salary distribution by job roles
- Workforce distribution by borough
- Employee retention using fiscal year cutoff logic

## 🎯 How to Rub?


## 📁 Dataset

Based on publicly available payroll data from the New York City government.
