 /*---------------------------------------------------------------------------
  *     Name: view.sas
  *
  *  Summary: Demo of using views.  Views lack data values, are logical
  *           instead of physical and usually the consumer (PROCs, SETs,
  *           MERGEs, etc) don't differentiate.
  *
  *           They are dynamic.  They are read-only.  They cannot be
  *           indexed.  They are best for reading a dataset *once*.
  *
  *           Best when you're going to read the dataset only ONCE!  Downside
  *           is that VIEW is not portable and can't be accessed randomly e.g.
  *           POINT etc.
  *
  *           See also view_speed_comparison.sas
  *
  *  Created: Mon, 08 Nov 1999 14:41:30 (Bob Heckel)
  * Modified: Tue 11 Jul 2006 17:20:27 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options fullstimer;

/* View is faster unless ds are passed many times. */

data sample1;
   input density  crimerate  state $ 14-27  stabbrev $ 29-30;
   cards;
51.2 4615.8  Minnesota      MN
55.2 4271.2  Vermont        VT
9.1 2678.0   South Dakota   SD
102.4 3371.7 North Carolina NC
9.4 2833.0   North Dakota   ND
120.4 4649.9 North Carolina NC
  ;
run;
proc print; run;


 /* Can't have a dataset and a view with the same name in the same lib. */
libname BOBH 'c:/temp';

 /* Must first remove sample2.sas7bdat if any exist from a previous sample
  * code example's run.  Name must be the same, sample2 in this case !
  */
data BOBH.sample2 / view=BOBH.sample2;
  set sample1;
  where state ? 'North';
run;
proc print data=BOBH.sample2; run;



 /* Store source code */
data foo / view=foo (source=SAVE);
  set sashelp.shoes (obs=1);
run;
  
 /* View source code */
data view=foo;
  describe;
run;
