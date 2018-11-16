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


-- Non-merge:
-- Update-if-exists
update bricks_1 b1
set    ( b1.colour, b1.shape ) = ( 
  select b2.colour, b2.shape 
  from   bricks_2 b2
  where  b1.brick_id = b2.brick_id
);
-- Insert-if-not-exists
insert into bricks_1
  select *
  from bricks_2 b2
  where not exists (
    select 1 from bricks_1 b1
    where  b1.brick_id = b2.brick_id
  );


-- Merge:
merge into bricks_1 b1
	using bricks_2 b2 on (b1.brick_id=b2.brick_id)
		when matched then
			update set b1.colour = b2.colour, b1.shape = b2.shape;
		when not matched then
			insert ( b1.brick_id, b1.colour, b1.shape )
			values ( b2.brick_id, b2.colour, b2.shape );
  
select * from bricks_1;  
