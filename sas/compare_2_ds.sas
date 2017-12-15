options nosource;
 /*---------------------------------------------------------------------------
  *     Name: compare_2_ds.sas
  *
  *  Summary: Determine if all obs on one ds are on another ds in a variety of
  *           ways.
  *
  *           See also compare_contents_variables.sas
  *
  *  Created: Wed 30 Oct 2002 11:15:09 (Bob Heckel)
  * Modified: Thu 08 Sep 2016 09:44:52 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%macro db6;
  libname l '.';

  %dbpassword;
    proc sql;
      connect to odbc as myconn (user=&user. password=&jasperpassword. dsn='db6' readbuff=7000);

      create table l.t as select * from connection to myconn (

        select distinct genericproductidentifier as gpi, outcomecode, roleoftherapycode, 'Y' as chronic
        from medispan.indgind
        where trim(leading '0' from roleoftherapycode) in ('1','3') 
              and trim(leading '0' from outcomecode) not in ('1')
        order by genericproductidentifier, outcomecode, roleoftherapycode
        ;

      );

      disconnect from myconn;
    quit;
    %put !!!&SQLRC &SQLOBS;
%mend;
/***%db6;***/


%macro compare;
  libname l '.';
  libname l2 '/Drugs/TMMEligibility/Delhaize/Imports/20160725/Data';

  title 'before';
  proc sql;
    select * 
    from l2.medispanchronic
/***    where gpi = '4927002000H320'***/
/***    where gpi = '05000040000320'***/
    where gpi = '25150035101820'
    ;
  quit;

  title 'after';
  proc sql;
    select * 
    from l.t
/***    where gpi = '25100020000305'***/
/***    where gpi = '4927002000H320'***/
    where gpi = '25150035101820'
    ;
  quit;


  title 'on sas not db';
  proc sql;
    create table notonsas as
    select gpi, outcomecode, roleoftherapycode from l.t
    EXCEPT
    select gpi, outcomecode, roleoftherapycode from l2.medispanchronic
    ;
  quit;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;  

  title 'on db not sas';
  proc sql;
    create table notondb as
    select gpi, outcomecode, roleoftherapycode from l2.medispanchronic
    EXCEPT
    select gpi, outcomecode, roleoftherapycode from l.t
    ;
  quit;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;  


  proc sql;
    create table ondbonly as
    select b.gpi as gpiold, b.outcomecode as outcomecodeold, b.roleoftherapycode as roleoftherapycodeold, a.gpi as gpinew, a.outcomecode as outcomecodenew, a.roleoftherapycode as roleoftherapycodenew
    from notonsas a left join notondb b on a.gpi=b.gpi
    ;
  quit;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;  

  proc sql;
    create table onsasonly as
    select b.gpi as gpiold, b.outcomecode as outcomecodeold, b.roleoftherapycode as roleoftherapycodeold, a.gpi as gpinew, a.outcomecode as outcomecodenew, a.roleoftherapycode as roleoftherapycodenew
    from notonsas a right join notondb b on a.gpi=b.gpi
    ;
  quit;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;  
  

  title 'final';
  data l2.compare_medispan_20160908;
    set ondbonly onsasonly;
  run;
  proc sort nodupkey;
    by gpinew gpiold outcomecodenew outcomecodeold roleoftherapycodenew roleoftherapycodeold ;
  run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;  

%mend;
%compare;




endsas;
options ls=180 ps=max; libname l '.';
%macro m;
proc sql;
  connect to odbc as myconn (user=&user. password=&password. dsn='db2ateb' readbuff=7000);
     %if %sysfunc(exist(l.ndc)) %then
        %do;
          %put l.ndc exists;
        %end;
      %else
        %do;
          create table l.ndc as select * from connection to myconn (
            select * from medispan.ndc
          );
        %end;
  disconnect from myconn;
quit;

proc sql;
  connect to odbc as myconn (user=&user. password=&password. dsn='jasper' readbuff=7000);
     %if %sysfunc(exist(l.ndc2)) %then
        %do;
          %put l.ndc2 exists;
        %end;
      %else
        %do;
          create table l.ndc2 as select * from connection to myconn (
            select * from medispan.ndc
          );
        %end;
  disconnect from myconn;
quit;

proc sql;
  select ndc_upc_hri from l.ndc
  EXCEPT
  select ndc_upc_hri from l.ndc2
  ;
quit;
%mend;
*%m;



title 'tmp1';
data work.tmp1;
  infile cards;
  length numb 4;
  input numb;
  cards;
41283
41340
41325
41555
41666
  ;
run;
proc sort;
  by numb;
run;
proc print data=_LAST_(obs=max); run;

title 'tmp2';
data work.tmp2;
  infile cards;
  length numb 4;
  input numb;
  cards;
41283
41325
99999
  ;
run;
proc sort;
  by numb;
run;
proc print data=_LAST_(obs=max); run;


title 'on both - sas merge';
data sasversion;
  merge work.tmp1 (in=large) work.tmp2 (in=small);
  by numb;
  if large and small;
run;
proc print data=_LAST_(obs=max); run;


title 'on both - proc sql where';
proc sql;
  create table sqlversion1 as
  select *
  from tmp1 as a, tmp2 as b
  where a.numb = b.numb
  ;
quit;
proc print data=_LAST_(obs=max); run;


title 'not on both - proc sql where';
proc sql;
  create table sqlversion2 as
  select *
  from tmp2
  where not (numb in (select numb
                      from tmp1))
  ;
quit;
proc print data=_LAST_(obs=max); run;


title 'proc sql left join - make sure larger tbl is on left - gives you '
      'all recs from that tbl and matches where it can (as many times as '
      'it can)'
      ;
proc sql;
  create table sqlversion3 as
  select a.numb, b.numb as nb
  from tmp1 as a left join tmp2 as b on a.numb=b.numb
  ;
quit;
proc print data=_LAST_(obs=max); run;


title 'proc sql left join - only on first tbl';
proc sql;
  create table sqlversion3 as
  select a.numb, b.numb as nb
  from tmp1 as a left join tmp2 as b on a.numb=b.numb
  where b.numb is null
  ;
quit;
proc print data=_LAST_(obs=max); run;


title 'are tables identical?  if not, list what is NOT on 1 that IS on 2';
proc sql;
  select * from tmp2
  EXCEPT
  select * from tmp1
  ;
quit;

 /* This is good tell say yes/no there are diffs, otherwise it's confusing as
  * hell, use the preceding EXCEPT instead
  */
title 'proc compare';
proc compare base=tmp1 compare=tmp2;


 /* If tables are small */
libname l '.';
proc sort data=l.material_mapping_tablebefore out=TMPnewmaterial_mapping_table(drop=LASTMODCCF); by mat_cod; run;
proc export data=l.material_mapping_tablebefore OUTFILE='TMPnewMaterial_Mapping_Table.csv' DBMS=CSV REPLACE; run;

proc sort data=l.material_mapping_tableprd out=TMPprodmaterial_mapping_table(drop=LASTMODCCF); by mat_cod; run;
proc export data=l.material_mapping_tableprd OUTFILE='TMPprodMaterial_Mapping_Table.csv' DBMS=CSV REPLACE; run;
 /* then vim -d TMP* */
