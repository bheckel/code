 /* See also ~/code/sas/call_execute_stored_proc_using_dataset.sas to build by loop dataset */
proc sql;
  connect to odbc as myconn (user=&user.  password=&ajsperpassword.  dsn=ajsper readbuff=7000);

    execute (
      update analytics.mtmtargeted
      set lasttargetdate=%bquote(')&date_max.%bquote(')
      where taebpatientid in (&taebpatientids.)
    ) by myconn;

  disconnect from myconn;
quit;
