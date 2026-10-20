-- CKD Population Health Analysis | PostgreSQL
-- 01: Source schema and cleaned adult analytical view
-- Data loading is a separate prerequisite: import the original CKD CSV into kidney
-- after creating the source table. The source file is not included.
-- Execute this script before 02_data_validation.sql and 03_exploratory_analysis.sql.

CREATE TABLE kidney (
    participant_id TEXT,
    age NUMERIC,
    gender TEXT,
    ethnicity TEXT,
    education_level TEXT,
    poverty_income_ratio NUMERIC,
    bmi NUMERIC,
    weight_kg NUMERIC,
    height_cm NUMERIC,
    bp_systolic NUMERIC,
    bp_diastolic NUMERIC,
    serum_creatinine NUMERIC,
    blood_urea_nitrogen NUMERIC,
    albumin_serum NUMERIC,
    phosphorus NUMERIC,
    bicarbonate NUMERIC,
    calcium NUMERIC,
    uric_acid NUMERIC,
    urine_creatinine NUMERIC,
    urine_albumin NUMERIC,
    albumin_creatinine_ratio NUMERIC,
    diabetes_diagnosed TEXT,
    insulin_use TEXT,
    diabetes_pills TEXT,
    ever_smoked TEXT,
    current_smoker TEXT,
    egfr NUMERIC,
    ckd_stage TEXT,
    ckd_present INTEGER
);

CREATE VIEW kidney_clean AS

SELECT
    -- Participant information
    participant_id,
    age,
    gender,
    ethnicity,
    education_level,
    poverty_income_ratio,

    -- Age transformation
    CASE
        WHEN age >= 18 AND age < 30 THEN '18-29'
        WHEN age >= 30 AND age < 40 THEN '30-39'
        WHEN age >= 40 AND age < 50 THEN '40-49'
        WHEN age >= 50 AND age < 60 THEN '50-59'
        WHEN age >= 60 AND age < 70 THEN '60-69'
        ELSE '70+'
    END AS age_group,

    -- Body measurements
    bmi,
    weight_kg,
    height_cm,

    CASE
        WHEN bmi IS NULL THEN 'Unknown'
        WHEN bmi < 18.5 THEN 'Underweight'
        WHEN bmi < 25 THEN 'Normal'
        WHEN bmi < 30 THEN 'Overweight'
        ELSE 'Obese'
    END AS bmi_category,

    -- Blood pressure
    bp_systolic,
    bp_diastolic,

    -- Kidney / laboratory measurements
    serum_creatinine,
    blood_urea_nitrogen,
    albumin_serum,
    phosphorus,
    bicarbonate,
    calcium,
    uric_acid,
    urine_creatinine,
    urine_albumin,
    albumin_creatinine_ratio,
    egfr,

    -- Original CKD variables retained for traceability
    ckd_stage,
    ckd_present,

    -- Corrected analytical CKD outcome
    CASE
        WHEN ckd_stage = 'No CKD' THEN 'No CKD'
        WHEN ckd_stage LIKE 'Stage%' THEN 'CKD'
        WHEN ckd_stage = 'Unknown' THEN 'Unknown'
        ELSE 'Unknown'
    END AS analytical_ckd_status,

    -- Original diabetes variable
    diabetes_diagnosed,

    -- Clean diabetes category
    CASE
        WHEN diabetes_diagnosed = '1.0' THEN 'Diabetes'
        WHEN diabetes_diagnosed = '2.0' THEN 'No Diabetes'
        WHEN diabetes_diagnosed = '3.0' THEN 'Borderline'
        ELSE 'Unknown'
    END AS diabetes_status,

    insulin_use,
    diabetes_pills,

    -- Original smoking variables
    ever_smoked,
    current_smoker,

    -- Clean smoking category
    CASE
        WHEN ever_smoked = '1.0' THEN 'Ever Smoked'
        WHEN ever_smoked = '2.0' THEN 'Never Smoked'
        ELSE 'Unknown'
    END AS smoking_status

FROM kidney

-- Primary analytical population
WHERE age >= 18;
