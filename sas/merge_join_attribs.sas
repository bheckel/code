 /* Determine which ds SAS takes attributes when similarly named vars are
  * being merged.
  *
  * "WARNING: Multiple lengths were specified for the BY variable name by
  * input data sets. This may cause unexpected results."
  *
  * Because SAS builds the Program Data Vector (PDV) from left to right, the
  * leftmost data set in the MERGE statement will be first to supply variable
  * attributes. If there are overlapping variables, only one can reside on the
  * PDV and it will have the attributes associated with the left most of the
  * data sets that contains it. This includes the BY variables. It is always
  * wise to ensure that the attributes of the BY variables are consistent
  * across all of the data sets
  *
  * Adapted: Sat Nov 12 13:36:32 2005 (Bob Heckel - SAS Technology Report Nov
  * 2005) 
  * Modified: Tue 15 Dec 2015 13:36:20 (Bob Heckel)
  */

data first;
  attrib name label='Name from first data set' format=$5. length=$5
         score label='Score from first data set' format=2. length=8
         class label='Class from first data set'
         ;
  input name $ class $ score ;
  cards;
Tim math 9
Sally math 10
John math 8
  ;
run;
proc print;run;

data second;
  attrib name label='Name from second data set' format=$10. length=$10
         class label='Class from second data set' format=$10. length=$10
         grade label='Grade from second data set' format=$1. length=$1
         ;
  input name $ class $ grade ;
  cards;
Tim mathematic A
Sally science C
John history B
  ;
run;
proc print;run;

proc sort data=first; by name class; run;
proc sort data=second; by name class; run;

data student;
  merge first second;
  by name;  /* same result without any BY, in this case at least */
 /***   by name class; ***/
run;
title 'merge'; proc print data=student; run;
proc contents data=student; run;

 /* Same except class comes from first ds (due to SELECT * , we have to
  * specifiy b.name, b.class, a.score, a.grade to do an identical table) 
  */
proc sql;
  create table student as
  select *
  from first, second
  where first.name=second.name
  ;
quit;
title 'join'; proc print data=student; run;
proc contents data=student; run;
