options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: combine_textfiles.sas
  *
  *  Summary: Combine two textfiles.
  *
  *  Created: Tue 22 Jun 2004 10:06:21 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

filename MAPO "DWJ2.FLMOR03O.USMED" DISP=OLD UNIT=NCHS LRECL=16
              BLKSIZE=8000 RECFM=FB;

filename MAPR "DWJ2.FLMOR03R.USMED" DISP=OLD UNIT=NCHS LRECL=16
              BLKSIZE=8000 RECFM=FB;

filename MAP "DWJ2.FLMOR03.USMED" DISP=OLD UNIT=NCHS LRECL=16
             BLKSIZE=8000 RECFM=FB;

data tmpO;
  infile MAPO TRUNCOVER;
  input @1 block $CHAR16.;
run;

data tmpR;
  infile MAPR TRUNCOVER;
  input @1 block $CHAR16.;
run;

 /* Creates tmp on the fly. */
proc append base=tmp data=tmpO; run;
proc append base=tmp data=tmpR; run;

proc print data=tmp; run;

data _NULL_;
  set tmp;
  file MAP;
  put @1 block $CHAR16.;
run;



 /*********************************************************************/
 /*  TODO doesn't work on mainframe (or Windows?? haven't tested yet) */
%macro bobh;
filename MAPO "DWJ2.FLMOR03O.USMED" DISP=OLD UNIT=NCHS LRECL=16
              BLKSIZE=8000 RECFM=FB;

filename MAPR "DWJ2.FLMOR03R.USMED" DISP=OLD UNIT=NCHS LRECL=16
              BLKSIZE=8000 RECFM=FB;

filename MAP "DWJ2.FLMOR03.USMED" DISP=OLD UNIT=NCHS LRECL=16
             BLKSIZE=8000 RECFM=FB;
%mend bobh;
%macro bobh2;
filename MAPO "bqh0.junk" DISP=OLD UNIT=NCHS LRECL=80
              BLKSIZE=8000 RECFM=FB;
filename MAP "bqh0.junkmap" DISP=OLD UNIT=NCHS LRECL=80
              BLKSIZE=8000 RECFM=FB;

data _NULL_;
  file MAP mod;
  infile MAPO;
  input;
  put _INFILE_;
run;
%mend bobh2;
 /*********************************************************************/
