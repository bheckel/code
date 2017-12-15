   /* Jemshaid Cheema
      Jemshaid.Cheema@sas.com
      (919) 531-4782

      APPLICATION DISPATCHER PULLDOWN MENU PROGRAM

      This program describes how to use the "three-step"
      method to write an Application Dispatcher program
      that creates a dynamic pulldown menu. */

data _null_;

   /* All FILE statements could be modified to direct
      output to the _WEBOUT reserved file reference. */

   file 'C:\temp\pulldown.html';
   put '<HTML>';
   put '<!-- DISPDYNFORM.SAS -->';
   put '<!-- Application Dispatcher analog of "Dynamic Form to Run Dispatcher" (c09s2d1a).  -->';
   put;
   put '<HEAD>';
   put '   <TITLE>HTML Dynamic Form, Action is Dispatcher program.</TITLE>';
   put '</HEAD>';
   put;
   put '<BODY>';
   put '<FORM METHOD="GET" ACTION="http://l3056.na.sas.com/cgi-bin8/broker.exe">';
   put '<H3 ALIGN="CENTER">Select a Month and Hub Location</H3>';
   put '<H4 ALIGN="CENTER">To Request the Revenue Report</H4>';
   put '<BR>&nbsp;';
   put '<BR>';
   put '<HR>';
   put '<br>&nbsp;';
   put '<br>&nbsp;';

   /* Remember to write the SELECT tag in a DATA step that
      is executed only one time.  This DATA step is
      executed only once, because it does not have a SET,
      MERGE, or INPUT statement. */

   put 'Month: &nbsp;';
   put '<SELECT NAME="monthnum">';
run;

proc sql;
   create table months as
      select distinct month ,
            put(month,monyy7.) as monname,
            month(month) as monnum format=2.0
         from ia.sales_1999
         order by monnum
   ;
quit;

data _null_;
   file 'C:\temp\pulldown.html' mod;
   set months;

   /* Exercise caution when quoting. */

   put '   <OPTION VALUE="' monnum '">' monname;
run;

data _null_;
   file 'C:\temp\pulldown.html' mod;
   put '</SELECT>';
   put '<BR>&nbsp;';
   put '<BR>&nbsp;';
   put 'Hub Location: &nbsp;';
   put '<SELECT NAME="dest">';
run;

proc sql;
   create table destinations as
      select distinct Destination as loc
         from ia.sales_1999
         order by Destination
   ;
quit;

data _null_;
   file 'C:\temp\pulldown.html' mod;
   set destinations;
   put '   <OPTION>' loc;
run;

data _null_;
   file 'C:\temp\pulldown.html' mod;
   put '</SELECT>';
   put '<BR>&nbsp;';
   put '<BR>&nbsp;';
   put '<HR>';
   put '<INPUT TYPE="RESET" VALUE="Clear Form">&nbsp;&nbsp;';
   put '<INPUT TYPE="SUBMIT" VALUE="Submit the Values">';
   put '<INPUT TYPE="HIDDEN" NAME="_debug" VALUE="2">';
   put '<INPUT TYPE="HIDDEN" NAME="_service" VALUE="appserv">';
   put '<INPUT TYPE="HIDDEN" NAME="_program" VALUE="web1samp.dispparm.sas">';
   put '</FORM>';
   put;
   put '<P>';
   put 'Program executes Application Dispatcher program: appserv.c08s1d1b.sas, same as when hard-coded with HTML.';
   put;
   put '</BODY>';
   put '</HTML>';
run;
