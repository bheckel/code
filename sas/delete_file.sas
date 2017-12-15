
options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: delete_file.sas
  *
  *  Summary: Delete a file.
  *
  *  Created: Thu 10 Dec 2009 16:09:19 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter NOxwait;

 /* Windows */

%let OUTP=\\zebwd08D26987\Advair_HFA\Output_Compiled_Data;

data _null_;
  rc=system("del &OUTP\PLOTs\stability\placeholder.cgm");
  put rc=;
run;
