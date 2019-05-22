
/* Analytic functions compute an aggregate value based on a group of rows. They
 * differ from aggregate functions in that they RETURN MULTIPLE ROWS FOR EACH
 * GROUP. The group of rows is called a window and is defined by the
 * analytic clause. For each row, a sliding window of rows is defined. The
 * window determines the range of rows used to perform the calculations for the
 * current row. Window sizes can be based on either a physical number of rows
 * or a logical interval such as time.
 *
 * Analytic functions are the last set of operations performed in a query
 * except for the final ORDER BY clause. All joins and all WHERE, GROUP BY, and
 * HAVING clauses are completed *before* the analytic functions are processed.
 * Therefore, analytic functions can appear only in the SELECT list or ORDER BY
 * clause NOT in a predicate.  They can often be used to eliminate potentially 
 * expensive subqueries.
 *
 * P  partition
 * O  order
 * W  window
 *
 */

-- Aggregate functions vs. Analytic functions:

SELECT COUNT(*) DEPT_COUNT
FROM scott.emp
WHERE deptno IN (20, 30);
/*
DEPT_COUNT
11
*/

--                             _______
SELECT empno, deptno, COUNT(*) OVER () DEPT_COUNT
FROM scott.emp
WHERE deptno IN (20, 30);
/*
EMPNO	DEPTNO	DEPT_COUNT
7698	30	11
7566	20	11
7788	20	11
7902	20	11
7369	20	11
7499	30	11
7521	30	11
7654	30	11
7844	30	11
7876	20	11
7900	30	11
*/


SELECT deptno, COUNT(*) COUNT_BY_DEPT
FROM scott.emp
WHERE deptno IN (20, 30)
GROUP BY deptno;
/*

DEPTNO	COUNT_BY_DEPT
20	5
30	6
*/

-- This allows you to also see the values from all the other columns, which you can't when using GROUP BY:
--                             __________________________
SELECT empno, deptno, COUNT(*) OVER (PARTITION BY deptno) COUNT_BY_DEPT
FROM scott.emp
WHERE deptno IN (20, 30);
/*
EMPNO	DEPTNO	COUNT_BY_DEPT
7876	20	5
7369	20	5
7902	20	5
7788	20	5
7566	20	5
7844	30	6
7654	30	6
7521	30	6
7900	30	6
7698	30	6
7499	30	6
*/

---

-- Assign integer values to the rows depending on their ORDER BY (mandatory here)
select empno, ename, job, sal,
       -- row_number() gives a running (unique) serial number to a partition of records, e.g. give separate sets of running serial to employees of each department based on their hire date
       row_number() OVER (order by sal) as sal_row_number  -- 1,2,3,4,5... ties are indeterminant
       row_number() OVER (order by sal, empno) as sal_row_number2  -- 1,2,3,4,5... with tie-breaker being empno

       -- RANK will skip the next number if there are ties i.e. Olympic ranking
       rank() OVER (order by sal) as sal_rank,  -- 1,2,2,4,5... no #3 
       rank() OVER (order by sal DESC NULLS LAST ) as hi_sal_rank_with_nulls

       dense_rank() OVER (order by sal) as sal_dense_rank,  -- 1,2,2,3,4... two 2s then normal seq resumes
from emp

---

-- Employees in department 10 are ranked by their salary within their department (rank of highest salary is 1).
-- The rank for each employee not in department 10 is 0. 
select e.*, rank() over ( order by e.sal desc )
from emp e
where deptno = 10
union all
select e.*, 0
from emp e
where deptno != 10;

---

/* Analytic SQL windowing function.  See also greater_than_average.sql outliers.sql */

with v as (
          select date '2000-01-01' d, 10 amt from dual
union all select date '2000-01-02', 11 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-04', 10 from dual
union all select date '2000-01-05', 14 from dual
)
select d
      ,amt
      ,count(1) OVER (order by d) cnt_cumul_grp  -- 1,2,4,4,5,6
      ,row_number() OVER (order by d) row_seq_in_dt_order  -- 1,2,3,4,5,6
      ,rank() OVER (order by d) orderbydt -- 1,2,3,3,5,6 Olympic has holes
      ,dense_rank() OVER (order by d) orderbydt_dense -- 1,2,3,3,4,5,6 still have dups like Olympic but fill the holes
      ,row_number() OVER (partition by d order by d) rownumbyday  -- 1,1,1,2,1,1
      -- Can be Top N by day if used as a subquery
      ,rank() OVER (partition by d order by amt) rank_by_day -- 1,1,1,1,1,1 would be 1,1,1,1,3,1,1 if union all select date '2000-01-03', 99 from dual existed and dense_rank would make the 3 a 2
      ,first_value(amt) OVER (partition by d order by d) firstdot  -- 10,11,30,30,10,14
      -- Good for cols where only the first appearance holds empno and rest are blank and need to be padded out (like a report for human consumption)
      ,last_value(amt IGNORE NULLS) OVER (order by d)  lastdot_fillin_the_blank  -- 10,11,30,30,10,14
      ,last_value(amt) OVER (order by d RANGE between current row and unbounded following) last_from_lastdategrp  -- 14,14,14,14,14,14
      -- The NTH_VALUE clause lets us identify boundary values that are not necessarily the minima and maxima which could be identified by FIRST_VALUE() and LAST_VALUE()
      ,nth_value(amt,2) OVER (order by d) second_highest_skip_outliers  -- , 11, 11, 11, 11, 11
      ,round(amt/nth_value(amt,2) over (order by d),2)*100 percent_diff  -- , 100, 273, 273, 91, 127
      -- Default windowing clause for ORDER BY is "RANGE between unbounded preceding and current row"
      ,sum(amt) OVER (order by d) running_total0  -- 10,21,51,81,81,91,105
      -- But usually the default isn't what you want, normally running totals should only include values from previous ROWS
      ,sum(amt) OVER (order by d ROWS between unbounded preceding and current row) running_total1  -- 10,21,51,81,91,105
--      ,sum(amt) OVER (order by d ROWS between MYFUNC(foo) preceding and 0 following) running_total2
--      ,sum(amt) OVER (order by d ROWS between MYSEQ-MYTRAILING_SEQ preceding and 0 following) running_total3
      ,avg(amt) OVER (order by d ROWS between 1 preceding and 1 following) moving_average  -- 10.5,17,23.6666666,23.333333,18,12
      -- Use time RANGE not physical ROWS to avoid missing data
      ,sum(amt) OVER (order by d RANGE between interval '2' day preceding and current row) running_total_2day  -- 10,21,81,81,81,84
      ,avg(amt) OVER (order by d RANGE between interval '2' day preceding and current row) moving_average_2day  -- 10,10.5,20.25,20.25,20.25,21
      -- Always need an ORDER BY for LAG() & LEAD()
      ,lag(amt) OVER (order by d) amt_before  -- NULL,10,11,30,30,10
      ,lag(amt, 2, 0) OVER (order by d) amt_2before_nonull  -- 0,0,10,11,30,30
      ,lead(amt) OVER (partition by d order by d) amt_after  -- , , 30, , ,  good for finding a change in status when you have daily data
      -- Want only first date in a contiguous series otherwise leave blank
      ,case when nvl(lag(d) over (order by d), d) != d-1 then d end lowval_of_range  -- 01jan, , , 03jan, , 
      ,nvl(amt, lag(amt IGNORE NULLS) OVER (partition by d order by d)) fillin_the_blank_handle_nulls  -- 10,11,30,30,10,14
      --_______________________________________ <--still just another aggregation function like count(1) or sum(amt)
      ,listagg(d,', ') within group(order by d) OVER (partition by amt) csv
      ,100*cume_dist() OVER ( order by d) as cumedist  -- 16.666, 33,333, 66,66, 66,66, 83,333, 100
      ,100*percent_rank() OVER (order by d) as pctrank  -- 0, 20, 40, 40, 80, 100
      ,ntile(4) OVER (order by amt) as quartile  -- 1(10), 1(10), 2(11), 2(14), 3(30), 4(30)
      ,sum(amt) OVER () grand_sum  -- 105,105,105,105,105,105
      ,avg(amt) OVER () grand_avg  -- 17.5,17.5,17.5,17.5,17.5,17.5
      ,count(1) OVER () grand_sum -- 7,7,7,7,7,7
from v;

---

-- Want department number and name of the employee that has the highest salary in that department.
-- In the event of a ties (same salary), choose the employee with the first name in alphabetic sequence

-- Compare self join version:
select deptno, ename top_emp, sal
  from scott.emp e
 where not exists ( 
   select 1
     from scott.emp
    where deptno = e.deptno and (sal > e.sal) or (sal = e.sal and ename < e.ename)
 )
 order by 1;

-- Compare FETCH FIRST version (the only one that won't let you add SAL to the select):
select distinct deptno, 
       ( select ename
           from scott.emp
          where deptno = e.deptno
         order by sal desc, ename 
         FETCH FIRST ROW ONLY
       ) top_emp
from scott.emp e
order by 1;

-- Compare Analytic function version:
select distinct deptno, 
       first_value(ename) over ( partition by deptno order by sal desc, ename ) as top_emp,
       first_value(sal)   over ( partition by deptno )                          as sal
from scott.emp
order by 1;

---

select deptno, empno, ename, job, sal,
       sum(sal) OVER (
         partition by deptno
         order by ename
         ) as running_total
from emp
order by deptno, ename
/* 
DEPTNO	EMPNO	ENAME	JOB	SAL	RUNNING_TOTAL
10	7782	CLARK	MANAGER	2450	2450
10	7839	KING	PRESIDENT	5000	7450
10	7934	MILLER	CLERK	1300	8750
20	7876	ADAMS	CLERK	1100	1100
20	7902	FORD	ANALYST	3000	4100
20	7566	JONES	MANAGER	2975	7075
20	7788	SCOTT	ANALYST	3000	10075
20	7369	SMITH	CLERK	800	10875
30	7499	ALLEN	SALESMAN	1600	1600
30	7698	BLAKE	MANAGER	2850	4450
30	7900	JAMES	CLERK	950	5400
30	7654	MARTIN	SALESMAN	1250	6650
30	7844	TURNER	SALESMAN	1500	8150
30	7521	WARD	SALESMAN	1250	9400
*/

---

-- Most recent record (for the whole day) only
SELECT * 
FROM (
  SELECT d.JOB_NAME , d.LOG_DATE, d.STATUS, d.ADDITIONAL_INFO, j.SCHEDULE_NAME ,  row_number() OVER (PARTITION BY trunc(log_date) ORDER BY log_date DESC) rownbr
  FROM   USER_SCHEDULER_JOB_RUN_DETAILS d LEFT JOIN USER_SCHEDULER_JOBS j ON j.JOB_NAME = d.JOB_NAME
  WHERE  d.LOG_DATE > (SYSDATE-1)
)
WHERE rownbr = 1
