
 /* XML data must be rectangular, non-hierachical (the usual XML way is
  * hierachical while SAS is usually relational), otherwise we need XML Mapper
  * to build XSLT:
  *
  * Attributes are dropped and SAS determines the data type, format and
  * informat of all vars during a simple read by SAS.
  */
libname myxml XML '.\junk.xml';

proc contents data=myxml._ALL_; run;
proc print data=myxml.STUDENTS(obs=max) width=minimum; run;


endsas;
junk.xml:

<?xml version="1.0" ?>
<SCHOOL>
   <STUDENTS>
      <ID> 0755 </ID>
      <NAME> Brad Martin </NAME>
      <ADDRESS> 1611 Glengreen </ADDRESS>
      <CITY> Huntsville </CITY>
      <STATE> Texas </STATE>
   </STUDENTS>

   <STUDENTS>
      <ID> 1522 </ID>
      <NAME> Zac Harvell </NAME>
      <ADDRESS> 11900 Glenda </ADDRESS>
      <CITY> Houston </CITY>
      <STATE> Texas </STATE>
   </STUDENTS>
</SCHOOL>
