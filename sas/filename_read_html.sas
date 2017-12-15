
***filename H HTTP 'http://www.spc.noaa.gov:80/climo/reports/100430_rpts_torn.csv';
filename H HTTP 'http://www.communities.gov.uk/documents/corporate/xls/175179413.csv';

proc import datafile='H'
            out=foo
            dbms=CSV
            replace
            ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
