options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: compiled_macro.sas
  *
  *  Summary: Compile, use and view source of, a macro.
  *
  *  Adapted: Wed 14 Sep 2005 17:10:28 (Bob Heckel --
  *        http://support.sas.com/91doc/getDoc/mcrolref.hlp/a001328775.htm)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

libname L 'c:/temp';

options mstored sasmstore=L;

%macro compiled_macro(foo) / STORE SOURCE DES='store macro description here';
  %put hello world &foo;
%mend;



 /* The following would normally not be in same file as the source above */

 /* Call */
%compiled_macro('ok then');


 /* Prints originally compiled macro source code. */
%copy compiled_macro / SOURCE;

