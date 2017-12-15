
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Macro
 *  INPUT:            Library, dataset and variable(s) to ignore during
 *                    sorting
 *  PROCESSING:       Sort dataset
 *  OUTPUT:           A reordered dataset sorted qualitative then quantitative
 *******************************************************************************
 */
%macro reorderQualQuant(lib, ds, override);
  %local ordcharnum overrideSQL i f;

  %let i=1;
  %let f=%qscan(&override, &i, ' '); 
  %let overrideSQL=;

  /* Quote and comma-separate for the SQL query */
  %do %while ( &f ne  );
    %let overrideSQL=&overrideSQL,"&f";
    %let i=%eval(&i+1);
    %let f=%qscan(&override, &i, ' '); 
  %end;

  /* Remove leading comma */
  %let overrideSQL=%substr(%bquote(&overrideSQL), 2);

  proc sql NOPRINT;
    create table tmpordered as
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
