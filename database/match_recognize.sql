-- Modified: 13-Nov-2020 (Bob Heckel)
-- See also start_with_connect_by_hierarchy.sql

-- Row pattern matching. Grouping conditions that depend on relations BETWEEN rows IN A CERTAIN ORDER.

-- Consider MATCH_RECOGNIZE as an alternative to GROUP BY for cases where you cannot easily specify a grouping 
-- value from each row, but the grouping criteria are RELATIONS between rows. Group data that doesn’t have some 
-- key value to GROUP BY, but instead relates the rows by being consecutive (or not too far apart).

-- Count groups between gaps in sequence
with ints(i) as (
   select 1 from dual union all
   select 2 from dual union all
   select 3 from dual union all
   select 6 from dual union all
   select 8 from dual union all
   select 9 from dual
   -- can't use this, need the gaps
   /* select rownum i from dual connect by level < 10 */
)
select first_int, last_int, ints_in_grp, group_sum
from ints MATCH_RECOGNIZE(
       order by i
       measures
          first(i) as first_int  -- navigation
        , last(i)  as last_int  -- navigation
        , count(*) as ints_in_grp 
        , sum(i) as group_sum
       -- Use for debugging to display MATCH_NUMBER()s to prove we are matching multiple rows, e.g. 1,1,1,2,2,2... Then toggle off.
       -- But you can then only SELECT items in MEASURES.
       --ALL ROWS PER MATCH
       ONE ROW PER MATCH
       -- If the pattern matching hits a definition in the pattern that is not defined (our strt), it is simply assumed always to be 
       -- true, any row matches it. This way we capture the very first record which would otherwise be skipped. That's because the
       -- row after a strt match will always be one_higher.
       pattern (strt one_higher*)
       define
          one_higher as i = prev(i) + 1
    )
order by first_int;
/*
 FIRST_INT   LAST_INT INTS_IN_GRP  GROUP_SUM
---------- ---------- ----------- ----------
         1          3           3          6
         6          6           1          6
         8          9           2         17
*/

---

-- Want date ranges where hits increased by at least 200 day over day
select url, from_day, to_day, days, begin, growth, daily
from web_page_counter_hist MATCH_RECOGNIZE(
       partition by page_no
       order by day
       measures
          first(friendly_url) as url
        , first(day) as from_day
        , last(day) as to_day
        , count(*) as days
        , first(counter) as begin
        , next(counter) - first(counter) as growth
        , (next(counter) - first(counter)) / count(*) as daily
       one row per match
       after match skip past last row
       pattern ( peak+ )
       define
          peak as next(counter) - counter >= 200
    )
order by page_no, from_day;
/*
URL                  FROM_DAY           TO_DAY                   DAYS      BEGIN     GROWTH      DAILY
-------------------- ------------------ ------------------ ---------- ---------- ---------- ----------
/Shop                12-APR-19 00:00:00 15-APR-19 00:00:00          4       5800       1039     259.75
/Categories          28-APR-19 00:00:00 28-APR-19 00:00:00          1       4625        360        360
*/

---

-- Adapted: 11-Nov-2020 (Bob Heckel -- https://oracle-base.com/articles/12c/pattern-matching-in-oracle-database-12cr1)

--DROP TABLE sales_history PURGE;

CREATE TABLE sales_history (
  id            NUMBER,
  product       VARCHAR2(20),
  tstamp        TIMESTAMP,
  units_sold    NUMBER,
  CONSTRAINT sales_history_pk PRIMARY KEY (id)
);
/
ALTER SESSION SET nls_timestamp_format = 'DD-MON-YYYY';
/
INSERT INTO sales_history VALUES ( 1, 'TWINKIES', '01-OCT-2014', 17); --peaknum1
INSERT INTO sales_history VALUES ( 2, 'TWINKIES', '02-OCT-2014', 19); --peaknum1
INSERT INTO sales_history VALUES ( 3, 'TWINKIES', '03-OCT-2014', 23); --peaknum1
INSERT INTO sales_history VALUES ( 4, 'TWINKIES', '04-OCT-2014', 23); --peaknum1
INSERT INTO sales_history VALUES ( 5, 'TWINKIES', '05-OCT-2014', 16); --peaknum1
INSERT INTO sales_history VALUES ( 6, 'TWINKIES', '06-OCT-2014', 10); --peaknum2 AFTER MATCH SKIP TO LAST mydown  - less intuitive but avoids missing the new start, 10, which needs to be processed twice - AFTER MATCH SKIP TO LAST ROW doesn't exist
INSERT INTO sales_history VALUES ( 7, 'TWINKIES', '07-OCT-2014', 14); --peaknum2 AFTER MATCH SKIP PAST LAST ROW  - more intuitive, starts at next cycle
INSERT INTO sales_history VALUES ( 8, 'TWINKIES', '08-OCT-2014', 16); --peaknum2
INSERT INTO sales_history VALUES ( 9, 'TWINKIES', '09-OCT-2014', 15); --peaknum3
INSERT INTO sales_history VALUES (10, 'TWINKIES', '10-OCT-2014', 17); --peaknum3
INSERT INTO sales_history VALUES (11, 'TWINKIES', '11-OCT-2014', 23); --peaknum3
INSERT INTO sales_history VALUES (12, 'TWINKIES', '12-OCT-2014', 30); --peaknum3
INSERT INTO sales_history VALUES (13, 'TWINKIES', '13-OCT-2014', 31); --peaknum3
INSERT INTO sales_history VALUES (14, 'TWINKIES', '14-OCT-2014', 29); --peaknum3
INSERT INTO sales_history VALUES (15, 'TWINKIES', '15-OCT-2014', 25); --peaknum3
INSERT INTO sales_history VALUES (16, 'TWINKIES', '16-OCT-2014', 21); --peaknum3
INSERT INTO sales_history VALUES (17, 'TWINKIES', '17-OCT-2014', 35); --peaknum4
INSERT INTO sales_history VALUES (18, 'TWINKIES', '18-OCT-2014', 46); --peaknum4
INSERT INTO sales_history VALUES (19, 'TWINKIES', '19-OCT-2014', 45); --peaknum4
INSERT INTO sales_history VALUES (20, 'TWINKIES', '20-OCT-2014', 30); --peaknum4
COMMIT;

SELECT id,
       product,
       tstamp,
       units_sold,
       RPAD('#', units_sold, '#') AS graph
FROM   sales_history
ORDER BY id;

--DROP TABLE sales_audit PURGE;

CREATE TABLE sales_audit (
  id            NUMBER,
  product       VARCHAR2(20),
  tstamp        TIMESTAMP,
  CONSTRAINT sales_audit_pk PRIMARY KEY (id)
);
/
ALTER SESSION SET nls_timestamp_format = 'DD-MON-YYYY HH24:MI:SS';
/
INSERT INTO sales_audit VALUES ( 1, 'TWINKIES', '01-OCT-2014 12:00:01');
INSERT INTO sales_audit VALUES ( 2, 'TWINKIES', '01-OCT-2014 12:00:02');
INSERT INTO sales_audit VALUES ( 3, 'DINGDONGS', '01-OCT-2014 12:00:03');
INSERT INTO sales_audit VALUES ( 4, 'HOHOS', '01-OCT-2014 12:00:04');
INSERT INTO sales_audit VALUES ( 5, 'HOHOS', '01-OCT-2014 12:00:05');
INSERT INTO sales_audit VALUES ( 6, 'TWINKIES', '01-OCT-2014 12:00:06');
INSERT INTO sales_audit VALUES ( 7, 'TWINKIES', '01-OCT-2014 12:00:07');
INSERT INTO sales_audit VALUES ( 8, 'DINGDONGS', '01-OCT-2014 12:00:08');
INSERT INTO sales_audit VALUES ( 9, 'DINGDONGS', '01-OCT-2014 12:00:09');
INSERT INTO sales_audit VALUES (10, 'HOHOS', '01-OCT-2014 12:00:10');
INSERT INTO sales_audit VALUES (11, 'HOHOS', '01-OCT-2014 12:00:11');
INSERT INTO sales_audit VALUES (12, 'TWINKIES', '01-OCT-2014 12:00:12');
INSERT INTO sales_audit VALUES (13, 'TWINKIES', '01-OCT-2014 12:00:13');
INSERT INTO sales_audit VALUES (14, 'DINGDONGS', '01-OCT-2014 12:00:14');
INSERT INTO sales_audit VALUES (15, 'DINGDONGS', '01-OCT-2014 12:00:15');
INSERT INTO sales_audit VALUES (16, 'HOHOS', '01-OCT-2014 12:00:16');
INSERT INTO sales_audit VALUES (17, 'TWINKIES', '01-OCT-2014 12:00:17');
INSERT INTO sales_audit VALUES (18, 'TWINKIES', '01-OCT-2014 12:00:18');
INSERT INTO sales_audit VALUES (19, 'TWINKIES', '01-OCT-2014 12:00:19');
INSERT INTO sales_audit VALUES (20, 'TWINKIES', '01-OCT-2014 12:00:20');
COMMIT;

-- There were 4 distinct peaks/spikes ("V shapes") in the sales, giving us the location of the start, peak and end of the pattern
SELECT *
  FROM sales_history MATCH_RECOGNIZE(
         PARTITION BY product
         ORDER BY tstamp
         MEASURES mystrt.tstamp AS start_tstamp,  -- this measure could be eliminated (along w/ORDER BY) and we'll get the same results
                  LAST(myup.tstamp) AS peak_tstamp,
                  LAST(mydown.tstamp) AS end_tstamp,
                  MATCH_NUMBER() AS peaknum,
                  -- Show the DEFINE name
                  CLASSIFIER() AS cls
         ONE ROW PER MATCH
         AFTER MATCH SKIP TO LAST mydown --uporsame
         PATTERN (mystrt myup+ myflat* mydown+)  -- find the 4 "V"s
         --SUBSET uporsame = (myup, myflat) -- same result in this example
         DEFINE
           myup   AS myup.units_sold > PREV(myup.units_sold),
           myflat AS myflat.units_sold = PREV(myflat.units_sold),
           mydown AS mydown.units_sold < PREV(mydown.units_sold)
       ) MR
 ORDER BY MR.product, MR.start_tstamp;
/*
PRODUCT              START_TSTAMP                    PEAK_TSTAMP                     END_TSTAMP                         PEAKNUM CLS                                                                                                                             
-------------------- ------------------------------- ------------------------------- ------------------------------- ---------- --------------------------------------------------------------------------------------------------------------------------------
TWINKIES             01-OCT-14 12.00.00.000000000 AM 03-OCT-14 12.00.00.000000000 AM 06-OCT-14 12.00.00.000000000 AM          1 MYDOWN                                                                                                                          
TWINKIES             06-OCT-14 12.00.00.000000000 AM 08-OCT-14 12.00.00.000000000 AM 09-OCT-14 12.00.00.000000000 AM          2 MYDOWN                                                                                                                          
TWINKIES             09-OCT-14 12.00.00.000000000 AM 13-OCT-14 12.00.00.000000000 AM 16-OCT-14 12.00.00.000000000 AM          3 MYDOWN                                                                                                                          
TWINKIES             16-OCT-14 12.00.00.000000000 AM 18-OCT-14 12.00.00.000000000 AM 20-OCT-14 12.00.00.000000000 AM          4 MYDOWN                                                                                                                          
*/

-- Details
SELECT *
  FROM sales_history MATCH_RECOGNIZE(
         PARTITION BY product
         ORDER BY tstamp
         MEASURES mystrt.tstamp AS start_tstamp,
                  FINAL LAST(myup.tstamp) AS peak_tstamp,
                  FINAL LAST(mydown.tstamp) AS end_tstamp,
                  MATCH_NUMBER() AS mno,
                  CLASSIFIER() AS cls
         ALL ROWS PER MATCH
         AFTER MATCH SKIP TO LAST mydown
         PATTERN (mystrt myup+ myflat* mydown+)
         DEFINE
           myup AS myup.units_sold > PREV(myup.units_sold),
           mydown AS mydown.units_sold < PREV(mydown.units_sold),
           myflat AS myflat.units_sold = PREV(myflat.units_sold)
       ) MR
 ORDER BY MR.product, MR.mno, MR.tstamp;


-- Details of the only occurrence of a general rise in values, containing a single dipping value
SELECT *
  FROM sales_history MATCH_RECOGNIZE(
         PARTITION BY product
         ORDER BY tstamp
         MEASURES STRT.tstamp AS start_tstamp,
                  FINAL LAST(UP.tstamp) AS peak_tstamp,
                  MATCH_NUMBER() AS mno,
                  CLASSIFIER() AS cls
         ALL ROWS PER MATCH
         AFTER MATCH SKIP TO LAST DOWN
         PATTERN (STRT UP+ DOWN{1} UP+)
         DEFINE
           UP AS UP.units_sold > PREV(UP.units_sold),
           DOWN AS DOWN.units_sold < PREV(DOWN.units_sold)
       ) MR
 ORDER BY MR.product, MR.tstamp;


-- Want sales of 2 or more TWINKIES, followed by exactly 2 DINGDONGS and exactly 1 HOHOS sale, followed by 3 or more TWINKIES sales.
-- There is only a single match for that pattern in the data.
SELECT *
  FROM sales_audit MATCH_RECOGNIZE(
         --PARTITION BY product
         ORDER BY tstamp
         MEASURES FIRST(TWINKIES.tstamp) AS start_tstamp,
                  FINAL LAST(TWINKIES.tstamp) AS end_tstamp,
                  MATCH_NUMBER() AS mno,
                  CLASSIFIER() AS cls
         ALL ROWS PER MATCH
         AFTER MATCH SKIP TO LAST TWINKIES
         PATTERN (TWINKIES{2,} DINGDONGS{2} HOHOS{1} TWINKIES{3,})
         -- A run of TWINKIES sales separated by exactly three sales matching any combination of DINGDONGS and/or HOHOS
         /*PATTERN(TWINKIES+ (DINGDONGS | HOHOS){3} TWINKIES+)*/ 
         DEFINE
           TWINKIES AS TWINKIES.product='TWINKIES',
           DINGDONGS AS DINGDONGS.product='DINGDONGS',
           HOHOS AS HOHOS.product='HOHOS'
       ) MR
 ORDER BY MR.mno, MR.tstamp;


---

-- Adapted from https://learning.oreilly.com/library/view/practical-oracle-sql/9781484256176/html/475066_1_En_18_Chapter.xhtml)

-- Find overlapping "VV" pattern (and without a FLAT)
/*
SYMBOL     DAY                     PRICE
---------- ------------------ ----------
BEER       01-APR-19 00:00:00       14.9 -- VV1
BEER       02-APR-19 00:00:00       14.2 -- VV1
BEER       03-APR-19 00:00:00       14.2 -- VV1
BEER       04-APR-19 00:00:00       15.7 -- VV1, UP1 also STRT for VV2
BEER       05-APR-19 00:00:00       15.6 -- VV1                    VV2
BEER       08-APR-19 00:00:00       14.8 -- VV1                    VV2
BEER       09-APR-19 00:00:00       14.8 -- VV1                    VV2
BEER       10-APR-19 00:00:00         14 -- VV1                    VV2
BEER       11-APR-19 00:00:00       14.4 -- VV1                    VV2, UP2 also STRT, up pattern broken, so go to 12-APR
BEER       12-APR-19 00:00:00       15.2 -- VV1                    VV2  fail, only matches a V not a VV
BEER       15-APR-19 00:00:00         15 --                        VV2  fail again, same reason
BEER       16-APR-19 00:00:00       13.7 --                        VV2  fail again, same reason
BEER       17-APR-19 00:00:00       14.3 --                        VV2  fail again, same reason
BEER       18-APR-19 00:00:00       14.3 --                        VV2  fail again, same reason
BEER       19-APR-19 00:00:00       15.5 --                        VV2  fail again, same reason
*/
select *
from ticker
match_recognize (
   partition by symbol
   order by day
   measures
      match_number() as match
    , first(day)     as first_day
    , last(day)      as last_day
    , count(*)       as days
    , classifier()   as cls
   one row per match
   after match skip to first up
   pattern (
      strt down+ up+ down+ up+
   )
   define
      down as price < prev(price)
           or (    price = prev(price)
               and price = last(down.price, 1)
              )
    , up   as price > prev(price)
           or (    price = prev(price)
               and price = last(up.price  , 1)
              )
)
order by symbol, first_day;
/*
SYMBOL          MATCH FIRST_DAY          LAST_DAY                 DAYS  CLS
---------- ---------- ------------------ ------------------ ----------  ---
BEER                1 01-APR-19 00:00:00 12-APR-19 00:00:00         10   UP
BEER                2 04-APR-19 00:00:00 19-APR-19 00:00:00         12   UP
*/
