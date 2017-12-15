 /* Copy the resulting output (proc format statement) and paste it into
  * ckformat.step2.sas   Don't copy the  lib=FMTL  part!
  *
  *           ___CHECK FORMATS___
  */
options NOcenter;

%include 'BQH0.PGM.LIB(RECREATE)';
 /* Always 2003! */
***libname FMTL "DWJ2.FET2003.FMTLIB" DISP=SHR WAIT=10;
libname FMTL "DWJ2.FET2003R.FMTLIB" DISP=SHR WAIT=10;
 /* On local PC */
%RebuildFormat(FMTL, V007A);
