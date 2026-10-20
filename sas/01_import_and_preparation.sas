/* CKD Population Health Analysis
   01 - Import and data preparation
   Source: User's SAS Studio analysis; reorganized for GitHub.
   Update the CSV path to the location of kidney_clean.csv in your SAS environment.
   Run this script first in the same SAS session as the following scripts.
*/

proc import datafile="/home/u64312761/kidney_clean.csv"
    out=kidney
    dbms=csv
    replace;
    getnames=yes;
run;

/* Inspect types after import. Numeric fields imported as character in
   the original workflow due to missing-value strings in the CSV. */
proc contents data=kidney;
run;

/* Coerce selected numeric variables; invalid/missing text becomes missing. */
data kidney_fixed;
    set kidney;
    age_n = input(age, ?? best32.);
    bmi_n = input(bmi, ?? best32.);
    bp_systolic_n = input(bp_systolic, ?? best32.);
    bp_diastolic_n = input(bp_diastolic, ?? best32.);
    acr_n = input(albumin_creatinine_ratio, ?? best32.);
    pir_n = input(poverty_income_ratio, ?? best32.);
    egfr_n = input(egfr, ?? best32.);
run;

proc contents data=kidney_fixed;
    title "Contents of Prepared CKD Dataset";
run;
title;

proc print data=kidney(obs=10);
run;

/* Use age_n so minimum and maximum are numeric. */
proc sql;
    select count(*) as total_participants,
           min(age_n) as minimum_age,
           max(age_n) as maximum_age
    from kidney_fixed;
quit;

proc freq data=kidney_fixed;
    tables analytical_ckd_status / missing;
run;
