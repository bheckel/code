options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: alltreechecker.sas
  *
  *  Summary: For a tree of datasets, run simple (no parms) procs on each one
  *
  *  Created: Fri 11 Mar 2011 10:42:44 (Bob Heckel)
  * Modified: Mon 16 May 2011 10:59:23 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter ls=180;

/***options fmtsearch=(MYFMTLIB); libname MYFMTLIB "c:/datapost/code";***/

%global DRV DS;
%let DRV=z;  /* also may want to enable/disable macros at bottom */


 /*=======================================================================*/
%macro ForEach(s, procwhat);
  %local i f;

  %let i=1;

  %do %until (%qscan(&s, &i, ' ')=  );
    %let f=%qscan(&s, &i, ' '); 
    /*...........................................................*/
    %put !!! f is &f;
    title "!!!&f";
    proc &procwhat data=&f; run;
    /*...........................................................*/
    %let i=%eval(&i+1);
  %end;
%mend;


%macro ProcessAvailableDS;
  proc sql NOPRINT;
    create table dic as
    select memname, libname
    from dictionary.members
    where libname eq 'L' and memtype eq 'DATA'
    ;
  quit;

  proc sql NOPRINT;
    select compress(libname)||'.'||compress(memname) into :DS separated by ' '
    from dic
    ;
  quit;
%mend;
 /*=======================================================================*/


%macro MDPI;
  proc printto PRINT="u:/projects/harness/&DRV.&SYSDATE._MDPI.lst" NEW;

  libname l (
    "&DRV:/datapost/data/GSK/Zebulon/MDPI"
    "&DRV:/datapost/data/GSK/Zebulon/MDPI/AdvairDiskus"
    "&DRV:/datapost/data/GSK/Zebulon/MDPI/SereventDiskus"
  );
  %ProcessAvailableDS;
  %ForEach(&DS, freq)

  proc printto; run;
%mend;

%macro MDI;
  proc printto PRINT="u:/projects/harness/&DRV.&SYSDATE._MDI.lst" NEW;

  libname l (
    "&DRV:/datapost/data/GSK/Zebulon/MDI"
    "&DRV:/datapost/data/GSK/Zebulon/MDI/VentolinHFA"
  );
  %ProcessAvailableDS;
  %ForEach(&DS, freq)

  proc printto; run;
%mend;

%macro SD;
  proc printto PRINT="u:/projects/harness/&DRV.&SYSDATE._SD.lst" NEW;

  libname l (
    "&DRV:/datapost/data/GSK/Zebulon/SolidDose/Bupropion"
    "&DRV:/datapost/data/GSK/Zebulon/SolidDose/Lamictal"
    "&DRV:/datapost/data/GSK/Zebulon/SolidDose/Methylcellulose"
    "&DRV:/datapost/data/GSK/Zebulon/SolidDose/Valtrex"
    "&DRV:/datapost/data/GSK/Zebulon/SolidDose/Wellbutrin"
    "&DRV:/datapost/data/GSK/Zebulon/SolidDose/Zyban"
  );
  %ProcessAvailableDS;
  %ForEach(&DS, freq)

  proc printto; run;
%mend;

%macro ChunkTS;
  proc printto PRINT="u:/projects/harness/&DRV.&SYSDATE._chunkTS.lst" NEW;

  libname l (
    "&DRV:/datapost/code"
  );
  %ProcessAvailableDS;
  %ForEach(&DS, print)

  proc printto; run;
%mend;


%MDPI;
%MDI;
%SD;
%ChunkTS;

%put _all_;
