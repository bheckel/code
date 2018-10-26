
/* See also insert_invitations.pck */


/* https://blogs.oracle.com/oraclemagazine/bulk-processing-with-bulk-collect-and-forall */

 /* If the SQL engine raises an error, the PL/SQL engine will save that
  * information in a pseudocollection named SQL%BULK_EXCEPTIONS, and continue
  * executing statements. When all statements have been attempted, PL/SQL then
  * raises the ORA-24381 error
*/
BEGIN
   FORALL indx IN 1 .. l_eligible_ids.COUNT SAVE EXCEPTIONS
      UPDATE employees emp
         SET emp.salary =
                emp.salary + emp.salary * increase_pct_in
       WHERE emp.employee_id = l_eligible_ids (indx);
EXCEPTION
   WHEN OTHERS
   THEN
      IF SQLCODE = -24381
      THEN
         FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
         LOOP
            DBMS_OUTPUT.put_line (
                  SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX
               || ': '
               || SQL%BULK_EXCEPTIONS (indx).ERROR_CODE);
         END LOOP;
      ELSE
         RAISE;
      END IF;
END;

---

CURSOR c IS
   select ri.risk_id as import_risk_id, ri.new_risk_id, rp.risk_id, 
          asp.account_site_id, asp.product, ri.product_code
          ,rp.risk_product_id,ri.at_risk_amount, ri.risk_amount,
          sum(nvl(ri.at_risk_amount,0)) over (partition by rp.risk_id) as tot_at_risk_amt
   from   risk_import_uk ri,
          risk_product rp,
          account_site_product asp
   where  rp.risk_id = ri.new_risk_id
   and    asp.ACCOUNT_SITE_PRODUCT_ID = rp.ACCOUNT_SITE_PRODUCT_ID
   and    asp.PRODUCT = ri.PRODUCT_CODE
   order  by rp.risk_id;
   
TYPE t_tab_type IS TABLE OF c%ROWTYPE;
t_tab t_tab_type;

l_tab_size NUMBER := 0;

BEGIN
  OPEN c;
  LOOP
     FETCH c BULK COLLECT INTO t_tab LIMIT 500;
     l_tab_size := t_tab.COUNT;
     EXIT WHEN l_tab_size = 0;
     
     FORALL i IN 1..l_tab_size
         UPDATE RISK_PRODUCT
         SET    UPDATED = UPDATED, UPDATEDBY = UPDATEDBY,
                AT_RISK_AMOUNT = t_tab(i).AT_RISK_AMOUNT
         where  risk_product_id = t_tab(i).risk_product_id;
         
     COMMIT;
          
  END LOOP;
  CLOSE c;
END;


---

CREATE OR REPLACE PACKAGE ORION32598 IS

 PROCEDURE ptgcleanup;

END ORION32598;
/
CREATE OR REPLACE PACKAGE BODY ORION32598 IS

  PROCEDURE ptgcleanup IS
    l_defect_num   VARCHAR2(50)   := 'ORION-32598';
    l_release_num  VARCHAR2(50)   := 'N/A';
    l_description  VARCHAR2(4000) := 'Delete (move to hist table) Inactive and > 6 month-old PLAN_TO_GOAL records';
    l_tab_size     PLS_INTEGER    := 0;
    l_tab_size_tot PLS_INTEGER    := 0;
    l_limit_group  PLS_INTEGER    := 0;

    CURSOR c IS 
      select x.plan_to_goal_id
      ...
    ;
    
    TYPE t_ptg_tab_type IS TABLE OF c%ROWTYPE;

    t_ptg t_ptg_tab_type;

    BEGIN
      OPEN c;
      LOOP
        FETCH c BULK COLLECT INTO t_ptg LIMIT 300;

        l_limit_group := l_limit_group + 1;
        l_tab_size := t_ptg.COUNT;
        l_tab_size_tot := l_tab_size_tot + l_tab_size;
        
        dbms_output.put_line(to_char(sysdate, 'DD-Mon-YYYY HH24:MI:SS') || ': iteration ' || l_limit_group || ' processed ' || l_tab_size || ' records' || ' total ' || l_tab_size_tot);

        EXIT WHEN l_tab_size = 0;

        /* Implicit update of plan_to_goal_hist */
        FORALL i IN 1 .. l_tab_size
          DELETE from plan_to_goal where plan_to_goal_id=t_ptg(i).plan_to_goal_id;

        --ROLLBACK;
        COMMIT;
      END LOOP;
    CLOSE c;
    
    MAINT.logdatachange(step => 0, status => l_description, release => l_release_num, defect => l_defect_num, startTime => SYSDATE); 

  END ptgcleanup;

END ORION32598;
/
