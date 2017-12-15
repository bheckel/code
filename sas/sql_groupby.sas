options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sql_groupby.sas
  *
  *  Summary: Group by SQL statements.
  *
  *           See also bygroup_processing.sas
  *
  *  Created: Wed 19 May 2004 17:22:50 (Bob Heckel)
  * Modified: Mon 09 Mar 2009 08:27:45 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* demo #1 */

proc print data=SASHELP.shoes (obs= 10); run;

proc sql;
  create table foo as
  select region, subsidiary, sum(sales) as sumy 
  from SASHELP.shoes
  group by 1, 2
  ;
quit;
proc print data=_LAST_; run;



 /* demo #2 */

proc format;
  value $F_AGEGRP '001'-'003','201'-'699' = 'Infant and Toddlers'
                  '004'-'011'             = 'Children'
                  '012'-'019'             = 'Adolescents'
                  '020'-'049'             = 'Adults'
                  '050'-'198'             = 'Older Adults'
                  '199','999'             = 'Unknown'
                  ;
run;

data foo;
  input count  age $  itemid;
  cards;
1 003 9
2 023 9
3 025 7
4 025 9
5 035 9
6 099 9
  ;
run;

data foo;
  set foo;
  /* For demo only, easier to do this:
   * select distinct fmtage, sum(count) as scount FORMAT=$F_AGEGRP.
   * ...
   */
  fmtage = put(age, $F_AGEGRP.);
  where itemid eq 9;
run;

proc sql;
  select distinct fmtage, sum(count) as scount
  from foo
  group by fmtage
  ;
quit;



 /* demo #3 */
%let MINCNTOFRGN=99;
%let MAXCNTOFRGN=999;
proc sql NOprint;
  /* Error checking */
  select case
    when count(distinct region) lt &MINCNTOFRGN then "ERROR"
    when count(distinct region) gt &MAXCNTOFRGN then "ERROR"
    else " "
  end into :CHK
  from sashelp.shoes
  ;
  /* Data pulling */
  select count(distinct stores) into :R1-:R4
  from sashelp.shoes
  group by region
  ;
quit;
%put _all_;
