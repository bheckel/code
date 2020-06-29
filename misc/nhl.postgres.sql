-- Created: Sun Nov 16 20:53:13 2003 (Bob Heckel)

-- Simple load of CSV data into a database.
-- Assumes this has been completed previously:
-- $ createdb nhl

-- Execute:
-- $ unzip NHL2004FreePlayers.zip
-- First 4 lines are header crap.
-- $ tail +5 NHL2004FreePlayers.csv >| ~/tmp/currentNHL.csv
-- $ dos2unix ~/tmp/currentNHL.csv
-- $ psql nhl < nhl.postgres.sql


---drop table hockey20031116;

-- All fields must be accounted for.  Using xN for those that don't matter.
create table hockey20031117 (x1 text,
                             player text, 
                             team text,
                             x2 text,
                             x3 text,
                             gp smallint,
                             goal smallint,
                             assist smallint,
                             pts smallint,
                             pm smallint,
                             pim smallint,
                             pp smallint,
                             ppa smallint,
                             sh smallint,
                             sha smallint,
                             gw smallint,
                             gt smallint,
                             s smallint,
                             pct real,
                             gs smallint,
                             min smallint,
                             w smallint,
                             l smallint,
                             t smallint,
                             ega smallint,
                             ga smallint,
                             avg smallint,
                             sa smallint,
                             sv smallint,
                             svp smallint,
                             so smallint
                             );

-- E.g. ,Sergei Fedorov,ana,,,17,5,9,14,-5,8,1,4,0,0,0,0,58,0.086,,,,,,,,,,,,
copy hockey20031117 
from '/home/bheckel/tmp/currentNHL.csv' 
using delimiters ','
;

-- Test via:
-- psql nhl
-- select player, goal, assist, pim, pct from hockey20031116 where team = 'was' order by pct desc;
