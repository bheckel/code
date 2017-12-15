//BQH0EFGX JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=5,CLASS=V,REGION=0M
//STEP1    EXEC SAS90,TIME=100,OPTIONS='MEMSIZE=0,ALTPRINT=OLST,
//                                                ALTLOG=OLOG'
//OLST     DD DISP=SHR,DSN=BQH0.INC.SASLIST WAIT=10
//OLOG     DD DISP=SHR,DSN=BQH0.INC.SASLOG WAIT=10
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//SYSIN    DD *

options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: loopallmvds.sas
  *
  *  Summary: Summarize a variable on all states all years MVDS datasets.
  *
  *  Created: Tue 07 Sep 2004 15:18:19 (Bob Heckel)
  * Modified: Thu 21 Apr 2005 12:40:21 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter replace=no mlogic mprint sgen;

%macro ForEach(stlist, begyr, endyr);
  %local i j s;

  %let i=1;
  %let s=%scan(&stlist, &i, ' ');

  %do %while ( %bquote(&s) ne  );
    %let i=%eval(&i+1);

    %let j=&begyr;
    %do %while ( &j le &endyr  );
      libname L "/u/dwj2/mvds/MOR/&j" DISP=SHR;

      data tmp;
        set L.&s.NEW (keep= DETHNIC2);
      run;

      proc append base=tmpall data=tmp; run;

      %let j=%eval(&j+1);
    %end;

    %let s=%scan(&stlist, &i, ' ');
  %end;
%mend ForEach;
 /***
%ForEach(AK AL AR AS AZ CA CO CT DC DE FL GA GU HI IA ID IL IN KS KY LA
         MA MD ME MI MN MO MP MS MT NC ND NE NH NJ NM NV NY OH OK OR PA 
         PR RI SC SD TN TX UT VA VI VT WA WI WV WY YC);
 ***/
 /* No revisers */
 /***
%ForEach(AK AL AR AS AZ CA CO CT DC DE FL GA GU HI IA ID IL IN KS KY LA
         MA MD ME MI MN MO MP MS MT NC ND NE NH NJ NM NV NY OH OK OR 
         PR RI SC SD TN TX UT VA VI VT WI WV WY YC, 2003, 2003);
  ***/
%ForEach(CA ID MT NY YC, 2003, 2003);
 /*** %ForEach(AK AL, 2003, 2004); ***/


proc freq;
  tables DETHNIC2;
run;
