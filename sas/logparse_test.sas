options ps=max ls=max NOcenter;
 /* Benchmark SAS code

    1- Add this as the first line of your code:

    %include '~/code/sas/passinfo.sas'; %passinfo;

    2- Point to your code's resulting log

    3- Run this
 */

%include '~/code/sas/logparse.sas';

/***%logparse(~/passinfo_test.log, perftemp, OTH,, append=NO);***/
/***proc contents data=perftemp; run;***/

%logparse(/Drugs/Cron/Weekly/TMMCensusHPLoop/tmm_census_loop_17.log, before, OTH,, append=NO);
%logparse(~/t.log, after, OTH,, append=NO);


/***proc print data=before width=minimum heading=H; var stepcnt stepname realtime;run;title;***/
/***proc print data=after width=minimum heading=H; var stepcnt stepname realtime;run;title;***/

endsas;
proc sql;
/***  select a.stepcnt, a.stepname, a.realtime, b.stepcnt, b.stepname, b.realtime***/
  select a.stepname, a.realtime, b.stepname, b.realtime
  from before a join after b on a.stepname=b.stepname
  where a.realtime gt 0
  ;
quit;
