options nosource;
 /*---------------------------------------------------------------------------
  *     Name: input_textvalue.sas
  *
  *  Summary: Demo of using a text value as a marker to determine where the
  *           input pointer should go to next (it is positioned immediately 
  *           after the text value).
  *
  *  Adapted: Fri 21 Feb 2003 17:17:33 (Bob Heckel -- SAS Tips & Techniques
  *                                     Phil Mason)
  * Modified: Wed 20 Nov 2013 14:04:30 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data identifier_in_data;
  input @'USED' quant;
  cards;
first USED 1.234 ok value
number 2 USED 4.56 bye
third happens to be: USED 123456789.012
  ;
run;
proc print; format quant 10.4; var quant; run;



data parse_apache_weblog;
  input @'[' AccessDate DATE11. @'GET' File :$20.;
  cards;
130.192.70.235 - - [08/Jun/2004:23:51:32 -0700] "GET /rover.jpg HTTP/1.1" 200 66820
128.32.236.8 - - [08/Jun/2004:23:51:40 -0700] "GET /grooming.html HTTP/1.0" 200 8471
128.32.236.8 - - [08/Jun/2004:23:51:40 -0700] "GET /Icons/brush.gif HTTP/1.0" 200 89
118.171.121.37 - - [08/Jun/2004:23:56:46 -0700] "GET /bath.gif HTTP/1.0" 200 14079
  ;
run;
proc print data=_LAST_(obs=max); run;
