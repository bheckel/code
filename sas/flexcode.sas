options nosource;
 /*---------------------------------------------------------------------------
  *     Name: flexcode.sas
  *
  *  Summary: Demo of generating code at runtime.  Improves on using proc
  *           printto
  *
  *  Adapted: Mon 09 Dec 2002 16:23:38 (Bob Heckel -- Rick Aster SAS
  *                                     Programming Shortcuts p. 442)
  *---------------------------------------------------------------------------
  */
options source source2;

data work.houses;
   input style $8. sqfeet bedroom baths street & $15. price;
   cards;
RANCH      1250       2      1.0   Sheppard Avenue         64000
RANCH       720       1      1.0   Nicholson Drive         34550
TWOSTORY   1745       4      2.5   Highland Road          102950
CONDO      1860       2      2.0   Arcata Avenue          110700
;
run;

 /* Name must be 3 levels (excluding WORK) and the last level must be SOURCE. */
filename FLEX1 CATALOG 'work.temp.flex1.source';
data _NULL_;
  set work.houses;
  file FLEX1;
  put 'title1' +3 sqfeet:F6.2 ';';
  put +1 'proc print; run;';
run;

 /* Back to writing to Log. */
data _NULL_;
  put 'here is more';
run;

%include FLEX1 /source2;
