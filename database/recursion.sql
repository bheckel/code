-- https://github.com/connormcd/misc-scripts/blob/master/database_world_2021.sql
create table car_fuel
  (    dte date,
       pctfull number(*,0),
       litres number(*,0)
  ) ;

Insert into CAR_FUEL (DTE,PCTFULL,LITRES) values (to_date('01/AUG/21','DD/MON/RR'),0,45);
Insert into CAR_FUEL (DTE,PCTFULL,LITRES) values (to_date('09/AUG/21','DD/MON/RR'),20,37);
Insert into CAR_FUEL (DTE,PCTFULL,LITRES) values (to_date('13/AUG/21','DD/MON/RR'),60,22);
Insert into CAR_FUEL (DTE,PCTFULL,LITRES) values (to_date('21/AUG/21','DD/MON/RR'),20,20);
Insert into CAR_FUEL (DTE,PCTFULL,LITRES) values (to_date('26/AUG/21','DD/MON/RR'),5,60);
Insert into CAR_FUEL (DTE,PCTFULL,LITRES) values (to_date('03/SEP/21','DD/MON/RR'),15,32);
Insert into CAR_FUEL (DTE,PCTFULL,LITRES) values (to_date('11/SEP/21','DD/MON/RR'),80,15);
Insert into CAR_FUEL (DTE,PCTFULL,LITRES) values (to_date('15/SEP/21','DD/MON/RR'),60,20);  

with t as (
  select car_fuel.*,
         --row_number() over (order by dte ) as seq
         rownum as seq
    from car_fuel
  ), results(dte, pctfull, litres, dirt, seq) as (  -- WITH column alias list is mandatory when doing recursion using "t"
  select dte, pctfull, litres, litres*0.05 dirt, seq
    from t
   where seq = 1
  union all
  select t.dte, t.pctfull, t.litres, r.dirt * t.pctfull/60 + t.litres*0.05 , t.seq
    from t, results r  -- results joins to itself recursively
   where t.seq - 1 = r.seq
   )
select * from results
  order by seq;
