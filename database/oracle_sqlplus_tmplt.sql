
-- Login to SQL*Plus (use oradev or oratst alias on Cygwin) then paste this
-- into it:
-- @c:/cygwin/home/bheckel/code/misccode/oracle_sqlplus_tmplt.sql
-- to source this file

set flush on;
spool off;
spool c:/cygwin/home/bheckel/t.LST;
set linesize 2000;
set pagesize 9999;
set termout off;

desc samp;

-- :new+e ~/t.LST
