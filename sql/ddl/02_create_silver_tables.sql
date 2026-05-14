CREATE SCHEMA IF NOT EXISTS silver;

CREATE TABLE IF NOT EXISTS silver.pipeline_metadata (
    pipeline_name TEXT PRIMARY KEY,
    last_batch_processed INT NOT NULL DEFAULT 0,
    updated_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO silver.pipeline_metadata (
    pipeline_name,
    last_batch_processed
)
VALUES
    ('bronze_to_silver', 0)
ON CONFLICT (pipeline_name)
DO NOTHING;


CREATE TABLE IF NOT EXISTS silver.nyc_payroll (
    fiscal_year INT NULL,
    agency_name VARCHAR(100) NULL,
    last_name VARCHAR(50) NULL,
    first_name VARCHAR(50) NULL,
    mid_init VARCHAR(10) NULL,
    agency_start_date DATE NULL,
    work_location_borough VARCHAR(50) NULL,
    title_description VARCHAR(100) NULL,
    leave_status VARCHAR(20) NULL,
    base_salary FLOAT NULL,
    pay_basis VARCHAR(20) NULL,
    regular_hours FLOAT NULL,
    regular_gross_paid FLOAT NULL,
    ot_hours FLOAT NULL,
    total_ot_paid FLOAT NULL,
    total_other_pay FLOAT NULL,
    batch_number INT NULL
);
