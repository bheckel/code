 /* {{{ */
options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: oracle_sql_tmplt.sas
  *
  *  Summary: Avoiding SQL*Plus and Toad, produce a viewable ds from an Oracle
  *           table or query.
  * 
  *           Note: use SQL*Plus for queries like DESCRIBE that do not produce
  *                 a dataset
  *
  *           Windows-specific.  Assumes a filename association for .sas
  *           exists
  *
  *           2006-03-21 currently configured for only links & lims dbs
  *
  *  Created: Thu 12 Jan 2006 10:16:31 (Bob Heckel)
  * Modified: Tue 21 Mar 2006 14:37:00 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter NOxwait fullstimer;  /* ls=80 is set programmatically */

%let TMPDIR=%str(&HOME/tmp/);
 /* Temporary SAS dataset */
%let VIEWRESULTSDS=ora%sysfunc(substr(&SYSPROCESSID,1,10));

libname T "&TMPDIR";

***%include "&HOME/code/sas/tabdelim.sas";


 /* ....................................................................... */

 /*<<<**************************************************************>>>*/
      /*<<<****************************************************>>>*/
          /*<<<********************************************>>>*/

 /* }}} */

%let d=links;  /* links or lims database */
%let wantSASgui=y;  /* 'y' or blank  */
 /* Note: this string uses passthru Oracle (not SAS) SQL e.g. upper() not
  * upcase(), use keyword FEEDBACK to debug what Oracle converts into 
  */
%let q=%bquote(

  SELECT 
  *
/*** meth_spec_nm, meth_var_nm, meth_rslt_char***/
/***  distinct prod_nm, pks_peak***/
/***  distinct t.meth_spec_nm, s.prod_nm***/
/***  distinct prod_nm, meth_var_nm, mfg_spec_txt_a***/
/***  distinct prod_nm, meth_spec_nm, meth_var_nm, column_nm***/

  FROM 
/***  samp ***/
/***  tst_rslt_summary***/
/***  indvl_tst_rslt ***/
  stage_translation
/***  pks_extraction_control***/

  WHERE 
/***  upper(meth_spec_nm) like %upcase('genusp%')***/
  samp_id=188383 and meth_spec_nm like %upcase('atm02065%')
/***  meth_spec_nm like 'APPEAR%'***/
/***  upper(meth_spec_nm) like %upcase('genusp%')***/
  
/***  GROUP BY***/
/***  meth_spec_nm***/

);


 /* DEBUG toggle the 'HOLD' for complex queries */
%let qHOLD=%bquote(

  select prod_nm, meth_spec_nm, pks_stage, pks_lab_tst_desc 
  from pks_extraction_control 
  where pks_stage like '%4th%' and pks_lab_tst_desc not like '%4th%'

);


 /* {{{ */
          /*<<<********************************************>>>*/
      /*<<<*******************************************************>>>*/
 /*<<<*****************************************************************>>>*/

 /* ....................................................................... */



%macro ChooseDbLogin(db);
  %global id pw path qrystr;

  %if &db eq links %then
    %do;
      %let id=pks;
      %let pw=pks;
      %let path=usdev100;
    %end;
  %else %if &db eq lims %then
    %do;
      %let id=sasreport;
      %let pw=sasreport;
      %let path=techops;
    %end;
  %else
    %put unknown db: &db;
%mend;
%ChooseDbLogin(&d);


proc sql feedback;
  CONNECT TO ORACLE(USER=&id ORAPW=&pw BUFFSIZE=25000 READBUFF=25000 
                    PATH=&path);
  CREATE TABLE T.&VIEWRESULTSDS AS SELECT * FROM CONNECTION TO ORACLE (
    &q
  );
  %let HSQLXRC=&SQLXRC;
  %let HSQLXMSG=&SQLXMSG;
  DISCONNECT FROM ORACLE;
  quit;
run;


%macro ViewGUITbl;
  %local nrows;

  %let nrows=%sysfunc(attrn(%sysfunc(open(T.&VIEWRESULTSDS)),NLOBSF)); 

  %if (&HSQLXRC eq 0) and (&nrows ne .) and (&nrows ne 0) and (&nrows lt 1000000) %then
    %do;
      data _null_;
        file PRINT;
        put "OK: rc (&HSQLXRC)   rows (&nrows)   msg (&HSQLXMSG)"; 
      run;
      %if &wantSASgui eq y %then
        x "start &TMPDIR.&VIEWRESULTSDS..sas7bdat";
      %else
        %do;
          options ls=80;
          proc print data=_LAST_(obs=max); run;
        %end;
    %end;
  %else
    %do;
      data _null_;
        file PRINT;
        %if &nrows eq . %then
          %do;
            put "ERROR: rc (&HSQLXRC)   rows (&nrows)   msg (&HSQLXMSG)"; 
          %end;
        %else
          %do;
            put "NO RECS: rc (&HSQLXRC)   rows (&nrows)   msg (&HSQLXMSG)"; 
          %end;
      run;
    %end;
%mend;



%ViewGUITbl;

 /* }}} */


endsas;
sql> @c:/cygwin/home/bheckel/utc/lemetadata/desc.sql  /* {{{ */
sql> describe samp
 name                                      null?    type
 ----------------------------------------- -------- ----------------------------
 samp_id                                   not null number(10)
 matl_nbr                                           varchar2(18)
 batch_nbr                                          varchar2(10)
 mfg_tst_grp                                        varchar2(8)
 sub_batch                                          varchar2(4)
 samp_comm_txt                                      varchar2(120)
 samp_status                                        varchar2(4)
 stability_study_nbr_cd                             varchar2(15)
 stability_samp_stor_cond                           varchar2(15)
 stability_samp_time_point                          varchar2(4)
 stability_study_grp_cd                             varchar2(15)
 stability_study_purpose_txt                        varchar2(120)
 storage_dt                                         date
 approved_by_user_id                                varchar2(30)
 approved_dt                                        date

sql> describe links_material
 name                                      null?    type
 ----------------------------------------- -------- ----------------------------
 matl_nbr                                  not null varchar2(18)
 batch_nbr                                 not null varchar2(10)
 matl_desc                                 not null varchar2(50)
 matl_mfg_dt                               not null date
 matl_exp_dt                               not null date
 matl_typ                                           varchar2(4)

sql> describe tst_rslt_summary
 name                                      null?    type
 ----------------------------------------- -------- ----------------------------
 samp_id                                   not null number(10)
 meth_spec_nm                              not null varchar2(40)
 meth_var_nm                               not null varchar2(40)
 meth_peak_nm                              not null varchar2(40)
 summary_meth_stage_nm                     not null varchar2(40)
 meth_rslt_char                                     varchar2(40)
 meth_rslt_numeric                                  number
 checked_by_user_id                                 varchar2(30)
 checked_dt                                         date
 proc_stat                                          number(4)
 lab_tst_desc                              not null varchar2(40)
 lab_tst_meth                                       varchar2(10)
 lab_tst_meth_spec_desc                             varchar2(40)
 samp_tst_dt                                        date
 upr_limit                                          varchar2(15)
 low_limit                                          varchar2(15)
 txt_limit_a                                        varchar2(200)
 txt_limit_b                                        varchar2(200)
 txt_limit_c                                        varchar2(200)

sql> describe indvl_tst_rslt
 name                                      null?    type
 ----------------------------------------- -------- ----------------------------
 res_id                                    not null number(10)
 samp_id                                   not null number(10)
 meth_spec_nm                              not null varchar2(40)
 meth_var_nm                               not null varchar2(40)
 meth_peak_nm                              not null varchar2(40)
 indvl_meth_stage_nm                       not null varchar2(40)
 indvl_tst_rslt_row                        not null number(8)
 indvl_tst_rslt_device                     not null varchar2(40)
 indvl_tst_rslt_nm                                  varchar2(40)
 indvl_tst_rslt_prep                                varchar2(40)
 indvl_tst_rslt_location                            varchar2(40)
 indvl_tst_rslt_time_pt                             varchar2(4)
 indvl_tst_rslt_val_num                             number
 indvl_tst_rslt_val_char                            varchar2(80)
 res_loop                                  not null number(4)
 res_repeat                                not null number(4)
 res_replicate                             not null number(4)

sql> describe tst_parm
 name                                      null?    type
 ----------------------------------------- -------- ----------------------------
 samp_id                                   not null number(10)
 meth_spec_nm                              not null varchar2(40)
 meth_var_nm                               not null varchar2(40)
 indvl_tst_rslt_device                     not null varchar2(40)
 tst_parm_nm                               not null varchar2(40)
 tst_parm_val_num                                   number
 tst_parm_val_char                                  varchar2(80)
 lims_var_nm                               not null varchar2(40)
 res_loop                                  not null number(4)
 res_repeat                                not null number(4)
 res_replicate                             not null number(4)

sql> describe pks_extraction_control
 name                                      null?    type
 ----------------------------------------- -------- ----------------------------
 meth_var_nm                               not null varchar2(40)
 meth_spec_nm                              not null varchar2(40)
 column_nm                                          varchar2(40)
 pks_extraction_macro                               varchar2(10)
 pks_var_nm                                         varchar2(40)
 pks_stage                                          varchar2(40)
 pks_level                                          varchar2(40)
 pks_format                                         varchar2(5)
 pks_peak                                           varchar2(40)
 pks_lab_tst_desc                                   varchar2(40)
 mfg_lower_spec_limit                               varchar2(10)
 mfg_upper_spec_limit                               varchar2(10)
 stability_lower_spec_limit                         varchar2(10)
 stability_upper_spec_limit                         varchar2(10)
 mfg_spec_txt_a                                     varchar2(200)
 mfg_spec_txt_b                                     varchar2(200)
 mfg_spec_txt_c                                     varchar2(200)
 stability_spec_txt_a                               varchar2(200)
 stability_spec_txt_b                               varchar2(200)
 stability_spec_txt_c                               varchar2(200)
 pks_extraction_cntrl_notes_txt                     varchar2(100)

sql> describe activity_log
 name                                      null?    type
 ----------------------------------------- -------- ----------------------------
 activity_dt                               not null date
 patron_id                                 not null varchar2(15)
 request_txt                               not null varchar2(40)
 condition_txt                             not null varchar2(200)

sql> describe rft_batch_summary
 name                                      null?    type
 ----------------------------------------- -------- ----------------------------
 matl_nbr                                  not null varchar2(18)
 batch_nbr                                 not null varchar2(10)
 mfg_proc                                  not null varchar2(15)
 room_line_nbr                                      varchar2(2)
 batch_start_dt                                     date
 batch_stop_dt                                      date
 op_id                                              varchar2(50)
 data_entry_user_id                        not null varchar2(50)
 rslt_data_desc                                     varchar2(40)
 num_rslt                                           number
 char_rslt                                          varchar2(40)
 comment_txt                                        varchar2(200)
 data_entry_dt                             not null date
 action_performed_by                       not null varchar2(50)

sql> describe c_of_a
 name                                      null?    type
 ----------------------------------------- -------- ----------------------------
 matl_nbr                                  not null varchar2(18)
 batch_nbr                                 not null varchar2(10)
 mfg_proc                                  not null varchar2(15)
 supplier_batch_one                                 varchar2(10)
 supplier_batch_two                                 varchar2(10)
 first_batch_srce                                   varchar2(15)
 second_batch_srce                                  varchar2(15)
 op_id                                              varchar2(50)
 data_entry_user_id                        not null varchar2(50)
 rslt_data_desc                                     varchar2(40)
 num_rslt                                           number
 char_rslt                                          varchar2(40)
 comment_txt                                        varchar2(200)
 data_entry_dt                             not null date
 action_performed_by                       not null varchar2(50)

sql> desc stage_translation;
 name                                      null?    type
 ----------------------------------------- -------- ----------------------------
 samp_id                                   not null number(10)
 meth_spec_nm                              not null varchar2(40)
 meth_var_nm                               not null varchar2(40)
 meth_peak_nm                              not null varchar2(40)
 summary_meth_stage_nm                     not null varchar2(40)
 lab_tst_desc                              not null varchar2(40)
 indvl_meth_stage_nm                       not null varchar2(40)

sql> spool off

 /* }}} */

  /* vim: set tw=999 ft=sas ff=unix foldmethod=marker: */ 
