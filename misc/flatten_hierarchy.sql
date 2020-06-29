
/*
https://www.oratable.com/flatten-hierarchical-data/

SQL> select * from empl;

EMP_NAME         EMP_ROLE        MANAGER_EMP_NA
---------------- --------------- --------------
Peter Matthews   PROJECT_MANAGER
Tom Ledford      TEAM_LEAD       Peter Matthews
Timothy Leigh    TEAM_LEAD       Peter Matthews
David Botham     DBA             Peter Matthews
Trevor Malcolm   TEAM_MEMBER     Tom Ledford
Toby Mayer       TEAM_MEMBER     Tom Ledford
Trevor McDermott TEAM_MEMBER     Timothy Leigh
Thor Martin      TEAM_MEMBER     Timothy Leigh

We want:

PROJECT_MANAGER (Level 1)
	DBA (Level 2)
	TEAM_LEAD (Level 2)
		TEAM_MEMBER (Level 3)

*/

-- 3.
select emplevel1 project_manager
, decode(rolelevel2, 'DBA', emplevel2) dba
, decode(rolelevel2, 'TEAM_LEAD', emplevel2) team_lead
, emplevel3 team_member
from
  (
   -- 2.
   select
     regexp_substr(role_path, '[^/]+', 1, 1) rolelevel1
   , regexp_substr(emp_path, '[^/]+', 1, 1) emplevel1
   , regexp_substr(role_path, '[^/]+', 1, 2) rolelevel2
   , regexp_substr(emp_path, '[^/]+', 1, 2) emplevel2
   , regexp_substr(role_path, '[^/]+', 1, 3) rolelevel3
   , regexp_substr(emp_path, '[^/]+', 1, 3) emplevel3
   from
     (
     -- 1.
     select
       sys_connect_by_path (emp_role, '/') role_path
     , sys_connect_by_path (emp_name, '/') emp_path
     from empl
     start with manager_emp_name is null
       connect by prior
       emp_name = manager_emp_name
      )
   );

/* 1.  Connects by path and gives us:
ROLE_PATH                              EMP_PATH
-------------------------------------- -----------------------------------------
/PROJECT_MANAGER                       /Peter Matthews
/PROJECT_MANAGER/TEAM_LEAD             /Peter Matthews/Tom Ledford
/PROJECT_MANAGER/TEAM_LEAD/TEAM_MEMBER /Peter Matthews/Tom Ledford/Trevor Malcolm
/PROJECT_MANAGER/TEAM_LEAD/TEAM_MEMBER /Peter Matthews/Tom Ledford/Toby Mayer
/PROJECT_MANAGER/TEAM_LEAD             /Peter Matthews/Timothy Leigh
/PROJECT_MANAGER/TEAM_LEAD/TEAM_MEMBER /Peter Matthews/Timothy Leigh/Trevor McDermott
/PROJECT_MANAGER/TEAM_LEAD/TEAM_MEMBER /Peter Matthews/Timothy Leigh/Thor Martin
/PROJECT_MANAGER/DBA                   /Peter Matthews/David Botham
/*

/* 2. Splits on slash and gives us: 
ROLELEVEL1      EMPLEVEL1       ROLELEVEL2 EMPLEVEL2     ROLELEVEL3  EMPLEVEL3
--------------- --------------- ---------- ------------- ----------- ----------------
PROJECT_MANAGER Peter Matthews
PROJECT_MANAGER Peter Matthews  TEAM_LEAD  Tom Ledford
PROJECT_MANAGER Peter Matthews  TEAM_LEAD  Tom Ledford   TEAM_MEMBER Trevor Malcolm
PROJECT_MANAGER Peter Matthews  TEAM_LEAD  Tom Ledford   TEAM_MEMBER Toby Mayer
PROJECT_MANAGER Peter Matthews  TEAM_LEAD  Timothy Leigh
PROJECT_MANAGER Peter Matthews  TEAM_LEAD  Timothy Leigh TEAM_MEMBER Trevor McDermott
PROJECT_MANAGER Peter Matthews  TEAM_LEAD  Timothy Leigh TEAM_MEMBER Thor Martin
PROJECT_MANAGER Peter Matthews  DBA        David Botham

*/

/* 3. The inline view gives us
PROJECT_MANAGER DBA             TEAM_LEAD       TEAM_MEMBER
--------------- --------------- --------------- ---------------
Peter Matthews
Peter Matthews                  Tom Ledford
Peter Matthews                  Tom Ledford     Trevor Malcolm
Peter Matthews                  Tom Ledford     Toby Mayer
Peter Matthews                  Timothy Leigh
Peter Matthews                  Timothy Leigh   Trevor McDermott
Peter Matthews                  Timothy Leigh   Thor Martin
Peter Matthews  David Botham
*/
