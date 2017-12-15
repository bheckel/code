*****************************************************************************;
*                         PROGRAM HEADER                                    *;
*---------------------------------------------------------------------------*;
*       PROJECT NUMBER: VCCXXXXXXXXXXX                                      *;
*                                                                           *;
*       PROGRAM NAME: Retain_Sampling_Plan.sas        SAS VERSION: 8.2      *;
*                                                     DATE: 08-Jun-2007     *;
*                                                                           *;
*       DEVELOPED BY: Bob Heckel (adapted from original by Blake E. Roland  *;
*                     and James Arroway)                                    *;
*                                                                           *;
*       PROJECT REPRESENTATIVE: Kathryn Spencer                             *;
*                                                                           *;
*       PURPOSE: To create a list of randomly selected samples from each    *;
*                APR Level.  The target sample size for each level is 10%   *;
*                of the total number of samples for each level.  Product    *;
*                and Week are sampling strata where each product and each   *;
*                week will be sampled at least once.  For MDI the criteria  *;
*                will also include a minimum of 4 packaged lots.            *;
*                The database will be updated to indicate which samples     *;
*                were chosen.                                               *;
*                                                                           *;
*       SINGLE USE OR MULTIPLE USE? (SU OR MU) MU                           *;
*---------------------------------------------------------------------------*;
*       PROGRAM ASSUMPTIONS OR RESTRICTIONS: None                           *;
*---------------------------------------------------------------------------*;
*       DESCRIPTION OF OUTPUT:  1 SAS Log file                              *;
*****************************************************************************;
*                     HISTORY OF CHANGE                                     *;
*-------------+---------+--------------+------------------------------------*;
*     DATE    | VERSION | NAME         | Description                        *;
*-------------+---------+--------------+------------------------------------*;
*  03-Jul-07  |    1.0  | Bob Heckel   |  - Use database queries as input   *;
*             |         |              |    instead of spreadsheets         *;
*             |         |              |  - Allow determination of classes  *;
*             |         |              |    to sample via external files    *;
*             |         |              |  - Use external files for config   *;
*             |         |              |    and return value information    *;
*             |         |              |  - Update database for chosen      *;
*             |         |              |    samples                         *;
*             |         |              |  - Write out SAS Log for audit     *;
*             |         |              |    trail and debugging             *;
*             |         |              |  - Send email to admin on db       *;
*             |         |              |    failure                         *;
*-------------+---------+--------------+------------------------------------*;
*  03-Aug-11  |    2.0  | Bob Heckel   |  - Modify MDI percentage selection *;
*             |         |              |    criteria to include a minimum   *;
*             |         |              |    of 4. S. Parker ZXXXXXXXXXXX    *;
*-------------+---------+--------------+------------------------------------*;
*  15-Aug-14  |    3.0  | Bob Heckel   |  - Add condition to eliminate      *;
*             |         |              |    any empty records in            *;
*             |         |              |    finalRetainList                 *;
*****************************************************************************;
*****************************************************************************;
*                       MODULE HEADER                                       *;
*---------------------------------------------------------------------------*;
*       DESIGN COMPONENT: SETUP                                             *;
*                                                                           *;
*       INPUT: Control files in basedir                                     *;
*                                                                           *;
*       PROCESSING: Configure macrovariables, determine APRs to process,    *;
*                   build formats.                                          *;
*                                                                           *;
*       OUTPUT: None                                                        *;
*****************************************************************************;
options number NOdate NOmlogic mprint symbolgen ls=180;

%let basepath=&SYSPARM;

proc printto log="&basepath\Retain_Sampling_Plan.log" NEW; run;

filename CTRL "&basepath\Retain_Sampling_Plan.ctrl";
filename INI "&basepath\Retain_Sampling_Plan.ini";
filename ORARC "&basepath\Retain_Sampling_Plan.rc";


 /* Read control file to determine titles, what to process and whether 10%
  * sampling is needed.
  */
data commadelim;
  infile CTRL DLM=',' DSD MISSOVER;
  input aprnum ?? aprname :$80.  sampleit :$1.;
  list;
  if aprnum ne .;  /* Added V2: skip comments and blank lines */
run;

/* Determine which APRs are to be processed.  Not necessarily all *will* be
 * processed at 10% so this is a potential maximum.
 */
proc sql NOPRINT;
  select distinct aprnum, aprnum into :APRLIST separated by ' ', 
                                      :APRLISTCOMMAS separated by ','
  from commadelim
  ;
quit;

/* Determine which APRs are to be processed by 10% random selection. */
proc sql NOPRINT;
  select distinct aprnum into :APRLISTXPCT separated by ' '
  from commadelim
  where sampleit = 'Y'
  ;
quit;

/* Build dynamic SAS format */
data dynfmt (rename=(aprnum=START aprname=LABEL));
  set commadelim;
  retain fmtname 'f_aprcls';
run;
/*
----------------------------------------------------------------------------
|       FORMAT NAME: F_APRCLS LENGTH:    7   NUMBER OF VALUES:    7        |
|   MIN LENGTH:   1  MAX LENGTH:  40  DEFAULT LENGTH   7  FUZZ: STD        |
-----------------+----------------+-----------------------------------------
|START           |END             |LABEL  (VER. 8.2     24MAR2011:15:09:27)|
----------------------------------------------------------------------------
|               1|               1|Bottles                                 |
|               2|               2|Blister                                 |
|               3|               3|MDI                                     |
|               4|               4|MDPI                                    |
|               5|               5|Other                                   |
|               6|               6|Bulk                                    |
|               7|               7|Relenza                                 |
----------------------------------------------------------------------------
 */
proc format library=work cntlin=dynfmt; run;


/* Read INI file to determine sample rate and database login parameters */
data _null_;
  infile INI DLM='=' MISSOVER;
  input key :$40. val :$40.;
  list;
  if substr(key, 1, 1) not in('', ' ', ';');  /* Added V2: skip comments and blank lines */
  call symput(key, compress(val));
run;


 /* If database query fails or produces no records */
%macro SendErrorEmail(qry);
  %put &qry;

  %if &qry eq norecords %then
    %let subj=No records found while running Retain_Sampling_Plan.sas on &box;
  %else
    %let subj=Error running Retain_Sampling_Plan.sas on &box;

  /* This is a mess because Blat requires doublequoting its parameters.  And the attachment is 
   * a mandatory Blat parameter.
   */
  sendcmd = "&mailpgm " || '"' || "&basepath\Retain_Sampling_Plan.rc" || '"' ||
            ' -t ' || '"' || "&address"          || '"' ||
            ' -s ' || '"' || "&subj"             || '"' ||
            ' -f ' || '"' || "&from"             || '"' ||
            ' -server ' || '"' || "&mailsvr"     || '"'
            ;
  put sendcmd=;
  cmdrc = system(sendcmd);
  put cmdrc=;
  abort abend 002;
%mend SendErrorEmail;


%macro CheckForDBErr(action);
  data _null_;
    infile ORARC;
    input @1 rc  @@;
    if rc eq 0 then do;
      /* no problems, stop checking */
      stop;
    end;
    else do;
      input @1 errmsg $CHAR80.;
      put "ERROR during &action " errmsg;
      %SendErrorEmail(&action);
    end;
  run;
%mend;


************************************************************************;
*                       MODULE HEADER                                  *;
*----------------------------------------------------------------------*;
*       DESIGN COMPONENT: READ                                         *;
*                                                                      *;
*       INPUT: Retain database                                         *;
*                                                                      *;
*       PROCESSING: Read in data.  Sort by APR Class.                  *;
*                                                                      *;
*       OUTPUT: Dataset finalRetainList                                *;
************************************************************************;

proc sql feedback;
  CONNECT TO ORACLE(USER=&oraid ORAPW=&orapw PATH=&orapath);
    CREATE TABLE valData AS SELECT * FROM CONNECTION TO ORACLE (
      select a.matl_nbr as materialNum, a.fnsh_prod_id_nbr, b.prod_desc as prodDesc, a.lot_nbr as lotNum, 
      a.retn_dt as retainDate, a.retn_loc as location, a.prod_exp_dt as expDate
      from retain.fnsh_prod a, retain.material b 
      where a.matl_nbr=b.matl_nbr 
      and a.PROD_ACT_IND = 'Y' AND a.DELETED_IND = 'N'
       and a.prod_sel = 'N' and 
      a.fnsh_prod_id_nbr IN (select fnsh_prod_id_nbr from retain.audit_fnsh_prod where action_type = 'INSERT' 
      and action_date >= (select nvl(max(prod_sel_dt), to_date('01/01/1900','MM/DD/YYYY')) from retain.fnsh_prod) )
    );
  DISCONNECT FROM ORACLE;
quit;
%PUT &SQLXRC;
%PUT &SQLXMSG;

 /* File will hold a single '0' on success */
data _null_;
  file ORARC;
  put "&SQLXRC";                                           
  put "&SQLXMSG";                                           
run;                                                                        
%CheckForDBErr(valData SELECT);

 /* Check for records found - if zero then it's not worth continuing */
data _null_;
  dsid=open('work.valData');
  numobs=attrn(dsid, 'nobs');
  rc=close(dsid);
  if not numobs then do;
    put 'ERROR: no records found in database';
    %SendErrorEmail(norecords);
  end;
run;


proc sql feedback;
  CONNECT TO ORACLE(USER=&oraid ORAPW=&orapw PATH=&orapath);
    CREATE TABLE aprData AS SELECT * FROM CONNECTION TO ORACLE (
      select matl_nbr as materialNum, prod_desc as prodDesc, prod_class as aprclass 
      from retain.material 
      where matl_typ = 'FP' and act_ind = 'Y'
      order by prod_desc
    );
  DISCONNECT FROM ORACLE;
quit;
%PUT &SQLXRC;
%PUT &SQLXMSG;
 /* File will hold a single '0' on success */
data _null_;
  file ORARC;
  put "&SQLXRC";                                           
  put "&SQLXMSG";                                           
run;                                                                        
%CheckForDBErr(aprData SELECT);

data aprData;
  set aprData;
  if aprclass in ( &APRLISTCOMMAS );
run;


proc sort data=valData NODUPKEY;
  by retainDate lotNum materialNum prodDesc expDate;
run;

proc sort data=valData;
  by prodDesc materialNum;
run;

proc sort data=aprData;
  by prodDesc materialNum;
run;

data retainList; 
  merge valData aprData; 
  by prodDesc materialNum; 
run;

 /* In cases where only one or a few classes are present from valData, we
  * remove the other classes (i.e. remove from aprData-they exist here only as
  * a result of the merge)  
  */
data retainList;
  set retainList;
  if fnsh_prod_id_nbr='' and lotnum='' and retaindate='' and location='' and expdate=''
    then delete;
  if aprclass=''
    then delete;
run;


/*********** For Test cases and debugging in production ***********/
proc sql;
  create table tmpcnt as
  select aprclass, count(*) as APR_Count
  from retainList
  group by aprclass
  ;
quit;
data _null_;
  set tmpcnt end=e;
  format aprclass f_aprcls.;
  if _n_ eq 1 then do;
    put '**** For UTC - initial samples pulled (retainList) ****';
    put 'APRClass  Apr_Count';
    put aprclass APR_Count;
  end;
  else
    put aprclass APR_Count;

  if e then
    put '*******************************************************';
run;
/******************************************************************/


 /* We don't know what classes are going to be pulled until runtime.  The
  * Retain_Sampling_Plan.ctrl file gives all *possible* classes.  The next
  * steps filter that list. 
  */

 /* Override &APRLIST (originally populated by external file of desired
  * classes) to currently *available* classes.
  */
proc sql NOPRINT;
  select distinct aprclass into :APRLIST separated by ' '
  from retainList
  ;
quit;

proc sort data=retainList out=tmpretainList;
  by aprclass;
run;

data actualYclasses;
  merge tmpretainList(keep=aprclass in=in1) commadelim(in=in2 rename=(aprnum=aprclass));
  by aprclass;
  if in1 and sampleit eq 'Y';
run;

 /* Override &APRLISTXPCT (originally populated by external file of desired Y
  * classes) to currently *available* classes. 
  */
proc sql NOPRINT;
  select distinct aprclass into :APRLISTXPCT separated by ' '
  from actualYclasses
  ;
quit;


/*********** For Test cases and debugging in production ***********/
data _null_;
  set retainList end=e;
  if _n_ eq 1 then do;
    put '**** Dump of dataset retainList ****';
    put _all_;
  end;
  else
    put _all_;

  if e then
    put '************************************';
run;
/******************************************************************/


data retainList; 
  set retainList;
  format aprclass f_aprcls.;
  label materialNum = 'Material Number'
           prodDesc = 'Product Description'
             lotNum = 'Lot Number'
         retainDate = 'Retain Date'
           location = 'Location'
            expDate = 'Expiration Date'
           aprclass = 'APR Class';
run;


/* Calculate week number for use as one of the sampling strata */
data retainList(drop=numDays tmpdt); 
  set retainList;

  /* Comes from Oracle as e.g. 19JUN2004:00:00:00 */
  tmpdt = datepart(retainDate);
  numDays = intck('day', '01Jan1900'd, tmpdt);
  /* weekNumber = # of weeks since 01Jan1900, used for reference */
  weekNumber = ceil(numDays/7);
run; 


%macro BuildBreakoutDS;
  %local i e;
  %let i=1;
  %let e=%scan(&APRLIST, &i);
  %do %while (%length(&e));

    data aprclass_&e; set retainList;
      if aprclass not in (&e) then delete;
    run;
    data aprclass_&e; set aprclass_&e;
      order=_n_;
    run;

    %let i=%eval(&i+1);
    %let e=%scan(&APRLIST, &i);
  %end;
%mend;
%BuildBreakoutDS


%macro Sampler(dsInput, strata1, strata2, desRate, dsOutputSample);
   /* Jamie's algorithm (untouched except where commented with Version number): */
  data ds_ALL_DATA;
    set &dsInput;
  run;

  **********;
  * CALCULATE DESIRED/target SAMPLE SIZE, 'desSampN';
  proc means data=ds_ALL_DATA noprint;
    var order;
    output out=ds_PopN n=PopN;
  run;

  data _null_;
    set ds_PopN;

    call symput('PopN',PopN);

    /* Modified V2: S. Parker: "Need change for class 3 either 4 packaged lots
     * per month or 10% of the total monthly volume, whichever is greater, will
     * be selected for MDI products"
     */
    calcDesRate = ceil(&desRate * PopN);

    /* MDI class 3 ignores 10% criteria when it would result in less than 4 batches */
    if ( (calcDesRate lt &sampleminMDI) and ("&dsInput" eq 'aprclass_3') and (PopN eq 2) ) then do;
      put "!!! desRate * PopN for &dsInput is too low per IT00587.  Adjusting to 2 from " calcDesRate=;
      call symput('desSampN', 2);
    end;
    else if ( (calcDesRate lt &sampleminMDI) and ("&dsInput" eq 'aprclass_3') and (PopN eq 3) ) then do;
      put "!!! desRate * PopN for &dsInput is too low per IT00587.  Adjusting to 3 from " calcDesRate=;
      call symput('desSampN', 3);
    end;
    else if ( (calcDesRate lt &sampleminMDI) and ("&dsInput" eq 'aprclass_3') and (PopN eq 4) ) then do;
      put "!!! desRate * PopN for &dsInput is too low per IT00587.  Adjusting to 4 from " calcDesRate=;
      call symput('desSampN', 4);
    end;
    else if ( (calcDesRate lt &sampleminMDI) and ("&dsInput" eq 'aprclass_3') and (PopN gt 4 and PopN lt 41) ) then do;
      put "!!! desRate * PopN for &dsInput is too low per IT00587.  Adjusting to &sampleminMDI from " calcDesRate=;
      call symput('desSampN', &sampleminMDI);
    end;
    else do;
      put "!!! desRate * PopN for &dsInput is acceptable per IT00587: " calcDesRate=;
      call symput('desSampN', calcDesRate);
    end;
  run;

  **********;
  * SAMPLE ALL_DATA W/N=1 BY STRATA1 (ensures that each strata has at least one sample);
  * dsSAMPLE_1;
  proc sort data=ds_ALL_DATA;
    by &strata1;
  run;

   /* Added V2: Initialize to empty */
  data ds_SAMPLE_1; run; data ds_SAMPLE_2; run; data ds_SAMPLE_1_2; run; data ds_SAMPLE_3;

  proc surveyselect data=ds_ALL_DATA METHOD=SRS N=1 OUT=ds_SAMPLE_1 NOprint;
    STRATA &strata1;
  run;
  **********;
  * FIND ALL STRATA2 THAT ARE NOT IN SAMPLE_1 = list_sample1Strata2;
  * get unique list of strata2 from ds_allData=list_allStrata2;
  proc sort data=ds_ALL_DATA; 
    by &strata2; 
  run;
  data list_all_Strata2(keep = &strata2);
    set ds_ALL_DATA;
    by &strata2;
    if first.&strata2;
  run;
  * get unique list of strata2 from sample_1 = list_sample1Strata2;
  proc sort data=ds_SAMPLE_1; 
    by &strata2; 
  run;
  data list_sample1_Strata2(keep = &strata2);
    set ds_SAMPLE_1;
    by &strata2;
    if first.&strata2;
  run;
  * get unique list of strata2 in list_all_Strata2, and not in list_sample1_Strata2= list_unsampled_Strata2;
  data list_unsampled_Strata2;
    merge   list_all_Strata2(in = inAll)
        list_sample1_Strata2(in = inSamp1);
    by &strata2;
    if inAll and not inSamp1;
  run;
  * get ds_unsampledStrata2Data from ds_allData having strata2 from list_unsampledStrata2;
  data ds_unsampledStrata2Data;
    merge ds_ALL_DATA list_unsampled_Strata2(in=inUnsampled);
    by &strata2;
    if inUnsampled;
  run;
  **********;
  * SAMPLE W/N=1 BY STRATA2 FROM ds_unsampledStrata2Data = ds_SAMPLE_2;
  proc sort data=ds_unsampledStrata2Data;
    by &strata2;
  run;
  proc surveyselect data=ds_unsampledStrata2Data METHOD=SRS N=1 OUT=ds_SAMPLE_2 NOprint;
    STRATA &strata2;
  run;
  **********;
  * COMBINE SAMPLE_1 AND SAMPLE_2 (this is my minimum sample)=SAMPLE_1_2;
  data ds_SAMPLE_1_2;
    set ds_SAMPLE_1 ds_SAMPLE_2;
  run;
  * IF n_SAMPLE_1_2 < desSampN THEN SAMPLE MORE TO FILL IN;
  proc means data = ds_SAMPLE_1_2 noprint;
    var order;
    output out=dsNsample_1_2 n=n_SAMPLE_1_2;
  run;
  data _null_;
    set dsNsample_1_2;
    call symput('n_SAMPLE_1_2',n_SAMPLE_1_2);
  run;

  %if (&n_SAMPLE_1_2 >= &desSampN) %then %do;
  * DONE SAMPLING;
    data ds_FINAL_SAMPLE;
      set ds_SAMPLE_1_2;
    run;
  %end;
  %else %do;
  * SAMPLE MORE;
  * REMOVE SAMPLE_1_2 FROM ALL_DATA=REDUCED_DATA;
  proc sort data = ds_ALL_DATA; by order; run;
  proc sort data = ds_SAMPLE_1_2; by order; run;  
  data ds_REDUCED_DATA;
    merge ds_ALL_DATA ds_SAMPLE_1_2(in=inSample_1_2);
    by order;
    if not inSample_1_2;
  run;
  * SAMPLE P% (w/o strata) FFOM REDUCED_DATA=SAMPLE_3;
  *calculate necessary sampling rate to get to desired sample size;
  data _null_;
    n_Needed = &desSampN - &n_SAMPLE_1_2;
    n_Unsampled = &PopN - &n_SAMPLE_1_2;
    calculated_Rate = n_Needed / n_Unsampled;
    call symput('calculated_Rate',calculated_Rate);
  run;
  proc surveyselect data=ds_REDUCED_DATA METHOD=SRS rate=&calculated_Rate OUT=ds_SAMPLE_3 NOprint;
  run;

  * FINAL_SAMPLE = SAMPLE_1_2 + SAMPLE_3;
  data ds_FINAL_SAMPLE;
    set ds_SAMPLE_1_2 ds_SAMPLE_3;
  run;
  %end;

  data &dsOutputSample;
    set ds_FINAL_SAMPLE;
  run;
%mend Sampler;


%macro LoopSampler;
  %local i e;
  %let i=1;
  %let e=%scan(&APRLISTXPCT, &i);
  %do %while (%length(&e));

    %Sampler(aprclass_&e, proddesc, weekNumber, &samplerate, aprclass_&e);
    proc sort data=aprclass_&e; by order; run;

    %let i=%eval(&i+1);
    %let e=%scan(&APRLISTXPCT, &i);
  %end;
%mend;
%LoopSampler;


%macro BuildSetStmt;
  %global SETSTMT;
  %local i e;
  %let i=1;
  %let e=%scan(&APRLIST, &i);
  %do %while (%length(&e));

    %let SETSTMT=&SETSTMT aprclass_&e;
    /* Added V2: provide debugging info to respond to client questions */
    proc print data=aprclass_&e(obs=max) width=minimum; run;

    %let i=%eval(&i+1);
    %let e=%scan(&APRLIST, &i);
  %end;
%mend;
%BuildSetStmt;

data finalRetainList; 
  set &SETSTMT;
  /* Added V3: avoid attempting to insert empty records (from the Sampler process) 
   * into the database
   */
  if fnsh_prod_id_nbr ne .;
run;


/*********** For test cases and debugging in production ***********/
data _null_;
  set finalRetainList end=e;
  if _n_ eq 1 then do;
    put '**** Dump of dataset finalRetainList ****';
    put _all_;
  end;
  else
    put _all_;

  if e then
    put '*****************************************';
run;
/******************************************************************/


*****************************************************************************;
*                       MODULE HEADER                                       *;
*---------------------------------------------------------------------------*;
*       DESIGN COMPONENT: UPDATE                                            *;
*                                                                           *;
*       INPUT: SAS Dataset finalRetainList                                  *;
*                                                                           *;
*       PROCESSING: Update database                                         *;
*                                                                           *;
*       OUTPUT: none                                                        *;
*****************************************************************************;

data _null_;
  /* Convert current SAS datetime to Oracle datetime format */
  x = put(datetime(), datetime.);
  call symput('ORANOW', "'"||substr(x,1,2)||substr(x,3,3)||substr(x,6,2)||" "||substr(x,9,8)||"'");
run;

 /* Must break id num list into blocks to avoid overflowing SAS/Oracle maximum
  * lengths
  */
data _null_;
  retain list cnt loop;
  /* At least 500 x avg length of digits */
  format list: $9500.;
  set finalRetainList end=e;

  /* Break IN statement every 501 id nums */
  if _N_ eq 1 or cnt eq 501 then 
    do;
      cnt=0;
      loop+1;
    end;

  cnt+1;

  if cnt eq 1 then 
    do;
      list = trim(fnsh_prod_id_nbr);
    end;
  else if fnsh_prod_id_nbr ne . then 
    do;
      list = trim(left(list))||','||trim(left(fnsh_prod_id_nbr));
    end;

  if cnt=501 or e then 
    do;
      /* Build string for Oracle e.g. 'FNSH_PROD_ID_NBR IN (52499,52951...' */
      call symput('IDLIST'||compress(put(loop,5.)), 'FNSH_PROD_ID_NBR IN ('||trim(left(list))||')');
      call symput('NUMLOOPS', loop);
    end;
run;

proc sql;
  CONNECT TO ORACLE(USER=&oraid ORAPW=&orapw PATH=&orapath);
    EXECUTE (
      update retain.fnsh_prod 
      set prod_sel = 'Y', prod_sel_dt = TO_DATE(&ORANOW, 'DDMONYY:HH24:MI:SS')
      /* E.g. WHERE FNSH_PROD_ID_NBR IN (52499,52951...) OR FNSH_PROD_ID_NBR IN (9999,... */
      where &IDLIST1 %macro x; %DO Loop=2 %TO &NumLoops; OR &&IDLIST&Loop %END; %mend; %x
  ) BY ORACLE;
  DISCONNECT FROM ORACLE;
quit;

data _null_;
  file ORARC;
  put "&SQLXRC";                                           
  put "&SQLXMSG";                                           
run;                                                                        
%CheckForDBErr(UPDATE);


/*********** For Test cases and debugging in production ***********/
proc sql;
  create table tmpcnt as
  select aprclass, count(*) as APR_Count
  from finalRetainList
  where aprclass ne .
  group by aprclass
  ;
quit;
data _null_;
  set tmpcnt end=e;
  if _N_ eq 1 then 
    do;
      put "**** For UTC of % sample subset pulled (finalRetainList) ****";
      put 'APRClass Apr_Count';
      put aprclass APR_Count;
    end;
  else
    put aprclass APR_Count;

  if e then
    put '*************************************************************';
run;

%put _all_;


proc printto; run;
