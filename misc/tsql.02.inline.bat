:: The backslash confuses Cygwin so must run via .bat
:: Query must be on single line
osql -E -S W23PSQL02\PRODUCTION -w 256 -Q "use pubs select top 10 * from authors"
