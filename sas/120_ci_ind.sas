
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Pull Cascade Impaction method
 *  DESIGN COMPONENT: Process data
 *  INPUT:            LIMS individuals dataset
 *  PROCESSING:       Build temporary method dataset
 *  OUTPUT:           Temporary dataset ci_ind
 *------------------------------------------------------------------------------
 *                     HISTORY OF CHANGE                                      
 *-------------+---------+--------------------+---------------------------------
 *     Date    | Version | Modification By    | Nature of Modification              
 *-------------+---------+--------------------+---------------------------------
 *  14-Apr-09  |    1.0  | Bob Heckel         | Original. CCF 81260.
 *-------------+---------+--------------------+---------------------------------
 *  12-Oct-09  |    2.0  | Bob Heckel         | CCF 84681 (Add 28 Dose):
 *             |         |                    | Changed 'stren' to 'dose'.
 *-------------+---------+--------------------+---------------------------------
 *******************************************************************************
 */
    options compress=yes source source2 fullstimer ls=180 ps=max mautosource 
            sasautos=(SASAUTOS, "\\zebwd08D26987\datapost\Serevent_Diskus\CODE\lib") mprint NOmlogic sgen NOcenter xsync NOxwait
            ;
     libname OUTDIR '\\zebwd08D26987\datapost\Serevent_Diskus\OUTPUT_COMPILED_DATA';

 /* 4 results per device */
%macro ci_indPEAKINFOCALCSUMS(dose);
  data ci_ind&dose;
    set OUTDIR.pullLIMS_ind&dose;

    if SpecName eq 'ATM02170CASCADEHPLC' 
       and Name eq 'PEAKINFOCALCSUMS'
       and ColName in ('NAME$', 'DEVICENUMBER', 'BTLAVG$')
       ;
  run;

  %let dsid=%sysfunc(open(_LAST_)); %local cnt; %let cnt=%sysfunc(attrn(&dsid, NLOBSF)) %sysfunc(close(&dsid));
  %if &cnt le 1 %then %goto EXIT;

  proc sort data=ci_ind&dose;
    by SampId SampName SampCreateTS SpecName Name RowIx Presentation Market;
  run;
  proc transpose data=ci_ind&dose out=tmp_ci_ind&dose;
    by SampId SampName SampCreateTS SpecName Name RowIx Presentation Market;
    id ColName;
    var ElemStrVal;
    copy SampStatus DispName;
  run;

  data ci_ind&dose(rename=(BTLAVG_=result DEVICENUMBER=device));
    length test $150;
    set tmp_ci_ind&dose;

    if _NAME_ ne '';

    %mfg_batch;
    %study;
    %storage_condition;
    %time_point;
    %datastatus;

    test = 'CI - ' || NAME_;
  run;

  /* Add TOTAL grouping per system requirements IT01132 */
  proc sort data=ci_ind&dose;
    by SampId SampName SampCreateTS SpecName Name Presentation Market device RowIx;
  run;
  data ci_ind&dose;
    set ci_ind&dose;
    by SampId SampName SampCreateTS SpecName Name Presentation Market device;

    numres = input(result, F8.);

    if first.device then do;
      total = 0;
    end;

    if NAME_ in('SUM-FPM', 'SUM-TP0', 'SUM-67&F') then do;
      total+numres;
    end;

    output;

    if last.device then do;
      test = 'CI - TOTAL';
      result = total;
      output;
    end;
  run;

  proc append base=ci_indPEAKINFOCALCSUMS data=ci_ind&dose; run;
%EXIT:
%mend;
%ci_indPEAKINFOCALCSUMS(28);
%ci_indPEAKINFOCALCSUMS(60);


 /* 9 parameter categories per sampid */
%macro ci_indPARAMETERS(dose);
  data ci_ind&dose;
    set OUTDIR.pullLIMS_ind&dose;

    if SpecName eq 'ATM02170CASCADEHPLC' 
       and Name eq 'PARAMETERS'
       and ColName in:('PARAMETERS$', 'DEVICE')
       ;
  run;

  %let dsid=%sysfunc(open(_LAST_)); %local cnt; %let cnt=%sysfunc(attrn(&dsid, NLOBSF)) %sysfunc(close(&dsid));
  %if &cnt le 1 %then %goto EXIT;

  proc sort data=ci_ind&dose;
    by SampId SampName SampCreateTS SpecName Name RowIx Presentation Market;
  run;
/***proc print data=ci_ind&dose(obs=max where=(sampid=281583)) width=minimum; run;  ***/

/***  proc transpose data=ci_ind&dose(where=(colname=:'DEVICE' or colname='PARAMETERS$')) out=tmp_ci_ind&dose;***/
  proc transpose data=ci_ind&dose out=tmp_ci_ind&dose;
/***    by SampId SampName SampCreateTS SpecName Name RowIx ColumnIx Presentation Market;***/
    by SampId SampName SampCreateTS SpecName Name RowIx ;
    id ColName;
    var ElemStrVal;
/***    copy SampStatus DispName;***/
  run;
/***proc print data=tmp_ci_ind&dose(obs=max where=(sampid=314918)) width=minimum; run;  ***/
/***proc print data=tmp_ci_ind&dose(obs=max where=(sampid=281583)) width=minimum; run;  ***/

  proc sort data=tmp_ci_ind&dose;
    by SampId SampName SampCreateTS SpecName Name RowIx;
  run;
  data tmp_ci_ind&dose;
    update tmp_ci_ind&dose(obs=0) tmp_ci_ind&dose;
    by SampId SampName SampCreateTS SpecName Name RowIx;
  run;

  proc transpose data=tmp_ci_ind&dose out=tmp_ci_ind&dose;
    by SampId SampName SampCreateTS SpecName Name _name_;
    id parameters_;
    var device:;
  run;

  data ci_ind&dose(rename=(devicealp=device));
    set tmp_ci_ind&dose;
    by sampid;

    if first.sampid /*and first.SampName and first.SampCreateTS and first.SpecName and first.name and first._name_*/ then
      devicenum = 1;
     else
       devicenum+1;

    devicealp = put(devicenum, 8. -L);  /* other methods expect device to be alpha */
  run;

/***proc print data=tmp_ci_ind&dose(obs=max where=(sampid=281587)) width=minimum; run;  ***/
/***proc print data=tmp_ci_ind&dose(obs=max where=(sampid=314918)) width=minimum; run;  ***/
/***proc print data=tmp_ci_ind&dose(obs=max where=(sampid=281583)) width=minimum; run;  ***/
%macro bobh2804100416; /* {{{ */
  data tmp_ci_ind&dose;
    set tmp_ci_ind&dose;
    device = '1';
    devicex = DEVICE1_;
  run;
  proc sort data=tmp_ci_ind&dose;
    by SampId SampName SampCreateTS SpecName Name RowIx Presentation Market device;
  run;

  proc transpose data=ci_ind&dose(where=(colname='DEVICE2$' or colname='PARAMETERS$')) out=tmp_ci_ind2&dose;
    by SampId SampName SampCreateTS SpecName Name RowIx Presentation Market;
    id ColName;
    var ElemStrVal;
    copy SampStatus DispName;
  run;

  data tmp_ci_ind2&dose;
    set tmp_ci_ind2&dose;
    device = '2';
    devicex = DEVICE2_;
  run;
  proc sort data=tmp_ci_ind2&dose;
    by SampId SampName SampCreateTS SpecName Name RowIx Presentation Market device;
  run;

  data ci_ind&dose;
    merge tmp_ci_ind&dose tmp_ci_ind2&dose;
    by SampId SampName SampCreateTS SpecName Name RowIx Presentation Market device;
  run;

  data ci_ind&dose;
    set ci_ind&dose(keep= sampid SampName SampCreateTS SpecName PARAMETERS_ devicex device);
    if PARAMETERS_ ne '';
  run;

  proc sort data=ci_ind&dose;
    by SampId SampName SampCreateTS SpecName device;
  run;
  proc transpose data=ci_ind&dose out=ci_ind&dose;
    by SampId SampName SampCreateTS SpecName device;
    id PARAMETERS_;
    var devicex;
  run;
%mend bobh2804100416; /* }}} */

  proc append base=ci_indPARAMETERS data=ci_ind&dose; run;
%EXIT:
%mend ci_indPARAMETERS;
%ci_indPARAMETERS(60);
%ci_indPARAMETERS(28);


proc sort data=ci_indPEAKINFOCALCSUMS;
  by SampId SampName SpecName SampCreateTS SpecName device;
run;
proc sort data=ci_indPARAMETERS;
  by SampId SampName SpecName SampCreateTS SpecName device;
run;
data ci_ind;
  merge ci_indPEAKINFOCALCSUMS ci_indPARAMETERS;
  by SampId SampName SpecName SampCreateTS SpecName device;
run;
data ci_ind;
  set ci_ind;
  /* Due to the variety of devices from 2 to 6, the 2's get blanks for 3-6 */
  if test eq '' then delete;
run;
/***proc print data=ci_ind(obs=max where=(sampid=281587)) width=minimum; run;  ***/
/***proc print data=ci_ind(obs=max where=(sampid=314918)) width=minimum; run;  ***/
/***proc print data=ci_ind(obs=max where=(sampid=281583)) width=minimum; run;  ***/
/***proc print data=ci_ind(obs=max ) width=minimum; run;  ***/

