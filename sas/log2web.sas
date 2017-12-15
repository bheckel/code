 /**********************************************************************
  * PROGRAM NAME: BQH0.SAS.INTRNET.PDS(LOG2WEB)
  *
  *  DESCRIPTION: Print mainframe SAS Logs to the user's browser.
  *
  *     CALLS TO: nothing
  *    CALLED BY: http://mainframe.cdc.gov/sasweb/nchs/misc/log2web.html
  *
  *  INPUT MVARS: the_sub the_st the_yr the_evt the_uid
  *
  *   PROGRAMMER: BQH0
  * DATE WRITTEN: 2004-07-01
  *
  *   UPDATE LOG:
  * 2004-07-06 (bqh0) force Log de-migration using SAS system option
  * 2005-03-16 (bqh0) allow viewing of new FCAST logs
  *********************************************************************/
options notes NOsource NOdate NOs99nomig;

%macro ChooseFile;
  %global LOG;

  /* Choose based on the HTML form's submit button. */
  %if %str(&the_sub) eq %str(View Current Jobstream Log) %then
    %do;
      %let LOG=DWJ2.&the_stabbrev.&the_yr..&the_evt..LOG;
    %end;
  %else %if %str(&the_sub) eq %str(View Current FCAST TSA Log) %then
    %do;
      %let LOG=DWJ2.FCAST.&the_uid..TSA.&the_pgm1..LOG;
    %end;
  %else %if %str(&the_sub) eq %str(View Current FCAST OTH Log) %then
    %do;
      %let LOG=DWJ2.FCAST.&the_uid..OTH.&the_pgm2..LOG;
    %end;
  %else %if %str(&the_sub) eq %str(View Current FCAST REV Log) %then
    %do;
      %let LOG=DWJ2.FCAST.&the_uid..REV.&the_pgm3..LOG;
    %end;
  %else
    %do;
      %put Unknown submit button pressed;
      data _NULL_; abort abend 002; run;
    %end;
%mend ChooseFile;
%ChooseFile;


%macro PrintLog;
  %local ANYOBS;

  %if %sysfunc(fileexist("&LOG")) %then
    %do;
      filename F "&LOG" DISP=SHR WAIT=5;

      /* Test for zero records. */
      %let ANYOBS=0;
      data _NULL_;
        infile F obs=1;
        input;
        call symput('ANYOBS', _N_);
      run;

      %if &ANYOBS ne 0 %then
        %do;
          data _NULL_;
            infile F;
            input;
            file _WEBOUT;
            if _N_ eq 1 then
              put "<HR><CENTER><H2>&LOG</H2></CENTER><HR><BR><BR><PRE>";
            put _INFILE_;
          run;
        %end;
      %else
        %do;
          /* Avoid IntrNet "Application generated no output" errors. */
          data _NULL_;
            file _WEBOUT;
            put "<HR><CENTER><H2>&LOG</H2></CENTER><HR><BR><BR><PRE>";
            put "&LOG is empty.<BR><BR><PRE>";
          run;
        %end;
    %end;
  %else
    %do;
      data _NULL_;
        file _WEBOUT;
        put "<HR><CENTER><H2>&LOG</H2></CENTER><HR><BR><BR><PRE>";
        put "&LOG does not exist.";
      run;
    %end;
%mend PrintLog;
%PrintLog;
