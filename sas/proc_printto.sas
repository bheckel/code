options nosource;
 /*---------------------------------------------------------------------------
  *     Name: proc_printto.sas
  *
  *  Summary: Demo of using proc printto to divert Log, List and SAS output
  *           during the running of the program.
  *
  *           Use this to do it at startup:
  *             sas -LOG log_lst_file -PRINT log_lst_file mypgm.sas
  *           or
  *             t.bat - "d:\SAS Institute\SAS\V8\SAS.EXE" -config "d:\SAS institute\SAS\V8\LGI.cfg" -autoexec "d:\SAS_Programs\t.sas" -altlog "d:\SQL_Loader\Logs\LGI.log"
  *           
  *           TODO is ODS a better way to do this?
  *
  *  Created: Thu 31 Oct 2002 08:59:53 (Bob Heckel)
  * Modified: Tue 01 Apr 2008 13:19:57 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

filename putstuff 'junk';
 /* Print the SAS Log and List to the same file, overwriting any existing file
  * named junk.log 
  */
proc printto LOG=putstuff PRINT=putstuff NEW; run;
data sample;
  input idno $ 1-4 phone $ 6-15 height 17-18 weight 20-22;
  datalines;
2001 6029653564 71 200
2003 6029653456 70 195
2005 6029653345 76 250
2007 6029657891 65 150
  ;
run;

proc print; run;

ods listing file='junk2';
  title 'divert LIST to yet another external file inside proc printto';
  proc print data=sashelp.shoes(obs=5);run;
ods listing;

proc reg;
  model weight = height;
run;

proc printto; run;  /* close the 3 devices */
