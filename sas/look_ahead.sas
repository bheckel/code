options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: look_ahead.sas (see also look_behind.sas s/b symlinked as
  *                           get_next_obs.sas)
  *
  *  Summary: Look ahead and read the next value(s) by reading the same 
  *           dataset again, only starting at a later record.
  *
  *  Adapted: Fri 15 Aug 2003 13:29:58 (Bob Heckel -- Phil Mason Tip 43)
  * Modified: Fri 11 Sep 2009 12:28:58 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data name;
  /* Read this record... */
  set SASHELP.class;
  put '1st set obs number: ' _N_ '-->' _ALL_;

  /* ...then just read one variable from the next record */
  set SASHELP.class(firstobs=2 keep=name rename=(name=next_name)) ; 
  put '2nd set obs number: ' _N_ '-->' _ALL_;
run;
