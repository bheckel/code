http://philip.greenspun.com/sql/complex-queries.html

-- all three users love to go to Paris
insert into trip_to_paris_contest values (1,'2000-10-20');
insert into trip_to_paris_contest values (2,'2000-10-22');
insert into trip_to_paris_contest values (3,'2000-10-23');

-- only User #2 is a camera nerd
insert into camera_giveaway_contest values (2,'2000-05-01');


-- Suppose that we've got a new contest on the site. This time we're giving
-- away a trip to Churchill, Manitoba to photograph polar bears. We assume that
-- the most interested users will be those who've entered both the travel and the
-- camera contests. Let's get their user IDs so that we can notify them via email
-- (spam) about the new contest:


    select user_id from trip_to_paris_contest
    INTERSECT
    select user_id from camera_giveaway_contest;

       USER_ID
    ----------
    	 2

