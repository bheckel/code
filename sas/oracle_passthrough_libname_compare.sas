
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
