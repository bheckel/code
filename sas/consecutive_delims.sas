options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: consecutive_delims.sas
  *
  *  Summary: Demo of parsing a string similarly to the DLM DSD options of the
  *           datastep.
  *
  *  Adapted: Wed 12 Mar 2003 10:38:00 (Bob Heckel -- usenet post
  *                                     Howard_Schreier@ITA.DOC.GOV)
  *---------------------------------------------------------------------------
  */
options source;

%let s=01|02||04|||07;
  

data _NULL_;
  /* Nested tranwrd() required to handle multiple runs of empty pipes. */
  like_dsd = tranwrd(tranwrd("&s",'||','| |'),'||','| |');
  do i = 1 to 7;
    field = scan(like_dsd,i,'|');
    put i +(-1)": " field;
  end;
run;
