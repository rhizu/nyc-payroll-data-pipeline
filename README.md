# 🚀 NYC Payroll Data Pipeline & Analytics

An end-to-end data engineering project built on the New York City payroll dataset, focused on designing a scalable ETL pipeline and transforming raw data into actionable insights.

This project implements a modern data stack approach using a Medallion Architecture (Bronze → Silver → Gold) to ensure clean, reliable, and analytics-ready data.

## 🔧 What this project does
Ingests raw payroll data from CSV into the Bronze layer
Performs data cleaning, validation, and transformation in the Silver layer
Builds aggregated, business-ready datasets in the Gold layer
Enables analytical insights into workforce trends, salaries, and overtime patterns

## 🧱 Architecture Overview
- **Bronze Layer** → Raw, unprocessed data
- **Silver Layer** → Cleaned and structured data
- **Gold Layer** → Analytical tables and insights

## ⚙️ Tech Stack
- Python 
- SQL (PostgreSQL)
- Apache Airflow (for orchestration)
- Data Modeling (Star Schema)

## 📊 Key Insights Explored
- Overtime trends across agencies
- Salary distribution by job roles
- Workforce distribution by borough
- Employee retention using fiscal year cutoff logic

## 🎯 Why this project?
This project demonstrates:

- Strong understanding of ETL pipeline design
- Hands-on experience with data warehousing concepts
- Ability to turn raw data into meaningful business insights

## 📁 Dataset

Based on publicly available payroll data from the New York City government.
