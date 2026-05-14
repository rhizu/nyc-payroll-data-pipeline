CREATE SCHEMA IF NOT EXISTS gold;

-- =========================================
-- DIMENSION VIEWS
-- =========================================

CREATE OR REPLACE VIEW gold.dim_employee AS
SELECT DISTINCT
    ROW_NUMBER() OVER () AS employee_key,

    COALESCE(first_name, 'unknown') AS first_name,
    COALESCE(last_name, 'unknown') AS last_name,
    COALESCE(mid_init, 'unknown') AS mid_init,

    agency_start_date,

    COALESCE(leave_status, 'unknown') AS current_leave_status

FROM silver.nyc_payroll;

------------------------------------------------

CREATE OR REPLACE VIEW gold.dim_agency AS
SELECT DISTINCT
    ROW_NUMBER() OVER () AS agency_key,

    COALESCE(agency_name, 'unknown') AS agency_name

FROM silver.nyc_payroll;

------------------------------------------------

CREATE OR REPLACE VIEW gold.dim_title AS
SELECT DISTINCT
    ROW_NUMBER() OVER () AS title_key,

    COALESCE(title_description, 'unknown') AS title_description

FROM silver.nyc_payroll;

------------------------------------------------

CREATE OR REPLACE VIEW gold.dim_location AS
SELECT DISTINCT
    ROW_NUMBER() OVER () AS location_key,

    COALESCE(work_location_borough, 'unknown')
    AS work_location_borough

FROM silver.nyc_payroll;

------------------------------------------------

CREATE OR REPLACE VIEW gold.dim_pay_basis AS
SELECT DISTINCT
    ROW_NUMBER() OVER () AS pay_basis_key,

    COALESCE(pay_basis, 'unknown') AS pay_basis

FROM silver.nyc_payroll;

------------------------------------------------

CREATE OR REPLACE VIEW gold.dim_date AS
SELECT DISTINCT
    ROW_NUMBER() OVER () AS date_key,

    fiscal_year

FROM silver.nyc_payroll;

-- =========================================
-- FACT VIEW
-- =========================================

CREATE OR REPLACE VIEW gold.fact_payroll AS

SELECT

    ROW_NUMBER() OVER () AS payroll_fact_key,

    de.employee_key,
    da.agency_key,
    dt.title_key,
    dl.location_key,
    dp.pay_basis_key,
    dd.date_key,

    s.base_salary,
    s.regular_hours,
    s.regular_gross_paid,
    s.ot_hours,
    s.total_ot_paid,
    s.total_other_pay,

    s.batch_number,

    NOW() AS processed_at

FROM silver.nyc_payroll s

JOIN gold.dim_employee de
ON COALESCE(s.first_name, 'unknown') = de.first_name
AND COALESCE(s.last_name, 'unknown') = de.last_name
AND COALESCE(s.mid_init, 'unknown') = de.mid_init
AND s.agency_start_date IS NOT DISTINCT FROM de.agency_start_date

JOIN gold.dim_agency da
ON COALESCE(s.agency_name, 'unknown')
   = da.agency_name

JOIN gold.dim_title dt
ON COALESCE(s.title_description, 'unknown')
   = dt.title_description

JOIN gold.dim_location dl
ON COALESCE(s.work_location_borough, 'unknown')
   = dl.work_location_borough

JOIN gold.dim_pay_basis dp
ON COALESCE(s.pay_basis, 'unknown')
   = dp.pay_basis

JOIN gold.dim_date dd
ON s.fiscal_year = dd.fiscal_year;