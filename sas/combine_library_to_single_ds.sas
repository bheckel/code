options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: combine_library_to_single_ds.sas
  *
  *  Summary: Combine several ds in a library (or libraries) into one (for 
  *           querying), query it and specify which dataset contributed to
  *           the larger one.
  *
  *           TODO is %while simpler than %qscan ??
  *
  *  Created: Tue 25 Apr 2006 09:13:05 (Bob Heckel)
  * Modified: Wed 06 Jun 2007 08:33:28 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter NOreplace;

options noreplace mlogic sgen;
 /* DEBUG toggle */
***options obs=5;
libname A ('c:/cygwin/home/bheckel/projects/alldatasets/orig3chunk' 
           'c:/cygwin/home/bheckel/projects/alldatasets/jimsept06/chunksnew');


proc sql NOPRINT;
  select memname into :D separated by ' '
  from dictionary.members
  where libname eq 'A' and memname like '%SUM%'
/***  where libname eq 'A' and memname like '%IND%'***/
  ;
quit;

%macro SetStmt(s);
  %local i f;

  %let i=1;

  %do %until (%qscan(&s, &i)=  );
    %let f=%qscan(&s, &i); 
    /*......................................................*/
    A.&f(IN=in&i)
    /*......................................................*/
    %let i=%eval(&i+1);
  %end;
%mend SetStmt;

%macro IfStmt(s);
  %local i f;

  %let i=1;

  %do %until (%qscan(&s, &i)=  );
    %let f=%qscan(&s, &i); 
    /*......................................................*/
    if in&i then frds="&f"%str(;);
    /*......................................................*/
    %let i=%eval(&i+1);
  %end;
%mend IfStmt;

data v / view=v;
  length frds $50;
  set %SetStmt(&D);
  %IfStmt(&D)
run;

 

options ls=180;
 /********** Query the aggregated dataset view **********/

proc sql;
  select distinct samp_id, frds
  from v
  where samp_id = 200558
  ;
quit;

 /*******************************************************/



/* DUMP REUSABLE QUERIES HERE: */
endsas;

proc sql;
  select distinct samp_id
  from v
  where specname like 'AM0930%'
  ;
quit;

proc sql;
  select distinct samp_id
  from v
  where NOT (samp_id IN(select samp_id 
                    from v
                    where (specname="DISPNSMPDATA")));
quit;

proc sql;
  select distinct frds, resstrval
  from v
  where ((specname like 'ITEMC%'  and varname like 'PRODCODED%') or 
        (specname like 'MISC%' and varname like 'ITEMCODEDE%')) and 
	upcase(resstrval) like '%SAL%'
  ;
quit;

proc sql;
  select distinct samp_id,frds
  from v
  where specname like 'ATM02063%'
  ;
quit;


proc sql;
  create table l.srfix as
  select *
  from v
  where specname like 'ATM02063%'
  ;
quit;


proc sql;
  select distinct samp_id,resstrval,frds
  from v
  where specname = 'ITEMCODE' and upcase(resstrval) like '%PURP%'
  ;
quit;

proc sql;
  select distinct specname, frds
  from v
  where colname = 'TRAY$'
  ;
quit;

proc sql;
  create table l.tmp1 as
  select distinct samp_id
  from v
  ;
quit;

proc sql;
  select distinct resentuserid, resstrval, specname
  from v
  where varname = 'ANALYST$' and specname like 'APPEA%'
  ;
quit;

 /* Compare dataset's levels with database's levels */
proc sql;
  create table lnks as
  select distinct samp_id, specname, resstrval 
  from v
  where (specname like 'ITEMC%'  and varname like 'PRODCODED%') or 
        (specname like 'MISC%' and varname like 'ITEMCODEDE%')
  order by samp_id
  ;
quit;
libname ORA oracle user=pks password=pks path=usdev100;
proc sql;
  select distinct l.samp_id, specname, s.prod_nm,s.prod_level format=$8.,
         resstrval format=$52. 
  from lnks l JOIN ORA.samp s  ON l.samp_id=s.samp_id
  ;
quit;



data L.lelimsindres01a;
  set v;
  if samp_id in('187242','174505','177987','177819','150209','154056',
                '146099','144705','150077','143484','143418','179219',
		'157390','158126','145677','145612','174102','166806',
		'143409','142571','143654','149979','141765','157553',
		'157701','162888');
run;

proc sql;
  create table L.t1 as
  select distinct frds, specname
  from tmp
  ;
quit;


options ls=150;
proc sql;
  select distinct /*samp_id,*/ specname format=$35., varname format=$35., 
         resstrval format=$25./*, frds format=$25.*/
  from v
  where upcase(resstrval) like '%CONFORM%' and specname in ('ADVAIRMDPIAIRFLOW','ADVAIRMDPIAPPEAR','ADVAIRMDPIASSAYHPLC','ADVAIRMDPIBLENDASSAYHPLC','ADVAIRMDPIDOSEHPLC',
  'ADVAIRMDPIIMPHPLC','AM0344ASSAYHPLC','AM0428ASSAYHPLC','AM0430CUHPLC','AM0441ASSAYHPLC','AM0562ASSAYHPLC','AM0606CUHPLC','AM0607ASSAYHPLC','AM0611ASSAYHPLC','AM0612CUHPLC',
  'AM0627ASSAYHPLC','AM0636CUHPLC','AM0638ASSAYHPLC','AM0646CUHPLC','AM0648DISSHPLC','AM0656AM0613DISSHPLC','AM0664DISSHPLC','AM0667ASSAYCUHPLC','AM0705759DRUGRELEASEUV',
  'AM0707ASSAYHPLC','AM0735CUHPLC','AM0738ASSAYHPLC','AM0740ASSAYHPLC','AM0751LOD','AM0754CUHPLC','AM0755DISSHPLC','AM0756ASSAYHPLC','AM0779ASSAYHPLC','AM0823ASSAYCUHPLC',
  'AM0823ASSAYHPLC','AM0839IMPHPLC','AM0840DRUGRELEASEUV','AM0842ASSAYHPLC','AM0854DISSHPLC','AM0857DISSUV','AM0861ASSAYHPLC','AM0866ASSAYHPLC','AM0869CUHPLC',
  'AM0880PARTICULATEMATTER','AM0882ASSAYHPLC','AM0883DISSHPLC','AM0885IMPHPLC','AM0888DRUGRELEASEUV','AM0889PARTICULATEMATTER','AM0892BLENDASSAYHPLC','AM0895IMPHPLC',
  'AM0898CONTENTHPLC','AM0899ASSAYHPLC','AM0900DRUGRELEASEUV','AM0908CASCADEHPLC','AM0908STABCASCADEHPLC','AM0911DOSEHPLC','AM0930SIOALL','AM0931MICROBIALLIMITTESTS',
  'AM0933IDUV','AM0934WATERCONTENT','AM0944AIRFLOW','AM0952LEAKMAN','AM0957DISSUV','AM0975ASSAYHPLC','AM0995DOSEHPLC','APPEARDESCRIP','ATM02003FULLCASCADEHPLC',
  'ATM02006ASSAYHPLC','ATM02010ASSAYHPLC','ATM02016DISSHPLC','ATM02019CUHPLC','ATM02033CUHPLC','ATM02047CONTENTHPLC','ATM02048DOSEHPLC','ATM02049CONTENTHPLC',
  'ATM02050CASCADEHPLC','ATM02051BLENDASSAYHPLC','ATM02054ASSAYHPLC','ATM02056DISSUV','ATM02063DOSEHPLC','ATM02064CONTENTHPLC','COMMENT','DATESAMPLED','DispnSmpData',
  'GENCUBYTPW','GENMANCUBYTPW','GENUSPDISS','ITEMCODE','MDIWATERCONTENT','MDPIMICROSCOPICEVALUATION','MiscellaneousLogin','UNIFORMITYOFDOSAGEWEIGHT')
  order by specname
  ;
quit;

data tmp;
  set v;
  if frds =: 'SUMVE';
run;
proc print data=tmp; run;
