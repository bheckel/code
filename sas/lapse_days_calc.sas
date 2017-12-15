options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: lapse_days_calc.sas
  *
  *  Summary: Patients are expected to summarize their symptoms in a daily
  *           diary. The programmer is tasked with identifying if a patient had
  *           missed days, i.e. days in which the patient did not make an
  *           entry.
  *
  *  Adapted: Fri 11 May 2012 14:50:05 (Bob Heckel--SUGI 091-2011)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data lapses;
  input rec patient didate DATE9.;
  cards;
1 1001 01FEB2009
2 1001 02FEB2009
3 1001 04FEB2009
4 1001 04FEB2009
5 1001 05FEB2009
6 1001 08FEB2009
  ;
run;

data lapses;
  retain xprevdt;
  put 'PDV 1: ' _all_;
  set lapses;
  by patient didate;

  if first.patient then do;
    put 'PDV 2a: ' _all_;
    xprevdt=didate;
  end;
  else do; /* get lapse */
    if nmiss(didate, xprevdt) eq 0 then do;
      lapse=didate-xprevdt;
      put 'PDV 2b: ' _all_;
    end;
    else do;
      lapse=.;
    end;

    xprevdt=didate;  /* reset to current */
    put 'PDV 2c: ' _all_;
  end;
  put;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

