INSERT INTO gold.dim_agency (agency_name)
SELECT DISTINCT COALESCE(agency_name, 'unknown')
FROM silver.nyc_payroll s
WHERE NOT EXISTS (
    SELECT 1 FROM gold.dim_agency d
    WHERE d.agency_name = COALESCE(s.agency_name, 'unknown')
);

INSERT INTO gold.dim_title (title_description)
SELECT DISTINCT COALESCE(title_description, 'unknown')
FROM silver.nyc_payroll s
WHERE NOT EXISTS (
    SELECT 1 FROM gold.dim_title d
    WHERE d.title_description = COALESCE(s.title_description, 'unknown')
);

INSERT INTO gold.dim_location (work_location_borough)
SELECT DISTINCT COALESCE(work_location_borough, 'unknown')
FROM silver.nyc_payroll s
WHERE NOT EXISTS (
    SELECT 1 FROM gold.dim_location d
    WHERE d.work_location_borough = COALESCE(s.work_location_borough, 'unknown')
);

INSERT INTO gold.dim_pay_basis (pay_basis)
SELECT DISTINCT COALESCE(pay_basis, 'unknown')
FROM silver.nyc_payroll s
WHERE NOT EXISTS (
    SELECT 1 FROM gold.dim_pay_basis d
    WHERE d.pay_basis = COALESCE(s.pay_basis, 'unknown')
);

INSERT INTO gold.dim_date (fiscal_year)
SELECT DISTINCT fiscal_year
FROM silver.nyc_payroll s
WHERE NOT EXISTS (
    SELECT 1 FROM gold.dim_date d
    WHERE d.fiscal_year = s.fiscal_year
);

INSERT INTO gold.dim_employee (
    first_name,
    last_name,
    mid_init,
    agency_start_date,
    current_leave_status
)

SELECT
    first_name,
    last_name,
    mid_init,
    agency_start_date,
    current_leave_status

FROM (

    SELECT

        COALESCE(NULLIF(first_name, ''), 'unknown') AS first_name,

        COALESCE(NULLIF(last_name, ''), 'unknown') AS last_name,

        COALESCE(NULLIF(mid_init, ''), 'unknown') AS mid_init,

        agency_start_date,

        COALESCE(NULLIF(leave_status, ''), 'unknown')
            AS current_leave_status,

        ROW_NUMBER() OVER (
            PARTITION BY
                COALESCE(NULLIF(first_name, ''), 'unknown'),
                COALESCE(NULLIF(last_name, ''), 'unknown'),
                COALESCE(NULLIF(mid_init, ''), 'unknown'),
                agency_start_date
            ORDER BY batch_number DESC
        ) AS rn

    FROM silver.nyc_payroll

) t

WHERE rn = 1

ON CONFLICT (
    first_name,
    last_name,
    mid_init,
    agency_start_date
)
DO NOTHING;

INSERT INTO gold.fact_payroll (
    employee_key,
    agency_key,
    title_key,
    location_key,
    pay_basis_key,
    date_key,
    base_salary,
    regular_hours,
    regular_gross_paid,
    ot_hours,
    total_ot_paid,
    total_other_pay,
    dwh_total_pay,
    batch_number
)
SELECT

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
    COALESCE(s.regular_gross_paid, 0) + COALESCE(s.total_ot_paid, 0) + COALESCE(s.total_other_pay, 0) AS dwh_total_pay,
    s.batch_number

FROM silver.nyc_payroll s

JOIN gold.dim_employee de
ON COALESCE(s.first_name,'unknown') = de.first_name
AND COALESCE(s.last_name,'unknown') = de.last_name
AND COALESCE(s.mid_init,'unknown') = de.mid_init
AND s.agency_start_date = de.agency_start_date

JOIN gold.dim_agency da
ON COALESCE(s.agency_name,'unknown') = da.agency_name

JOIN gold.dim_title dt
ON COALESCE(s.title_description,'unknown') = dt.title_description

JOIN gold.dim_location dl
ON COALESCE(s.work_location_borough,'unknown') = dl.work_location_borough

JOIN gold.dim_pay_basis dp
ON COALESCE(s.pay_basis,'unknown') = dp.pay_basis

JOIN gold.dim_date dd
ON s.fiscal_year = dd.fiscal_year

WHERE s.batch_number > %s
ON CONFLICT (
    employee_key,
    agency_key,
    title_key,
    location_key,
    pay_basis_key,
    date_key,
    batch_number
)
DO NOTHING;