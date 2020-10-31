

proc sql;
  CONNECT TO ORACLE(USER=setars ORAPW=mypw BUFFSIZE=25000 READBUFF=25000 PATH=sed);

  CREATE TABLE t AS SELECT * FROM CONNECTION TO ORACLE 
  (

    SELECT OBJECT_NAME, PROCEDURE_NAME ,OBJECT_TYPE  
      FROM dba_procedures --dba_objects
     WHERE OBJECT_TYPE IN('PROCEDURE' , 'PACKAGE','FUNCTION') AND procedure_name IS NOT NULL
       AND rownum < 9;
     ORDER BY object_name, procedure_name

  );

  DISCONNECT FROM ORACLE;
quit;
proc print data=_LAST_(obs=max); run;


LIBNAME ORION ORACLE PATH=SED SCHEMA=SETARS USER=setars PASSWORD="mypw";

data t;
  set ORION.account_base(obs=9);
run;

title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;



 /****************************************************************************/
 /* Passthrough */
proc sql;
  /*                   8 char max                                           */
  CONNECT TO ORACLE AS myoragist (USER=ist2_stat ORAPW=tab09stat PATH=sprd117);
  CONNECT TO ORACLE AS myoralims (USER=asreport ORAPW=asreport PATH=sprd259);

  /* Query only */
  SELECT * FROM CONNECTION TO myoragist (
    /* Oracle-style SQL/schema: */
    select count(*) mygcnt from gist2_c.rslt
  );

  SELECT * FROM CONNECTION TO myoralims (
    /* Oracle-style SQL/schema: */
    select count(*) mylcnt from spec
  );

 /* Build datasets */
  CREATE TABLE mysasgist AS SELECT * FROM CONNECTION TO myoragist (
    /* Oracle-style SQL/schema: */
    select * from gist2_c.rslt where rownum<5
  );

  CREATE TABLE mysaslims AS SELECT * FROM CONNECTION TO myoralims (
    /* Oracle-style SQL/schema: */
    select * from spec where rownum<5
  );

  DISCONNECT FROM myoragist;
  DISCONNECT FROM myoralims;
quit;
 /****************************************************************************/

 /****************************************************************************/
 /* Libname */
libname ORA oracle user=ks password=ev123dba path=sdev388;

proc sql;
  create table t as
  select *
  from ORA.pks_extraction_control
  order by prod_nm, meth_spec_nm, meth_var_nm
  ;
quit;
 /****************************************************************************/
