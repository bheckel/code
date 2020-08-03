-- MySQL template
-- Run via:
-- $ mysql -t indocc < mysql.sql

-- show tables;
-- desc iando;
-- select max(slen) from iando;
-- select * from iando where slen > 69;
-- select indliteral, occliteral from iando where slen > 69;
-- select indliteral, occliteral from iando where match (indliteral) against ('firestone');
-- explain select * from iando where slen > 69;
--- select indliteral, match (indliteral) against ('finance center') as score from iando
--- where match (indliteral) against ('finance center') limit 2;
select occliteral, occnum from iando where occnum = 70;
