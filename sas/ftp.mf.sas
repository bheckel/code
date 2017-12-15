options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ftp.mf.sas
  *
  *  Summary: Using SAS's internal FTP feature to write a file somewhere 
  *           other than the mainframe.
  *
  *  Created: Thu 19 Feb 2004 15:21:39 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data foo;
  input gpa hsm hss hse;
  cards;
1 2 3 4 
3 2 3 4 
1 3 3 7 
1 2 3 4 
  ;
run;
 
filename OUT FTP 'junktest.txt' 
             CD='/home/alm5/public_html' 
             HOST='158.111.250.31'
             USER='alm5'
             PASS='dAebrpt5'
             DEBUG
             ;

data _NULL_;
  set foo;
  file OUT;
  put _ALL_;
run;
