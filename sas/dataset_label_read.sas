options NOreplace NOcenter fullstimer;

libname L '/u/dwj2/mvds/MOR/2004';
***libname L 'DWJ2.NAT2003.MVDS.LIBRARY.NEW' DISP=SHR WAIT=1;

 /* Fastest */
data _null_;                                             
 memlabel = attrc(open("L.AKOLD"),"label");         
 call symput('CREATEDFROM',memlabel);                          
run;
%put &CREATEDFROM;


 /* Next fastest */
proc sql noprint;
  select memlabel into :CREATEDFROM
  from dictionary.tables
  where memname like 'AKOLD'
  ;
quit;
%put &CREATEDFROM;


 /* Pig */
data _null_;                                                      
 set SASHELP.vtable(where=(libname='L' and memname="AKOLD")); 
 call symputx('CREATEDFROM',memlabel);                                  
run;                                                              
%put &CREATEDFROM;

