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

---


# 🚀 How to Run the Project

## 1️⃣ Clone Repository

```bash
git clone https://github.com/rhizu/nyc-payroll-data-pipeline.git
```

Move into project directory:

```bash
cd nyc-payroll-data-pipeline
```

---

## 2️⃣ Add Dataset

Download the NYC Payroll CSV dataset and place it inside:

```text
data/
```

Example:

```text
data/nyc_payroll_data.csv
```

---

## 3️⃣ Start Docker Containers

Run:

```bash
docker-compose up -d
```

Verify containers:

```bash
docker ps
```

---

## 4️⃣ Open Airflow

Open browser:

```text
http://localhost:8080
```

Default Login:

```text
Username: airflow
Password: airflow
```

---

## 5️⃣ Execute Pipeline

Inside Airflow:

1. Enable the DAG
2. Trigger the DAG

Execution Flow:

```text
Bronze Layer
    ↓
Silver Layer
    ↓
Gold Layer
```

---

## 6️⃣ Verify PostgreSQL Tables

Connect to PostgreSQL container:

```bash
docker exec -it <postgres_container_name> psql -U postgres -d nyc_payroll_db
```

View Gold tables:

```sql
\dt gold.*
```

Run sample query:

```sql
SELECT * FROM gold.fact_payroll LIMIT 10;
```

---

## 7️⃣ Connect Power BI

In Power BI:

1. Get Data → PostgreSQL
2. Connect using:

```text
Server: localhost
Port: 5432
Database: nyc_payroll_db
```

Load Gold layer tables for visualization.

---

## 📊 Key Insights Explored
- Overtime trends across agencies
- Salary distribution by job roles
- Workforce distribution by borough
- Employee retention using fiscal year cutoff logic

## 📁 Dataset

https://www.kaggle.com/datasets/new-york-city/nyc-citywide-payroll-data
