options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: zipfiles.sas
  *
  *  Summary: Demo of extracting a file from a zip
  *
  *           Experimental in 9.1.3 may be decommissioned
  *
  *  Adapted: Fri 22 Apr 2005 09:36:36 (Bob Heckel -- Phil Mason tip 126)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /*          magic        */
filename IN saszipam 'c:\cygwin\home\bqh0\tmp\testing\sastest.zip';

data _null_;
  infile IN(one.txt);
  input ;
  put _infile_;
  if _n_> 10 then
    stop ;
run ;
