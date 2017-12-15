options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: uniform.sas
  *
  *  Summary: Get small random sample.
  *
  *  Created: Fri 18 Feb 2005 10:49:41 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;


data tmp;
  ***set SASHELP.shoes(keep=product);
  set SASHELP.zipcode;

  u=uniform(0);

  if u le .001;
run;
proc print data=_LAST_(obs=max); run;
