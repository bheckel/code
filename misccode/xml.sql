-- Adapted https://oracle-base.com/articles/misc/sqlxml-sqlx-generating-xml-content-using-sql
SELECT XMLELEMENT("dept_list",
         XMLAGG (
           XMLELEMENT("dept",
             XMLATTRIBUTES(d.deptno AS "deptno"),
             XMLFOREST(
               d.deptno AS "deptno",
               d.dname AS "dname",
               d.loc AS "loc",
               (SELECT XMLAGG(
                         XMLELEMENT("emp",
                           XMLFOREST(
                             e.empno AS "empno",
                             e.ename AS "ename",
                             e.job AS "job",
                             e.mgr AS "mgr",
                             e.hiredate AS "hiredate",
                             e.sal AS "sal",
                             e.comm AS "comm"
                           )
                         )
                       )
                FROM   scott.emp e
                WHERE  e.deptno = d.deptno
               ) "emp_list"
             )
           )
         )
       ) AS "depts"
FROM   scott.dept d
WHERE  d.deptno = 10;
