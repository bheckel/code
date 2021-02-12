
select empno,mgr, CONNECT_BY_ISCYCLE from emp CONNECT BY NOCYCLE PRIOR empno=mgr;

-- the pseudo column is always 0. But if you force a loop by making CLARK into KING's manager,

update emp set mgr=7782;

-- then you'll see the loop on empno 7782 and 7839.
