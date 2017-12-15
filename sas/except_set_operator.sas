options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: except_set_operator.sas
  *
  *  Summary: Like Oracle's MINUS set operator.
  *
  *           Subtract the entries from one table out of another, i.e.
  *           select records unique to one table
  *
  *  Created: Thu 27 Apr 2006 15:06:38 (Bob Heckel)
  * Modified: Tue 05 Mar 2013 09:57:13 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter ls=100 ps=max;

title 'employees';
data employees;
  length emp $15;
  array a[*] n1-n4 (1 2 3 4);
  emp='current1';
  output;
  emp='chgddepts';
  output;
  emp='current2';
  output;
  ;
run;
proc print data=_LAST_(obs=max); run;

title 'employeehistory';
data employeehistory;
  length emp $15;
  array a[*] n1-n4 (3 4 5 6);
  emp='gone';
  output;
  emp='chgddepts';
  output;
  ;
run;
proc print data=_LAST_(obs=max); run;


title 'emp from employees EXCEPT from employeehistory';
proc sql;
  /* Only works for a single var or get "WARNING: A table has been extended..."
   * Otherwise we need:
   * SELECT * FROM employees AS a INNER JOIN (SELECT emp FROM employees  EXCEPT  SELECT emp FROM employeehistory) AS b ON a.emp=b.emp
   */
/***  select emp, n1***/

  /* Put the larger table first */
  select emp
  from employees

  EXCEPT

  select emp
  from employeehistory
  ;
quit;


title 'compare - JOIN employees on employeehistory where employeehistory null (WILL BE NO OUTPUT)';
 /* Does not work the same as EXCEPT example above, 0 obs */
proc sql;
  select a.emp
  from employees a JOIN employeehistory b  ON a.emp=b.emp
  where b.emp IS NULL
  ;
quit;


title 'compare - sort-sort-merge';
proc sort data=employees; by emp; run;
proc sort data=employeehistory; by emp; run;
data uniquetoemployeetbl(keep=emp);
  merge employees(in=in1) employeehistory(in=in2);
  if in1 eq 1 and in2 eq 0;
  by emp;
run;
proc print data=_LAST_(obs=max); run;
