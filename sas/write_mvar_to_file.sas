%let M = '123,456,789';
%let F = %sysget(TMP);  /* OS environment variable */

filename F "&F/junk";

data _null_;
  file F;
  put &M;
run;

 /* read_mvar_from_file.sas to get the data from file into another mvar */
