options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: build_dummy_ds_100_random_variables.sas
  *
  *  Summary: Build an X by Y dummy dataset
  *
  *  Created: Wed 24 Sep 2014 09:44:28 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

options ls=180 ps=max; libname l '.';

data l.t(drop= i j);
  array varr{*} v1-v100;  /* array of variable names */

  do i=1 to 10;           /* observations */
    do j=1 to dim(varr);  /* variables */
      varr{j} = ranuni(i);
    end;
    output; /* an obs of 100 vars */
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
