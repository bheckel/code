-- Adapted: 20-Sep-2019 (Bob Heckel -- https://use-the-index-luke.com/sql/partial-results/fetch-next-page)

-- The Oracle database supports OFFSET since release 12c. Earlier releases provide
-- the pseudo column ROWNUM that numbers the rows in the result set automatically.
-- It is, however, not possible to apply a greater than or equal to (>=) filter on
-- this pseudo-column. To make this work, you need to first “materialize” the row
-- numbers by renaming the column with an alias.


/*
  	EMPNO	ENAME	JOB	MGR	HIREDATE	SAL	COMM	DEPTNO
1	7839	KING	PRESIDENT	NULL	17.11.2011 00:00:00	5000	NULL	10
2	7788	SCOTT	ANALYST	7566	09.12.2012 00:00:00	3000	NULL	20
3	7902	FORD	ANALYST	7566	03.12.2011 00:00:00	3000	NULL	20
4	7566	JONES	MANAGER	7839	02.04.2011 00:00:00	2975	NULL	20
5	7698	BLAKE	MANAGER	7839	01.05.2011 00:00:00	2850	NULL	30
6	7782	CLARK	MANAGER	7839	09.06.2011 00:00:00	2450	NULL	10
7	7499	ALLEN	SALESMAN	7698	20.02.2011 00:00:00	1600	300	30
8	7844	TURNER	SALESMAN	7698	08.09.2011 00:00:00	1500	0	30
9	7934	MILLER	CLERK	7782	23.01.2012 00:00:00	1300	NULL	10
10	7654	MARTIN	SALESMAN	7698	28.09.2011 00:00:00	1250	1400	30
11	7521	WARD	SALESMAN	7698	22.02.2011 00:00:00	1250	500	30
12	7876	ADAMS	CLERK	7788	12.01.2013 00:00:00	1100	NULL	20
13	7900	JAMES	CLERK	7698	03.12.2011 00:00:00	950	NULL	30
14	7369	SMITH	CLERK	7902	17.12.2010 00:00:00	800	NULL	20
*/

-- Note the use of the alias RN for the lower bound and the ROWNUM pseudo column itself for the upper bound:
SELECT *
  FROM ( SELECT tmp.*, rownum rn
           FROM ( SELECT *
                    FROM emp
                   ORDER BY sal DESC
                ) tmp
          WHERE rownum <= 10
       )
 WHERE rn > 5;
/*
  	EMPNO	ENAME	JOB	MGR	HIREDATE	SAL	COMM	DEPTNO	RN
1	7782	CLARK	MANAGER	7839	09.06.2011 00:00:00	2450	NULL	10	6
2	7499	ALLEN	SALESMAN	7698	20.02.2011 00:00:00	1600	300	30	7
3	7844	TURNER	SALESMAN	7698	08.09.2011 00:00:00	1500	0	30	8
4	7934	MILLER	CLERK	7782	23.01.2012 00:00:00	1300	NULL	10	9
5	7521	WARD	SALESMAN	7698	22.02.2011 00:00:00	1250	500	30	10
*/

-- But this has two pagination disadvantages: (1) the pages drift when inserting new sal
-- because the numbering is always done from scratch; (2) the response time
-- increases when browsing further back.

-- So use:
SELECT *
  FROM ( SELECT emp.*
              , ROW_NUMBER() OVER (ORDER BY sal DESC) rn  -- 1-14 KING thru SMITH
           FROM emp
       ) tmp
 WHERE rn between 6 and 10  -- CLARK thru MARTIN
 ORDER BY sal DESC
