@echo off
:: Connect to each Samba share and exit.
:: Created: Wed, 01 Nov 2000 14:17:03 (Bob Heckel)
:: Modified: Tue 23 Oct 2001 10:51:50 (Bob Heckel)

:: This will usually fail.  Will not be needed unless using persistent:yes
cmd /C net use * /delete >nul

echo Attempting to Samba share lisa ~bheckel at O: ...
:: TODO why doesn't the alias hpLfs01 work?
:::cmd /C net use o: \\hpLfs01\bheckel /persistent:no /user:bheckel the9Fisu
cmd /C net use o: \\bart\bheckel /persistent:no /user:bheckel the9Fisu

echo Attempting to Samba share lisa /devshare at P: ...
cmd /C net use p: \\hpLdev01\devshare /persistent:no /user:software S0ftware

echo Attempting to Samba share prtpy0qx ~bheckel at R: ...
cmd /C net use r: \\prtpy0qx\bheckel /persistent:no /user:bheckel the9Fisu

:::echo Attempting to Samba share smtmgr ~bheckel at S: ...
:::cmd /C net use s: \\smtmgr\bheckel /persistent:no /user:bheckel the9Fisu

pause
