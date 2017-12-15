options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: set_vars_missing_if_any_missing.sas
  *
  *  Summary: If any are missing, we want all set to missing (throw out whole record)
  *
  *  Adapted: Mon 14 Jun 2004 14:58:01 (Bob Heckel -- SUGI 252-29)
  *---------------------------------------------------------------------------
  */
options source;

data mydata (drop= i);
  input a b c x;
  ***array arr[3] a b c ;
  /* Better */
  array arr[*] a b c ;

  ***do i = 1 to 3;
  /* Better */
  do i = 1 to dim(arr);
   if x eq . then arr[i] = .;
  end;

  cards;
1 2 3 .
2 3 4 5
3 4 5 6
4 5 6 .
  ;
run;
proc print data=_LAST_; run;
