%macro qc_wc(dsin=);
  proc sql; select min(age) label='Min Age', int(mean(age)) label='Mean Age', max(age) label='Max Age' from hppBKUP2; quit;
  proc sql; select min(statusmodifieddate) format=DATETIME9. label='Min Status Modified', int(mean(statusmodifieddate)) format=DATETIME9. label='Mean Status Modified', max(statusmodifieddate) format=DATETIME9. label='Max Status Modified' from hppBKUP2; quit;
  proc freq data=&dsin nlevels order=freq;
    tables stateprov patientgender patientstatusid new / NOCUM; 
  run;
%mend;
