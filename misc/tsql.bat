:: The backslash confuses Cygwin so must run via .bat
osql -E -S WNETBPMS1\PRODUCTION -w 256 -i %1
