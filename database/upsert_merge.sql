--  Created: 18-Jun-2020 (Bob Heckel)
-- Modified: 16-Dec-2022 (Bob Heckel)
-- see also insert_new_record_correlated.sql

---

CREATE TABLE members (
  member_id NUMBER PRIMARY KEY,
  first_name VARCHAR2(50) NOT NULL,
  last_name VARCHAR2(50) NOT NULL,
  rank VARCHAR2(20)
);

CREATE TABLE member_staging AS SELECT * FROM members;
  
INSERT INTO members(member_id, first_name, last_name, rank) VALUES(1,'Abel','Wolf','Gold');
INSERT INTO members(member_id, first_name, last_name, rank) VALUES(2,'Clarita','Franco','Platinum');
INSERT INTO members(member_id, first_name, last_name, rank) VALUES(3,'Darryl','Giles','Silver');
INSERT INTO members(member_id, first_name, last_name, rank) VALUES(4,'Dorthea','Suarez','Silver');
INSERT INTO members(member_id, first_name, last_name, rank) VALUES(5,'Katrina','Wheeler','Silver');
INSERT INTO members(member_id, first_name, last_name, rank) VALUES(6,'Lilian','Garza','Silver');
INSERT INTO members(member_id, first_name, last_name, rank) VALUES(7,'Ossie','Summers','Gold');
INSERT INTO members(member_id, first_name, last_name, rank) VALUES(8,'Paige','Mcfarland','Platinum');
INSERT INTO members(member_id, first_name, last_name, rank) VALUES(9,'Ronna','Britt','Platinum');
INSERT INTO members(member_id, first_name, last_name, rank) VALUES(10,'Tressie','Short','Bronze');

INSERT INTO member_staging(member_id, first_name, last_name, rank) VALUES(1,'Abel','Wolf','Silver');
INSERT INTO member_staging(member_id, first_name, last_name, rank) VALUES(2,'Clarita','Franco','Platinum');
INSERT INTO member_staging(member_id, first_name, last_name, rank) VALUES(3,'Darryl','Giles','Bronze');
INSERT INTO member_staging(member_id, first_name, last_name, rank) VALUES(4,'Dorthea','Gate','Gold');
INSERT INTO member_staging(member_id, first_name, last_name, rank) VALUES(5,'Katrina','Wheeler','Silver');
INSERT INTO member_staging(member_id, first_name, last_name, rank) VALUES(6,'Lilian','Stark','Silver');

MERGE INTO member_staging x
  USING (SELECT member_id, first_name, last_name, rank FROM members) y
    ON (x.member_id  = y.member_id)
      WHEN MATCHED THEN
        UPDATE SET x.first_name = y.first_name, 
                   x.last_name = y.last_name, 
                   x.rank = y.rank
         WHERE x.first_name <> y.first_name OR 
                x.last_name <> y.last_name OR 
                x.rank <> y.rank 
      WHEN NOT MATCHED THEN
        INSERT(x.member_id, x.first_name, x.last_name, x.rank) VALUES(y.member_id, y.first_name, y.last_name, y.rank);

---

/*
https://www.oratable.com/oracle-merge-command-for-upsert/

SQL> select * from student;

        ID NAME                 SCORE
---------- --------------- ----------
         1 Jack                   540
         2 Rose
         3 William                650
         4 Caledon                620
         5 Fabrizio               600
         6 Thomas
         7 Ruth                   680
         8 Spacer                 555

SQL> select * from student_n;

        ID NAME                 SCORE
---------- --------------- ----------
         7 Ruth                   690
         8 Spicer                 620
         9 Wallace                600
        10 Lizzy
        11 Brock                  705
*/

merge into student a
using
  (select id, name, score
   from student_n) b
on (a.id = b.id)
when MATCHED then
  update set a.name = b.name
           , a.score = b.score
--delete where a.score < 640
when NOT MATCHED then
  insert (a.id, a.name, a.score)
  values (b.id, b.name, b.score)
;

-- 5 rows merged.

/*
SQL> select * from student;

        ID NAME                 SCORE
---------- --------------- ----------
         1 Jack                   540
         2 Rose
         3 William                650
         4 Caledon                620
         5 Fabrizio               600
         6 Thomas
         7 Ruth                   690
        11 Brock                  705
        10 Lizzy
         9 Wallace                600
         8 Spicer                 620

11 rows selected.
*/

-- You cannot update any of the columns you are merging on, ID in this case.
--
-- The delete condition works on the source, not the target so Fabrizio stays undeleted.
--
-- Oracle has to be able to identify a single target record for update. The
-- simplest method of ensuring this is to join source and target tables by the
-- primary key of the target.
--
-- If the source has 3 records and all 3 are identical to the target, MERGE
-- will report ‘3 rows merged’ though this merge made no difference to the
-- target table.

---

  MERGE INTO activity_search
    USING dual ON (activity_search_id = inActiv_ID)
    --If activity_search_id already exists
    WHEN MATCHED THEN
      UPDATE
         set updated         = AS_UPDATE_DATE,
             updatedby       = AS_UPDATED_BY,
             account_name    = AS_ACCOUNT_NAME,
             account_name_id = AS_ACCOUNT_NAME_ID,
             badabingle      = to_char(sysdate, 'DDMONYYYY HH24:MI:SS')
       where activity_search_id = inActiv_ID
    WHEN NOT MATCHED THEN  
      --If ACTIVITY_SEARCH does NOT exist
      INSERT
        (ACTIVITY_SEARCH_ID,
         CREATED,
         CREATEDBY,
         UPDATED,
         UPDATEDBY,
         SEARCH_MATCH_CODE,
         ACCOUNT_NAME,
         ACCOUNT_name_ID,
         BADABINGLE)
      Values
        (inActiv_ID,
         AS_CREATED_DATE,
         AS_CREATED_BY,
         AS_UPDATE_DATE_BASE,
         AS_UPDATED_BY_BASE,
         null,
         AS_ACCOUNT_NAME,
         AS_ACCOUNT_NAME_ID,
         to_char(sysdate, 'DDMONYYYY HH24:MI:SS'));

---

-- Insert if we don't have a record to update aka upsert
-- You can delete rows from the target table. But only those that match a row in the source.

-- SOURCE
create table bricks_1 (
  brick_id integer not null,
  colour   varchar2(10),
  shape    varchar2(10)
);

-- TARGET
create table bricks_2 (
  brick_id integer not null,
  colour   varchar2(10),
  shape    varchar2(10)
);

insert into bricks_1 values ( 1, 'red', 'cube' );

insert into bricks_2 values ( 1, 'blue', 'pyramid' );
insert into bricks_2 values ( 2, 'blue', 'cube' );

commit;


-- Two-step non-merge version:

-- 1. Update-if-exists in the other table
update bricks_1 b1
   set ( b1.colour, b1.shape ) = ( select b2.colour, b2.shape 
                                     from bricks_2 b2
                                    where b1.brick_id = b2.brick_id );
-- 2. Insert-if-not-exists in the other table
insert into bricks_1
  select *
  from bricks_2 b2
  where not exists (
    select 1 from bricks_1 b1
     where  b1.brick_id = b2.brick_id
  );


-- One-step merge version:
merge into bricks_1 b1
	using bricks_2 b2 on (b1.brick_id=b2.brick_id)
		when matched then
			update set b1.colour = b2.colour, b1.shape = b2.shape;
		when not matched then
			insert ( b1.brick_id, b1.colour, b1.shape ) values ( b2.brick_id, b2.colour, b2.shape );

---

merge into RISK_EMP
  using dual on ( employee_id = riskRec.employee_id and risk_id = riskRec.risk_id )
    -- If the new TSR is already on the risk (WHEN MATCHED) then do nothing
    WHEN NOT MATCHED THEN
    -- Otherwide add the TSR to the risk
    INSERT 
      (risk_employee_id,
       risk_id,
       employee_id,
       owner,
       created,
       createdby,
       updated,
       updatedby)
    VALUES
      (uid_risk_employee.nextval,
       riskRec.risk_id,
       riskRec.employee_id,
       0,
       sysdate,
       2,
       sysdate,
       2);

---

MERGE INTO mkc_revenue_adj kra
     USING jmpcsv jmp
ON ( kra.sdm_business_key = jmp.sdm_business_key )
WHEN MATCHED THEN UPDATE
SET 
    kra.mkc_revenue_adj_id = jmp.mkc_revenue_adj_id,
    kra.account_id = jmp.account_id,
    kra.adjust = jmp.adjust,
    kra.adjust_inserted = jmp.adjust_inserted,
    kra.adjust_notes = jmp.adjust_notes,
    kra.rate_date = jmp.rate_date
WHEN NOT MATCHED THEN
INSERT (
  kra.mkc_revenue_adj_id,
  kra.account_id,
  kra.adjust,
  kra.adjust_inserted,
  kra.adjust_notes,
  kra.rate_date
  )
VALUES ( 
  uid_mkc_revenue_adj_id.NEXTVAL,
  jmp.account_id,
  jmp.adjust,
  jmp.adjust_inserted,
  jmp.adjust_notes,
  jmp.rate_date
  )
;

