
-- http://philip.greenspun.com/sql/complex-queries.html
-- See also minus.sql

create table trip_to_paris_contest (user_id NUMBER, dt DATE);

-- all three users love to go to Paris
insert into trip_to_paris_contest values (1, to_date('2000-10-20', 'YYYY-MM-DD'));
insert into trip_to_paris_contest values (2, to_date('2000-10-22', 'YYYY-MM-DD'));
insert into trip_to_paris_contest values (2, to_date('2018-10-22', 'YYYY-MM-DD'));
insert into trip_to_paris_contest values (3, to_date('2000-10-23', 'YYYY-MM-DD'));

create table camera_giveaway_contest (user_id NUMBER, dt DATE);

-- only User #2 is a camera nerd
insert into camera_giveaway_contest values (2, '30MAY2018');

commit;

-- We assume that the most interested users will be those who've entered both
-- the travel and the camera contests. Let's get their user IDs so that we can
-- notify them via email (spam) about the new contest:

select user_id from trip_to_paris_contest
INTERSECT  -- there is no ALL, the default shows unique, see next example for 'ALL'
select user_id from camera_giveaway_contest;
/*
       USER_ID
    ----------
    	 2
*/

select user_id from trip_to_paris_contest p 
where  exists ( 
  select null from camera_giveaway_contest c 
  where  c.user_id = p.user_id 
) 
/*
       USER_ID
    ----------
    	 2
    	 2
*/

/* With EXISTS you have to consider if null values are possible. If they are, check whether pairs of columns are both null as well as equal. */
select user_id from trip_to_paris_contest p 
where  exists ( 
  select 1 from camera_giveaway_contest c 
  where  c.user_id = p.user_id OR (p.user_id is null and c.user_id is null)	
) 
