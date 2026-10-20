/* CKD Population Health Analysis
   02 - Descriptive statistics and chi-square tests
   Prerequisite: 01_import_and_preparation.sas creates WORK.KIDNEY_FIXED.
   Original analysis tests associations; it does not establish causation.
*/

proc means data=kidney_fixed
    n nmiss min mean median max maxdec=2;
    var age_n bmi_n bp_systolic_n bp_diastolic_n
        acr_n pir_n egfr_n;
    title "Descriptive Analysis of Numeric Variables";
run;
title;

/* Albumin-to-creatinine ratio (ACR) distribution */
proc univariate data=kidney_fixed;
    var acr_n;
    histogram acr_n;
run;

/* ACR distribution among adults with classified CKD status */
proc means data=kidney_fixed
    n median q1 q3 qrange mean maxdec=2;
    class analytical_ckd_status;
    var acr_n;
    where analytical_ckd_status in ('CKD', 'No CKD');
run;

/* Diabetes vs CKD: Pearson chi-square test.
   Borderline/Unknown diabetes and Unknown CKD excluded, per original analysis. */
proc freq data=kidney_fixed;
    tables diabetes_status*analytical_ckd_status / chisq;
    where analytical_ckd_status in ('CKD', 'No CKD')
      and diabetes_status in ('Diabetes', 'No Diabetes');
run;

/* Ever-smoking history vs CKD: Pearson chi-square test */
proc freq data=kidney_fixed;
    tables smoking_status*analytical_ckd_status / chisq;
    where analytical_ckd_status in ('CKD', 'No CKD')
      and smoking_status in ('Ever Smoked', 'Never Smoked');
run;
