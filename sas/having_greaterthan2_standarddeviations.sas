data patients;
   input @1  Patno  $3.
         @4  Visit  mmddyy10.
         @14 HR      3.
         @17 SBP     3.
         @20 DBP     3.;
   format Visit mmddyy10.;
   cards;
00106/12/1998 80130 80
00106/15/1998 78128 78
00201/01/1999 48102 66
00201/10/1999 70112 82
00202/09/1999 74118 78
00310/21/1998 68120 70
00403/12/1998 70102 66
00403/13/1998 70106 68
00504/14/1998 72118 74
00504/14/1998 74120 80
00611/11/1998100180110
00709/01/1998 68138100
00710/01/1998 68140 98
;
run;

proc sql;
   select Patno, SBP
   from patients
   having SBP not between mean(SBP) - 2 * std(SBP) and mean(SBP) + 2 * std(SBP) 
          /* and SBP is not missing; */
   ;
quit;
