# SAS Analysis — CKD Population Health Project

These programs are organized from the original SAS Studio code for this project.

Run in order within the **same SAS session**:

1. `01_import_and_preparation.sas` — imports the cleaned PostgreSQL export and creates `kidney_fixed` with numeric analysis fields.
2. `02_descriptive_and_chisquare.sas` — descriptive summaries, ACR distributions, and chi-square tests for diabetes and smoking.
3. `03_age_adjusted_logistic_regression.sas` — binary CKD outcome and separate logistic regression models adjusting smoking and diabetes associations for age.

## Before running

- Download or export the `kidney_clean.csv` dataset from the PostgreSQL preparation stage.
- Update the `datafile=` path in script 01 to the CSV's location in your SAS environment.
- Scripts 02 and 03 expect the temporary SAS dataset `WORK.KIDNEY_FIXED` created by script 01.
- The original analysis converted selected variables imported as text into numeric variables with `INPUT(..., ?? BEST32.)`; review variable types if your CSV import behaves differently.

## Methodological notes

The analysis uses **unweighted** sample data and should not be interpreted as nationally representative CKD prevalence. Chi-square tests are unadjusted; logistic regression models separately adjust the smoking and diabetes comparisons for age. These analyses are observational and do not establish causality.

## Editing notes

The original source had a clear typo (`kidney_fi*+xed`) in a validation query. It was corrected to `kidney_fixed`, and the age range check now uses numeric `age_n`. The scripts have been organized but **not executed or independently validated** in SAS in this environment.
