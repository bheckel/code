options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: date_formats.sas
  *
  *  Summary: Demo of applying date formats to SAS variables.
  *
  *  Adapted: Fri 31 Oct 2003 15:01:36 (Bob Heckel --
  *           http://homepage.ntlworld.com/philipmason/Tips%20Newsletter/52.htm)
  * Modified: Tue 22 Jun 2010 11:04:21 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;


 /* SAS-supplied date styles: */
data _NULL_;
  now=today();
  put 'Blanks ... ' now YYMMDDB8.;
  put 'Colon ... ' now YYMMDDC8.;
  put 'Dash ... ' now YYMMDDD8.;
  put 'No Separator ... ' now YYMMDDN8.;
  put 'Period ... ' now YYMMDDP8.;
  put 'Slash ... ' now YYMMDDS8.;
run;



data t;
  infile cards;
  input a $ b $ c d YYMMDD8.;
  cards;
aa bb 11 20000707
cc dd 12 20010707
ff gg 13 60 01 31
hh ii 14 60-02-01
jj kk 15 60:02:01
ll mm 16 60/02/01
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;



 /* Custom date style: */
proc format;                                                                    
  picture f_date OTHER = '%Y-%0m-%0d %0H:%0M'(datatype=datetime);               
run;                                                                            
                                                                                
data _null_;                                                                    
  now = put(datetime(), f_date.);                                                
  put now=;
  start = dhms(date(),0,0,0);                                                    
  put start=;
  finish = dhms(date(),23,59,59);                                                 
  put finish=;
run;


 /* Formatting macrovariables holding SAS date-like strings */
%let LODT=01MAY2005;
%let HIDT=01JUN2005;

%let LODTPLUS=%sysfunc(putn("&LODT"D, MMDDYYS10.));
 /* Dont' think I can do this inline b/c of the double quotes required in the
  * putn().
  */
title "date range &LODTPLUS";
proc print data=sashelp.shoes(obs=2); run;



 /* Assay_Testdate is 21-MAY-1998, Assay_createdate is 05-21-98 */
data base_Impurity;
  infile DRUG delimiter = ',' MISSOVER DSD end=e;

  format Assay_createdate Assay_Testdate DATE9.;

  input Assay_Description :$100.
        Assay_createdate :DATE9.
        Assay_Status :$30.
        Assay_Testdate :MMDDYY8.
        Assay_loop :8.2
        ;
run;
