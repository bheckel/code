-- http://www.orafaq.com/scripts/sql/matrix.txt

-- EMPNO		ENAME			JOB					MGR				HIREDATE			SAL			COMM			DEPTNO
-- 7566			JONES			MANAGER			7839			02-APR-81			2975			-			20
-- 7788			SCOTT			ANALYST			7566			19-APR-87			3000			-			20
-- 7902			FORD			ANALYST			7566			03-DEC-81			3000			-			20
-- 7369			SMITH			CLERK				7902			17-DEC-80			800				-			20
-- 7876			ADAMS			CLERK				7788			23-MAY-87			1100			-			20

SELECT job,
  sum(decode(deptno,10,sal)) DEPT10,
  sum(decode(deptno,20,sal)) DEPT20,
  sum(decode(deptno,30,sal)) DEPT30,
  sum(decode(deptno,40,sal)) DEPT40
FROM scott.emp
GROUP BY job

-- JOB			DEPT10			DEPT20			DEPT30			DEPT40
-- ANALYST			-				6000			-							-
-- CLERK			1300			1900			950						-
-- SALESMAN		-				-					5600						-
-- MANAGER		2450			2975			2850					-
-- PRESIDENT	5000			-					-							-
