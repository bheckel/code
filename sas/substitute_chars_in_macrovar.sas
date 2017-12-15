options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: substitute_chars_in_macrovar.sas
  *
  *  Summary: Replace ':' with '=' 
  *
  *  Created: Thu 08 Oct 2009 09:42:50 (Bob Heckel)
  * Modified: Wed 02 Sep 2015 11:42:53 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Windows to Unix path */
data _null_;
  x="M:\Drugs\Personnel\bob\test.txt";
  x2=tranwrd(x, 'M:', '');
  x2=tranwrd(x2, '\', '/');
  put x2=;
run;



filename INI 'Serevent_Diskus.ini';

data _null_;
  infile INI DLM='=' MISSOVER lrecl=2000;
  input key :$40. val :$2000.;
  if substr(key, 1, 1) ne ';';  /* skip comments */
  call symput(key, left(trim(val)));
run;

%macro m;
  %let PULL60WHERE=%sysfunc(translate(%quote(&PULL60WHERE), '=', ':'));
  %put &PULL60WHERE;
%mend;%m

endsas;
; This file controls 0_MAIN_Serevent_Diskus.sas and is usually found in \<PROJECT>\CODE\util\
DBNAME=usprd259
DBUSER=sasreport
DBPW=sasreport
DPSVR=C:
DIRROOT=cygwin\home\bheckel\projects\datapost\tmp
; Earliest desired sample create date for this product - to minimize database pull size
DBMINDATE=01-JAN-08
DEBUGON=0
; Which presentations to pull
WANT60=1
WANT28=0
WANT14=0
; Using colon to allow this .ini to parse on '=' properly
PULL60WHERE=UPPER(R.ResStrVal):'SEREVENT DISKUS 50 MCG 60D EVAL/STRP' OR UPPER(R.ResStrVal):'SEREVENT DISKUS 50 MCG 60CT EVAL' OR UPPER(R.ResStrVal):'SEREVENT DISKUS 50MCG 60 DOSE' OR UPPER(R.ResStrVal):'SEREVENT INHALERS, 21 MCG - 60 ACT' OR UPPER(R.ResStrVal):'SEREVENT'
