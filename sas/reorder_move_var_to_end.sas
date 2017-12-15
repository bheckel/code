options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: reorder_move_var_to_end.sas
  *
  *  Summary: Move a variable to the end of a dataset.
  *
  *  Created: Fri 22 Jan 2010 08:50:25 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%macro move_var_to_end(lib, ds, var2move);
  %local order new_ord;

  proc sql NOprint;
    create table _currorder as
    select name, varnum
    from dictionary.columns
    where libname eq "%upcase(&lib)" and memname eq "%upcase(&ds)"
    ;

    select distinct(name), varnum into :order separated by ' ', :throwaway
    from _currorder
    order by varnum
    ;
  quit;

  data _null_;
    call symput('new_ord', tranwrd("&order", "&var2move", ''));
  run;

  data &lib..&ds;
    retain &new_ord;
    set &lib..&ds;
  run;
%mend;

 /* Create test dataset */
proc print data=sashelp.shoes(obs=5) width=minimum; run; data tmp; set sashelp.shoes; run;

 /* Case sensitive!                             */
 /*           ____       ______                 */
%move_var_to_end(WORK, tmp, Stores);

proc print data=tmp(obs=5) width=minimum; run;
