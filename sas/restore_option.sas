options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: restore_option.sas
  *
  *  Summary: Determine current SAS options and restore later
  *
  *  Created: Fri 16 Jan 2009 10:12:10 (Bob Heckel)
  * Modified: Tue 08 May 2018 14:28:23 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source pagesize=20 mlogic;

proc sql;
/***describe table DICTIONARY.options***/
  select setting into :TMPMLOGIC
  from DICTIONARY.options
  where optname = 'MLOGIC'
  ;
quit;

%macro m;
  %if &TMPMLOGIC eq MLOGIC %then %do; options NOMLOGIC; %end;
  proc options; run;
%mend; %m;
