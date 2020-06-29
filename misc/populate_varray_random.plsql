DECLARE 
   CURSOR c_rand IS
     SELECT account_search_id 
     FROM account_search SAMPLE(0.1) 
     WHERE ROWNUM<4;

   TYPE a_ids IS VARRAY(3) OF PLS_INTEGER;
   ids a_ids := a_ids();
   cnt INTEGER := 0;
   
BEGIN 
   FOR i IN c_rand LOOP 
      cnt := cnt + 1;
       
      ids.EXTEND; 
      ids(cnt) := i.account_search_id; 
      
      dbms_output.put_line(cnt ||' '|| ids(cnt)); 
   END LOOP; 
END; 
/
