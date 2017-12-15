
 /* Intentional error introduced by shortening 22 to 19.  The ?? keeps it from
  * being mentioned in the Log that Yr is now screwed up.  A single ? would
  * only keep SAS Log quiet, ?? sets _ERROR_ to 0 as well so you can really
  * bury the bodies.
  */
data quietcomplexmixedinput;
  infile cards;
  input ParkName $ 1-19  State $  Yr ??  @40 Acreage COMMA9.;
  cards;
Yellowstone           ID/MT/WY 1872    4,065,493   123
Everglades            FL 1934          1,398,800   123
Yosemite              CA 1864            760,917   123
Great Smoky Mountains NC/TN 1926         520,269   123
Wolf Trap Farm        VA 1966                130   123
  ;
run;

title 'data readin is wrong, should not have suppressed the error';
proc print data=_LAST_;
  format Acreage COMMA10.;
run;
