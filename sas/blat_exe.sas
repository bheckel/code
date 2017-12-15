 /* http://rtpsawn321/links/batchUTC_9.asp */


options source;
DATA _NULL_;
  sendcmd = 'D:\Sas_Programs\SAS_Mail\Blat.exe "d:\unit_test_files\vcc60335.txt" -t "rsh86800@gsk.com,rsh86800@gsk.com" -s "subj3" -f "pks@gsk.com" -server "smtphub.glaxo.com"';
  put '+++SendCmd: ' sendcmd;
  cmdrc = system(sendcmd);
  put '+++'cmdrc'+++';
run;
