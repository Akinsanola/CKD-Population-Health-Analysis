-- CKD Population Health Analysis | PostgreSQL
-- 03: Exploratory analysis of classified adults
-- Requires kidney_clean view from 01_data_cleaning.sql.
-- Most CKD proportions exclude unknown analytical_ckd_status; additional
-- risk factor analyses also exclude Unknown in the corresponding category.
-- Unweighted sample proportions are not national population prevalence.

--Does the proportion of participants classified with CKD differ across adult age groups?
WITH age_ckd AS (
    SELECT
        age_group,
        COUNT(*) AS known_participants,
        COUNT(
            CASE
                WHEN analytical_ckd_status = 'CKD' THEN 1
            END
        ) AS ckd_cases,
        COUNT(
            CASE
                WHEN analytical_ckd_status = 'No CKD' THEN 1
            END
        ) AS no_ckd
    FROM kidney_clean
    WHERE analytical_ckd_status <> 'Unknown'
    GROUP BY age_group
)
SELECT
    age_group,
    known_participants,
    ckd_cases,
    no_ckd,
    ROUND(
        ckd_cases * 100.0 / known_participants,
        2
    ) AS ckd_proportion
FROM age_ckd;

-- Does CKD proportion differ between male and female participants with known CKD classification?
WITH gender_ckd AS (
    SELECT
        gender,
        COUNT(*) AS known_participants,
        COUNT(
            CASE
                WHEN analytical_ckd_status = 'CKD' THEN 1
            END
        ) AS ckd_cases,
        COUNT(
            CASE
                WHEN analytical_ckd_status = 'No CKD' THEN 1
            END
        ) AS no_ckd
    FROM kidney_clean
    WHERE analytical_ckd_status <> 'Unknown'
    GROUP BY gender
)
SELECT
    gender,
    known_participants,
    ckd_cases,
    no_ckd,
    ROUND(
        ckd_cases * 100.0 / known_participants,
        2
    ) AS ckd_proportion
FROM gender_ckd;

-- How does CKD proportion vary across ethnicity groups among adults with known CKD classification?
WITH ethnicity_ckd AS (
    SELECT
        ethnicity,
        COUNT(*) AS known_participants,
        COUNT(
            CASE
                WHEN analytical_ckd_status = 'CKD' THEN 1
            END
        ) AS ckd_cases,
        COUNT(
            CASE
                WHEN analytical_ckd_status = 'No CKD' THEN 1
            END
        ) AS no_ckd
    FROM kidney_clean
    WHERE analytical_ckd_status <> 'Unknown'
    GROUP BY ethnicity
)
SELECT
    ethnicity,
    known_participants,
    ckd_cases,
    no_ckd,
    ROUND(
        ckd_cases * 100.0 / known_participants,
        2
    ) AS ckd_proportion
FROM ethnicity_ckd
ORDER BY ckd_proportion DESC;

-- Does CKD classification vary with socioeconomic position as measured by poverty-income ratio?
WITH pir AS(
SELECT
	CASE
		WHEN poverty_income_ratio < 1 THEN '<1'
		WHEN poverty_income_ratio >=1 AND poverty_income_ratio <2 THEN '1-<2'
		WHEN poverty_income_ratio >=2 AND poverty_income_ratio <4 THEN '2-<4'
		WHEN poverty_income_ratio >=4 AND poverty_income_ratio <=5 THEN '4-5'
	END AS pir_group,
	analytical_ckd_status
FROM kidney_clean
WHERE poverty_income_ratio IS NOT NULL
),

pir_ckd AS (
    SELECT
        pir_group,
        COUNT(*) AS known_participants,
        COUNT(
            CASE
                WHEN analytical_ckd_status = 'CKD' THEN 1
            END
        ) AS ckd_cases,
        COUNT(
            CASE
                WHEN analytical_ckd_status = 'No CKD' THEN 1
            END
        ) AS no_ckd
    FROM pir
    WHERE analytical_ckd_status <> 'Unknown' 
    GROUP BY pir_group
)
SELECT 
	pir_group, 
	known_participants, 
	ckd_cases, 
	no_ckd, 
	ROUND(ckd_cases * 100.0/ known_participants, 2) AS ckd_proportions 
FROM pir_ckd
ORDER BY ckd_proportions DESC
;

-- How does CKD proportion vary across adult BMI categories?
WITH bmi_ckd AS (
    SELECT
        bmi_category,
        COUNT(*) AS known_participants,
        COUNT(
            CASE
                WHEN analytical_ckd_status = 'CKD' THEN 1
            END
        ) AS ckd_cases,
        COUNT(
            CASE
                WHEN analytical_ckd_status = 'No CKD' THEN 1
            END
        ) AS no_ckd
    FROM kidney_clean
    WHERE analytical_ckd_status <> 'Unknown' AND bmi_category <> 'Unknown'
    GROUP BY bmi_category
)
SELECT 
	bmi_category, 
	known_participants, 
	ckd_cases, 
	no_ckd, 
	ROUND(ckd_cases * 100.0/ known_participants, 2) AS ckd_proportions 
FROM bmi_ckd
ORDER BY ckd_proportions DESC
;

-- Does CKD proportion differ between adults who have ever smoked and those who have never smoked?
WITH smoking_ckd AS (
    SELECT
        smoking_status,
        COUNT(*) AS known_participants,
        COUNT(
            CASE
                WHEN analytical_ckd_status = 'CKD' THEN 1
            END
        ) AS ckd_cases,
        COUNT(
            CASE
                WHEN analytical_ckd_status = 'No CKD' THEN 1
            END
        ) AS no_ckd
    FROM kidney_clean
    WHERE analytical_ckd_status <> 'Unknown' AND smoking_status <> 'Unknown'
    GROUP BY smoking_status
)
SELECT 
	smoking_status, 
	known_participants, 
	ckd_cases, 
	no_ckd, 
	ROUND(ckd_cases * 100.0/ known_participants, 2) AS ckd_proportions 
FROM smoking_ckd
ORDER BY ckd_proportions DESC
;

-- Diabetes vs ckd
WITH diabetes_ckd AS (
    SELECT
        diabetes_status,
        COUNT(*) AS known_participants,
        COUNT(
            CASE
                WHEN analytical_ckd_status = 'CKD' THEN 1
            END
        ) AS ckd_cases,
        COUNT(
            CASE
                WHEN analytical_ckd_status = 'No CKD' THEN 1
            END
        ) AS no_ckd
    FROM kidney_clean
    WHERE analytical_ckd_status <> 'Unknown' AND diabetes_status <> 'Unknown'
    GROUP BY diabetes_status
)
SELECT 
	diabetes_status, 
	known_participants, 
	ckd_cases, 
	no_ckd, 
	ROUND(ckd_cases * 100.0/ known_participants, 2) AS ckd_proportions 
FROM diabetes_ckd
ORDER BY ckd_proportions DESC
;

-- How many percentage points does CKD proportion increase from one age group to the next?
WITH age_ckd AS (
    SELECT
        age_group,
		CASE
    		WHEN age_group = '18-29' THEN 1
    		WHEN age_group = '30-39' THEN 2
   			WHEN age_group = '40-49' THEN 3
    		WHEN age_group = '50-59' THEN 4
    		WHEN age_group = '60-69' THEN 5
    		WHEN age_group = '70+' THEN 6
		END AS age_order,
        COUNT(*) AS known_participants,
        COUNT(
            CASE
                WHEN analytical_ckd_status = 'CKD' THEN 1
            END
        ) AS ckd_cases,
        COUNT(
            CASE
                WHEN analytical_ckd_status = 'No CKD' THEN 1
            END
        ) AS no_ckd
FROM kidney_clean
WHERE analytical_ckd_status <> 'Unknown' 
GROUP BY age_group, age_order
),
age_rates AS (
SELECT
    age_group,
    age_order,
    known_participants,
    ckd_cases,
    no_ckd,
    ROUND(
        ckd_cases * 100.0 / known_participants,
        2
    ) AS ckd_proportion
FROM age_ckd)
SELECT
    age_group,
    ckd_proportion,
    LAG(ckd_proportion) OVER (ORDER BY age_order) AS previous_ckd_proportion,
	ckd_proportion - LAG(ckd_proportion) OVER (ORDER BY age_order) AS percentage_point_change
FROM age_rates
ORDER BY age_order;

-- Blood Pressure and CKD: Do average blood-pressure measurements differ between adults classified as CKD and No CKD?
SELECT
    analytical_ckd_status,
    COUNT(*) AS participants,
    ROUND(AVG(bp_systolic), 2) AS avg_systolic_bp,
    ROUND(AVG(bp_diastolic), 2) AS avg_diastolic_bp
FROM kidney_clean
WHERE analytical_ckd_status <> 'Unknown'
  AND bp_systolic IS NOT NULL
  AND bp_diastolic IS NOT NULL
GROUP BY analytical_ckd_status
ORDER BY analytical_ckd_status;
-- Kidney Marker: ACR and CKD
SELECT
    analytical_ckd_status,
    COUNT(albumin_creatinine_ratio) AS participants_with_acr,
    ROUND(AVG(albumin_creatinine_ratio), 2) AS avg_acr,
    ROUND(MIN(albumin_creatinine_ratio), 2) AS min_acr,
    ROUND(MAX(albumin_creatinine_ratio), 2) AS max_acr
FROM kidney_clean
WHERE analytical_ckd_status <> 'Unknown'
  AND albumin_creatinine_ratio IS NOT NULL
GROUP BY analytical_ckd_status
ORDER BY analytical_ckd_status;
