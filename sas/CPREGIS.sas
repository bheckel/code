//BQH0HFSR JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M
//STEP1    EXEC SAS90,TIME=100,OPTIONS='MEMSIZE=0,ALTLOG=OLOG,
//                                      ALTPRINT=OLST'
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//OLST     DD PATH='/u/bqh0/sas.tmp.lst'
//OLOG     DD PATH='/u/bqh0/sas.tmp.log'
//SYSIN    DD *

options source NOcenter mlogic mprint sgen NOs99nomig;
x umask 007;

%macro ForEachRegister(event);
  %local i j s;

  %let i=1;
  %let s=%scan(&event, &i, ' ');

  %do %while ( %bquote(&s) ne  );
    %let i=%eval(&i+1);
    %let j=1994;

    %do %while ( &j le 2005  );
      libname OLDL "DWJ2.REGISTER.&s.&j" DISP=SHR;
      libname NEWL "/u/dwj2/register/&s./&j";

      proc copy in=OLDL out=NEWL memtype=DATA; 
        select register history backup bttupd today yest;
      run;

      %let j=%eval(&j+1);
    %end;

    %let s=%scan(&event, &i, ' ');
  %end;
%mend ForEachRegister;
%ForEachRegister(NAT MOR FET MED MIC);
