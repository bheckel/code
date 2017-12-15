//BQH0HFSL JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M
//STEP1    EXEC SAS90,TIME=100,OPTIONS='MEMSIZE=0,ALTLOG=OLOG,
//                                      ALTPRINT=OLST'
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//OLST     DD PATH='/u/bqh0/saslst'
//OLOG     DD PATH='/u/bqh0/saslog'
//SYSIN    DD *

x umask 007;

%macro ForEach(event);
  %local i j s;

  %let i=1;
  %let s=%scan(&event, &i, ' ');

  %do %while ( %bquote(&s) ne  );
    %let i=%eval(&i+1);
    %let j=3;  /* 2003 */

    %do %while ( &j le 4  );
      libname OLDL "DWJ2.REGISTER.&s.200&j" DISP=SHR;
      libname NEWL "/u/dwj2/register/&s./200&j";

      proc copy in=OLDL out=NEWL memtype=DATA; 
        select register history backup bttupd today yest;
      run;

      %let j=%eval(&j+1);
    %end;

    %let s=%scan(&event, &i, ' ');
  %end;
%mend ForEach;
%ForEach(NAT MOR FET MED MIC);
