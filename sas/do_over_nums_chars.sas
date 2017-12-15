options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: do_over_nums_chars.sas
  *
  *  Summary: Demo of iterating a dataset by data type.
  *           Search and replace entire dataset.
  *
  *  Created: Fri 26 Sep 2008 14:23:43 (Bob Heckel)
  * Modified: Tue 03 Nov 2009 10:46:55 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Create a list of all numeric variables.
  * A simple  options missing=0  is easier in this case.
  */
data nums;
  input n1 n2;
  array nums _NUMERIC_;

   /* Process list, replace blanks with zeros */
  do over nums;
    if nums eq . then
      nums = 0;
  end;

  cards;
0 1
2 3
. 5
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


data nums;
  input c1 $ c2 $;
  array cs _CHARACTER_;

  do over cs;
    if cs eq: 'zaz' then
      cs = 'CHARCONVERTED';
  end;

  cards;
foo_bar baz_boom
zoo_bar zaz_boom
zaz_bar za2boom
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;



data _null_;
  /* DO OVER only works on implicitly subscripted arrays */
  array mya x1-x4 (1,3,5,7);
  do over mya;
    /* Automatic variable _I_ */
    put mya(_i_)=;
  end;
run;

