options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: split.simple.sas
  *
  *  Summary: Perl-like split of a delimited string.
  *
  *  Created: Tue 07 Dec 2004 10:11:39 (Bob Heckel)
  * Modified: Tue 29 Mar 2005 14:56:40 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

***%let VAR=Congenital Anomalies--Rectal Atresia/Stenosis;
%let VAR=Congenital Anomalies--Tracheo-esophageal Fistula/Esophageal Atresia;

data _null_;
  delim='--';
  len=length(delim);
  rightsubstring=substr("&VAR",(index("&VAR",delim)+len));
  put rightsubstring=;
run;

data _null_;
  delim='--';
  leftsubstring=substr("&VAR",1,(index("&VAR",delim)-1));
  put leftsubstring=;
run;

 /* or even more simply */
%let wtf=thishasa space;
%let wtf2=%scan(&wtf, 1, ' ');
%put !!!&wtf2;
