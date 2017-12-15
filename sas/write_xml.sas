options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: write_xml.sas
  *
  *  Summary: Edit an XML file in-place.
  *
  *  Created: Tue 20 Jul 2010 15:20:16 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* If the .xml doesn't already exist: */
libname xlib xml 'junk.xml';
data xlib.junk;
  set SASHELP.shoes(obs=5);
run;

 /* XML to SAS */
data _junk;
  set xlib.junk;
run;

 /* Add an (incomplete) obs */
data _junk2;
  region='Africa';
  output;
run;
proc append base=_junk data=_junk2 FORCE;run;

 /* SAS back to XML */
data xlib.junk;
  set _junk;
run;
