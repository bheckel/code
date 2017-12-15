options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: random_sample_wo_replace.sas
  *
  *  Summary: Random sampling without replacement.
  *
  *  Adapted: Tue 25 May 2010 13:42:12 (Bob Heckel--SAS9 Advanced Certification)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data sampler;
  sampsz = 10;
  obsleft = nobs;

  do while ( sampsz gt 0 );
    pickit+1;
    if ranuni(0) lt sampsz/obsleft then do;
      set sashelp.shoes point=pickit nobs=nobs;
      output;
      sampsz = sampsz-1;
    end;
    obsleft = obsleft-1;
  end;
  stop;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

