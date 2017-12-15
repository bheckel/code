-- Change accounts from within SQL*Plus
-- E.g.
-- scott@ORATEST> @connect tony/davis
-- tony@ORATEST>

set termout off
connect &1
@c:/cygwin/home/bheckel/code/misccode/_sqlplusrc.sql
set termout on
