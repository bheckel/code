options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: shorten_length_format.sas
  *
  *  Summary: Take large character fields (eforms had them at 4000!) and cut 
  *           them down.
  *
  *  Created: Tue 17 Feb 2009 10:57:49 (Bob Heckel)
  * Modified: Tue 25 Sep 2012 08:39:21 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter NOlabel;

proc sql NOPRINT;
  select distinct name, name into :vars1 separated by ' $100 ', :vars2 separated by ' $100. '
  from dictionary.columns
  where libname eq 'WORK' and memname eq 'EFORMSVALTREX' and type ne 'num'
  ;
quit;

data eforms&product;
  /* for trailing var  */
  /*            ____   */
  length &vars1 $100;
  format &vars2 $100.;
  set eforms&product(drop= _NAME_ _LABEL_);
run;


endsas;
data t;
  input ch $;
  cards;
abc
def
  ;
run;
proc sql ;
  select distinct *
  from dictionary.columns
  where libname eq 'WORK' and memname eq 'T'
  ;
quit;



