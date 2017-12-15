options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_upload.sas
  *
  *  Summary: Demo of data file transfer without FTP.
  *           See proc_downoad.sas for more complexity.
  *
  *           TODO how to upload a dataset into an existing sas library?
  *
  *  Created: Thu 29 May 2003 08:12:38 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

filename LOCAL 'junk';

%include "&HOME/code/sas/connect_setup.sas";
signon cdcjes2;
rsubmit;


filename REMOTE 'bqh0.junk';

proc upload infile=LOCAL outfile=REMOTE; 
run;

 /* Capture remote macrovariable. */
%sysrput rc=&SYSINFO;


endrsubmit;
signoff cdcjes2;


%macro Checkrc;
  %if &rc ne 0 %then 
    %put !!!transfer failure!!!;
%mend Checkrc;
%Checkrc;
