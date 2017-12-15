options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: pipe_unixcmd.sas
  *
  *  Summary: Demo of reading and parsing data from the Unix environment.
  *
  *  Adapted: Sat 02 Aug 2003 18:34:35 (Bob Heckel -- SUGI28 Multi-plaform SAS
  *                                     David Johnson)
  *---------------------------------------------------------------------------
  */
options source;

filename UNIXPIPE PIPE 'env';

 /* TODO not working */
data _NULL_;
  retain username 'unknown';
  infile UNIXPIPE TRUNCOVER;
  input @1 readstr $CHAR80.;
  if readstr eq: "LOGNAME" then
    username=trim(substr(readstr,index(readstr,'=')+1));
  call symput('MYLOGNAME', username);
run;
