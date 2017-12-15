/* long to wide aka "spreading" */

/*
--------------------------- pharmacypatientid=10119 -----------------------------

              medicationname                   storeid     minfill      maxfill

ATORVASTATIN CALCIUM;APO-ATORVASTATIN 10 MG     0299      31MAR2016    20NOV2016
PERINDOPRIL ERBUMINE;COVERSYL 4 MG              0299      22JAN2016    18NOV2016
ROSUVASTATIN CALCIUM;APO-ROSUVASTATIN 5 MG      0299      18NOV2016    07MAR2017
ROSUVASTATIN CALCIUM;CRESTOR 5 MG               0299      15AUG2016    16SEP2016
TAMSULOSIN HCL;FLOMAX CR 0.4 MG                 0299      18NOV2016    24FEB2017
TAMSULOSIN HCL;SDZ-TAMSULOSIN CR 0.4 MG         0299      11JAN2017    11JAN2017
...
there are 27 drugs for some pharmacypatientids
...
*/


proc transpose out=t3;
  by pharmacypatientid;
  var maxfill;
run;


/*
-------------------------------------------------------------- pharmacypatientid=10119 ------------------------------------------------------------

     _NAME_       COL1         COL2         COL3         COL4         COL5         COL6       COL7    COL8    COL9    COL10    COL11

     maxfill    20NOV2016    18NOV2016    07MAR2017    16SEP2016    24FEB2017    11JAN2017     .       .       .        .        .

     COL12    COL13    COL14    COL15    COL16    COL17    COL18    COL19    COL20    COL21    COL22    COL23    COL24    COL25    COL26    COL27

       .        .        .        .        .        .        .        .        .        .        .        .        .        .        .        .
*/
