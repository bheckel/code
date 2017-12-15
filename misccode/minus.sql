http://philip.greenspun.com/sql/complex-queries.html

-- all three users love to go to Paris
insert into trip_to_paris_contest values (1,'2000-10-20');
insert into trip_to_paris_contest values (2,'2000-10-22');
insert into trip_to_paris_contest values (3,'2000-10-23');

-- only User #2 is a camera nerd
insert into camera_giveaway_contest values (2,'2000-05-01');


-- Suppose that we're going to organize a personal trip to Paris and want to
-- find someone to share the cost of a room at the Crillon. We can assume that
-- anyone who entered the Paris trip contest is interested in going. So perhaps we
-- should start by sending them all email. On the other hand, how can one enjoy a
-- quiet evening with the absinthe bottle if one's companion is constantly
-- blasting away with an electronic flash? We're interested in people who entered
-- the Paris trip contest but who did not enter the camera giveaway:

    select user_id from trip_to_paris_contest
    MINUS
    select user_id from camera_giveaway_contest;

       USER_ID
    ----------
    	 1
    	 3

