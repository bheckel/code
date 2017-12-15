@echo off
::                                              %1                   %2                  %3                            %4
:: E.g. %send_to_dropbox(cygpath=/cygdrive/e/Users/Bob.Heckel/, fn=test.fdw, server=dataproc.mrk.taeb.com, droppath=/mnt/nfs/home/bheckel);
:: This tempfile is required to allow Cygwin to do a chmod as the "linux" owner:
echo %1%2
start /B  c:/cygwin64/bin/bash.exe -c "/bin/cp %1%2 ~/%2 && /bin/chmod 777 ~/%2 && /bin/scp -p ~/%2 %3@%4 && /bin/rm -f ~/%2"
:: On Windows we can't trap any errors via 2>/tmp/e.err so leave cmd up for user
echo 'press enter to continue'
pause
exit
