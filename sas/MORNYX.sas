//BQH0NY JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=5,CLASS=V,REGION=0M
//*
//*** OUTPUT LIST OF BF19 FILE NAMES TO DATASET:
//*LIST    EXEC PGM=IDCAMS
//*SYSPRINT DD DSN=BQH0.BF19.DATASET,DISP=OLD
//*SYSIN DD *
//* LISTC LEVEL(BF19)
//*** END OUTPUT
//*
//STEP1   EXEC SAS,OPTIONS='MSGCASE,MEMSIZE=0'
//WORK    DD SPACE=(CYL,(450,450),,,ROUND)
//SYSIN   DD *
 ********************************************************************;
 *     Name: MORNYX;
 *  Summary: Determine decedents coded with state-of-residence = NY ;
 *           and county = 010, 011, 053, 077 or 087 (i.e. NYC);
 *           but dying outside of NYC ;
 *                                                                   ;
 *           Create one 142 byte NCHS formatted demographic and one ;
 *           mapping file for the pseudo certificates ;
 *  Adapted: Wed 14 Aug 2002 15:49:05 (Bob Heckel);
 ********************************************************************;
options ls=133 caps notes source mprint symbolgen mlogic mprint;

%global BYR TOTCUR TR DEBUG;

* TODO elminate hardcoded counties below;
%let xstate=YC;    /* abbreviation for state to exclude */
%let xstatec=33;   /* code for state to exclude */
%let BYR=2001;     /* file year */

* Renamed per David J. from NYMOR01.USRES,MED;
filename nchsfmt "DWJ2.YCMOR01.USRES" DISP=NEW UNIT=NCHS LRECL=142 
                                      BLKSIZE=14200 RECFM=FB;
filename medmap "DWJ2.YCMOR01.USMED" DISP=NEW UNIT=NCHS LRECL=16 
                                     BLKSIZE=8000 RECFM=FB;

* Reads in file names from listing of all bf19 files;
data rawdata;
  length fn $ 25;
  infile 'BQH0.BF19.DATASET' truncover;
  input fn $ 18-42;
run;

data _NULL_;
  s = substr("&BYR", 3, 2);
  call symput('TR', s);
run;

data allfile;
  set rawdata;
  length bf19 $ 4 st $ 2 yr $ 2 indx $ 2 type $ 7;

  word1 = scan(fn,1,'.');
  word2 = scan(fn,2,'.');
  word3 = scan(fn,3,'.');

  st=substr(fn,6,2);
  yr=substr(fn,9,2);

  * Don't bother looking at decedent dead in home state.  Only want;
  * decedent dead in state that is not his residence state;
  if st="&xstate" then delete;

  * Determine yrn by checking to see if 2 or 3 digit shipment;
  * number was used;
  if length(word2) ge 8 then
    do;
      yrn=substr(fn,9,5);
      indx=substr(fn,21,2);
    end;
  else
     do;
       yrn=substr(fn,9,4);
       indx=substr(fn,20,2);
     end;
  * type is now the value of word3 (natmer for example);
  type=substr(word3,1,6);
  bf19=substr(fn,1,4);
  lbr=substr(fn,6,2) || substr("&BYR",1,4);
  fn=trim(fn);
  if bf19 ne 'BF19' then delete;
  if type ne 'MORMER' then delete;
  if yr ne &TR then delete;

  * Deletes merged files that end with an alpha extension;
  * but on 12102001 david asked us to use the 2000 mortality;
  * dataset names that end in the letter m;
  * prev we were told to retain these files but use the final;
  * files as listed in the excel spreadsheet without the letter m;
  * the following if statement and the else are the latest editions;
  if type eq 'MORMER' and yr eq '00' then
    do;
      if substr(indx,1,1) ge 'a' and substr(indx,1,1) le 'z' then
        do;
          if substr(indx,1,1) ne 'm' then delete;
        end;
      if substr(indx,2,1) ge 'a' and substr(indx,2,1) le 'z' then
        do;
          if substr(indx,2,1) ne 'm' then delete;
        end;
    end;
  else
    do;
      if 'a' le substr(indx,1,1) le 'z' then delete;
      if 'a' le substr(indx,2,1) le 'z' then delete;
    end;
run;

* Convert the yr and shipment number (yrn) to numeric before sorting;
* so the 3 digit ship nos are at bottom;
data allfile;
  set allfile;
  yrnum = input(yrn,5.);
run;

proc sort data=allfile;
  by st yrnum indx;
run;

* Correct the problem with the extensions of the bf19 medmer files;
data allfile;
  set allfile;
  ext = substr(fn,23,3);
  if ext ne '' then delete;
run;

* Choose the latest bf19 from the dataset;
data allfile;
  set allfile;
  by st yrnum indx;
  if last.st;
  keep fn lbr yr;
run;

data current;
  set allfile;
  keep lbr;
run;

data _NULL_;
   set current end=last;
   n = _N_;
   if last then call symput('TOTCUR',n);
run;

data current;
  set current;
  length st $ 2;
  st= substr(lbr,1,2);
  keep st;
run;

* Turn off chatter to avoid interfering with filename statement generation;
options nonotes nosource pagesize=2000;

filename fname '&name' DISP=NEW UNIT=FILE LRECL=80 BLKSIZE=1920 
                       RECFM=FB;

proc printto log=fname new;
run;

data _NULL_;
  set allfile;
  put 'filename ' lbr "'" fn  "' " 'DISP=SHR;';
run;

data _NULL_;
  set current;
  n = _N_;
  put '%let cur' n "=" st ";";
run;

proc printto;
run;

options ls=133 caps notes source source2 mprint symbolgen;

%include fname '&name';

%macro readin;
  %do j = 1 %to &TOTCUR;
    %do k = &BYR %to &BYR;
      %let s = &&cur&j;
      data in&j&k;
        infile &s&k;
        input @89 stres $char2.  @91 county $char3.  @;
        * Want NYC residents dead outside of NYC;
        * The five boroughs are listed in the IN statement;
        if stres = "&xstatec" and
           county in('010', '011', '053', '077', '087');
          input @5 certno $char6.  @47 alias $char1.
                @48 blockA $char5.  @64 blockB $char7.
                @74 blockC $char3.  @77 stod $char2.
                @79 blockD $char10.  @91 blockE $char7. 
                @117 blockF $char1.  @135 blockG $char8.
                ;

        if alias = '1' then delete;
      run;
    %end;
  %end;
%mend readin;
%readin

* Create dataset names IN12000, IN22000, IN32000...IN562000;
* TODO how does the number between IN and 2000 map to the states?;
%macro curfiles;
  %do k=1 %to &TOTCUR;
    in&k&BYR
  %end;
%mend curfiles;

* Concatenate the IN12000... datasets into one dataset;
data rpt;
  set %curfiles;
run;

proc sort data=rpt;
  by stod certno;
run;

data rpt;
  set rpt;
  * Initialize pseudo certificate number;
  certinit = 0;
  certinit + _N_;
  * Zero padded per NCHS format;
  fakecert=put(certinit,z6.);
run;

* Create the NCHS formatted file;
data _NULL_;
  set rpt;
  file nchsfmt;
  put @5 fakecert  @48 blockA  @64 blockB  @74 blockC  @77 stod
      @79 blockD  @89 "&xstatec"  @91 blockE  @117 blockF  @135 blockG
      ;
run;

* Create the certificate mapping file for Donna per David's specifications;
data _NULL_;
  set rpt;
  file medmap;
  put @1 stod  @4 certno  @11 fakecert;
run;

/*
//
