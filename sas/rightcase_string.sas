options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: rightcase_string.sas
  *
  *  Summary: Upper case the first letter of a word.
  *
  *  Created: Wed 23 Apr 2003 12:44:18 (Bob Heckel)
  * Modified: Wed 27 Oct 2004 15:53:29 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%let ALL_LOWERCASE = upperme;

data _NULL_;
  uppercasefirst=translate(substr("&ALL_LOWERCASE", 1, 1),
                       'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                       'abcdefghijklmnopqrstuvwxyz') ||
                 substr("&ALL_LOWERCASE", 2);

  call symput('RIGHTCASED', uppercasefirst);
  put uppercasefirst=;
run;

 /* TODO Not working */
 /***
%let RCASE1=%sysfunc(translate(substr("&ALL_LOWERCASE",1,1),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'));
%let RCASE2=%sysfunc(substr("&RCASE1",2));
%let RCASE=&RCASE1.&RCASE2;
%put !!! RCASE &RCASE;
 ***/

 /* Version v9.1+ only */
%let RIGHTCASE=%sysfunc(propcase(upperme));
%put !!! RIGHTCASE &RIGHTCASE;
