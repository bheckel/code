
 /* c:/PROGRA~1/SASINS~1/SAS/V8/sas.exe -sysin './maillogs.sas' -log './maillogs.log' */

%let PGM=%str(U:\gsk\maillogs.sas);

filename MAILTHIS email ('bheckel@gmail.com' 'rsh86800@gsk.com')
/***filename MAILTHIS email ('rsh86800@gsk.com')***/
         subject="DP Logs &SYSDATE"
         attach=('z:\datapost\code\datapost_extract.log'
                 'z:\datapost\code\datapost_transform.log')
         ;
data _null_;
  file MAILTHIS;
  put "&SYSDAY Logs from &PGM";
  put;
  put 'record counts g!/observations read from the data set.*LIMS/d';
run;
