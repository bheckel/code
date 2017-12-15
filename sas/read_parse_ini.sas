options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: read_parse_ini.sas
  *
  *  Summary: Read in and parse INI file structured data into macrovars.
  *
  *           See also exclude_from_filelist.sas or input_named.sas if
  *           the data is simple "key=value" file
  *
  *  Created: Tue 06 May 2007 12:24:30 (Bob Heckel)
  * Modified: Wed 03 Aug 2011 13:22:10 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

/***filename INI "c:\cygwin\home\bheckel\projects\retain\Retain_Sampling_Plan.ini";***/
filename INI "junk.ini";

 /* Character in first field */
data _null_;
  infile INI DLM='=' MISSOVER;
  input key :$40. val :$40.;
  if substr(key, 1, 1) not in('', ' ', ';');  /* skip comments and blank lines */
  /* Not quoted - 'key' !! */
  call symput(key, compress(val));
run;
%put _all_;

 /* Builds:
GLOBAL ORAID retain_user
GLOBAL ORAPATH usdev388
GLOBAL BOX rtpsawn321
GLOBAL ORAPW retainu388
GLOBAL ORIGMPRINT 
GLOBAL MAILPGM d:\sas_programs\sas_mail\blat.exe
GLOBAL FROM NOREPLY_Retain_Sampling_Plan.sas@gsk.com
GLOBAL ADDRESS rsh86800@gsk.com
GLOBAL SAMPLERATE 0.1
 */



 /* Compare - numeric in first field */
data commadelim;
  infile CTRL DLM=',' DSD MISSOVER;
  input aprnum ?? aprname :$80.  sampleit :$1.;
  list;
  put '!!!'aprnum=;
  if aprnum ne .;  /* Added V2: skip comments and blank lines */
run;
/*
# Comment lines like this are ignored
# APR Class (numeric),Label (max 80 char),Random Sample (Y or N)
# Y=Select 10%, N=Select 100%, classes not listed are ignored, see .ini for MDI exception 
1,Bottles,Y
2,Blister,Y
3,MDI,Y
4,MDPI,Y
5,Other,N
6,Bulk,N
7,Relenza,Y
*/



endsas;
; this is junk.ini
samplerate=0.1
box=rtpsawn321
orapath=usdev388
oraid=retain_user
orapw=retainu388
mailpgm=d:\sas_programs\sas_mail\blat.exe
mailsvr=smtphub.glaxo.com
from=NOREPLY_Retain_Sampling_Plan.sas@gsk.com
address=rsh86800@gsk.com
