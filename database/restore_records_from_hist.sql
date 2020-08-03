-- Modified: 02-Apr-2020 (Bob Heckel)
-- see also insert_new_record_correlated.sql

create table bob as SELECT p.* FROM purchases_with_dims p

create table bob_hist as SELECT p.*, sysdate-rownum dt FROM purchases_with_dims p

delete from bob WHERE id in(601,602,603);

-- Restore deleted records using history table
DECLARE
  TYPE mynt_t IS TABLE OF bob_hist%rowtype; 
  mynt mynt_t; 

  CURSOR c1 IS
    SELECT * FROM bob_hist WHERE purchased <= '07JAN16';
BEGIN 
  OPEN c1;
  LOOP
    FETCH c1 BULK COLLECT INTO mynt LIMIT 2;
    EXIT WHEN mynt.count = 0;

--    FOR i in 1..mynt.COUNT LOOP 
--      dbms_output.put_line('i:' || i || mynt(i).id); 
--    END LOOP;

      FORALL i IN 1 .. mynt.count
        INSERT INTO bob (
          purchased, brewery_id, brewery_name, product_id, product_name, group_id, group_name, qty, cost
          )
          (SELECT
          purchased, brewery_id, brewery_name, product_id, product_name, group_id, group_name, qty, cost 
          FROM bob_hist
          WHERE id = mynt(i).id); 
        
        COMMIT;
        --ROLLBACK;
  END LOOP;
END;

select * from bob_hist where purchased <= '07JAN16';
select * from bob where purchased <= '07JAN16';
