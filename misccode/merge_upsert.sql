  MERGE INTO activity_search
    USING dual ON (activity_search_id = inActiv_ID)
    --If ACTIVITY_SEARCH already exists
    WHEN MATCHED THEN
      UPDATE
         set updated         = AS_UPDATE_DATE,
             updatedby       = AS_UPDATED_BY,
             account_name    = AS_ACCOUNT_NAME,
             account_name_id = AS_ACCOUNT_NAME_ID,
             badabingle      = to_char(sysdate, 'DDMONYYYY HH24:MI:SS')
       where ACTIVITY_search_id = inActiv_ID
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


-- Non-merge version:
-- Update-if-exists
update bricks_1 b1
   set ( b1.colour, b1.shape ) = ( select b2.colour, b2.shape 
                                     from bricks_2 b2
                                    where b1.brick_id = b2.brick_id );
-- Insert-if-not-exists
insert into bricks_1
  select *
  from bricks_2 b2
  where not exists (
    select 1 from bricks_1 b1
     where  b1.brick_id = b2.brick_id
  );


-- Merge version:
merge into bricks_1 b1
	using bricks_2 b2 on (b1.brick_id=b2.brick_id)
		when matched then
			update set b1.colour = b2.colour, b1.shape = b2.shape;
		when not matched then
			insert ( b1.brick_id, b1.colour, b1.shape )
			values ( b2.brick_id, b2.colour, b2.shape );
