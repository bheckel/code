//BQH0HFSM JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M
//STEP1    EXEC SAS90,TIME=100,OPTIONS='MEMSIZE=0,ALTLOG=OLOG,
//                                      ALTPRINT=OLST'
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//OLST     DD PATH='/u/bqh0/sas.tmp.lst'
//OLOG     DD PATH='/u/bqh0/sas.tmp.log'
//SYSIN    DD *

 /* Takes about 20 minutes to run. */

options source NOcenter mlogic mprint sgen;
x umask 007;

%macro Cp(st, yr);
  libname OLDL "DWJ2.&st.200&yr..MVDS.LIBRARY.NEW" DISP=SHR;
  libname NEWL "/u/dwj2/mvds/&st./200&yr";

  proc copy in=OLDL out=NEWL memtype=DATA; 
  run;
%mend Cp;


%macro ForEachMVDS(event);
  %local i j s;

  %let i=1;
  %let s=%scan(&event, &i, ' ');

  %do %while ( %bquote(&s) ne  );
    %let i=%eval(&i+1);
    %let j=3;  /* 2003 */

    %do %while ( &j le 4  );
      /* Only want 2004 for closed-out NAT & FET events. */
      %if (not %sysfunc(indexw(NAT FET, &s))) %then
        %do;
          %Cp(&s, &j);
        %end;

      %if (%sysfunc(indexw(NAT FET, &s))) %then
        %do;
          %if &j eq 4 %then
            %do;
              %Cp(&s, &j);
            %end;
        %end;

      %let j=%eval(&j+1);
    %end;

    %let s=%scan(&event, &i, ' ');
  %end;
%mend ForEachMVDS;
%ForEachMVDS(NAT MOR FET MED MIC);
