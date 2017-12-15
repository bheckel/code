/*----------------------------------------------------------------------------
 *   Program Name:  spndrecon.sas
 *
 *        Summary:  New version after EAE changes.  Runs Inst & Eng.
 *                  Make Sure JOBCOST & JOBPERF Are Current
 *                  Pgm moves costx and renames wk98xx.ssd01 on ~/ARCHIVE
 *
 *                  Assumes this is being run Mon or Tues of pre-close wk.
 *
 *                  Change %let manually.
 *
 *  TODO -- chg fmt to use commas
 *  TODO -- avoid manual keying of dates, use SAS functions.  Manipulate
 *          costx before referring to it later.
 *  TODO -- make modular, too difficult to maintain as it is now.
 *
 *         Created: 26Aug98 (Bob Heckel)
 *        Modified: 21Sep98 (Bob Heckel)
 *        Modified: Mon 12/14/98 01:34:25 (Bob Heckel)
 *        Modified: Tue Jan 05 1999 08:43:16 (Bob Heckel -- use
 *                  macrovariables for dates. Add C214.)
 *        Modified: Tue Jan 26 1999 12:14:07 (Bob Heckel -- Add C218)
 *        Modified: Mon Mar 29 1999 12:35:12 (Bob Heckel -- clean up %lets)
 *        Modified: Tue Apr 27 1999 15:50:56 (Bob Heckel -- libname, path
 *                                            changes, new comments)
 *        Modified: Tue May 25 1999 10:26:41 (Bob Heckel -- bug fix path
 *                                            change)
 *        Modified: Tue Jul 27 1999 11:33:27 (Bob Heckel -- use symput instead
 *                                            of manual dates. Elim 
 *                                            proc prints)
 *        Modified: Tue, 24 Aug 1999 13:50:39 (Bob Heckel -- specify HTAYB to
 *                                             prevent O, etc. in 1999)
 *        Modified: Mon, 22 Nov 1999 11:10:22 (Bob Heckel -- use proc copy and
 *                                             proc datasets)
 *        Modified: Wed, 05 Jan 2000 10:45:28 (Bob Heckel--manual, temporary
 *                                             adjustments for final run of 
 *                                             199952.  Add C219, elim C218)
 *        Modified: Mon, 31 Jan 2000 16:15:47 (Bob Heckel -- modi for travel,
 *                                             RFT, contractor, etc.)
 *        Modified: Thu, 02 Mar 2000 09:54:51 (Bob Heckel -- new IOC regions)
 * RESET TEMP MAN ADJS FOR MAR CLOSE!!!!!!!!!!!!
 *----------------------------------------------------------------------------
 */
title;footnote;

options linesize=95 pagesize=32767 nodate source source2 notes mprint
       symbolgen mlogic obs=max errors=3 nonumber nostimer;

/* Where to find jobcost, jobperf */
libname master '/disc/data/master/';
/*** libname master '~/freeze_dec27/ren_indices/'; ***/

/* TODO RESET TEMP COMMENTED OUT SECTIONS WHEN NORMAL PRODUCTION RUNS ARE BACK
 * IN MAR.
 */
/* Where the latest costx.ssd01 is to be copied FROM. */
/*** libname custfin '/DART2/ServOpsFinance/'; ***/

/* Where latest costx.ssd01 is to be copied TO and where to look for prior
 * yrend wk9952.ssd01. 
 */
libname arch '~/ARCHIVE';


/* Change monthly++++++++Change monthly+++++++++Change monthly+++++++++ */
/* No longer used?? */
/*** %let YYYYMON = 2000Jan; ***/
/* Used in report header to display month.  Not used for calcs. */
%let MONYY = Feb00;
/* Week used on Final Jobs output spreadsheet titles YYWW.  Last week of
 * spndrecon month. 
 */
/* Current (i.e. close wk) NT week identifies current wkxxxx costx to use.
 * TODO use substr and symput to generate. 
 */
%let CURRWK = 0009;
/* Change monthly++++++++Change monthly++++++++++++++Change monthly++++ */


/* DEBUG */
/*** %let WKPLUS12 = 200012; ***/
/* Close week plus 12 weeks.  Used for Open. E.g. 199942 */
data _null_;
  /* 12 wks times 7 days = 84 */
  call symput('WKPLUS12', input(put(today() + 84, ntyyww.), 6.));
run;

/* DEBUG */
/*** %let CLOSEWK = 200001; ***/
/* Close, i.e. current (NOT spreadsheet date!!) wk minus 1. Used for Final. */
/* E.g. 199927 */
data _null_;
/***   call symput('WKMINUS1', input(put(today() - 7, ntyyww.), 6.)); ***/
  call symput('CLOSEWK', input(put(today(), ntyyww.), 6.));
run;
 

/* Change yearly+++++++++++Change yearly+++++++++++Change yearly++++++ */
/* Dataset used as the EOY costx.  E.g. /extdisc/ARCHIVE/wk9850.ssd01 */
%let EOYDS = 9952;
/* Last wk of prior yr. */
%let LASTWKYR = 199952;
/* Used for display header on report. */
%let PRIORYR = 1999;
/* Change yearly+++++++++Change yearly+++++++++++Change yearly++++++++ */


/* TODO RESET TEMP COMMENTED OUT SECTIONS WHEN NORMAL PRODUCTION RUNS ARE BACK
 * IN MAR.
 */
/* Copy costx.ssd01 from central's /DART2/ServOpsFinance to ~/ARCHIVE and
 * rename as wk9946.ssd01 to begin this pgm.
 */
/*** proc copy in=custfin out=arch memtype=data; ***/
/***   select costx; ***/
/*** run; ***/

/*** proc datasets library=arch memtype=data; ***/
/***   change costx = wk&CURRWK; ***/
/*** run; ***/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *                              Installation
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 */

/* Since costx is not populated with CAN jobs, need to create this CAN-only
 * dataset. 
 */
proc sql;
  create table work.cancotmp as
    select a.job_id,
           a.class,
           a.rgncode,
           a.distcode,
           a.ord_stat,
           a.ordtype,
           a.i_cost,
           b.emphrsi,
           b.ctrhrsi,
           b.vendhrsi
    from master.jobcost a,
         master.jobperf b
           where a.d_date > 199500 and
                 a.ord_stat = 'CAN' and
                 a.job_id = b.job_id;
quit;

/* Actual hrs must be calculated but not actual dollars. */
data work.cancotmp;
  set work.cancotmp;
  /* Create a list of all numeric variables.  Must use this block ea time new
   * vars are created.
   */
  array nums _numeric_;
  /* Process list, replace blanks with zeros. */
  do over nums;
    if nums = . then
       nums = 0;
  end;
  iacthrs = emphrsi + ctrhrsi + vendhrsi;
run;

/* Left join with wk9751.ssd01.  "9751" will always indicate the prior year in
 * this code's comments. */
proc sql;
  create table work.cancotmp as
    select a.job_id,
           a.ord_stat,
           a.rgncode,
           a.distcode,
           a.iacthrs,
           a.i_cost,
           b.i_cost as i_cost97,
           b.emphrsi as emhrsi97,
           b.ctrhrsi as cohrsi97,
           b.vendhrsi as vehrsi97
    from work.cancotmp a
      left join
        arch.wk&EOYDS b
          on a.job_id = b.job_id;
quit;

/* TODO do I need hours to do spndrecon? */
/* Calc 97 iacthr97; act dollars ok as is */
data work.cancotmp;
  set work.cancotmp;
  /* Create a list of all numeric variables */
  array nums _numeric_;
  /* Process list, replace blanks with zeros */
  do over nums;
    if nums = . then
       nums = 0;
  end;
  iacthr97 = emhrsi97 + cohrsi97 + vehrsi97;
run;

/* Calc delta 98 vs 97 that is the YTD amount */
data work.cancotmp;
  set work.cancotmp;
  array nums _numeric_;
  do over nums;
    if nums = . then
       nums = 0;
  end;
  iacthrsd = iacthrs - iacthr97;
  i_costd = i_cost - i_cost97;
run;

proc tabulate data=work.cancotmp;
  class rgncode;
  var iacthrs iacthr97 iacthrsd i_cost i_cost97 i_costd;
  table rgncode all, iacthrs iacthr97 iacthrsd i_cost i_cost97 i_costd /rts=12;
  label iacthrs  = "Inst Act Hrs"
        iacthr97 = "&PRIORYR Inst Act Hrs"
        iacthrsd = "YTD Inst Act Hrs"
        i_cost   = "Inst Act Cost"
        i_cost97 = "&PRIORYR Inst Act Cost"
        i_costd  = "YTD Inst Act Cost";
  title "&MONYY YTD Cancelled Project Cost Spending";
  where rgncode in ('C201','C202','C227','C228','C229','C230','C204','C206','C208',
                    'C209','C210','C211','C212','C213','C214','C219') and
        job_id not like '$%';
run;

data work.tmp1;
  set work.cancotmp;
    where distcode = 'OM68';
run; 
   
proc tabulate data=work.tmp1; 
  class rgncode; 
  var i_cost iacthrs iacthr97 iacthrsd i_cost i_cost97 i_costd; 
  table rgncode all, iacthrs iacthr97 iacthrsd i_cost i_cost97 i_costd /rts=12; 
  label iacthrs  = "Inst Act Hrs" 
        iacthr97 = "&PRIORYR Inst Act Hrs" 
        iacthrsd = "YTD Inst Act Hrs" 
        i_cost   = "Inst Act Cost" 
        i_cost97 = "&PRIORYR Inst Act Cost" 
        i_costd  = "YTD Inst Act Cost"; 
  title "&MONYY YTD Cancelled Project Cost Spending OM68";
  where rgncode in ('C201','C202','C227','C228','C229','C230','C204','C206','C208', 
                    'C209','C210','C211','C212','C213','C214','C219') and 
        job_id not like '$%';
run; 
 

/* Output a proc tabulate to determine YTD spending.  Open jobs only.  Doesn't
 * require as much manipulation as cancostx.sas  b/c using costx (which
 * doesn't capture CAN).
 */
title; footnote;

/* Left join with wk9751 */
proc sql;
  create table work.opncotmp as
    select a.job_id,
           a.ord_stat,
           a.rgncode,
           a.distcode,
           a.ftsdate,
           a.d_date,
           a.prodcode,
           a.prodline,
           a.iacthrs,
           a.i_cost,
           b.i_cost as i_cost97,
           b.emphrsi as emhrsi97,
           b.ctrhrsi as cohrsi97,
           b.vendhrsi as vehrsi97
    from arch.wk&CURRWK a
      left join
        arch.wk&EOYDS b
          on a.job_id = b.job_id;
quit;

/* Calc 97 iacthr97, act dollars ok as is */
data work.opncotmp;
  set work.opncotmp;
  array nums _numeric_;
  do over nums;
    if nums = . then
       nums = 0;
  end;
  iacthr97 = emhrsi97 + cohrsi97 + vehrsi97;
run;

/* Calc delta 98 vs 97 that is the YTD amount */
data work.opncotmp;
  set work.opncotmp;
  array nums _numeric_;
  do over nums;
    if nums = . then
       nums = 0;
  end;
  iacthrsd = iacthrs - iacthr97;
  i_costd = i_cost - i_cost97;
run;

proc tabulate data=work.opncotmp;
  class rgncode;
  var iacthrs iacthr97 iacthrsd i_cost i_cost97 i_costd;
  table rgncode all, iacthrs iacthr97 iacthrsd i_cost i_cost97 
        i_costd /rts=12;
  label iacthrs  = "Inst Act Hrs"
        iacthr97 = "&PRIORYR Inst Act Hrs"
        iacthrsd = "YTD Inst Act Hrs"
        i_cost   = "Inst Act Cost"
        i_cost97 = "&PRIORYR Inst Act Cost"
        i_costd  = "YTD Inst Act Cost";
  title "&MONYY YTD Open Project Cost Spending";
    /* See criteria.sas */
    where rgncode in ('C201','C202','C227','C228','C229','C230','C204','C206','C208',
                      'C209','C210','C211','C212','C213','C214','C219') and
          job_id not like '$%' and  
          /* 'O' added first week of 2000. */
          prodline in ('H', 'T', 'A', 'Y', 'B', 'O') and
          distcode ^= 'OM68' and  
          job_id ^= 'H1X172' and  
          /* Open Criteria */
          ftsdate < 199200 and 
          d_date < &WKPLUS12 and  /* Preclose week plus 12 weeks */
          prodcode not in ('SWBILL','NTBILL','CSBILL','SABILL')
          ;
run;

/* Create OM68 and append to file */
data work.tmp1;
  set work.opncotmp;
      where distcode = 'OM68';
run;
 
proc tabulate data=work.tmp1;
  class rgncode;
  var i_cost iacthrs iacthr97 iacthrsd i_cost i_cost97 i_costd;
  table rgncode all, iacthrs iacthr97 iacthrsd i_cost i_cost97 
        i_costd /rts=12;
  label iacthrs  = "Inst Act Hrs"
        iacthr97 = "&PRIORYR Inst Act Hrs"
        iacthrsd = "YTD Inst Act Hrs"
        i_cost   = "Inst Act Cost"
        i_cost97 = "&PRIORYR Inst Act Cost"
        i_costd  = "YTD Inst Act Cost";
  title "&MONYY YTD Open Project Cost Spending OM68";
    /* See criteria.sas */
    where rgncode in ('C201','C202','C227','C228','C229','C230','C204','C206','C208',
                      'C209','C210','C211','C212','C213','C214','C219') and
          job_id not like '$%' and  
          prodline in ('H', 'T', 'A', 'Y', 'B', 'O') and
		job_id ^= 'H1X172' and  
          /* Open Criteria */
          ftsdate < 199200 and 
          d_date < &WKPLUS12 and  /* Preclose week plus 12 weeks. */
          prodcode not in ('SWBILL','NTBILL','CSBILL','SABILL')
          ;
run;

/* Output a proc tabulate to determine YTD spending.
 * Final jobs only.
 * Doesn't require as much manipulation as 
 * cancostx.sas  b/c using costx (which doesn't capture CAN).
 */
title; footnote;

/* Left join with e.g. wk9751 */
proc sql;
  create table work.fincotmp as
   select a.job_id,
          a.ord_stat,
          a.rgncode,
          a.distcode,
          a.prodline,
          a.ftsdate,
          a.iacthrs,
          a.i_cost,
          b.i_cost as i_cost97,
          b.emphrsi as emhrsi97,
          b.ctrhrsi as cohrsi97,
          b.vendhrsi as vehrsi97
   from arch.wk&CURRWK a
     left join
       arch.wk&EOYDS b
         on a.job_id = b.job_id;
quit;

/* Calc 97 iacthr97, act dollars ok as is. */
data work.fincotmp;
  set work.fincotmp;
  array nums _numeric_;
  do over nums;
    if nums = . then
       nums = 0;
  end;
  iacthr97 = emhrsi97 + cohrsi97 + vehrsi97;
run;

/* Calc delta 98 vs 97 that is the YTD amount. */
data work.fincotmp;
  set work.fincotmp;
  array nums _numeric_;
  do over nums;
    if nums = . then
       nums = 0;
  end;
  iacthrsd = iacthrs - iacthr97;
  i_costd = i_cost - i_cost97;
run;

proc tabulate data=work.fincotmp;
  class rgncode;
  var iacthrs iacthr97 iacthrsd i_cost i_cost97 i_costd;
  table rgncode all, iacthrs iacthr97 iacthrsd i_cost i_cost97 
        i_costd /rts=12;
  label iacthrs = "Inst Act Hrs"
        iacthr97 = "&PRIORYR Inst Act Hrs"
        iacthrsd = "YTD Inst Act Hrs"
        i_cost = "Inst Act Cost"
        i_cost97 = "&PRIORYR Inst Act Cost"
        i_costd = "YTD Inst Act Cost";
  title "&MONYY YTD Final Project Cost Spending";
  /* See criteria.sas */
  where rgncode in ('C201','C202','C227','C228','C229','C230','C204','C206','C208',
                    'C209','C210','C211','C212','C213','C214','C219') and
        job_id not like '$%' and
        prodline in ('H', 'T', 'A', 'Y', 'B', 'O') and
        distcode ^= 'OM68' and
        job_id ^= 'H1X172' and
        /* Final Criteria */
        /* Last week of previous yr. */
        ftsdate > &LASTWKYR and
        ftsdate < &CLOSEWK
        ;
run;

/* Create OM68 and append to file */
data work.tmp1;
  set work.fincotmp;
      where distcode = 'OM68';
run;

proc tabulate data=work.tmp1;
  class rgncode;
  var i_cost iacthrs iacthr97 iacthrsd i_cost i_cost97 i_costd;
  table rgncode all, iacthrs iacthr97 iacthrsd i_cost i_cost97 
        i_costd /rts=12;
  label iacthrs  = "Inst Act Hrs"
        iacthr97 = "&PRIORYR Inst Act Hrs"
        iacthrsd = "YTD Inst Act Hrs"
        i_cost   = "Inst Act Cost"
        i_cost97 = "&PRIORYR Inst Act Cost"
        i_costd  = "YTD Inst Act Cost";
  title "&MONYY YTD Final Project Cost Spending OM68";
  where rgncode in ('C201','C202','C227','C228','C229','C230','C204','C206','C208',
                    'C209','C210','C211','C212','C213','C214','C219') and
        job_id not like '$%' and
        prodline in ('H', 'T', 'A', 'Y', 'B', 'O') and
        job_id ^= 'H1X172' and
        /* Final Criteria */
        ftsdate > &LASTWKYR and
        ftsdate < &CLOSEWK 
        ;
run;



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *                              Engineering
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 */
proc sql;
  create table work.cancotmp as
    select a.job_id,
           a.class,
           a.rgncode,
           a.distcode,
           a.ord_stat,
           a.ordtype,
           a.e_cost,
           a.prodline,
           b.emphrse,
           b.ctrhrse,
           b.vendhrse
    from master.jobcost a,
         master.jobperf b
           where a.d_date > 199500 and
                 a.ord_stat = 'CAN' and
                 a.job_id = b.job_id;
quit;

/* Actual hrs must be calculated but not actual dollars */
data work.cancotmp;
  set work.cancotmp;
  /* Create a list of all numeric variables.  Must use this block ea time new
   * vars are created */
  array nums _numeric_;
  /* Process list, replace blanks with zeros */
  do over nums;
    if nums = . then
       nums = 0;
  end;
  eacthrs = emphrse + ctrhrse + vendhrse;
run;

/* Left join with wk9751 */
proc sql;
  create table work.cancotmp as
   select a.job_id,
          a.ord_stat,
          a.rgncode,
          a.distcode,
          a.eacthrs,
          a.e_cost,
          a.prodline,
          b.e_cost as e_cost97,
          b.emphrse as emhrse97,
          b.ctrhrse as cohrse97,
          b.vendhrse as vehrse97
   from work.cancotmp a
     left join
       arch.wk&EOYDS b
         on a.job_id = b.job_id;
quit;

/* Calc 97 eacthr97, act dollars ok as is */
data work.cancotmp;
  set work.cancotmp;
  array nums _numeric_;
  do over nums;
    if nums = . then
       nums = 0;
  end;
  eacthr97 = emhrse97 + cohrse97 + vehrse97;
run;

/* Calc delta 98 vs 97 that is the YTD amount */
data work.cancotmp;
  set work.cancotmp;
  array nums _numeric_;
  do over nums;
    if nums = . then
       nums = 0;
  end;
  eacthrsd = eacthrs - eacthr97;
  e_costd = e_cost - e_cost97;
run;

proc tabulate data=work.cancotmp;
  class rgncode;
  var eacthrs eacthr97 eacthrsd e_cost e_cost97 e_costd;
  table rgncode all, eacthrs eacthr97 eacthrsd e_cost e_cost97 e_costd /rts=12;
  label eacthrs  = "Eng Act Hrs"
        eacthr97 = "&PRIORYR Eng Act Hrs"
        eacthrsd = "YTD Eng Act Hrs"
        e_cost   = "Eng Act Cost"
        e_cost97 = "&PRIORYR Eng Act Cost"
        e_costd  = "YTD Eng Act Cost";
  title "&MONYY YTD Cancelled Project Cost Spending";
  where rgncode in ('C201','C202','C227','C228','C229','C230','C204','C206','C208',
                    'C209','C210','C211','C212','C213','C214','C219') and
        job_id not like '$%'
        ;
run;

data work.tmp1;
  set work.cancotmp;
      where distcode = 'OM68';
run;
 
proc tabulate data=work.tmp1;
  class rgncode;
  var e_cost eacthrs eacthr97 eacthrsd e_cost e_cost97 e_costd;
  table rgncode all, eacthrs eacthr97 eacthrsd e_cost e_cost97 e_costd /rts=12;
  label eacthrs  = "Eng Act Hrs"
        eacthr97 = "&PRIORYR Eng Act Hrs"
        eacthrsd = "YTD Eng Act Hrs"
        e_cost   = "Eng Act Cost"
        e_cost97 = "&PRIORYR Eng Act Cost"
        e_costd  = "YTD Eng Act Cost";
  title "&MONYY YTD Cancelled Project Cost Spending OM68";
  where rgncode in ('C201','C202','C227','C228','C229','C230','C204','C206','C208',
                    'C209','C210','C211','C212','C213','C214','C219') and
        job_id not like '$%'
        ;
run;

/* Output a proc tabulate to determine YTD spending.
 * Open jobs only.
 * Doesn't require as much manipulation as 
 * cancostx.sas  b/c using costx (which doesn't capture CAN).
 */
title; footnote;

/* Left join with wk9751 */
proc sql;
  create table work.opncotmp as
   select a.job_id,
          a.ord_stat,
          a.rgncode,
          a.distcode,
          a.prodline,
          a.ftsdate,
          a.d_date,
          a.prodcode,
          a.eacthrs,
          a.e_cost,
          b.e_cost as e_cost97,
          b.emphrse as emhrse97,
          b.ctrhrse as cohrse97,
          b.vendhrse as vehrse97
   from arch.wk&CURRWK a
     left join
       arch.wk&EOYDS b
         on a.job_id = b.job_id;
quit;

/* Calc 97 eacthr97, act dollars ok as is */
data work.opncotmp;
  set work.opncotmp;
  array nums _numeric_;
  do over nums;
    if nums = . then
       nums = 0;
  end;
  eacthr97 = emhrse97 + cohrse97 + vehrse97;
run;

/* Calc delta 98 vs 97 that is the YTD amount */
data work.opncotmp;
  set work.opncotmp;
  array nums _numeric_;
  do over nums;
    if nums = . then
       nums = 0;
  end;
  eacthrsd = eacthrs - eacthr97;
  e_costd = e_cost - e_cost97;
run;

proc tabulate data=work.opncotmp;
  class rgncode;
  var eacthrs eacthr97 eacthrsd e_cost e_cost97 e_costd;
  table rgncode all, eacthrs eacthr97 eacthrsd e_cost e_cost97 
        e_costd /rts=12;
  label eacthrs = "Eng Act Hrs"
        eacthr97 = "&PRIORYR Eng Act Hrs"
        eacthrsd = "YTD Eng Act Hrs"
        e_cost = "Eng Act Cost"
        e_cost97 = "&PRIORYR Eng Act Cost"
        e_costd = "YTD Eng Act Cost";
  title "&MONYY YTD Open Project Cost Spending";
    /* See criteria.sas */
    where rgncode in ('C201','C202','C227','C228','C229','C230','C204','C206','C208',
                      'C209','C210','C211','C212','C213','C214','C219') and
          job_id not like '$%' and  
          prodline in ('H', 'T', 'A', 'Y', 'B', 'O') and
          distcode ^= 'OM68' and  
          job_id ^= 'H1X172' and  
          /* Open Criteria */
          ftsdate < 199200 and 
          d_date < &WKPLUS12 and  /* Preclose week plus 12 weeks. */
          prodcode not in ('SWBILL','NTBILL','CSBILL','SABILL')
          ;
run;

/* Create OM68 and append to file */
data work.tmp1;
  set work.opncotmp;
      where distcode = 'OM68';
run;
 
proc tabulate data=work.tmp1;
  class rgncode;
  var e_cost eacthrs eacthr97 eacthrsd e_cost e_cost97 e_costd;
  table rgncode all, eacthrs eacthr97 eacthrsd e_cost e_cost97 
        e_costd /rts=12;
  label eacthrs  = "Eng Act Hrs"
        eacthr97 = "&PRIORYR Eng Act Hrs"
        eacthrsd = "YTD Eng Act Hrs"
        e_cost   = "Eng Act Cost"
        e_cost97 = "&PRIORYR Eng Act Cost"
        e_costd  = "YTD Eng Act Cost";
  title "&MONYY YTD Open Project Cost Spending OM68";
    /* See criteria.sas */
    where rgncode in ('C201','C202','C227','C228','C229','C230','C204','C206','C208',
                      'C209','C210','C211','C212','C213','C214','C219') and
          job_id not like '$%' and  
          prodline in ('H', 'T', 'A', 'Y', 'B', 'O') and
          job_id ^= 'H1X172' and  
          /* Open Criteria */
          ftsdate < 199200 and 
          d_date < &WKPLUS12 and  /* Preclose week plus 12 weeks. */
          prodcode not in ('SWBILL','NTBILL','CSBILL','SABILL')
          ;
run;


/* Output a proc tabulate to determine YTD spending.
 * Final jobs only.
 * Doesn't require as much manipulation as 
 * cancostx.sas  b/c using costx (which doesn't capture CAN).
 */
title; footnote;

/* Left join with e.g. wk9751 */
proc sql;
  create table work.fincotmp as
   select a.job_id,
          a.ord_stat,
          a.rgncode,
          a.distcode,
          a.prodline,
          a.ftsdate,
          a.eacthrs,
          a.e_cost,
          b.e_cost as e_cost97,
          b.emphrse as emhrse97,
          b.ctrhrse as cohrse97,
          b.vendhrse as vehrse97
   from arch.wk&CURRWK a
     left join
       arch.wk&EOYDS b
         on a.job_id = b.job_id;
quit;

/* Calc 97 eacthr97, act dollars ok as is */
data work.fincotmp;
  set work.fincotmp;
  array nums _numeric_;
  do over nums;
    if nums = . then
       nums = 0;
  end;
  eacthr97 = emhrse97 + cohrse97 + vehrse97;
run;

/* Calc delta 98 vs 97 that is the YTD amount */
data work.fincotmp;
  set work.fincotmp;
  array nums _numeric_;
  do over nums;
    if nums = . then
       nums = 0;
  end;
  eacthrsd = eacthrs - eacthr97;
  e_costd = e_cost - e_cost97;
run;

proc tabulate data=work.fincotmp;
  class rgncode;
  var eacthrs eacthr97 eacthrsd e_cost e_cost97 e_costd;
  table rgncode all, eacthrs eacthr97 eacthrsd e_cost e_cost97 
        e_costd /rts=12;
  label eacthrs  = "Eng Act Hrs"
        eacthr97 = "&PRIORYR Eng Act Hrs"
        eacthrsd = "YTD Eng Act Hrs"
        e_cost   = "Eng Act Cost"
        e_cost97 = "&PRIORYR Eng Act Cost"
        e_costd  = "YTD Eng Act Cost";
  title "&MONYY YTD Final Project Cost Spending";
  /* See criteria.sas */
  where rgncode in ('C201','C202','C227','C228','C229','C230','C204','C206','C208',
                    'C209','C210','C211','C212','C213','C214','C219') and
        job_id not like '$%' and
        prodline in ('H', 'T', 'A', 'Y', 'B', 'O') and
        distcode ^= 'OM68' and
        job_id ^= 'H1X172' and
        /* Final Criteria */
        ftsdate > &LASTWKYR and
        ftsdate < &CLOSEWK
        ;
run;

/* Create OM68 and append to file */
data work.tmp1;
  set work.fincotmp;
      where distcode = 'OM68';
run;

proc tabulate data=work.tmp1;
  class rgncode;
  var e_cost eacthrs eacthr97 eacthrsd e_cost e_cost97 e_costd;
  table rgncode all, eacthrs eacthr97 eacthrsd e_cost e_cost97 
        e_costd /rts=12;
  label eacthrs  = "Eng Act Hrs"
        eacthr97 = "&PRIORYR Eng Act Hrs"
        eacthrsd = "YTD Eng Act Hrs"
        e_cost   = "Eng Act Cost"
        e_cost97 = "&PRIORYR Eng Act Cost"
        e_costd  = "YTD Eng Act Cost";
  title "&MONYY YTD Final Project Cost Spending OM68";
  where rgncode in ('C201','C202','C227','C228','C229','C230','C204','C206','C208',
                    'C209','C210','C211','C212','C213','C214','C219') and
        job_id not like '$%' and
        prodline in ('H', 'T', 'A', 'Y', 'B', 'O') and
        job_id ^= 'H1X172' and
        /* Final Criteria */
        ftsdate > &LASTWKYR and
        ftsdate < &CLOSEWK
        ;
run;

