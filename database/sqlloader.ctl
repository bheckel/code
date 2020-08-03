-- Oracle 8.1.6 SQL*Loader examples
-- 2006-01-11 http://download-east.oracle.com/docs/cd/A87860_01/doc/server.817/a76955/part2.htm

-- $ sqlldr userid=scott/tiger control=sqlloader.ctl log=sqlloader.log
-- or
-- $ sqlldr CONTROL=foo.ctl, LOG=bar.log, BAD=baz.bad, DATA=etc.dat 
            USERID=scott/tiger, ERRORS=999, LOAD=2000, DISCARD=toss.dis,
            DISCARDMAX=5

-- Loading Variable-Length Data (no .dat file)

LOAD DATA
INFILE *
INTO TABLE dept
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(deptno, dname, loc)
BEGINDATA
12,RESEARCH,"SARATOGA"
10,"ACCOUNTING",CLEVELAND
11,"ART",SALEM
13,FINANCE,"BOSTON"
21,"SALES",PHILA.
22,"SALES",ROCHESTER
42,"INT'L","SAN FRAN"



--  Loading Fixed-Format Fields

LOAD DATA
INFILE 'ulcase2.dat'
-- Table need not be empty when this keyword is used.  Use REPLACE to do a
-- delete and append
APPEND 
INTO TABLE emp
(empno         POSITION(01:04)   INTEGER  EXTERNAL,
 ename          POSITION(06:15)   CHAR,
 job            POSITION(17:25)   CHAR,
 mgr            POSITION(27:30)   INTEGER EXTERNAL,
 sal            POSITION(32:39)   DECIMAL  EXTERNAL,
 comm           POSITION(41:48)   DECIMAL  EXTERNAL,
 deptno         POSITION(50:51)   INTEGER  EXTERNAL)


.dat:
7782 CLARK      MANAGER   7839 2572.50           10
7839 KING       PRESIDENT      5500.00           10
7934 MILLER     CLERK     7782  920.00           10
7566 JONES      MANAGER   7839 3123.75           20
7499 ALLEN      SALESMAN  7698 1600.00   300.00  30
7654 MARTIN     SALESMAN  7698 1312.50  1400.00  30
