options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: order_char_then_num.sas
  *
  *  Summary: Order a dataset by character variables, then numeric variables.
  *           With override for vars to be placed up front.
  *
  *  Created: Wed 02 Apr 2008 14:12:11 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter NOlabel;

data datads;
  n1=5; a1="betical"; n2=9; a2="cal"; a3="almost"; a4="ended";
  output;
run;

%macro reorderQualQuant(lib, ds, override);
  %local ordcharnum overrideSQL i f;

  %let i=1;
  %let f=%qscan(&override, &i, ' '); 
  %let overrideSQL=;

  /* Quote and commaseparate for the SQL query */
  %do %while ( &f ne  );
    %let overrideSQL=&overrideSQL,"&f";
    %let i=%eval(&i+1);
    %let f=%qscan(&override, &i, ' '); 
  %end;

  /* Remove leading comma */
  %let overrideSQL=%substr(%bquote(&overrideSQL), 2);
  %put !!!&overrideSQL;

  proc sql NOPRINT;
    create table tmpordered as
    /* use SAS' "num" to determine numeric then push to rear */
    select name,
           case when type='num' then varnum+1000
                else varnum
                end as vord
    from dictionary.columns
    where libname eq "%upcase(&lib)" and memname eq "%upcase(&ds)"
    order by vord
    ;

    select distinct(name) into :ordcharnum separated by ' '
    from tmpordered
    where name not in(&overrideSQL)
    ;
  quit;

  data &lib..&ds;
    retain &override &ordcharnum;
    set &lib..&ds;
  run;
%mend;
%reorderQualQuant(WORK, datads, a2 a3);

proc print data=_LAST_(obs=max) width=minimum; run;

