/* Analytic functions compute an aggregate value based on a group of rows. They
 * differ from aggregate functions in that they RETURN MULTIPLE ROWS FOR EACH
 * GROUP. The group of rows is called a window and is defined by the
 * analytic_clause. For each row, a sliding window of rows is defined. The
 * window determines the range of rows used to perform the calculations for the
 * current row. Window sizes can be based on either a physical number of rows
 * or a logical interval such as time.
 *
 * Analytic functions are the last set of operations performed in a query
 * except for the final ORDER BY clause. All joins and all WHERE, GROUP BY, and
 * HAVING clauses are completed before the analytic functions are processed.
 * Therefore, analytic functions can appear only in the select list or ORDER BY
 * clause. */

select empno, ename, job, sal,
       -- "Olympic" 1,2,2,4,5... no 3
       rank() OVER (order by sal) as sal_rank,
       -- 1,2,2,3,4... two 2s
       dense_rank() OVER (order by sal) as sal_dense_rank,
       -- 1,2,3,4,5... ties are indeterminant
       row_number() OVER (order by sal) as sal_row_number
       -- 1,2,3,4,5... with tie-breaker being empno
       row_number() OVER (order by sal, empno) as sal_row_number
       rank() OVER (order by sal DESC NULLS LAST ) as sal_rank_with_nulls
from emp


select name, gross_sales,
       100*cume_dist() OVER ( order by gross_sales ) as cumedist
       100*percent_rank() OVER ( order by gross_sales ) as pctrank
       ntile(4) OVER ( order by gross_sales DESC ) as quartile
from movies

---

-- Employees in department 10 are ranked by their salary within their department (rank of highest salary is 1).
-- The rank for each employee not in department 10 is 0. 
select e.*,
       rank() over ( order by e.sal desc )
from emp e
where deptno = 10
union all
select e.*, 0
from emp e
where deptno != 10;

---

/* Windowing function.  See also greater_than_average.sql */

with v as (
          select date '2000-01-01' d, 10 amt from dual
union all select date '2000-01-02', 11 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-04', 10 from dual
union all select date '2000-01-05', 14 from dual
)
select d
      ,amt
      ,avg(amt) OVER (order by d rows between 1 preceding and 1 following) moving_window_avg
      ,sum(amt) OVER (order by d rows between unbounded preceding and current row) cumulative_sum
      ,sum(amt) OVER () grand_sum
      ,avg(amt) OVER () grand_avg
      --,dense_rank() over (order by d) orderbydt -- 1,2,3...
      ,rank() over (order by d) orderbydt -- 1,3,3...
FROM v;

---

-- Running total balance
SELECT
  t.*,
  t.current_balance - NVL(
    SUM(t.amount) OVER (
      PARTITION by t.account_id
      ORDER BY     t.value_date DESC,
                   t.id         DESC
      ROWS BETWEEN UNBOUNDED PRECEDING
           AND     1         PRECEDING
    ),
  0) AS balance
FROM     transactions t
WHERE    t.account_id = 1
ORDER BY t.value_date DESC, t.id DESC

---

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
select deptno, empno, ename, job, sal,
       sum(sal) OVER ( partition by deptno order by ename) as running_total
from emp
order by deptno, ename
