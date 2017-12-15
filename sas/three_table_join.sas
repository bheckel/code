options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: three_table_join.sas
  *
  *  Summary: Join three tables using a WHERE approach and an ON approach.
  *
  *           Also a good demo of SQL's CASE statement.
  *
  * select a.*, b.unitprice, b.pricecode, c.gppcpricecode, c.unitprice as upricec, d.drugname, d.genericproductidentifier
  * from ((medispan.medndc a LEFT JOIN medispan.medprc b on a.ndcupchri=b.ndcupchri) left join medispan.medgpr c on a.genericproductpackagingcode=c.genericproductpackagingcode) left join medispan.medname d on a.drugdescriptoridentifier=d.drugdescriptoridentifier
  *       ------------------ A to B ------------------------------------------------
  *      ---------------------------------------------------- AB to C ----------------------------------------------------------------------------------------------------------
  *      ----------------------------------------------------------------------------------------- ABC to D ----------------------------------------------------------------------------------------------------------------------------------------------------------
  * where a.ndcupchri in('62295290701','62295290501','62295290401','62295290301')
  *
  *  Adapted: Sat 14 Jan 2006 19:46:31 (Bob Heckel -- Combining and Modifying)
  * Modified: Tue 25 Aug 2015 15:29:19 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data employee;
   input id : $4. name & $14. emptype : $1. @25 location $20.;
  cards; /* {{{ */
341 Kreuger, John  H    Bldg A, Rm 1111
511 Olszweski, Joe  S   Bldg A, Rm 1234
5112 Nuhn, Len  S       Bldg A, Rm 2123
5132 Nguyen, Luan  S    Bldg B, Rm 5022
5151 Oveida, Susan  S   Bldg D, Rm 2013
3551 Sook, Joy    H     Bldg E, Rm 2533
3782 Comuzzi, James  S  Bldg E, Rm 1101
381 Smith, Ann  S       Bldg C, Rm 3321
  ;  
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max);run;

data daily;
  input idnum $4. itemno quantity;
  cards;
341       101      2
341       103      1
511       101      1
511       103      1
5112      105      1
5132      105      1
3551      104      1
3551      105      2
3782      104      1
341       101      2
511       101      1
511       103      3
5112      105      1
5112      101      3
5132      105      2
3551      104      1
3551      105      2
3551      103      2
3782      104      1
3782      105      3
  ;  
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max);run;

data prices;
  input itemno price;
  cards;
101      0.30
102      0.65
103      2.75
104      1.25
105      0.85
  ;  
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max);run;


title 'WHERE - Total charge for all items purchased by employee';
proc sql;
  create table charge as
  select e.id, e.name, e.location,
         sum(quantity*price) as total format=dollar8.2,
         case emptype
           when 'H' then 'underling'
           when 'S' then 'overlord'
           else 'special'
          end as etype
      from employee as e, daily as d, prices as p
      /* Link is:
       *   PRICES' item number to DAILY's item number then 
       *   EMPLOYEE's employee id to DAILY's employee id.
       */
      where p.itemno=d.itemno and
            e.id=d.idnum
      group by e.id, e.name, e.location, etype
      ;
quit;
proc print data=_LAST_(obs=max); run;


 /* Same but harder to figure out */
title 'ON - Total charge for all items purchased by employee';
proc sql;
  create table charge as
  select e.id, e.name, e.location,
         sum(quantity*price) as total format=dollar8.2,
         case emptype
           when 'H' then 'underling'
           when 'S' then 'overlord'
           else 'special'
          end as etype
  from (prices p JOIN daily d  ON p.itemno=d.itemno) JOIN employee e  ON e.id=d.idnum
  /* 1  ^^^^^^^^      ^^^^^^^                                                           p to d  */
  /* 2  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^       ^^^^^^^^^^                    pd to e */
  group by e.id, e.name, e.location, etype
  ;
quit;
proc print data=_LAST_(obs=max); run;
