
 /* Traditional graphs are saved in SAS graphics catalogs and are controlled by
  * the GOPTIONS statement. In contrast, ODS Graphics produces graphs in
  * standard image file formats (not graphics catalogs), and their appearance
  * and layout are controlled by ODS styles and templates. */

ods _all_ close;
ods rtf file="loess.rtf" style=HTMLBlue;
ods graphics on;

proc loess data=sashelp.enso;
   model pressure = year / clm residual;
run;

ods rtf close;
ods listing;
