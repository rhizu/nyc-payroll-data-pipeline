CREATE SCHEMA IF NOT EXISTS bronze;

CREATE TABLE IF NOT EXISTS bronze.batch_log (
    batch_number SERIAL PRIMARY KEY,
    registered_at TIMESTAMP NOT NULL DEFAULT NOW(),
    source_file TEXT NOT NULL,
    row_count INT,
    status TEXT NOT NULL DEFAULT 'IN_PROGRESS'
);

CREATE TABLE IF NOT EXISTS bronze.nyc_payroll (
    fiscal_year VARCHAR NULL,
    agency_name VARCHAR NULL,
    last_name VARCHAR NULL,
    first_name VARCHAR NULL,
    mid_init VARCHAR NULL,
    agency_start_date VARCHAR NULL,
    work_location_borough VARCHAR NULL,
    title_description VARCHAR NULL,
    leave_status_as_of_june_30 VARCHAR NULL,
    base_salary VARCHAR NULL,
    pay_basis VARCHAR NULL,
    regular_hours VARCHAR NULL,
    regular_gross_paid VARCHAR NULL,
    ot_hours VARCHAR NULL,
    total_ot_paid VARCHAR NULL,
    total_other_pay VARCHAR NULL,
    batch_number INT NOT NULL
);