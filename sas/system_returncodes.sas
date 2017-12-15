options noxwait;
data _null_;
  rc2 = system("type junk.2008* > MOSTRECENT.tmp");
  rc3 = system("move junk.2008* .\archive\");
  put rc2= rc3=;  /* s/b 0s */

  rc=system("/Drugs/EGP/cho.sh fyu:sas &converted_change_perms 2>/Drugs/Personnel/bob/foo/wtf.err");
  rc=system('/bin/bash /Drugs/Cron/Daily/FredsImm/fredsimm.sh 2>/Drugs/Cron/Daily/FredsImm/fredsimm.err');
run;
