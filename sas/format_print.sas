options NOcenter NOreplace;

 /* View the contents of a SAS format catalog file */

***libname FLIB 'DWJ2.NAT1989.FORMAT.ODSLIB';  /* pre-MVDS formats */
***libname FLIB 'X:\BPMS\_Common\Data';
libname FLIB 'c:\temp'; 

 /* View, display, print permanent stored formats */
proc format library= WORK FLIB FMTLIB;
  /* Or if you already know the format names: */
  ***select $f_rgn;
  ***select $LISTA;
run;
