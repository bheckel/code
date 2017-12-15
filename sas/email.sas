options nosource;
 /*---------------------------------------------------------------------------
  *     Name: email.sas
  *
  *  Summary: Demo of using SAS to send email.
  *
  *           EMAILHOST must be properly defined by the administrator.
  *
  *           V8:
  *           This must be added to
  *           C:/Program Files/SAS Institute/SAS/V8/SASV8.CFG
  *           or via GUI
  *           Tools:Options:System:Communications
  *           to avoid using Outlook, etc.
  *
  *           -emailsys SMTP
  *           -emailhost smtphub.glaxo.com
  *           -emailport 25
  *
  *            Othewise get "ERROR: Undetermined I/O failure."
  *
  *
  *            V9:
  *            options emailsys=SMTP emailhost=smtphub.glaxo.com emailport=25;
  *
  *            See also zerorecs.sas
  *
  *  Adapted: Thu 07 Nov 2002 13:41:27 (Bob Heckel -- SAS OnlineDoc v8.2)
  * Modified: Wed 10 Aug 2016 10:15:13 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* Simple warning email */
%if &DUPS eq 1 %then %do;
  /* Tag e.g. MAILTHIS max len is 8! */
  filename MAILTHIS EMAIL ('bob.heckel@taeb.com') subject='Duplicates found during /Drugs/Cron/Daily/build_shortname_ds.sas execution';
  data _null_; file MAILTHIS; put; run;
%end;



 /* Canonical */
 /* Parens are important when multiple recipients */
filename MAILTHIS EMAIL ('bheckel@mgail.com' 'rsh86800@sgk.com')
         cc=('foo@example.com')                                                                                                   
         subject="GDM has a low record count &SYSDAY &SYSDATE"
         attach=('u:\gsk\zerorecs.txt' 'z:\datapost\cfg\DataPost_Results.xml')
         ;

%let CNTFMTD=%sysfunc(putn(&CNT, COMMA9.));

data _null_;
  file MAILTHIS;
  put "a low GDM record count exists according to &PGM";
  put;
  put "select count(*) from gdm_dist.vw_lift_rpt_results_nl where site_name='Zebulon'";
  put;
  put "count is &CNTFMTD";
  put;
run;



%macro Emailer;
  %if &the_saveout eq on %then %do;
    filename OUTGOING EMAIL ("&the_email")
             subject="Your requested output data DEBUG: &SYSTIME"
             /* V8 bug: if lims.csv is 0 bytes, dlip21.csv will not attach */
             attach=("&PTH/lims.csv" "&PTH/dlip21.csv")
             ;

    data _null_;
      file OUTGOING;
      put "testing &the_email";
      put 'Raw data is available here: //zebwd08d26987/share$';
    run;
  %end;
%mend;
%Emailer;


%macro SimpletestW2K;
  /* Keyword EMAIL is a "device type." */
  /* Automatically picks up my network id and password on W2K. */
  /* Parens needed only for multiple items.  Note no commas! */
  filename OUTGOING EMAIL ('bqh0@cdc.gov' 'bqh0@tstdev.nchs.cdc.gov')
           cc='dummyaddress309809823@cdc.gov'
           subject="Sent via SAS email device  DEBUG: &SYSTIME"
           attach="c:\temp\junk.pdf"
           ;

  data _NULL_;
    file OUTGOING;
    put 'Jim,';
    put 'Do not panic.';
    put 'Bob';
  run;
%mend;
***%SimpletestW2K;


%macro Complextest;
  filename OUTGOING EMAIL;

  data _NULL_;
    file OUTGOING;
    ***length name  dept $ 21;
    /* More explicitly: */
    length name $ 21  dept $ 21;
    input name $  dept $;
    put '!EM_TO! bqh0@cdc.gov';
    put '!EM_SUBJECT! subject is: ' dept;
    put 'bodytext Here is a testfile.';
    if dept='marketing' then
      put '!EM_ATTACH! c:/temp/junk.pdf';
    else
      put '!EM_ATTACH! c:/temp/junk2.pdf';
    put '!EM_SEND!';
    put '!EM_NEWMSG!';
    put '!EM_ABORT!';
    cards;
    aa  marketing
    bb  sales
    cc  other
    ;
  run;
%mend;
***%Complextest;


 /* OK to run via Connect */
%macro ODSMainframeVersionSendPDF;
  filename OUTPDF
           'BQH0.EMAILP'
           DISP=OLD
           UNIT=TEMP
           RECFM=VB
           LRECL=259
           ;

  filename OUTBOX EMAIL
           to='bqh0@cdc.gov'
           subject="Unknown report &SYSDATE"
           attach=('BQH0.EMAILP' EXT='PDF')
           ;

  ods listing close;
  ods PDF file=OUTPDF;
    proc print data=SASHELP.shoes(obs=10); run;
  ods PDF close;
  ods listing;

  file OUTBOX;
  data _NULL_;
    file OUTBOX;
    put 'testing - please ignore';
  run;
%mend;
***%ODSMainframeVersionSendPDF;


%macro ODSHTMLVersion;
  filename mail EMAIL to="robert.heckel@gsk.com" subject="HTML output" content_type="text/html";
  ODS listing close;
  ODS HTML body=mail;
  proc print data=sashelp.shoes(obs=10); run;
  ODS HTML close;
  ODS listing;
%mend;
***%ODSHTMLVersion;



filename MAILTHIS email ('bob.heckel@aeb.com')
  subject="Eligible Patient Count Validation"
  content_type="text/html"
  ;

data _null_;
  set dummy END=LastObs;
  file MAILTHIS;
  by Msg;

  put '<HTML><BODY><PRE>';
  if first.MSG Then Do;
    put "WARNING: Significant changes were detected in eligible patient populations!!";
    put ;
    put "Please see detail below:";
    put ;
    put @1 'clientid'
      @7 '/ '  'storeid'
      @75 '/ ' 'post_ts'
    ;
    put '----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0';
  end;

  put @1 clientid
    @7 '/ '  storeid
    @17 '/ ' status
    @75 '/ ' post_ts;

  if last.MSG then Do;
    put;
    put "Please be aware that store closures & other removals of the eligible population should show up too.";
  end;
  put '<IMG SRC="logo.png" height="40" width="160">';
  put '</HTML></BODY></PRE>';
run;



 /* Conditional but without needing macro */
data _null_;
  rc1=system("chmod -R 777 /Drugs/Scorecards/2016/20160211_Run1/Cards/Storeid_06/ 2>/Drugs/Scorecards/2016/scorecard_chmod.err");
  rc2=system("find /Drugs/Scorecards/2016/20160211_Run1/Cards/Storeid_0/ -name '*.pdf*' -exec cp -p {} ~bheckel/mnt/nfs/dropboxes/scorecards/ \; 2>/Drugs/Scorecards/2016/scorecard_cp.err");
  put rc1= rc2=;

  if (rc1 ne 0) or (rc2 ne 0) then do;
    put 'ERROR: system failure during execution of scorecard code';

/***    to='bob.heckel@taeb.com';***/
    to="('fei.yu@taeb.com' 'bob.heckel@taeb.com')";
    file dummy EMAIL filevar=to subject='TESTING PLEASE IGNORE Error in scorecard code';

    stop;
  end;
run;



filename MAILTHIS EMAIL (&mailto)                                                                               
     from='analytics@taeb.com'                                                                                  
     cc=(&cc)                                                                                                   
     subject="TMM Refresh - &lcn (clientid-&clid) - RFD/Census"                                                 
     attach=("&rfdfilename" content_type="application/xlsx" "&censusfilename" content_type="application/xlsx")  
     content_type="text/html"                                                                                   
     ;                                                                                                          
                                                                                                                
data _null_;                                                                                                                                                                                          
  file MAILTHIS;                                                                                                                                                                                      
  put '<div style="font-family:Calibri">';                                                                                                                                                            
  put 'Hi, a new refresh has been imported. The RFD & Census spreadsheets are attached.';                                                                                                             
  put;                                                                                                                                                                                                
  put "Please reply to &replyto if you have any comments or questions.  Thanks!";                                                                                                                     
  put '</div><br><br>';                                                                                                                                                                               
  put '<div style="font-family:Calibri; font-style:italic; font-size:60%">';                                                                                                                          
  put 'If you have received the message in error, please advise the sender by reply email and please delete the message.  This message contains information which may be confidential or otherwise '  
      'protected.  Unless you are the addressee (or authorized to receive for the addressee), you may not use, copy, or disclose to anyone the message or any information contained in the message.'; 
  put '</div>';                                                                                                                                                                                       
  put;                                                                                                                                                                                                
run;                                                                                                                                                                                                  
