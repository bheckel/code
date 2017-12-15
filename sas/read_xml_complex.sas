
 /* XML data must be rectangular, non-hierachical (the usual XML way is
  * hierachical while SAS is usually relational), otherwise we need XML Mapper
  * to build XSLT.
  *
  * Attributes are dropped and SAS determines the data type, format and
  * informat of all vars during a simple read by SAS.
  */

filename MAPPER 'complex.map';
libname myxml XML 'complex.xml' xmlmap=MAPPER access=READONLY ;

/***proc contents data=myxml._ALL_; run;***/
proc print data=myxml.area(obs=max) width=minimum; run;

