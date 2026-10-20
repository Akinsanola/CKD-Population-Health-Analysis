/* CKD Population Health Analysis
   03 - Age-adjusted logistic regression
   Prerequisite: 01_import_and_preparation.sas creates WORK.KIDNEY_FIXED.
   These are separate models: smoking + age and diabetes + age.
   Observational associations are not causal estimates.
*/

/* Binary CKD outcome: CKD=1, No CKD=0, Unknown=missing */
data kidney_model;
    set kidney_fixed;
    if analytical_ckd_status = 'CKD' then ckd_binary = 1;
    else if analytical_ckd_status = 'No CKD' then ckd_binary = 0;
    else ckd_binary = .;
run;

/* Smoking association adjusted for age */
proc logistic data=kidney_model;
    class smoking_status (ref='Never Smoked') / param=ref;
    model ckd_binary(event='1') = smoking_status age_n;
    where smoking_status in ('Ever Smoked', 'Never Smoked');
run;

/* Diabetes association adjusted for age */
proc logistic data=kidney_model;
    class diabetes_status (ref='No Diabetes') / param=ref;
    model ckd_binary(event='1') = diabetes_status age_n;
    where diabetes_status in ('Diabetes', 'No Diabetes');
run;
