options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: unix_hfs.sas
  *
  *  Summary: Use Unix HFS filesystem to write SAS datasets created by
  *           mainframe.  Runs OK via Connect on the PC or can use this JCL to
  *           run from =2
  *
  *           //IN     DD DISP=SHR,DSN=BF19.MOX0401.NATMER                       
  *           //SYSIN  DD * 
  *
  *  Adapted: Wed 25 Feb 2004 15:52:05 (Bob Heckel -- Kryn Krautheim)
  *---------------------------------------------------------------------------
  */
options source;

filename IN 'BF19.MOX0401.NATMER' DISP=SHR;

 /* Creates (mkdir) new SAS library, i.e. directory. */
***libname TEST '/u/bqh0/newlib' DISP=NEW UNIT=TEMP DATACLAS=SAS;
 /* Use existing SAS library. */
libname TEST '/u/bqh0/newlib' DISP=OLD UNIT=TEMP DATACLAS=SAS;

data TEST.junk2;
  infile IN obs=10;
  input @3 cert $6.;
run;

proc print data=TEST.junk2; run;
