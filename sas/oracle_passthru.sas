options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: oracle_passthru.sas
  *
  *  Summary: Demo of SAS/ACCESS Oracle pass-through
  *
  *  Created: Thu 18 Oct 2012 10:51:34 (Bob Heckel)
  * Modified: Tue 06 Nov 2012 10:25:12 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

 /* Uppercase is boilerplate */

proc sql;
  /*                   8 char max, 9+ ignored                               */
  CONNECT TO ORACLE AS myoragist (USER=gist2_stat ORAPW=stab09stat PATH=suprd117);
/***  CONNECT TO ORACLE AS myoralims (USER=sasreport ORAPW=sasreport PATH=suprd259);***/
  CONNECT TO ORACLE AS myoralink (USER=pks_user ORAPW=pksu409 PATH=suprd409);

  /* Query only */
  SELECT * FROM CONNECTION TO myoragist (
    /* Oracle-style SQL/schema: */
    select count(*) mygcnt from gist2_c.rslt
  );

/***  SELECT * FROM CONNECTION TO myoralims (***/
    /* Oracle-style SQL/schema: */
/***    select count(*) mylcnt from spec***/
/***  );***/

  SELECT * FROM CONNECTION TO myoralink (
    /* Oracle-style SQL/schema: */
    select count(*) mylkcnt from samp
  );

 /* Build datasets */
  CREATE TABLE mysasgist AS SELECT * FROM CONNECTION TO myoragist (
    /* Oracle-style SQL/schema: */
    select * from gist2_c.rslt where rownum<5
  );

/***  CREATE TABLE mysaslims AS SELECT * FROM CONNECTION TO myoralims (***/
    /* Oracle-style SQL/schema: */
/***    select * from spec where rownum<5***/
/***  );***/

  CREATE TABLE mysaslink AS SELECT * FROM CONNECTION TO myoralink (
    /* Oracle-style SQL/schema: */
    select * from samp where rownum<5
  );

  DISCONNECT FROM myoragist;
/***  DISCONNECT FROM myoralims;***/
  DISCONNECT FROM myoralink;
quit;

proc print data=mysasgist(obs=10) width=minimum; run;
proc print data=mysaslims(obs=10) width=minimum; run;
proc print data=mysaslink(obs=10) width=minimum; run;


