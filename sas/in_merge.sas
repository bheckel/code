options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: in_merge.sas
  *
  *  Summary: Demo of using the IN statement with subsettings IFs to merge.
  *
  *           See also sql_vs_merge.sas and sql_union.sas
  *
  *  Adapted: Wed 08 Mar 2006 15:12:11 (Bob Heckel --
  *                         http://www2.sas.com/proceedings/sugi30/249-30.pdf)
  * Modified: Tue 21 Jun 2016 11:30:20 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;


data one;
  infile cards;
  input id $ name $;
  cards;
A01 SUE
A02 TOM
A05 KAY
A10 JIM
  ;
run;
proc print data=_LAST_(obs=max); run;

data two;
  infile cards;
  input id $ age $ sex $;
  cards;
A01 58 F
A02 20 M
A04 47 F
A10 11 M
  ;
run;
proc print data=_LAST_(obs=max); run;


data _null_; file PRINT; put '------------'; run;


title 'simple match-merge - no IN keywords (same as allrecs below)'
      ' aka FULL JOIN in SQL';
data foo;
  merge one two;
  by id;
run;
proc print data=_LAST_(obs=max); run;


data ones twos inboth nomatchin1 nomatchin2 allrecs nomatch inboth2;
  merge one(in=in1) two(in=in2);
  by id;

  /* LEFT OUTER join */
/***  if in1=1             then output ones;***/
  if in1               then output ones;

  /* RIGHT OUTER join */
  if in2               then output twos;

  /* INNER join */
/***  if (in1=1 and in2=1) then output inboth;***/
  if in1 and in2       then output inboth;
  if in1 = in2         then output inboth2;

  /* In one, not in other */
  if (in1=0 and in2=1) then output nomatchin1;

  /* In one, not in other going the other direction */
/***  if (in1=1 and in2=0) then output nomatchin2;***/
  /* same */
  if (in1 and not in2) then output nomatchin2;

  if (in1+in2)=1       then output nomatch;

  /* Useless, same as no condition, same as match-merge */
/***  if (in1=1 or in2=1)  then output allrecs;***/
  if in1 or in2  then output allrecs;
run;

title 'ones - Left outer join in SQL'; proc print data=ones; run;
title 'twos - Right outer join in SQL'; proc print data=twos; run;
title 'inboth - INNER JOIN  or a WHERE a.foo=b.foo SQL query'; proc print data=inboth; run;
title 'inboth2';proc print data=inboth2;run;
 /* See on_one_not_other.simple.sql.sas to pull these 2 off using SQL, must do
  * a ljoin with IS NULL the rightside ds
  */
title 'nomatchin1'; proc print data=nomatchin1; run;
title 'nomatchin2'; proc print data=nomatchin2; run;
 /* FULL JOIN in SQL (same as match merge without IN= stuff) */
title 'allrecs - same as match-merge'; proc print data=allrecs; run;
 /* Good for printing an error list when you expect all records to match */
title 'nomatch - only found on one of the two'; proc print data=nomatch; run;



endsas;
INNER JOIN SQL:

PROC SQL;
  CREATE TABLE QinBOTH AS
  SELECT *
  FROM one, two
  WHERE one.Id=two.Id
  ;
QUIT;

same (sometimes called "TABLE JOIN"):

PROC SQL;
  CREATE TABLE QinBOTH AS
  SELECT *
  FROM one INNER JOIN two  ON ONE.Id=TWO.Id    <---can leave off 'INNER'
  ;
QUIT;


match-merge's evil twin
PROC SQL; 
  CREATE TABLE Both AS 
  SELECT a.*, b.*  
  FROM one AS a FULL JOIN two AS b ON a.patient=b.patient
  ;
QUIT; 
