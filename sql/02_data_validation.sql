-- CKD Population Health Analysis | PostgreSQL
-- 02: Source profiling and validation of the cleaned adult view
-- Requires the kidney source table to be populated and kidney_clean to exist.
-- These queries document exploratory quality checks, including missing values.

SELECT COUNT(*)
FROM kidney;

-- 	Check for duplicates
SELECT COUNT(*) AS Total_records,
	   COUNT(DISTINCT Participant_id) AS Unique_participant,
	   COUNT(*)  - COUNT(DISTINCT Participant_id) AS Duplicated_Participant
FROM kidney;


-- Check for  Nulls 
SELECT
    COUNT(*) - COUNT(participant_id) AS participant_id_nulls,
    COUNT(*) - COUNT(age) AS age_nulls,
    COUNT(*) - COUNT(gender) AS gender_nulls,
    COUNT(*) - COUNT(ethnicity) AS ethnicity_nulls,
    COUNT(*) - COUNT(poverty_income_ratio) AS poverty_income_ratio_nulls,
    COUNT(*) - COUNT(bmi) AS bmi_nulls,
    COUNT(*) - COUNT(ever_smoked) AS ever_smoked_nulls,
    COUNT(*) - COUNT(ckd_present) AS ckd_present_nulls
FROM kidney;

-- Check Min, Max and Avg Age
SELECT MAX(Age) as Maximum_Age,
	   ROUND(AVG(Age), 2) as Average_Age,
	   MIN(Age) as Minimum_Age
FROM kidney;

-- Check the count of the age groups
SELECT
    COUNT(*) FILTER (WHERE age < 1) AS under_1,
    COUNT(*) FILTER (WHERE age >= 1 AND age < 18) AS age_1_to_17,
    COUNT(*) FILTER (WHERE age >= 18 AND age < 30) AS age_18_to_29,
    COUNT(*) FILTER (WHERE age >= 30 AND age < 40) AS age_30_to_39,
    COUNT(*) FILTER (WHERE age >= 40 AND age < 50) AS age_40_to_49,
    COUNT(*) FILTER (WHERE age >= 50 AND age < 60) AS age_50_to_59,
    COUNT(*) FILTER (WHERE age >= 60 AND age < 70) AS age_60_to_69,
    COUNT(*) FILTER (WHERE age >= 70) AS age_70_plus
FROM kidney;

-- Investigate the age further
SELECT 
    CASE
        WHEN age < 18 THEN 'Under 18'
        ELSE '18+'
    END AS age_group,
    COUNT(*) AS total_participants,
	COUNT(
        CASE
            WHEN ever_smoked IS NULL THEN 1
        END
    ) AS missing_ever_smoked
FROM kidney
GROUP BY
    CASE
        WHEN age < 18 THEN 'Under 18'
        ELSE '18+'
    END;

-- Check the gender count
SELECT gender,
	   COUNT(gender) as number_of_participants
FROM kidney
GROUP BY gender
ORDER BY number_of_participants DESC;

-- Check the Ethnicity count
SELECT ethnicity,
	   COUNT(ethnicity) as number_of_participants
FROM kidney
GROUP BY ethnicity
ORDER BY number_of_participants DESC;

-- Check the Ever Smoked count
SELECT ever_smoked,
	   COUNT(*) AS number_of_participants
FROM kidney
GROUP BY ever_smoked
ORDER BY number_of_participants DESC;

-- ckd present 
SELECT
    ckd_present,
    COUNT(*) AS number_of_participants
FROM kidney
GROUP BY ckd_present
ORDER BY number_of_participants DESC;

-- CKD CLassification Distribution
SELECT
    CASE
        WHEN age < 18 THEN 'Under 18'
        ELSE '18+'
    END AS age_group,
    ckd_present,
    COUNT(*) AS number_of_participants
FROM kidney
GROUP BY
    CASE
        WHEN age < 18 THEN 'Under 18'
        ELSE '18+'
    END,
    ckd_present
ORDER BY age_group, ckd_present;

-- CKD Stages for under 18
SELECT
    ckd_stage,
    COUNT(*) AS number_of_participants
FROM kidney
WHERE age < 18
GROUP BY ckd_stage
ORDER BY number_of_participants DESC;

-- Overall CKD Stages for each participants
SELECT
    ckd_stage,
    ckd_present,
    COUNT(*) AS number_of_participants
FROM kidney
GROUP BY ckd_stage, ckd_present
ORDER BY ckd_stage, ckd_present;

-- investigate the egfr for the ckd stage
SELECT COUNT(*) AS Number_of_Participants
FROM kidney
WHERE ckd_stage = 'Unknown' 
	AND egfr is NULL;

SELECT 
    COUNT(*) AS missing_egfr,
    COUNT(
        CASE 
            WHEN ckd_stage = 'Unknown' THEN 1
        END
    ) AS missing_egfr_and_unknown
FROM kidney
WHERE egfr IS NULL;

-- Check the missing value count of serum creatinine
SELECT COUNT(*)
FROM kidney
WHERE egfr IS NULL
  AND serum_creatinine IS NULL;

--  UNKNOWN CKD STATUS BY AGE GROUP
SELECT
    CASE
        WHEN age < 18 THEN 'Under 18'
        ELSE '18+'
    END AS age_group,
    COUNT(*) AS total_participants,
    COUNT(
        CASE
            WHEN ckd_stage = 'Unknown' THEN 1
        END
    ) AS unknown_ckd
FROM kidney
GROUP BY
    CASE
        WHEN age < 18 THEN 'Under 18'
        ELSE '18+'
    END;

-- Min, Avg and Max BMI
SELECT MIN(bmi) as Min_bmi,
	   ROUND(AVG(bmi), 2) as Avg_bmi,
	   MAX(bmi) as Max_bmi
FROM kidney;

-- missing bmi
SELECT
    CASE
        WHEN age < 18 THEN 'Under 18'
        ELSE '18+'
    END AS age_group,
    COUNT(*) AS total_participants,
    COUNT(
        CASE
            WHEN bmi is NULL THEN 1
        END
    ) AS null_bmi
FROM kidney
GROUP BY
    CASE
        WHEN age < 18 THEN 'Under 18'
        ELSE '18+'
    END;

-- Poverty_Income_Ratio (PIR)
SELECT MIN(poverty_income_ratio) as Min_PIR,
	   ROUND(AVG(poverty_income_ratio), 2) as Avg_PIR,
	   MAX(poverty_income_ratio) as Max_PIR
FROM kidney;

-- missing PIR across age group
SELECT
    CASE
        WHEN age < 18 THEN 'Under 18'
        ELSE '18+'
    END AS age_group,
    COUNT(*) AS total_participants,
    COUNT(
        CASE
            WHEN poverty_income_ratio IS NULL THEN 1
        END
    ) AS missing_PIR
FROM kidney
GROUP BY
    CASE
        WHEN age < 18 THEN 'Under 18'
        ELSE '18+'
    END;

-- Missing Ever smoked by groups
SELECT
    CASE
		WHEN age < 12 THEN 'Under 12'
        WHEN age >= 12 AND age < 18 THEN '12 - 17'
        ELSE '18+'
    END AS age_group,
    COUNT(*) AS number_of_participants, 
	COUNT(
        CASE
            WHEN ever_smoked IS NULL THEN 1
        END
    ) AS missing_ever_smoked
FROM kidney
GROUP BY
    CASE
		WHEN age < 12 THEN 'Under 12'
        WHEN age >= 12 AND age < 18 THEN '12 - 17'
        ELSE '18+'
    END;

SELECT MIN(bp_systolic) AS min_systolic,
	   ROUND(AVG(bp_systolic), 2) AS avg_systolic,
	   MAX(bp_systolic) AS max_systolic,
	   COUNT(*) - COUNT(bp_systolic) AS missing_bp_systolic,
	   MIN(bp_diastolic) AS min_diastolic,
	   ROUND(AVG(bp_diastolic), 2) AS avg_diastolic,
	   MAX(bp_diastolic) AS max_diastolic,
	   COUNT(*) - COUNT(bp_diastolic) AS missing_bp_diastolic
FROM kidney;

SELECT
    COUNT(
        CASE
            WHEN bp_systolic IS NULL AND bp_diastolic IS NULL THEN 1
        END
    ) AS both_missing,
    COUNT(
        CASE
            WHEN bp_systolic IS NULL AND bp_diastolic IS NOT NULL THEN 1
        END
    ) AS systolic_only_missing,
    COUNT(
        CASE
            WHEN bp_systolic IS NOT NULL AND bp_diastolic IS NULL THEN 1
        END
    ) AS diastolic_only_missing
FROM kidney;


-- AGE VS BP
SELECT
    CASE
		WHEN age < 12 THEN 'Under 12'
        WHEN age >= 12 AND age < 18 THEN '12 - 17'
        ELSE '18+'
    END AS age_group,
    COUNT(*) AS number_of_participants, 
	COUNT(
        CASE
            WHEN bp_systolic IS NULL AND bp_diastolic IS NULL THEN 1
        END
    ) AS missing_bp,
	ROUND(COUNT(CASE
            WHEN bp_systolic IS NULL AND bp_diastolic IS NULL THEN 1
        END) * 100.0 / COUNT(*), 2) AS missing_rate
FROM kidney
GROUP BY
    CASE
		WHEN age < 12 THEN 'Under 12'
        WHEN age >= 12 AND age < 18 THEN '12 - 17'
        ELSE '18+'
    END;

SELECT MIN(bp_systolic) AS min_systolic,
	   MAX(bp_systolic) AS max_systolic,
	   MIN(bp_diastolic) AS min_diastolic,
	   MAX(bp_diastolic) AS max_diastolic
FROM kidney
WHERE age >= 18;

-- Diabetes
SELECT diabetes_diagnosed,
		COUNT(*) AS Number_of_participants
FROM kidney
GROUP BY diabetes_diagnosed
ORDER BY Number_of_participants DESC;

-- Diabetes vs age group
SELECT
    CASE
		WHEN age < 12 THEN 'Under 12'
        WHEN age >= 12 AND age < 18 THEN '12 - 17'
        ELSE '18+'
    END AS age_group,
    COUNT(*) AS number_of_participants, 
	COUNT(
        CASE
            WHEN diabetes_diagnosed IS NULL THEN 1
        END
    ) AS missing_diabetes,
	ROUND(COUNT(CASE
           WHEN diabetes_diagnosed IS NULL THEN 1
        END) * 100.0 / COUNT(*), 2) AS missing_rate
FROM kidney
GROUP BY
    CASE
		WHEN age < 12 THEN 'Under 12'
        WHEN age >= 12 AND age < 18 THEN '12 - 17'
        ELSE '18+'
    END;

-- albumin_creatinine_ratio
SELECT MIN(albumin_creatinine_ratio) AS min_ACR,
	   ROUND(AVG(albumin_creatinine_ratio), 2) AS avg_ACR,
	   MAX(albumin_creatinine_ratio) AS max_ACR,
	   COUNT(*) - COUNT(albumin_creatinine_ratio) AS missing_ACR,
	   ROUND((COUNT(*) - COUNT(albumin_creatinine_ratio)) * 100.0 / COUNT(*), 2) AS missing_ACR_Rate
FROM kidney;

-- ACR VS Age groups
SELECT
    CASE
		WHEN age < 12 THEN 'Under 12'
        WHEN age >= 12 AND age < 18 THEN '12 - 17'
        ELSE '18+'
    END AS age_group,
    COUNT(*) AS number_of_participants, 
	COUNT(
        CASE
            WHEN albumin_creatinine_ratio IS NULL THEN 1
        END
    ) AS missing_ACR,
	ROUND(COUNT(CASE
           WHEN albumin_creatinine_ratio IS NULL THEN 1
        END) * 100.0 / COUNT(*), 2) AS missing_rate
FROM kidney
GROUP BY
    CASE
		WHEN age < 12 THEN 'Under 12'
        WHEN age >= 12 AND age < 18 THEN '12 - 17'
        ELSE '18+'
    END;

-- investigate high ACR
SELECT participant_id,
	   age,
	   albumin_creatinine_ratio,
	   ckd_stage
FROM kidney
WHERE albumin_creatinine_ratio IS NOT NULL
ORDER BY albumin_creatinine_ratio DESC
LIMIT 10;

-- Screening the remaining laboratory results
SELECT
    -- Blood Urea Nitrogen
    MIN(blood_urea_nitrogen) AS min_bun,
    ROUND(AVG(blood_urea_nitrogen), 2) AS avg_bun,
    MAX(blood_urea_nitrogen) AS max_bun,
    COUNT(*) - COUNT(blood_urea_nitrogen) AS missing_bun,
    ROUND(
        (COUNT(*) - COUNT(blood_urea_nitrogen)) * 100.0 / COUNT(*),
        2
    ) AS missing_bun_rate,

    -- Serum Albumin
    MIN(albumin_serum) AS min_albumin,
    ROUND(AVG(albumin_serum), 2) AS avg_albumin,
    MAX(albumin_serum) AS max_albumin,
    COUNT(*) - COUNT(albumin_serum) AS missing_albumin,
    ROUND(
        (COUNT(*) - COUNT(albumin_serum)) * 100.0 / COUNT(*),
        2
    ) AS missing_albumin_rate,

    -- Phosphorus
    MIN(phosphorus) AS min_phosphorus,
    ROUND(AVG(phosphorus), 2) AS avg_phosphorus,
    MAX(phosphorus) AS max_phosphorus,
    COUNT(*) - COUNT(phosphorus) AS missing_phosphorus,
    ROUND(
        (COUNT(*) - COUNT(phosphorus)) * 100.0 / COUNT(*),
        2
    ) AS missing_phosphorus_rate,

    -- Bicarbonate
    MIN(bicarbonate) AS min_bicarbonate,
    ROUND(AVG(bicarbonate), 2) AS avg_bicarbonate,
    MAX(bicarbonate) AS max_bicarbonate,
    COUNT(*) - COUNT(bicarbonate) AS missing_bicarbonate,
    ROUND(
        (COUNT(*) - COUNT(bicarbonate)) * 100.0 / COUNT(*),
        2
    ) AS missing_bicarbonate_rate,

    -- Calcium
    MIN(calcium) AS min_calcium,
    ROUND(AVG(calcium), 2) AS avg_calcium,
    MAX(calcium) AS max_calcium,
    COUNT(*) - COUNT(calcium) AS missing_calcium,
    ROUND(
        (COUNT(*) - COUNT(calcium)) * 100.0 / COUNT(*),
        2
    ) AS missing_calcium_rate,

    -- Uric Acid
    MIN(uric_acid) AS min_uric_acid,
    ROUND(AVG(uric_acid), 2) AS avg_uric_acid,
    MAX(uric_acid) AS max_uric_acid,
    COUNT(*) - COUNT(uric_acid) AS missing_uric_acid,
    ROUND(
        (COUNT(*) - COUNT(uric_acid)) * 100.0 / COUNT(*),
        2
    ) AS missing_uric_acid_rate

FROM kidney;

-- Final view validation
-- Check the new table created
-- 1. Check total adult records
SELECT COUNT(*) AS total_adults
FROM kidney_clean;


-- 2. Make sure participant IDs are still unique
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT participant_id) AS unique_participants,
    COUNT(*) - COUNT(DISTINCT participant_id) AS duplicates
FROM kidney_clean;


-- 3. Validate the corrected CKD outcome
SELECT
    analytical_ckd_status,
    COUNT(*) AS number_of_participants
FROM kidney_clean
GROUP BY analytical_ckd_status
ORDER BY number_of_participants DESC;

-- Among adults whose CKD classification is known, what is the overall CKD proportion?
SELECT 
	COUNT(*) AS known_participants,
	COUNT(
		CASE 
        	WHEN analytical_ckd_status = 'CKD' THEN 1
    END) AS ckd_cases,
	COUNT(
		CASE 
       	 	WHEN analytical_ckd_status = 'No CKD' THEN 1
    END) AS no_ckd,
	ROUND(
    COUNT(CASE WHEN analytical_ckd_status = 'CKD' THEN 1 END)
    * 100.0 / COUNT(*),
    2
) AS ckd_proportion
FROM kidney_clean
WHERE analytical_ckd_status <> 'Unknown'
;
