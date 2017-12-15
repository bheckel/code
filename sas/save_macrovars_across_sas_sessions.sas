options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: save_macrovars_across_sas_sessions.sas
  *
  *  Summary: Save mvars for later
  *
  *  Adapted: Wed 20 Jun 2012 10:51:31 (Bob Heckel--http://support.sas.com/software/93/index.html#s1=3)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

/* Place the GLOBAL macro variable(s) into a permanent SAS data set */ 

%let foo=bar;

libname l ".";

data l.vars;                                                                                                                             
  set sashelp.vmacro(where=(scope='GLOBAL'));                                                                                         
run;                                                                                                                                   
 
/* ...Submit the following in a subsequent SAS session...  */
 
libname l ".";

/* Place the macro variable(s) back into the GLOBAL symbol table. */
data _null_;                                                                                                                           
  set l.vars(where=(scope='GLOBAL'));                                                                                                   
  if substr(name,1,3) ne 'SYS' then do;                                                                                               
    call execute('%global '||left(trim((name)))||';');                                                                                   
    call execute('%let '||left(trim((name)))||'='||left(trim((value)))||';');                                                             
  end;                                                                                                                                 
run;  
