/*========================================================
                DATA PROFILING & QUALITY CHECKS
                    NYC PAYROLL DATASET
==========================================================*/

----------------------------------------------------------
-- 1. GENERAL NULL VALUE CHECKS
----------------------------------------------------------

-- Expectation: No critical business columns should contain NULL values
SELECT *
FROM bronze.nyc_payroll
WHERE fiscal_year = ''
   OR title_description = ''
   OR agency_name = ''
   OR first_name = ''
   OR last_name = ''
   OR base_salary = ''
   OR pay_basis = ''
   OR work_location_borough = '';


/*========================================================
                    FISCAL YEAR CHECKS
==========================================================*/

----------------------------------------------------------
-- Range Check
----------------------------------------------------------

SELECT *
FROM bronze.nyc_payroll
WHERE fiscal_year < '2014';


----------------------------------------------------------
-- Length Check
----------------------------------------------------------

SELECT *
FROM bronze.nyc_payroll
WHERE LENGTH(fiscal_year) > 4;


----------------------------------------------------------
-- Numeric Format Check
----------------------------------------------------------

SELECT *
FROM bronze.nyc_payroll
WHERE fiscal_year !~ '^[0-9]+$';


----------------------------------------------------------
-- Consistency Check
----------------------------------------------------------

SELECT DISTINCT fiscal_year
FROM bronze.nyc_payroll;


----------------------------------------------------------
-- Distribution / Duplicate Trend Check
----------------------------------------------------------

SELECT fiscal_year,
       COUNT(*) AS total_records
FROM bronze.nyc_payroll
GROUP BY fiscal_year
ORDER BY fiscal_year;


----------------------------------------------------------
-- Fiscal Year Validation Classification
----------------------------------------------------------

SELECT fiscal_year,
       CASE
           WHEN fiscal_year IS NULL THEN 'NULL'

           WHEN fiscal_year !~ '^[0-9]{4}$'
           THEN 'INVALID_FORMAT'

           WHEN fiscal_year::INT < 1900
             OR fiscal_year::INT > 2100
           THEN 'OUT_OF_RANGE'

           ELSE 'VALID'
       END AS fiscal_year_check
FROM bronze.nyc_payroll;



/*========================================================
                    AGENCY NAME CHECKS
==========================================================*/

----------------------------------------------------------
-- Distinct Agency Names
----------------------------------------------------------

SELECT DISTINCT agency_name
FROM bronze.nyc_payroll;


----------------------------------------------------------
-- Empty String Check
----------------------------------------------------------

SELECT *
FROM bronze.nyc_payroll
WHERE agency_name = '';


----------------------------------------------------------
-- Leading / Trailing Space Check
----------------------------------------------------------

SELECT agency_name
FROM bronze.nyc_payroll
WHERE agency_name != TRIM(agency_name);


----------------------------------------------------------
-- Case Standardization Check
----------------------------------------------------------

SELECT LOWER(agency_name) AS normalized_agency_name,
       COUNT(*)
FROM bronze.nyc_payroll
GROUP BY LOWER(agency_name)
ORDER BY COUNT(*) DESC;



/*========================================================
                FIRST NAME / LAST NAME CHECKS
==========================================================*/

----------------------------------------------------------
-- Empty Name Check
----------------------------------------------------------

SELECT *
FROM bronze.nyc_payroll
WHERE first_name = ''
   OR last_name = '';


----------------------------------------------------------
-- Leading / Trailing Spaces
----------------------------------------------------------

SELECT first_name
FROM bronze.nyc_payroll
WHERE first_name != TRIM(first_name);

SELECT last_name
FROM bronze.nyc_payroll
WHERE last_name != TRIM(last_name);


----------------------------------------------------------
-- Single Character Name Check
----------------------------------------------------------

SELECT first_name
FROM bronze.nyc_payroll
WHERE LENGTH(first_name) = 1;

SELECT last_name
FROM bronze.nyc_payroll
WHERE LENGTH(last_name) = 1;


----------------------------------------------------------
-- Invalid Character Check
----------------------------------------------------------

SELECT first_name
FROM bronze.nyc_payroll
WHERE first_name !~ '[A-Za-z]$';


----------------------------------------------------------
-- Missing First or Last Name Check
----------------------------------------------------------

SELECT first_name,
       last_name
FROM bronze.nyc_payroll
WHERE first_name = ''
  AND last_name != '';

SELECT first_name,
       last_name
FROM bronze.nyc_payroll
WHERE last_name = ''
  AND first_name != '';



/*========================================================
                    MIDDLE INITIAL CHECKS
==========================================================*/

----------------------------------------------------------
-- Empty Middle Initial Check
----------------------------------------------------------

SELECT mid_init
FROM bronze.nyc_payroll
WHERE mid_init = '';


----------------------------------------------------------
-- Distinct Middle Initial Values
----------------------------------------------------------

SELECT DISTINCT mid_init
FROM bronze.nyc_payroll;



/*========================================================
                AGENCY START DATE CHECKS
==========================================================*/

----------------------------------------------------------
-- NULL / Empty Date Check
----------------------------------------------------------

SELECT *
FROM bronze.nyc_payroll
WHERE agency_start_date = ''
   OR agency_start_date IS NULL;


----------------------------------------------------------
-- Logical Date Validation
-- Start year should not exceed fiscal year
----------------------------------------------------------

SELECT agency_start_date,
       fiscal_year
FROM bronze.nyc_payroll
WHERE EXTRACT(YEAR FROM agency_start_date::DATE)
      > fiscal_year::INT;

SELECT d.agency_name, ROUND(SUM(dwh_total_pay), 2) as total_pay
FROM gold.fact_payroll f
JOIN gold.dim_agency d ON d.agency_key = f.agency_key
GROUP BY d.agency_name
ORDER BY total_pay DESC
LIMIT 1;

SELECT
    pb.pay_basis,
    ROUND(SUM(fp.base_salary), 2) AS total_salary
FROM gold.fact_payroll fp
JOIN gold.dim_pay_basis pb
    ON fp.pay_basis_key = pb.pay_basis_key
GROUP BY pb.pay_basis
ORDER BY total_salary DESC;

SELECT * FROM bronze.nyc_payroll
LIMIT 1;

SELECT
    COUNT(DISTINCT employee_key) AS workforce_size
FROM gold.fact_payroll;

SELECT
    ROUND(SUM(total_ot_paid), 2) AS total_ot_cost
FROM gold.fact_payroll;

SELECT
    ROUND(SUM(dwh_total_pay), 2) AS total_payroll
FROM gold.fact_payroll;

SELECT 
    ROUND(AVG(base_salary), 2) AS average_employee_salary
FROM gold.fact_payroll;

--highest payroll spending agency
SELECT d.work_location_borough, ROUND(SUM(f.dwh_total_pay), 2) AS total_payroll
FROM gold.fact_payroll f
JOIN gold.dim_location d ON f.location_key = d.location_key
GROUP BY d.work_location_borough
ORDER BY total_payroll DESC
LIMIT 10;

SELECT d.fiscal_year, ROUND(SUM(dwh_total_pay), 2) AS yearly_payroll
FROM gold.fact_payroll f
JOIN gold.dim_date d ON d.date_key = f.date_key
GROUP BY d.fiscal_year
ORDER BY d.fiscal_year;

--overtime trend over years
SELECT d.fiscal_year, ROUND(SUM(f.total_ot_paid), 2) AS yearly_ot
FROM gold.fact_payroll f 
JOIN gold.dim_date d ON f.date_key = d.date_key
GROUP BY d.fiscal_year
ORDER BY d.fiscal_year;

SELECT d.fiscal_year, COUNT(employee_key) AS workforce_size
FROM gold.fact_payroll f 
JOIN gold.dim_date d ON f.date_key = d.date_key
GROUP BY d.fiscal_year
ORDER BY d.fiscal_year;

/*========================================================
                WORK LOCATION CHECKS
==========================================================*/

----------------------------------------------------------
-- NULL Borough Check
----------------------------------------------------------

SELECT work_location_borough
FROM bronze.nyc_payroll
WHERE work_location_borough IS NULL;


----------------------------------------------------------
-- Distinct Borough Values
----------------------------------------------------------

SELECT DISTINCT work_location_borough
FROM bronze.nyc_payroll;


----------------------------------------------------------
-- Leading / Trailing Space Check
----------------------------------------------------------

SELECT work_location_borough
FROM bronze.nyc_payroll
WHERE work_location_borough != TRIM(work_location_borough);



/*========================================================
                TITLE DESCRIPTION CHECKS
==========================================================*/

----------------------------------------------------------
-- Distinct Title Descriptions
----------------------------------------------------------

SELECT DISTINCT title_description
FROM bronze.nyc_payroll;


----------------------------------------------------------
-- NULL / Empty Title Check
----------------------------------------------------------

SELECT title_description
FROM bronze.nyc_payroll
WHERE title_description = ''
   OR title_description IS NULL;



/*========================================================
            LEAVE STATUS CONSISTENCY CHECKS
==========================================================*/

SELECT DISTINCT leave_status_as_of_june_30
FROM bronze.nyc_payroll;



/*========================================================
                    BASE SALARY CHECKS
==========================================================*/

----------------------------------------------------------
-- NULL / Empty Salary Check
----------------------------------------------------------

SELECT base_salary
FROM bronze.nyc_payroll
WHERE base_salary IS NULL
   OR base_salary = '';


----------------------------------------------------------
-- Salary Validation Classification
----------------------------------------------------------

SELECT base_salary,
       CASE
           WHEN base_salary IS NULL THEN 'NULL'

           WHEN NULLIF(
                    TRIM(
                        REPLACE(
                            REPLACE(base_salary, '$', ''),
                            ',', ''
                        )
                    ),
                    ''
                ) !~ '^[0-9]+(\.[0-9]+)?$'
           THEN 'NOT_NUMERIC'

           ELSE 'VALID'
       END AS base_salary_check
FROM bronze.nyc_payroll;



SELECT regular_gross_paid
FROM bronze.nyc_payroll
WHERE REPLACE(REPLACE(regular_gross_paid,'$',''),',','')
      !~ '^[0-9]+(\.[0-9]+)?$';

SELECT total_ot_paid
FROM bronze.nyc_payroll
WHERE REPLACE(REPLACE(total_ot_paid,'$',''),',','')
      !~ '^[0-9]+(\.[0-9]+)?$';

SELECT total_other_pay
FROM bronze.nyc_payroll
WHERE REPLACE(REPLACE(total_other_pay,'$',''),',','')
      !~ '^[0-9]+(\.[0-9]+)?$';
	  
SELECT regular_gross_paid
FROM silver.nyc_payroll
WHERE regular_gross_paid < 0

select * from silver.nyc_payroll
LIMIT 1;

----------------------------------------------------------
-- Negative Salary Check
----------------------------------------------------------

SELECT base_salary
FROM bronze.nyc_payroll
WHERE TRIM(
          REPLACE(
              REPLACE(base_salary, '$', ''),
              ',', ''
          )
      )::FLOAT < 0;



/*========================================================
                    PAY BASIS CHECKS
==========================================================*/

----------------------------------------------------------
-- Distinct Pay Basis Values
----------------------------------------------------------

SELECT DISTINCT pay_basis
FROM bronze.nyc_payroll;


----------------------------------------------------------
-- Leading / Trailing Spaces
----------------------------------------------------------

SELECT DISTINCT pay_basis
FROM bronze.nyc_payroll
WHERE pay_basis != TRIM(pay_basis);


----------------------------------------------------------
-- NULL / Empty Pay Basis
----------------------------------------------------------

SELECT pay_basis
FROM bronze.nyc_payroll
WHERE pay_basis IS NULL
   OR pay_basis = '';



/*========================================================
                REGULAR HOURS CHECKS
==========================================================*/

----------------------------------------------------------
-- Negative Hours Check
----------------------------------------------------------

SELECT regular_hours
FROM bronze.nyc_payroll
WHERE regular_hours::FLOAT < 0;


----------------------------------------------------------
-- Regular Hours Validation
----------------------------------------------------------

SELECT regular_hours,
       CASE
           WHEN regular_hours IS NULL THEN 'NULL'

           WHEN TRIM(regular_hours)::FLOAT < 0
           THEN 'INVALID'

           WHEN TRIM(regular_hours)
                !~ '^[0-9]+(\.[0-9]+)?$'
           THEN 'NON_NUMERIC'

           ELSE 'VALID'
       END AS regular_hours_check
FROM bronze.nyc_payroll;



/*========================================================
            REGULAR GROSS PAID CHECKS
==========================================================*/

----------------------------------------------------------
-- NULL / Empty Check
----------------------------------------------------------

SELECT regular_gross_paid
FROM bronze.nyc_payroll
WHERE regular_gross_paid IS NULL
   OR regular_gross_paid = '';


----------------------------------------------------------
-- Validation Check
----------------------------------------------------------

SELECT regular_gross_paid,
       CASE
           WHEN regular_gross_paid IS NULL THEN 'NULL'

           WHEN TRIM(
                    REPLACE(
                        REPLACE(regular_gross_paid, '$', ''),
                        ',', ''
                    )
                )::FLOAT < 0
           THEN 'INVALID'

           WHEN NULLIF(
                    TRIM(
                        REPLACE(
                            REPLACE(regular_gross_paid, '$', ''),
                            ',', ''
                        )
                    ),
                    ''
                ) !~ '^[0-9]+(\.[0-9]+)?$'
           THEN 'NOT_NUMERIC'

           ELSE 'VALID'
       END AS regular_gross_paid_check
FROM bronze.nyc_payroll;



/*========================================================
                    OVERTIME HOURS CHECKS
==========================================================*/

----------------------------------------------------------
-- NULL / Empty Check
----------------------------------------------------------

SELECT ot_hours
FROM bronze.nyc_payroll
WHERE ot_hours IS NULL
   OR ot_hours = '';


----------------------------------------------------------
-- Negative Overtime Hours
----------------------------------------------------------

SELECT ot_hours
FROM bronze.nyc_payroll
WHERE ot_hours::FLOAT < 0;


----------------------------------------------------------
-- Overtime Hours Validation
----------------------------------------------------------

SELECT ot_hours,
       CASE
           WHEN ot_hours IS NULL THEN 'NULL'

           WHEN ot_hours::FLOAT < 0
           THEN 'INVALID'

           WHEN ot_hours !~ '^[0-9]+(\.[0-9]+)?$'
           THEN 'NOT_NUMERIC'

           ELSE 'VALID'
       END AS ot_hours_check
FROM bronze.nyc_payroll;



/*========================================================
                TOTAL OVERTIME PAY CHECKS
==========================================================*/

----------------------------------------------------------
-- Validation Check
----------------------------------------------------------

SELECT total_ot_paid,
       CASE
           WHEN total_ot_paid IS NULL THEN 'NULL'

           WHEN TRIM(
                    REPLACE(
                        REPLACE(total_ot_paid, '$', ''),
                        ',', ''
                    )
                )::FLOAT < 0
           THEN 'INVALID'

           WHEN NULLIF(
                    TRIM(
                        REPLACE(
                            REPLACE(total_ot_paid, '$', ''),
                            ',', ''
                        )
                    ),
                    ''
                ) !~ '^[0-9]+(\.[0-9]+)?$'
           THEN 'NOT_NUMERIC'

           ELSE 'VALID'
       END AS total_ot_paid_check
FROM bronze.nyc_payroll;


----------------------------------------------------------
-- Overtime Pay Consistency Check
----------------------------------------------------------

SELECT ot_hours,
       total_ot_paid,
       CASE
           WHEN ot_hours::FLOAT = 0
                AND TRIM(
                        REPLACE(
                            REPLACE(total_ot_paid, '$', ''),
                            ',', ''
                        )
                    )::FLOAT > 0
           THEN 'INCONSISTENT'

           WHEN ot_hours::FLOAT > 0
                AND TRIM(
                        REPLACE(
                            REPLACE(total_ot_paid, '$', ''),
                            ',', ''
                        )
                    )::FLOAT = 0
           THEN 'SUSPICIOUS'

           ELSE 'VALID'
       END AS ot_consistency_check
FROM bronze.nyc_payroll;
