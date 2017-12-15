:: Run via MS Scheduler to fix cron after hibernation.

:: TODO avoid DOS window appearing
:: start /B C:\cygwin\home\bheckel\code\misccode\hiberoff.bat
:: does not work

c:\cygwin\bin\cygrunsrv -E cron
c:\cygwin\bin\cygrunsrv -S cron
