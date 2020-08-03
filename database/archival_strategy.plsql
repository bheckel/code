--https://asktom.oracle.com/pls/apex/f?p=100:11:0::::P11_QUESTION_ID:9534224000346780276

SQL> create table t as
  2  select date '2010-01-01'+rownum x, rownum y from dual connect by level <= 365*5;

Table created.

SQL>
SQL> alter table t add constraint PK primary key ( x );

Table altered.

SQL>
SQL> create table t_bkp as select * from t where 1=0;
create table t_bkp as select * from t where 1=0
             *
ERROR at line 1:
ORA-00955: name is already used by an existing object


SQL>
SQL> create or replace
  2  procedure archiver(p_date date) is
  3  begin
  4    begin
  5      execute immediate 'drop table t_temp purge';
  6    exception
  7      when others then null;
  8    end;
  9
 10    insert /*+ APPEND */ into t_bkp
 11    select * from t
 12    where x <= p_date;
 13
 14    dbms_output.put_line('Copied '||sql%rowcount||' rows to backup table');
 15
 16    execute immediate
 17      'create table t_temp as select * from t where x > date '''||to_char(p_date,'yyyy-mm-dd')||'''';
 18    dbms_output.put_line('Created t_temp with remaining rows');
 19
 20    execute immediate 'alter table t rename constraint PK to PK_OLD';
 21    execute immediate 'alter index PK rename to PK_OLD';
 22    dbms_output.put_line('Renamed constraint');
 23
 24    execute immediate
 25      'alter table t_temp add constraint PK primary key ( x ) ';
 26    dbms_output.put_line('Added constraint to t_temp');
 27
 28    execute immediate
 29      'rename t to t_gone';
 30    dbms_output.put_line('Renamed table t to t_gone');
 31
 32    execute immediate
 33      'rename t_temp to t';
 34    dbms_output.put_line('Renamed table t_temp to t');
 35
 36    execute immediate
 37      'drop table t_gone purge';
 38    dbms_output.put_line('t_gone is gone ');
 39
 40  end;
 41  /

Procedure created.

SQL>
SQL> set serverout on
SQL> exec archiver(date '2012-01-01');
Copied 730 rows to backup table
Created t_temp with remaining rows
Renamed constraint
Added constraint to t_temp
Renamed table t to t_gone
Renamed table t_temp to t
t_gone is gone

PL/SQL procedure successfully completed.

SQL>
SQL> select min(x) from t;

MIN(X)
---------
02-JAN-12

1 row selected.

SQL> exec archiver(date '2013-01-01');
Copied 366 rows to backup table
Created t_temp with remaining rows
Renamed constraint
Added constraint to t_temp
Renamed table t to t_gone
Renamed table t_temp to t
t_gone is gone

PL/SQL procedure successfully completed.

SQL> select min(x) from t;

MIN(X)
---------
02-JAN-13

1 row selected.
