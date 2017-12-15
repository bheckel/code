options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: foreach.sas
  *
  *  Summary: Iterate over an unspecified number of datasets etc.
  *
  *           %local _i; %let _i=1;
  *           %do %until (%scan(%bquote(&pxall), &_i)=  );
  *             %local _px; %let _px=%scan(%bquote(&pxall), &_i);
  *             %put processing parser &_px;
  *             %read_config(&_px);
  *             %run_parser(&_px);
  *             %let _i=%eval(&_i+1);
  *           %end;
  *
  *  Created: Tue 13 May 2006 14:25:14 (Bob Heckel)
  * Modified: Mon 22 Jun 2015 14:45:44 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* V9+ */
%local i next_name;
%do i=1 %to %sysfunc(countw(&name_list));
  %let next_name = %scan(&name_list, &i);
  %** DO whatever needs to be done for &NEXT_NAME;
%end;



 /* Simple print mvars */
%macro do_over_list(list);
  %let i=1;
  %do %until (%qscan(&list, &i)=  );
    %put %qscan(&list, &i);
    %let i=%eval(&i+1);
  %end;
%mend;
%do_over_list(aa bb cc);



 /* Iteration over a list */

 /* Canonical, using spaces, periods, whatever as default separators */
%macro ForEach(s);
  %local i f;

  %let i=1;

  %do %until (%qscan(&s, &i)=  );
    %let f=%qscan(&s, &i); 
    /*...........................................................*/
    data _null_;
      put "!!! &f";
    run;
    /*...........................................................*/
    %let i=%eval(&i+1);
  %end;
%mend ForEach;
%ForEach(foo bar baz)



 /* Assumes delimiter is a space */
%macro ForEach(s);
  %local i f state;

  %let i=1;  /* iterate over each word starting w/ first one */

  %do %until (%qscan(&s, &i)=  );
    %let f=%qscan(&s, &i, ' '); 
    /*...........................................................*/
    %let state=%substr(&f, 6, 2);
    proc contents data=L.&state.new;
    run;
    /*...........................................................*/
    %let i=%eval(&i+1);  /* IMPORTANT */
  %end;
%mend ForEach;
%ForEach(
BF19.AKX0009.MEDMER2
BF19.ALX0018.MEDMER2
)



 /* Most thorough */
libname L 'DWJ2.MED2000.MVDS.LIBRARY.NEW' DISP=SHR WAIT=5;
%macro ForEach2(s);
  %local i f;

  /* Initialize */
  %let i=1;
  %let f=%qscan(&s, &i, ' '); 

  %do %while ( &f ne  );
    /*...........................................................*/
    %let state=%substr(&f, 6, 2);
    proc contents data=L.&state.new;
    run;
    /*...........................................................*/
    %let i=%eval(&i+1);   /* IMPORTANT */
    %let f=%qscan(&s, &i, ' '); 
  %end;
%mend ForEach2;

