
--  Created: 02-Apr-2020 (Bob Heckel)
-- Modified: 22-Jul-2022 (Bob Heckel)
-- see restore_records_from_hist.sql insert_new_record_correlated.sql forall_insert.plsql

---

create table relations
( id   number       not null primary key
, name varchar2(30) not null
);

insert into relations
  select 1, 'Oracle Nederland' from dual 
  union all
  select 2, 'Ciber Nederland' from dual
;

-- or
insert into relations
  select level, dbms_random.string('a',30)
    from dual
 connect by level <= 100000
;

-- 100,000 row(s) inserted.
commit;

---

-- Any other fields get NULLs
insert into mailing_list (name, email) values ('Philip Greenspun','philg@foo.edu');

-- Shortcut without specifying phone_numbers fields but instead assuming their
-- order - the number of values must match the number of columns in the table
-- which in Oracle can be first verified:
select column_name 
from   user_tab_columns
where  table_name = 'PHONE_NUMBERS'
order  by column_id;

insert into phone_numbers values ('ogrady@foo.com','work','(800) 555-1212');

---

-- Insert 5-star ratings by James Cameron (207) for all movies in the database.
-- Leave the review date as NULL.
insert into rating
  select 207, mid, 5, NULL
  from movie
  where mid in(select distinct mid from movie)
;

---

-- INSERT ALL the shorthand multi-table INSERT

INSERT ALL  
  into teddies values ('Dinosaur King', 'red')  
  into bricks values ('sphere', 'green', 100)  
  select * from dual;


-- Or two records from one table on a pivot
INSERT ALL
 INTO plch_tickers (ticker, pricetype, price)
VALUES (ticker, 'O', open_price)
 INTO plch_tickers (ticker, pricetype, price)
VALUES (ticker, 'C', close_price)
	SELECT ticker, open_price, close_price FROM plch_stocks;

---

/* Adapted from Oracle Dev Gym Class */

create table toys ( 
  toy_id   integer,  
  toy_name varchar2(30), 
  price    number, 
  colour   varchar2(30) 
);

create table blue_toys ( toy_id integer, toy_name varchar2(30), price number, colour varchar2(30) );

create table cheap_toys ( toy_id integer, toy_name varchar2(30), price number, colour varchar2(30) );

create table expensive_toys ( toy_id integer, toy_name varchar2(30), price number, colour varchar2(30) );

insert into toys values (1, 'Cheapasaurus Rex', 0.99, 'blue');
insert into toys values (2, 'Cheapasaurus Rex', 0.99, 'red');
insert into toys values (3, 'Costsalottasaurs', 99.99, 'green');
insert into toys values (4, 'Bluesaurus', 21.99, 'blue');
commit;

INSERT FIRST 
	-- Insert first will only add rows to the first table where the when clause
  -- is true. This works from top to bottom. A row that has blue for the color and
  -- price > 20 meets all three criteria. But it will only go in blue_toys, because
  -- that is the top clause in the statement.

	-- Blue_toys is at the top of the insert. So any rows that meet this (toy_ids
  -- 1 and 4) will go in this table
  when colour = 'blue' then 
    into blue_toys values (toy_id, toy_name, price, colour)
  -- Any non-blue rows with a price >= 0 will go in cheap_toys
  when price >= 0 then 
    into cheap_toys values (toy_id, toy_name, price, colour)
	-- Toy_id 3 costs 99.99. So it meets the criterion for expensive_toys. But
  -- cheap_toys appears above this in the insert. So it goes in that table and this
  -- is skipped. Any row where the price is > 20 also has a price >= 0. So the
  -- insert will never add any rows to this table!
  when price > 20 then 
    into expensive_toys values (toy_id, toy_name, price, colour)
  select toy_id, toy_name, price, colour from toys;

select * from blue_toys
/*
TOY_ID	TOY_NAME	PRICE
1	Cheapasaurus Rex	.99
4	Bluesaurus	21.99
*/
select * from cheap_toys
/*
TOY_ID	TOY_NAME	PRICE	COLOUR
2	Cheapasaurus Rex	.99	red
3	Costsalottasaurs	99.99	green
*/
select * from expensive_toys
/*
*/

---

DECLARE
   l_employee   omag_employees%ROWTYPE;
BEGIN
   l_employee.employee_id := 500;
   l_employee.last_name := ‘Mondrian’;
   l_employee.salary := 2000;

   INSERT INTO omag_employees VALUES l_employee;
END;
/

---

-- See forall_insert.plsql for a better approach

 --  set serveroutput on
   declare
     TYPE t_nested_tbl IS TABLE OF number;
    id_table t_nested_tbl;

     cursor c1 is 
       select opportunity_id from opportunity where rownum<9;
   begin
     open c1; 
     loop
         FETCH c1 BULK COLLECT INTO id_table;
         EXIT WHEN id_table.COUNT = 0;
         FOR i IN 1 .. id_table.COUNT LOOP
           DBMS_OUTPUT.put_line('x ' || id_table(i));
         end loop;
     
    FOR i IN 1 .. id_table.COUNT loop
      DBMS_OUTPUT.put_line('x ' || id_table(i));
      INSERT /*+ APPEND */  INTO tmpOPPORTUNITY_EMPLOYEE_BASE
        (opportunity_employee_id,
         employee_id,founder,owner_type,TOTAL_SOFTWARE_REVENUE,MULTINATIONAL_NEG_NOTIFIED,DEAL_STRUCTURE_NEG_NOTIFIED,
         opportunity_id,
         h_version,
         created,
         createdby,
         updated,
         updatedby)
      VALUES
        (
        uid_opportunity_employee.NEXTVAL,
        88901,1,'S',0,1,1,
         id_table(i),
         1,
         sysdate,
         0,
         sysdate,
         0
        );
        
      IF mod(i, 10000) = 0 THEN
        commit;
      end if;

    end loop;
  end loop;    
  commit;     
  
    EXCEPTION
      WHEN OTHERS THEN
      rollback;
      DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
end;

--or loading a cursor into a collection
 --  set serveroutput on
   declare
     cursor c1 is 
       select opportunity_id from opportunity where rownum<9;
       
      TYPE t_idtbl IS TABLE OF c1%ROWTYPE;
      id_table t_idtbl;
   begin
     open c1; 
     loop
         FETCH c1 BULK COLLECT INTO id_table;
         EXIT WHEN id_table.COUNT = 0;
--         FOR i IN 1 .. id_table.COUNT LOOP
--           DBMS_OUTPUT.put_line('x ' || id_table(i).opportunity_id);
--         end loop;
     
    FOR i IN 1 .. id_table.COUNT loop
      DBMS_OUTPUT.put_line('x ' || id_table(i).opportunity_id);
      INSERT /*+ APPEND */  INTO tmpOPPORTUNITY_EMPLOYEE_BASE
        (opportunity_employee_id,
         employee_id,founder,owner_type,TOTAL_SOFTWARE_REVENUE,MULTINATIONAL_NEG_NOTIFIED,DEAL_STRUCTURE_NEG_NOTIFIED,
         opportunity_id,
         h_version,
         created,
         createdby,
         updated,
         updatedby)
      VALUES
        (
        uid_opportunity_employee.NEXTVAL,
        88901,1,'S',0,1,1,
         id_table(i).opportunity_id,
         1,
         sysdate,
         0,
         sysdate,
         0
        );
        
      IF mod(i, 10000) = 0 THEN
        commit;
      end if;

    end loop;
  end loop;    
  commit;     
  
    EXCEPTION
      WHEN OTHERS THEN
      rollback;
      DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
end;

---

-- With conditions:
    FORALL i IN 1 .. in_risk_table.COUNT SAVE EXCEPTIONS EXECUTE IMMEDIATE
      'INSERT INTO RISK_EMPLOYEE RE
        (risk_employee_id,
         risk_id,
         employee_id,
         ip_role_lov_id,
         owner,
         created,
         createdby,
         updated,
         updatedby)
      SELECT
         uid_risk_employee.nextval,
         :1,
         :2,
         34615,
         0,
         :3,
         0,
         :4,
         0 
      FROM DUAL 
      WHERE not exists
         (select 1
          from risk_employee 
          where RISK_ID = :5
            and EMPLOYEE_ID = :6)
         AND exists
        (select 1
          from risk_base r1, account_name an1, account_base ab1
          where r1.RISK_ID = :7
            and r1.risk_status in (''L'',''S'',''E'')
            and r1.account_name_id = an1.account_name_id
            and an1.account_id = ab1.account_id
            and ab1.salesgroup = r1.salesgroup)' USING in_risk_table(i)
                    .risk_id, in_risk_table(i).new_default_tsr_owner,
                     v_start_time, v_start_time, in_risk_table(i).risk_id, in_risk_table(i)
                    .new_default_tsr_owner, in_risk_table(i).risk_id
    ;

-- better but maybe not identical
    FORALL i IN 1 .. in_oppt_table.COUNT SAVE EXCEPTIONS EXECUTE IMMEDIATE
			-- Consider adding the new TSR as a secondary IP
			'MERGE INTO OPPORTUNITY_EMPLOYEE_BASE
				USING dual ON (employee_id = :1 and opportunity_id = :2)
				-- If the new TSR is already on the opp as an S (WHEN MATCHED) then do nothing
				WHEN NOT MATCHED THEN  
					-- Otherwide add the new TSR as a secondary (we never adjust the primary)
					INSERT
						(opportunity_employee_id,
						 opportunity_id,
						 employee_id,
						 territory_lov_id,
						 role_lov_id,
						 owner_type,
						 founder,
						 created,
						 createdby,
						 updated,
						 updatedby)
					Values
						(uid_opportunity_employee.NEXTVAL,
						 :3,
						 :4,
						 :5,
						 :6,
						 ''S'',
						 0,
						 :7,
						 0,
						 :8,
						 0
						 )'
       USING in_oppt_table(i).new_default_tsr_owner,
             in_oppt_table(i).opportunity_id,
             in_oppt_table(i).opportunity_id,
             in_oppt_table(i).new_default_tsr_owner,
             in_oppt_table(i).new_default_tsr_territory,
             in_oppt_table(i).new_ip_role_lov_id,
             v_start_time,
             v_start_time
    ;

---

-- Insert the parent row. Unless the parent has already been added
INSERT INTO xsp_processing_territory (xsp_processing_territory_id, xsp_processing_request_id, territory_lov_id, CREATED, CREATEDBY)
  SELECT UID_XSP_PROCESSING_TERRITORY.NEXTVAL, process_request_id, terr_id, process_date, employee_id
    FROM DUAL
   WHERE terr_id NOT IN (SELECT t.territory_lov_id FROM xsp_processing_territory t);

