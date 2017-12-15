options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_append_loop_all_datasets_in_lib.sas
  *
  *  Summary: Combine several datasets in a library into one
  *
  *  Created: Wed 05 Aug 2015 08:06:40 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

 /* Take each narrow dataset in libname l and append to single wide dataset */
%macro m;
  libname l '/Drugs/eckel/PQA_NDC_merge';
  proc sql NOPRINT;
    select memname into :ds separated by ' '
    from dictionary.members
    where libname like 'L';
  quit;
  %put _USER_;

  data t; set l.pqa_medlist(obs=0); length source $20; run;  /* source isn't on master, only on subsets */

  %local i f; %let i=1;
  %let f=%scan(&ds, &i, ' ');

  %do %while ( &f ne  );
    %let i=%eval(&i+1);

    proc append base=t data=l.&f FORCE; run;

    %let f=%scan(&ds, &i, ' ');
  %end;
%mend;
%m;
