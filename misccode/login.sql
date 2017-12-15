-- 2009-05-11 
-- This file is auto-sourced by Oracle if it's in PWD
--
-- Something like this should be set in .vimrc:
-- au GUIEnter afiedt.buf winpos 37 55 | se lines=20 | se columns=170 | se tw=999999 | :new | silent :args c:/spool/links/*.LST | :hide | map :wq :wq! | noremap ZZ :wq!<CR>

-- DEFINE _EDITOR=vi
DEFINE _EDITOR=gvim

-- ACCEPT 	Get input from the user
-- DEFINE 	Declare a variable (short: DEF)
-- DESCRIBE 	Lists the attributes of tables and other objects (short: DESC)
-- EDIT 	Places you in an editor so you can edit a SQL command (short: ED)
-- EXIT or QUIT Disconnect from the database and terminate SQL*Plus
-- GET 		Retrieves a SQL file and places it into the SQL buffer
-- HOST 	Issue an operating system command (short: !)
-- LIST 	Displays the last command executed/ command in the SQL buffer (short: L)
-- PROMPT 	Display a text string on the screen. Eg prompt Hello World!!!
-- RUN 		List and Run the command stored in the SQL buffer (short: /)
-- SAVE 	Saves command in the SQL buffer to a file. Eg "save x" will create a script file called x.sql
-- SET 		Modify the SQL*Plus environment eg. SET PAGESIZE 23
-- SHOW 	Show environment settings (short: SHO). Eg SHOW ALL, SHO PAGESIZE etc.
-- SPOOL 	Send output to a file. Eg "spool x" will save STDOUT to a file called x.lst
-- START 	Run a SQL script file (short: @)

-- column employee_id format A7
-- column comments format A2
set linesize 180
--set appinfo ON
--set appinfo "SQL*Plus ~/code/misccode/login.sql"
--set arraysize 15
--set autocommit OFF
--set autoprint OFF
--set autorecovery OFF
-- good for debugging speed problems - prints an EXPLAIN PLAN and execution
-- statistics after each SQL statement
--set autotrace OFF
--set blockterminator "."
--set cmdsep ON
--set colsep " "
--set compatibility NATIVE
--set concat "."
--set copycommit 0
--set copytypecheck ON
--set define "&"
--set describe DEPTH 1 LINENUM OFF INDENT ON
--set echo OFF
--set editfile ".afiedt.buf"
--set embedded OFF
--set endbuftoken ""
--set escape OFF
--set feedback 6
--set flagger OFF
--set flush ON
--set heading ON
--set headsep "|"
--set linesize 78
--set logsource ""
--set long 80
--set longchunksize 80
--set newpage 1
--set null "_null_"
--set numformat ""
--set numwidth 10
set pagesize 999
--set pause OFF
--set recsep WRAP
--set recsepchar " "
--set serveroutput OFF
--set shiftinout invisible
--set showmode OFF
--set sqlblanklines OFF
--set sqlcase MIXED
--set sqlcontinue "> "
--set sqlnumber ON
--set sqlprefix "#"
--set sqlterminator ";"
--set suffix "sql"
--set tab ON
--set termout ON
--set time OFF
--set timing OFF
--set trimout ON
--set trimspool OFF
--set underline "-"
--set verify ON
set wrap off

-- Avoid having to prime the pump with e.g.  ed c:/cygwin/home/bheckel/t.sql
-- to make afiedt.buf available immediately
---select SYSDATE from dual;

-- Build sqlprompt e.g. "pks@usdev100> "
undefine usr db
col usr new_value usr
col db  new_value db
set termout off
select lower(user) usr,
       --substr(global_name, 1, instr(global_name, '.')-1) db
       lower(global_name) db
from   global_name
/
set termout on
set sqlprompt '&&usr.@&&db.> '

-- GSK specific
column meth_spec_nm format a15;
column meth_var_nm format a15;
column meth_peak_nm format a20;
column indvl_meth_stage_nm format a20;
column indvl_tst_rslt_device format a20;
column INDVL_TST_RSLT_VAL_CHAR format a20;
column indvl_tst_rslt_time_pt format a10;
column column_nm format a25;
column pks_peak format a25;
column prod_nm format a20;
column lab_tst_desc format a30;
column meth_rslt_char format a15;
column meth_rslt_numeric format 99999.999;
column checked_by_user_id format a15;
column samp_tst_dt format a15;
column checked_dt format a15;
column lab_tst_meth_spec_desc format a25;
column summary_meth_stage_nm format a20;

