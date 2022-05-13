-- Use cartesian self-join to calculate median salary for each department
select deptno, avg(distinct sal) median
  from ( select e1.deptno, e1.sal
           from emp e1, emp e2
          where e1.deptno = e2.deptno
          group by e1.deptno, e1.sal
         having sum(decode(e1.sal, e2.sal, 1, 0)) >= abs(sum(sign(e1.sal - e2.sal))) )
group by deptno;
