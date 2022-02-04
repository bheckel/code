--  Created: 11-May-2009 (Bob Heckel)
-- Modified: 02-Sep-2021 (Bob Heckel)

-- This file is auto-sourced by Oracle sqlplus if it's in PWD
--
-- Something like this could be set in .vimrc:
-- au GUIEnter afiedt.buf winpos 37 55 | se lines=20 | se columns=170 | se tw=999999 | :new | silent :args c:/spool/links/*.LST | :hide | map :wq :wq! | noremap ZZ :wq!<CR>

DEFINE _EDITOR=vim
-- DEFINE _EDITOR='C:\Users\bheck\vim\vim81\gvim.exe -u c:\cygwin64\home\bheck\dotfiles\_vimrc'

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

--set appinfo ON
--set appinfo "SQL*Plus ~/code/misccode/login.sql"
--set arraysize 15
--set autocommit OFF
--set autoprint OFF
--set autorecovery OFF
-- good for debugging speed problems - prints an EXPLAIN PLAN and execution statistics after each SQL statement
--set autotrace ON
--set autotrace traceonly explain
--set blockterminator "."
--set cmdsep ON
--set colsep " "
--set compatibility NATIVE
--set concat "."
--set copycommit 0
--set copytypecheck ON
--set define OFF
--set define "&"
--set describe DEPTH 1 LINENUM OFF INDENT ON
--set echo OFF
--set editfile ".afiedt.buf"
--set embedded OFF
--set endbuftoken ""
--set escape OFF
--set feedback ON
--set flagger OFF
--set flush ON
--set heading ON
--set headsep "|"
set linesize 268
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
-- Display dbms_output messages:
set serveroutput ON size unlimited format wrapped
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
set time ON
set timing ON
--set trimout ON
--set trimspool OFF
--set underline "-"
--set verify ON
--set wrap OFF

-- Avoid having to prime the pump with e.g.  ed[it] c:/cygwin/home/bheckel/t.sql
-- to make afiedt.buf available immediately
---select SYSDATE from dual;
-- or just rely on this as a side-effect:
-- Build sqlprompt e.g. "pks@dev100> "
UNDEFINE _usr _db
col _usr new_value _usr
col _db  new_value _db
set termout off
select lower(user) _usr,
       --substr(global_name, 1, instr(global_name, '.')-1) _db
       lower(global_name) _db
from   global_name
/

set termout on
set sqlprompt '&&_usr.@&&_db.> '

-- project specific
--column meth_spec_nm format a15;
--column meth_rslt_numeric format 99999.999;
