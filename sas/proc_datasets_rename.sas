
 /* Avoids a weakness of proc copy which won't allow renaming on the fly.  But
  * is still weak in that we can't copy to a new lib while we're renaming.
  *
  * Probably best to just use proc append.
  */

***libname L 'c:/temp';
libname L 'DWJ2.USTOT.SASLIB' DISP=OLD WAIT=30;

 /* Rename a SAS dataset. */
proc datasets lib=L;
  /* If needed, delete old first. */
  ***delete UST2002OLDFET;
  /*         Old          New         */
  ***change UST2003OLDFET=UST2002OLDFET;
  change UST2002NEWFET=UST2002NEWFETbak;
  change UST2002OLDFET=UST2002OLDFETbak;
  change UST2003NEWFET=UST2003NEWFETbak;
  change UST2003NEWMOR=UST2003NEWMORbak;
  change UST2003NEWNAT=UST2003NEWNATbak;
  change UST2003OLDFET=UST2003OLDFETbak;
  change UST2003OLDMOR=UST2003OLDMORbak;
  change UST2003OLDNAT=UST2003OLDNATbak;
run;

 /* Runs a contents by default */


 /* Rename var */
proc datasets lib=l;
  modify ap;
  rename atebpatientid5=atebpatientid;
run;


 /* Rename both dataset and vars */
proc datasets lib=mylib;
  change DSD=DAD;
  modify DAD;
  rename dsd_trans = dad_trans
         admission_date=admdate;
  format admdate DATE9.;
run;
