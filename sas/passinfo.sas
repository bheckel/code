/******************************************************************
*
* The %PASSINFO macro prints session information to the SAS log
* for performance analysis. It is optional for use with the
* %LOGPARSE() macro, and both macros are experimental for SAS 9.1.
*
* See the Readme file for instructions.
*
*******************************************************************/


%macro passinfo;
  options fullstimer;
  data _null_;
    length  hostname $ 80;
    hostname=' ';  /* avoid message about uninitialized */
    temp=datetime();
    temp2=lowcase(trim(left(put(temp,datetime16.))));
    call symputx('datetime', temp2);

  %if ( &SYSSCP = WIN )   /* windows platforms */
  %then call symput('host', "%sysget(computername)");
  %else %if ( &SYSSCP = OS )  /* MVS platform */
  %then %do;
    call symput('host', "&syshostname");
  %end;
  %else %if ( &SYSSCP = VMS ) or ( &SYSSCP = VMS_AXP )
  %then %do; /* VMS platform */
    hostname = nodename();
    call symput('host', hostname);
  %end;
  %else %do;              /* all UNIX platforms */
    filename gethost pipe 'uname -n';
    infile gethost length=hostnamelen;
    input hostname $varying80. hostnamelen;
    call symput('host', hostname);
  %end;

  run;

  %put PASS HEADER BEGIN;
  %put PASS HEADER os=&sysscp;
  %put PASS HEADER os2=&sysscpl;
  %put PASS HEADER host=&host;
  %put PASS HEADER ver=&sysvlong;
  %put PASS HEADER date=&datetime;
  %put PASS HEADER parm=&sysparm;

  proc options option=MEMSIZE ; run;
  proc options option=SUMSIZE ; run;
  proc options option=SORTSIZE ; run;

  %put PASS HEADER END;

%mend passinfo;

