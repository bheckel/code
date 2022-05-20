-- Adapted: 18-May-2022 (Bob Heckel)
--
-- If the number of observations is odd, the number in the middle of the list
-- is the median. This can be found by taking the value of the (n+1)/2 -th
-- term, where n is the number of observations. Else, if the number of
-- observations is even, then the median is the simple average of the middle
-- two numbers

-- Use cartesian self-join to calculate median salary for each department
select deptno, avg(distinct sal) median
  from ( select e1.deptno, e1.sal
           from emp e1, emp e2
          where e1.deptno = e2.deptno
          group by e1.deptno, e1.sal
         having sum(decode(e1.sal, e2.sal, 1, 0)) >= abs(sum(sign(e1.sal - e2.sal))) )
group by deptno;
