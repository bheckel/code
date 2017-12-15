
 /* See http://support.sas.com/kb/32/684.html for details */

%macro m;
  * not %substr(' ;
  %put in macro m;
%mend;

data _null_;
  put 'in null';
  %m;
run;

endsas;
The comment line will cause failure
