-- Adapted: 03-Sep-2021 (Bob Heckel--https://docs.oracle.com/en/database/oracle/oracle-database/19/adwsm/DBMS_WM-reference.html#GUID-7C121AC5-D041-4829-9085-68CAAA3D4166)

-- set serverout on

CREATE TABLE cola_marketing_budget (
  product_id NUMBER PRIMARY KEY,
  product_name VARCHAR2(32),
  manager VARCHAR2(32),
  budget NUMBER
);

EXECUTE DBMS_WM.EnableVersioning ('cola_marketing_budget', 'VIEW_WO_OVERWRITE');

INSERT INTO cola_marketing_budget VALUES(
  1,
  'cola_a',
  'Alvarez',
  2.0
);
INSERT INTO cola_marketing_budget VALUES(
  2,
  'cola_b',
  'Baker',
  1.5
);
INSERT INTO cola_marketing_budget VALUES(
  3,
  'cola_c',
  'Chen',
  1.5
);
INSERT INTO cola_marketing_budget VALUES(
  4,
  'cola_d',
  'Davis',
  3.5
);
COMMIT;

select * from cola_marketing_budget ORDER BY 1;

EXECUTE DBMS_WM.CreateWorkspace ('B_focus_1');
EXECUTE DBMS_WM.CreateWorkspace ('B_focus_2');

EXECUTE DBMS_WM.GotoWorkspace ('B_focus_1');

UPDATE cola_marketing_budget
  SET manager = 'Beasley' WHERE product_name = 'cola_b';
UPDATE cola_marketing_budget
  SET budget = 3 WHERE product_name = 'cola_b';
UPDATE cola_marketing_budget
  SET budget = 1.5 WHERE product_name = 'cola_a';
UPDATE cola_marketing_budget
  SET budget = 1 WHERE product_name = 'cola_c';
UPDATE cola_marketing_budget
  SET budget = 3 WHERE product_name = 'cola_d';
COMMIT;

EXECUTE DBMS_WM.GotoWorkspace ('LIVE');
EXECUTE DBMS_WM.FreezeWorkspace ('B_focus_1');

EXECUTE DBMS_WM.GotoWorkspace ('B_focus_2');

UPDATE cola_marketing_budget
  SET manager = 'Burton' WHERE product_name = 'cola_b';
UPDATE cola_marketing_budget
  SET budget = 2 WHERE product_name = 'cola_b';
UPDATE cola_marketing_budget
  SET budget = 3 WHERE product_name = 'cola_d';
COMMIT;

EXECUTE DBMS_WM.GotoWorkspace ('B_focus_1');
--ORA-20002: GOTOWORKSPACE is not allowed for workspace: 'B_focus_1' frozen in NO_ACCESS mode

EXECUTE DBMS_WM.GotoWorkspace ('LIVE');

EXECUTE DBMS_WM.UnfreezeWorkspace ('B_focus_1');
EXECUTE DBMS_WM.RemoveWorkspace ('B_focus_1');

EXECUTE DBMS_WM.MergeWorkspace ('B_focus_2');
--LIVE==2 now

EXECUTE DBMS_WM.RemoveWorkspace ('B_focus_2');

EXECUTE DBMS_WM.DisableVersioning ('cola_marketing_budget', TRUE);

---

--  set serveroutput on
EXECUTE DBMS_WM.EnableVersioning ('cola_marketing_budget', 'VIEW_WO_OVERWRITE');

begin
  DBMS_WM.CreateWorkspace ('B_focus_3');
  DBMS_WM.GotoWorkspace ('B_focus_3');
end;

select * from cola_marketing_budget ORDER BY 1;

SELECT DBMS_WM.GetWorkspace FROM DUAL;--B_focus_3

EXECUTE DBMS_WM.BeginDDL('cola_marketing_budget');
alter table cola_marketing_budget_LTS add (foonum2 number);
select * from cola_marketing_budget_LTS ORDER BY 1;--0rec
EXECUTE DBMS_WM.CommitDDL('cola_marketing_budget');
select * from cola_marketing_budget_LTS ORDER BY 1;--tbl not exist

EXECUTE DBMS_WM.GotoWorkspace ('LIVE');
select * from cola_marketing_budget ORDER BY 1;

EXECUTE DBMS_WM.RemoveWorkspace ('B_focus_3');-- no more ws exist

select * from cola_marketing_budget ORDER BY 1;--'new' version still

drop table cola_marketing_budget;--not exist! 
--ORA-20061: versioned objects have to be version disabled before being dropped
drop table cola_marketing_budget_lts; drop table cola_marketing_budget_aux;

EXECUTE DBMS_WM.DisableVersioning ('cola_marketing_budget', TRUE);
--now can do it
drop table cola_marketing_budget;
