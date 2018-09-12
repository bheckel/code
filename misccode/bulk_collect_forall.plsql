
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
