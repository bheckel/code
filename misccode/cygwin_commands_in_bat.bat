@echo off
::                                                     %1             %2              %3               %4
::                                            _____________________ _______ ___________________ ___________________
:: E.g. e:\Analytics\send_mult_to_dropbox.bat /cygdrive/e/Analytics bheckel sas-01.wta.taeb.com ~/mnt/nfs/dropboxes
:: E.g. e:\Analytics\send_mult_to_dropbox.bat /cygdrive/e/Analytics bheckel adtaproc.mrk.taeb.com /mnt/nfs/home/janitor/dataproc/tmm/eligibility/pending

echo DEBUG parameter 1 is %1
echo DEBUG parameter 2 is %2
echo DEBUG parameter 3 is %3
echo DEBUG parameter 4 is %4
echo ---
echo DEBUG c:/cygwin64/bin/bash.exe -c "/bin/find %1 -name 'Weekly_Target_Patient_Report_*.pdf*' -exec /bin/scp {} %2@%3:%4 \;
echo ---

:::start /B  c:/cygwin64/bin/bash.exe -c "/bin/find /cygdrive/e/temp/ -name 'Weekly_Target_Patient_Report_*.pdf*' -exec /bin/chmod 777 {} \;"
start /B  c:/cygwin64/bin/bash.exe -c "/bin/find %1 -name 'Weekly_Target_Patient_Report_*.pdf*' -exec /bin/chmod 777 {} \;"

:::start /B  c:/cygwin64/bin/bash.exe -c "/bin/find /cygdrive/e/temp/ -name 'Weekly_Target_Patient_Report_*.pdf*' -exec /bin/scp {} bheckel@sas-01.twa.ateb.com:~/mnt/nfs/dropboxes/ \;"
start /B  c:/cygwin64/bin/bash.exe -c "/bin/find %1 -name 'Weekly_Target_Patient_Report_*.pdf*' -exec /bin/scp {} %2@%3:%4 \;"

:::pause
exit
