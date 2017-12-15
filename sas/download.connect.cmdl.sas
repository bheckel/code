options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_download.sas (s/b symlinked as download.connect.cmdline.sas)
  *
  *  Summary: Demo of data file transfer without FTP.  Download FROM mainframe
  *           in this case.  See download.sas for dataset downloading.
  *
  *           If it hangs, you may be facing a MF archiving.
  *
  *           Sample call:
  *           $ sr download.connect.cmdline.sas 'vscp2000.pgmlib(natgo2a)'
  *           $ sr download.connect.cmdline.sas 'bqh0.bytes476'
  *
  *
  *           See download.sas for a simpler version.
  *
  *
  *  Created: Thu 29 May 2003 08:12:38 (Bob Heckel)
  * Modified: Wed 09 Feb 2005 11:33:51 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%global CHICKENPARM;
 /* OK for FILENAMEs to actually be directories if using wildcards (see
  * below). 
  */
%global TMPF;
%let TMPF=junkdload;
filename LOCAL "&TMPF";

%include "&HOME/code/sas/connect_setup.sas";
signon cdcjes2;

   /* Pass param to the Connect session (opposite of %sysrput).  Must precede
    * rsubmit.
    */
  %syslput CHICKENPARM=&SYSPARM;
  rsubmit;

  ***filename REMOTE 'bqh0.junk';
  ***filename REMOTE 'bqh0.pgm.lib(mor03x)';
  filename REMOTE "&CHICKENPARM";

   /* Transfer ALL the files in the partitioned data set on the remote OS/390
    * host to the library on the local machine. 
    */
  ***proc download  infile=REMOTE('*') outfile=LOCAL('*'); 
  ***run;

   /* Single file transfer TO the local machine. */
  proc download  infile=REMOTE outfile=LOCAL; 
  run;

   /* Capture remote macrovariable return code to send back to local host. */
  %sysrput rc=&SYSINFO;

endrsubmit;
signoff cdcjes2;


%macro Checkrc;
  %if &rc ne 0 %then 
    %put !!!transfer failure!!!;
  %else
 /***     x "c:/util/vim/vim61/gvim &TMPF"; ***/
%mend Checkrc;
%Checkrc
