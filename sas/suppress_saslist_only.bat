
set sasexe=c:\PROGRA~1\SASINS~1\SAS\V8\sas.exe
:: Normal
:::%sasexe% -nosplash -sysin t.sas -log t.log -print t.lst
:: This version pops up a window with lst data in it
:::%sasexe% -nosplash -sysin t.sas  -log t.log -noprint
%sasexe% -NOsplash -sysin t.sas  -log t.log -NOterminal -NOprint
pause
