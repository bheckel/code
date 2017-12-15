 /*----------------------------------------------------------------------------
  *     Name: array_find_max.sas
  *
  *  Summary: Determine the highest number from the first four variables
  *           in each observation.
  *
  *           Also see highest_value.sas
  *
  *  Created: Thu 11 Jul 2002 10:13:19 (Bob Heckel)
  * Modified: Tue 24 Nov 2009 12:45:04 (Bob Heckel)
  *----------------------------------------------------------------------------
  */

data tmp;
  input a b c d e f g;
cards;
1 9 3 4 5 22 7
2 1 1 1 5 2 9
;
run;
proc print; run;


data tmp2;
  set tmp;

  /* Dump all the variables into an array: */
  ***array arr[*] _numeric_;
  /* Only want some of the vars: */
  array arr[*] a b c d ;

  maxnum = 0;  /* initialize */

  /* Get the max value of the first 4 numbers */
  do i = 1 to dim(arr);
    if arr[i] > maxnum then
       maxnum = arr[i];
  end; 

  /* Write to SAS Log */
  put 'The maximum number for this obs is: ' maxnum;
run;
proc print; run;
