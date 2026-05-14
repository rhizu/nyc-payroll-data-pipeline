INSERT INTO silver.nyc_payroll (
fiscal_year, 
agency_name, 
last_name, 
first_name, 
mid_init, 
agency_start_date, 
work_location_borough, 
title_description, 
leave_status, 
base_salary, pay_basis, 
regular_hours, 
regular_gross_paid, 
ot_hours, 
total_ot_paid, 
total_other_pay, 
batch_number
)

WITH cleaned_data AS (
    SELECT
        NULLIF(TRIM(fiscal_year), '')::INT AS fiscal_year, 

        LOWER(NULLIF(TRIM(agency_name), '')) AS agency_name, 

        NULLIF(
        LOWER(TRIM(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
                    TRIM(last_name),
                    '\s+', ' ', 'g'
                ),
                '(jr|sr)\.?$', '', 'i'
            ),
            '[^a-zA-Z\s]', '', 'g'
        )
    )),
    ''
) AS last_name,

        NULLIF(
        LOWER(TRIM(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
                    TRIM(first_name),
                    '\s+', ' ', 'g'
                ),
                '(jr|sr)\.?$', '', 'i'
            ),
            '[^a-zA-Z\s]', '', 'g'
        )
    )),
    ''
) AS first_name,

        LOWER(NULLIF(TRIM(mid_init), '')) AS mid_init,

        NULLIF(TRIM(agency_start_date), '')::DATE AS agency_start_date, 

        LOWER(NULLIF(TRIM(work_location_borough), '')) AS work_location_borough,

        LOWER(REGEXP_REPLACE(NULLIF(TRIM(title_description), ''),'[^A-Za-z0-9 ]', '', 'g')) AS title_description,

        LOWER(NULLIF(TRIM(leave_status_as_of_june_30), '')) AS leave_status, 

        NULLIF(TRIM(REPLACE(REPLACE(base_salary, '$', ''), ',', '')), '')::FLOAT AS base_salary, 

        LOWER(NULLIF(TRIM(pay_basis), '')) AS pay_basis, 

        NULLIF(TRIM(REPLACE(regular_hours, ',', '')), '')::FLOAT AS regular_hours,

        NULLIF(TRIM(REPLACE(REPLACE(regular_gross_paid, '$', ''), ',', '')), '')::FLOAT AS regular_gross_paid, 

        NULLIF(TRIM(REPLACE(ot_hours, ',', '')), '')::FLOAT AS ot_hours,

        NULLIF(TRIM(REPLACE(REPLACE(total_ot_paid, '$', ''), ',', '')), '')::FLOAT AS total_ot_paid, 

        NULLIF(TRIM(REPLACE(REPLACE(total_other_pay, '$', ''), ',', '')), '')::FLOAT AS total_other_pay,

        batch_number
    FROM bronze.nyc_payroll
    WHERE batch_number > (
    SELECT last_batch_processed
    FROM silver.pipeline_metadata
    WHERE pipeline_name = 'bronze_to_silver')
),

deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
        PARTITION BY 
        fiscal_year,
        agency_name,
        first_name,
        last_name,
        mid_init,
        agency_start_date,
        work_location_borough,
        title_description,
        base_salary,
        pay_basis
        ORDER BY batch_number DESC
        ) AS rn
    FROM cleaned_data
)

SELECT
    fiscal_year,
    agency_name,
    last_name,
    first_name,
    mid_init,
    agency_start_date,
    work_location_borough,
    title_description,

    CASE
        WHEN leave_status IN ('on leave', 'on separation leave') THEN 'on leave'
        WHEN leave_status = 'active' THEN 'active'
        WHEN leave_status = 'ceased' THEN 'inactive'
        WHEN leave_status = 'seasonal' THEN 'seasonal'
        ELSE 'unknown'
    END AS leave_status,

    base_salary,
    pay_basis,
    regular_hours,
    regular_gross_paid,
    ot_hours,
    total_ot_paid,
    total_other_pay,
    batch_number

FROM deduped
WHERE rn = 1
AND NOT (first_name IS NULL AND last_name IS NULL)
AND (mid_init IS NULL OR mid_init ~ '^[A-Za-z]$')
AND (
    agency_start_date IS NULL OR
    EXTRACT(YEAR FROM agency_start_date) <= fiscal_year
)
AND base_salary >= 0
AND regular_hours >= 0
AND regular_gross_paid >= 0
AND ot_hours >= 0
AND total_ot_paid >= 0
AND total_other_pay >= 0
