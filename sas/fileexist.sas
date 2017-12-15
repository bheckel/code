options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: fileexist.sas
  *
  *  Summary: Check for existence of a physical file.  Also works for
  *           directories (at least fexist does, that is).
  *
  *  Created: Wed 09 Jul 2003 12:46:55 (Bob Heckel)
  * Modified: Mon 09 Feb 2009 10:28:33 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source /*noxwait*/;

filename F "&HOME/bladerun_crawl";
filename F2 "&HOME/bladerun_crawlx";

data _null_;
  if fexist('F') and fexist('F2') then
    put 'both are there';
  else
    put 'one or both are not';
run;



%macro Fex(fn);
  %if %sysfunc(fileexist(&fn)) %then %put &fn exists;
  %else %put &fn does not exist;
%mend;
%Fex(c:/cygwin/home/bheckel/bladerun_crawlX);



%include "&HOME/code/sas/connect_setup.sas";
signon cdcjes2;
rsubmit;

%let fn = 'BF19.AKX0306.MORMER';
%macro Fex;
  %if %sysfunc(fileexist(&fn)) %then
    %do;
      %let fid=%sysfunc(fopen(&fn));
      %put !!! The external file &fn does exist.  fid is &fid;
    %end;
  %else
    %put !!! The external file &fn does NOT exist.;
%mend Fex;
%Fex;

endrsubmit;
signoff cdcjes2;



data _null_;
  if fileexist('FW_ONLINE.txt') then do;
    rc=system("move FW_ONLINE.txt INPROC.txt");
    filename F "INPROC.txt";
    call execute('%ProcessFreeWeigh');
  end;
  else
    put 'WARNING: no file';
run;
