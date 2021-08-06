-- Adapted: 02-Aug-2021 (Bob Heckel  - https://www.orafaq.com/node/4)

-- Simple to defrag
CREATE TABLE myemp (
	myempid  NUMBER PRIMARY KEY,
	ename  VARCHAR2(30),
	salary NUMBER(8,2),
  	bonus NUMBER(8,2),
	deptno NUMBER--,
 --   vc number generated always as (coalesce(bonus,salary)) virtual
  );
create index myemp_idx on myemp (ename);
insert into myemp values (1, 'Frank',  15000, 99, 10);
insert into myemp values (2, 'Willie',  10000, null, 20);
alter table myemp add vc number generated always as (coalesce(bonus,salary)) virtual;
alter table myemp drop column vc;

--  set serveroutput on
EXEC DBMS_REDEFINITION.CAN_REDEF_TABLE('admin', 'myemp', 2);  -- 2=rowid
CREATE TABLE myemp_work AS SELECT * FROM myemp WHERE 1=2;
EXEC DBMS_REDEFINITION.START_REDEF_TABLE('admin', 'myemp', 'myemp_work', NULL, 2);
select * from myemp_work;--2rec
EXEC DBMS_REDEFINITION.FINISH_REDEF_TABLE('admin', 'myemp', 'myemp_work');
DROP TABLE  myemp_work;


-- Complex
-- Create a new table with primary key...
CREATE TABLE myemp (
	empid  NUMBER PRIMARY KEY,
	ename  VARCHAR2(30),
	salary NUMBER(8,2),
	deptno NUMBER);
insert into myemp values (1, 'Frank', 15000, 10);
insert into myemp values (2, 'Willie',  10000, 20);
create index myemp_idx on myemp (ename);

--  set serveroutput on
-- Test if redefinition is possible...
EXEC DBMS_REDEFINITION.CAN_REDEF_TABLE('admin', 'myemp');

-- Create new empty interim table...
CREATE TABLE myemp_work (
	emp#   NUMBER PRIMARY KEY,	-- Change emp_id to emp#
	ename    VARCHAR2(30),
	salary   NUMBER(8,2),		-- We will increase salary by 10%
	deptno   NUMBER)
   PARTITION BY LIST (deptno) (  	-- Add list partitioning
	PARTITION p10 VALUES (10), 
	PARTITION p20 VALUES (20), 
	PARTITION p30 VALUES (30,40));

-- Create a transformation function...
CREATE FUNCTION raise_sal (salary NUMBER) RETURN NUMBER AS
BEGIN
 return salary + salary*0.10; 
END;
/

-- Start the redefinition process
EXEC DBMS_REDEFINITION.START_REDEF_TABLE('admin', 'myemp', 'myemp_work', -
	'empid emp#, ename ename, raise_sal(salary) salary, deptno deptno', -
	DBMS_REDEFINITION.CONS_USE_PK);

-- Apply captured changed to interim table
EXEC DBMS_REDEFINITION.SYNC_INTERIM_TABLE('admin', 'myemp', 'myemp_work');

-- Add constraints, indexes, triggers, grants on interim table...
create index myempidx2 on myemp_work (ename);

-- Finish the redefinition process...
EXEC DBMS_REDEFINITION.FINISH_REDEF_TABLE('admin', 'myemp', 'myemp_work');

SELECT * FROM myemp_work;

-- Cleanup
DROP TABLE myemp_work;
