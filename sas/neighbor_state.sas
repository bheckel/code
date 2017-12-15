options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: PROXIMIT.sas
  *
  *  Summary: Determine neighboring states and create datasets for each 
  *           state.
  *
  *  Adapted: Thu 22 Apr 2004 09:50:26 (kjk4)
  *---------------------------------------------------------------------------
  */
options mlogic mprint sgen NOcenter;

libname L 'BQH0.SASLIB';

%let YY=03;
%let EVT=MOR;

data one;
  set maps.uscenter;
  if ocean eq 'N';

  stnam = fipstate(state);
run;

 /* Add NCHS' 6 to the 51 states. */
data two;
  infile cards;
  input @1 stnam $2.  @4 lat 4.1  @10 long 5.1;
  cards;
YC 40.7  74.0
GU 13.2  215.3
MP 17.6  215.1
AS 14.3  169.6
PR 18.3  66.4
VI 18.1  64.8
  ;
run;

data final;
  set one two;

  %macro Show;
    %do i = 1 %to 57;
      data _null_;
        set final;
        if _n_ = &i then do;
          call symput ('STATENAME',trim(left(stnam)));
          call symput ('STATEX',long);
          call symput ('STATEY',lat);
       end;
      run;

      data L.&STATENAME.&EVT.&YY (keep= stnam dist);
        set final;
        if _n_ = &i then 
          delete;
        else 
          do;
            dist = sqrt(((lat-&STATEY)**2) + ((long-&STATEX)**2));
          end;
      run;

      proc sort data=L.&STATENAME.&EVT.&YY;
        by dist;
      run;
    %end;
  %mend Show;
  %Show
run;

 /* Elim non-revisers from the datasets. */


proc print data=L.CA&EVT.&YY;
run;

