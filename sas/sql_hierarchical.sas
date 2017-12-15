options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sql_hierarchical.sas
  *
  *  Summary: Demo of manager-employee hierarchy ordering.
  *
  *  Adapted: Thu 09 May 2013 13:41:29 (Bob Heckel--https://support.sas.com/documentation/cdl/en/sqlproc/62086/HTML/default/viewer.htm#a001349393.htm)
  * Modified: Wed 11 Dec 2013 11:00:25 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data t;
  input id lastn $ firstn $ supid;
  cards;
1001    Smith       John           1002    /* Employee */
1002    Johnson     Mary           None    /* Manager */
1003    Reed        Sam            None    /* Manager */
1004    Davis       Karen          1003    /* ... */
1005    Thompson    Jennifer       1002   
1006    Peterson    George         1002   
1007    Jones       Sue            1003   
1008    Murphy      Janice         1003   
1009    Garcia      Joe            1002 
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* Self-join */
proc sql;
  select a.id, a.firstn, a.lastn,
         b.id label='sid', b.firstn label='sfirstn', b.lastn label='slastn'
  from t a, t b
  where a.supid=b.id and a.supid is not missing
  ;
quit;
 
endsas;

      id  firstn    lastn          sid  sfirstn   slastn
----------------------------------------------------------
    1001  John      Smith         1002  Mary      Johnson 
    1005  Jennifer  Thompson      1002  Mary      Johnson 
    1006  George    Peterson      1002  Mary      Johnson 
    1009  Joe       Garcia        1002  Mary      Johnson 
    1004  Karen     Davis         1003  Sam       Reed    
    1007  Sue       Jones         1003  Sam       Reed    
    1008  Janice    Murphy        1003  Sam       Reed    
