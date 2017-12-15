
 /* Don't think there's a simple SAS equivalent, no avg() exists, mean() 
  * needs a list 
  */
proc sql;
  select avg(total_wt)
  from tmp2.asamp_individuals
  where mfg_batch= '67M1561';
quit;



 /* unrelated example */

 /* Average of 80 numbers spread across 16 observations in each group.  See
  * FreeWeigh.sas for a SAS FIRSTOBS approach.  TODO is there a better way w/o
  * a macro?
  */
proc sql;
  select sum(rvalue1), sum(rvalue2), sum(rvalue3), sum(rvalue4), sum(rvalue5) into :s1, :s2, :s3, :s4, :s5
	from tmp1.freeweigh_debugon
	group by sbatchnbr, sitemname
	having sbatchnbr eq '2000820593-9zm8355' and sitemname like 'Hardness-10%'
  ;
quit;
%macro m;
  %put %sysevalf((&s1+&s2+&s3+&s4+&s5)/80);
%mend; %m

endsas;
rvalue5    rvalue4   rvalue3...  sitemname     sbatchnbr
28          28.3       22.3      Hardness-10   2000820593-9zm8355
29          28.3       92.3      Hardness-10   2000820593-9zm8355
38          23.3       29.3      Hardness-10   2000820593-9zm8355
28          18.3       92.3      Hardness-10   2000820593-9zm8355
...
16 rows tot (5*16=80)
