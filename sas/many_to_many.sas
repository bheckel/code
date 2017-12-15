options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: many_to_many.sas
  *
  *  Summary: Slightly different results using MERGE vs. PROC SQL using
  *           ambiguous data.
  *
  *  Created: Thu 13 May 2010 14:52:55 (Bob Heckel)
  * Modified: Wed 31 Jul 2013 13:42:13 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data workers;
  infile cards MISSOVER;
  input name $  occup $;
  cards;
Rearden architect
Taggart engineer
Taggart hooker
Galt shadowman
Toohey strawman
  ;
run;
proc sort data=workers; by name; run;
proc print; run;

data scores;
  infile cards;
  input name $  qtr1-qtr3;
  cards;
Rearden 10 11 12 13
Rearden 4 3 2 1
Rearden 20 25 25 21
Taggart . . 10 10
Taggart 5 5 8 2
Galt 10 20 30 40
  ;
run;
proc sort data=scores; by name; run;
proc print; run;

title 'SAS match merge - probably not what you mean';
 /* Gives "NOTE: MERGE statement has more than one data set with repeats of BY values." */
data mergedSAS;
  merge workers scores;
  by name;
run;
proc print; run;

title 'proc sql - slightly different, no NOTE: - possibly what you mean';
proc sql;
  create table mergedSQL as
  select a.name as name,
         a.occup,
         b.qtr1,
         b.qtr2,
         b.qtr3
  from workers a, scores b
  where a.name=b.name
  ;
quit;
proc print; run;

title 'proc sql FULL JOIN - slightly different, no NOTE: - most likely what you mean';
proc sql;
  create table mergedSQL as
  /* coalesce() not needed in this example */
/***  select coalesce(a.name,b.name) as name,***/
  select a.name as name,
         a.occup,
         b.qtr1,
         b.qtr2,
         b.qtr3
  from workers a FULL JOIN scores b  ON a.name=b.name
  ;
quit;
proc print; run;
/*
Obs    name        occup      qtr1    qtr2    qtr3

 1     Galt       shadowma     10      20      30 
 2     Rearden    architec     10      11      12 
 3     Rearden    architec      4       3       2 
 4     Rearden    architec     20      25      25 
 5     Taggart    engineer      .       .      10 
 6     Taggart    engineer      5       5       8 
 7     Taggart    hooker        .       .      10 
 8     Taggart    hooker        5       5       8 
 9     Toohey     strawman      .       .       . 
*/
