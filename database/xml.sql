-- Adapted https://oracle-base.com/articles/misc/sqlxml-sqlx-generating-xml-content-using-sql
-- Convert a database table to XML
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
/*
<dept_list>
  <dept deptno="10">
    <deptno>10</deptno>
    <dname>ACCOUNTING</dname>
    <loc>NEW YORK</loc>
    <emp_list>
      <emp>
        <empno>7782</empno>
        <ename>CLARK</ename>
        <job>MANAGER</job>
        <mgr>7839</mgr>
        <hiredate>1981-06-09</hiredate>
        <sal>2450</sal>
      </emp>
      <emp>
        <empno>7839</empno>
        <ename>KING</ename>
        <job>PRESIDENT</job>
        <hiredate>1981-11-17</hiredate>
        <sal>5000</sal>
      </emp>
      <emp>
        <empno>7934</empno>
        <ename>MILLER</ename>
        <job>CLERK</job>
        <mgr>7782</mgr>
        <hiredate>1982-01-23</hiredate>
        <sal>1300</sal>
      </emp>
    </emp_list>
  </dept>
</dept_list>
*/

---

 --  set serveroutput on size 100000
declare
  l_xml xmltype:= xmltype('<set><tag>abc</tag></set>');

  cursor c_xmltab is
    select col1
    from xmltable('/set' passing l_xml
            columns col1 path 'tag' 
            ) x;

  l_rows c_xmltab%rowtype;
begin
  open c_xmltab;
  fetch c_xmltab into l_rows;
  dbms_output.put_line('l_rows.col1: '||l_rows.col1);
  close c_xmltab;
end;
