 /* See countall_datasets.sas when you want the whole dir (or can specify a
  * LIKE criteria.
  */

options noreplace;
libname K "&HOME/tmp/testing/tst";

%let p=
  amerge
  avandamet
  avandaryl
  avandia
  bupropionl
  combivirl
  epivirl
  flovent
  imitrex
  lamivudine
  lamotrigine
  lanoxin
  lotronex
  retrovir
  salmeterol
  serevent
  trandate
  trizivir
  valacyclovir
  valtrex
  ventolin
  watson
  wellburin
  wellbutrin
  zantac
  ziagen
  zidovudine
  zofran
  zovirax
  zyban
;

options nomlogic nomprint nosgen;
%macro looparray; 
  %local i elem; 

  %let i=0; 

  %do %while (%scan(&p, &i+1, %str( )) ne %str( ));
    %let i=%eval(&i+1); 
    %let elem=%scan(&p, &i, %str( ));  
    %put &elem ind recnt: %sysfunc(attrn(%sysfunc(open(K.ind&elem.01a)), NLOBSF));
    %put &elem sum recnt: %sysfunc(attrn(%sysfunc(open(K.sum&elem.01a)), NLOBSF));
  %end; 
%mend looparray; 
%looparray
