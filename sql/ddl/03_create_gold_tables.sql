CREATE SCHEMA IF NOT EXISTS gold;

CREATE TABLE IF NOT EXISTS gold.pipeline_metadata (
    pipeline_name TEXT PRIMARY KEY,
    updated_at TIMESTAMP DEFAULT NOW(),
    last_batch_processed INT
);

INSERT INTO gold.pipeline_metadata (
    pipeline_name,
    last_batch_processed
)
VALUES
    ('silver_to_gold', 0)
ON CONFLICT (pipeline_name)
DO NOTHING;

CREATE TABLE IF NOT EXISTS gold.dim_employee (
    employee_key BIGSERIAL PRIMARY KEY,
    first_name VARCHAR,
    last_name VARCHAR,
    mid_init VARCHAR,
    agency_start_date DATE,
    current_leave_status VARCHAR,
    UNIQUE(first_name, last_name, mid_init, agency_start_date)
);

CREATE TABLE IF NOT EXISTS gold.dim_agency (
    agency_key BIGSERIAL PRIMARY KEY,
    agency_name VARCHAR UNIQUE
);

CREATE TABLE IF NOT EXISTS gold.dim_title (
    title_key BIGSERIAL PRIMARY KEY,
    title_description VARCHAR UNIQUE
);

CREATE TABLE IF NOT EXISTS gold.dim_location (
    location_key BIGSERIAL PRIMARY KEY,
    work_location_borough VARCHAR UNIQUE
);

CREATE TABLE IF NOT EXISTS gold.dim_pay_basis (
    pay_basis_key BIGSERIAL PRIMARY KEY,
    pay_basis VARCHAR UNIQUE
);

CREATE TABLE IF NOT EXISTS gold.dim_date (
    date_key BIGSERIAL PRIMARY KEY,
    fiscal_year INT UNIQUE
);

CREATE TABLE IF NOT EXISTS gold.fact_payroll (
    payroll_fact_key BIGSERIAL PRIMARY KEY,

    employee_key BIGINT,
    agency_key BIGINT,
    title_key BIGINT,
    location_key BIGINT,
    pay_basis_key BIGINT,
    date_key BIGINT,

    base_salary NUMERIC(12,2),
    regular_hours NUMERIC(12,2),
    regular_gross_paid NUMERIC(12,2),
    ot_hours NUMERIC(12,2),
    total_ot_paid NUMERIC(12,2),
    total_other_pay NUMERIC(12,2),
    dwh_total_pay NUMERIC(14,2),

    batch_number INT,
    processed_at TIMESTAMP DEFAULT NOW(),

    CONSTRAINT fk_employee
        FOREIGN KEY (employee_key)
        REFERENCES gold.dim_employee(employee_key),

    CONSTRAINT fk_agency
        FOREIGN KEY (agency_key)
        REFERENCES gold.dim_agency(agency_key),

    CONSTRAINT fk_title
        FOREIGN KEY (title_key)
        REFERENCES gold.dim_title(title_key),

    CONSTRAINT fk_location
        FOREIGN KEY (location_key)
        REFERENCES gold.dim_location(location_key),

    CONSTRAINT fk_pay_basis
        FOREIGN KEY (pay_basis_key)
        REFERENCES gold.dim_pay_basis(pay_basis_key),

    CONSTRAINT fk_date
        FOREIGN KEY (date_key)
        REFERENCES gold.dim_date(date_key),

    UNIQUE (
        employee_key,
        agency_key,
        title_key,
        location_key,
        pay_basis_key,
        date_key,
        batch_number
    )
);