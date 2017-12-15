 /* Adapted: Sat Nov 12 13:04:27 2005 (Bob Heckel - SAS Technology Report Nov
  * 2005 Bryan Beverly
  */

%macro PingServer;
  /****************************************************/
  /*initialize the environment before processing */
  /* - not essential but a good housekeeping practice */
  /****************************************************/
  filename _all_ clear; /*remove existing filename allocations*/
  libname _all_ clear; /*remove existing libname allocations*/
  ods html close; /*close ODS if a prior job left it open*/
  proc datasets kill nolist; /*delete existing temporary data sets*/ run;
  quit;

  %macro ping(server=, /* name of server */
    prim=, /* primary recipient */
    cc1=, /* secondary recipient */
    cc2=); /* tertiary recipient */
    /* delete the prior file that stored server status information */
    x "rm -f /your/utility_jobs/server_status.dat";
    /* PING the server and pipe the status information into a text file */
    x "ping &server>/your/utility_jobs/server_status.dat";
    /* allocate the text file as an input source */
    filename server "/your/utility_jobs/server_status.dat";
    /* read the status data into a temporary file and capture the status */
    data server_chk;
      length servstat $ 70 status $ 5;
      infile server pad missover lrecl=70;
      input @1 servstat $char70.;
      status=scan(servstat,3);
    run;

    /* macro captures general metadata, including the number of observations */
    /*  - for this application, there should only be 1 observation */
    %macro metadata(ds);
      %global dset nvars nobs;
      %let dset = &ds;
      %let dsid = %sysfunc(open(&dset));
      %let nobs = %sysfunc(attrn(&dsid,NOBS));
      %let nvars = %sysfunc(attrn(&dsid,NVARS));

      %let rc = %sysfunc(close(&dsid));
    %mend metadata;
    %metadata(server_chk);

    /* store the status as a macro variable */
    data _null_;
      set server_chk;
      if _N_ = &nobs;
      call symput('status',status);
    run;
    %if &status ^= alive %then %do;
      /* send email and a cell phone text messages */
      data _null_;
        filename outbox email "&prim" ;
        file outbox
        cc=("&cc1","&cc2")
        subject="Please Check &server Immediately";
        put "a PING of &server detected a problem.";
      run;
    %end;
  %mend ping;

  %macro timer;
    %do i=1 %to 47; /* perform for 23.5 hours */
      %ping(server=SERVER_NAME1,
      prim=SOMEBODY@usa.gov,
      cc1=111CELLPHONE1@messaging.nextel.com,
      cc2=111CELLPHONE2@messaging.nextel.com);

      %ping(server=SERVER_NAME2,
      prim=SOMEBODY@usa.gov,
      cc1=222CELLPHONE1@messaging.nextel.com,
      cc2=222CELLPHONE2@messaging.nextel.com);
      %ping(server=SERVER_NAME3,
      prim=SOMEBODY@usa.gov,
      cc1=333CELLPHONE1@messaging.nextel.com,
      cc2=333CELLPHONE2@messaging.nextel.com);
      data _null_; /* suspend SAS for 30 minutes */
        snooze=sleep(1800*1000); /* time is in milli-seconds on UNIX servers */
      run; /* time is in seconds on Windows servers */
    %end;
  %mend timer;
  %timer;
  /* ************************************************* */
  /* clean up everything and reset the default options */
  /* ************************************************* */

  libname _all_ clear;
  filename _all_ clear;
  proc datasets kill nolist;
  run;
  quit;
%mend PingServer;
%PingServer;
