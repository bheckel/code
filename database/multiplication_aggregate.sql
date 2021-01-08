---------------------------------------------------------------------------------------------------------------------------
-- Adapted: 08-Jan-2021 (Bob Heckel--https://connor-mcdonald.com/2020/11/18/the-missing-multiplication-aggregation-in-sql/) 
--
-- Like SUM() but instead multiply each row by the next one
---------------------------------------------------------------------------------------------------------------------------

drop table t purge;
create table t as
select
  owner,
  decode(mod(rownum,10),
         0, dbms_random.value(1,1.5),   -- every 10th rec is a 0 so make it a small positive
         1, -dbms_random.value(1,1.5),  -- every 1st rec is a small negative
            dbms_random.value(0.8,1.1)  -- the rest are smaller positives
  ) x
from dba_objects where rownum< 500 and owner!='SYS'
;

-- Fails with "ORA-01489: result of string concatenation is too long" if >~500
select owner,
       xmlquery(
         (listagg(x,'*')  within group (order by rownum))
         returning content).getnumberval() as mult_product
  from t
 group by owner;

-- Better but have to handle negative numbers for logarithms
select owner,
       case
         when sum(case when x=0 then 1 end) > 0 then 0
         when mod(sum(case when x<0 then -1 end), 2) < 0 then -1
         else 1
       end * exp(sum(ln(abs(nullif(x, 0))))) mult_product
 from t
group by owner;

-- If better performance is needed, see the OBJECT approach on connor-mcdonald.com
