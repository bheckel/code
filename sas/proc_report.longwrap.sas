options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_report.longwrap.sas
  *
  *  Summary: Maintain first two columns as "headers" when the data wraps i.e.
  *           the columns are too numerous to stay in one row.
  *
  *           Good demo of creating a dummy dataset full of 'x's too.
  *
  *  Created: Fri 09 May 2006 15:41:14 (Bob Heckel)
  * Modified: Tue 08 Jun 2010 15:41:42 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter ls=80;

data t(drop= i j);  /* drop is unnecessary for this demo */
  array va[20] $15 v1-v20;
  do i=1 to 10;  /* rows */
    do j=3 to 20;  /* cols */
      va[1]=put(i,Z5.);
      va[2]=put(i**2,Z8.);
      va[j]=repeat('X',ranuni(0)*15);
    end;
    output;
end;

options nocenter;

title 'proc print version';
proc print;
  id v1 v2;
run;

title 'proc report version';
proc report HEADLINE HEADSKIP NOWD;
  column v1-v20;
  define v1 / ID;
  define v2 / ID;
run;
