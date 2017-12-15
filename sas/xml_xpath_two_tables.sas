options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: 
  *
  *  Summary: Demo of using XPATH map to read XML and build two tables
  *
  *  Adapted: Fri 30 Jul 2010 08:47:47 (Bob Heckel -- http://support.sas.com/documentation/cdl/en/engxml/62845/HTML/default/viewer.htm#/
  *                                                   documentation/cdl/en/engxml/62845/HTML/default/a002484895.htm)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

filename RSS 'rss.xml';
filename MAP 'rss.map';
libname RSS xml xmlmap=MAP;

title 'channel table'; proc print data=RSS.channel(obs=max) width=minimum; run;
title 'items table'; proc print data=RSS.items(obs=max) width=minimum; run;
