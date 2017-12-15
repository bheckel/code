
data _null_;
  rc=system('/Drugs/Personnel/bob/TMM/Affiliates/run_affiliate.sh Osborn_Aff 2>/Drugs/Personnel/bob/t.err');
  put rc=;
run;


data _null_;
  rc1=system("sleep 6");
  if rc1 eq 0 then do; put 'NOTE: synchronous sleep successful'; end; else do; put 'ERROR: sleep fail'; end;

  rc2=system("ls");
run;
