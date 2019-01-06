-- Good defaults:
set colsep '|'
set linesize 167
set pagesize 30
set pagesize 1000

---

-- avoid sqlplus default 9 char date truncation
select to_char(min(test_status_date), 'DDMONYY HH24:MI:SS') as mintsd, to_char(max(test_status_date), 'DDMONYY HH24:MI:SS') as maxtsd

###

$ sqlplus xdm_dist_r/xlice45read@kuprd613 @zeb_lift_rpt_results_nl_all_minmaxteststatusdt.sql

SQL*Plus: Release 8.1.7.0.0 - Production on Wed Jun 5 15:52:59 2013

(c) Copyright 2000 Oracle Corporation.  All rights reserved.


Connected to:
Oracle Database 10g Enterprise Edition Release 10.2.0.5.0 - 64bit Production
With the Partitioning, Data Mining and Real Application Testing options

SQL> help column


###


set termout off;
set linesize 2000;
set pagesize 9999;

spool u:/serevent.out;

-------------------------

select *
from


-------------------------

spool off;
quit;
