-- Adapted: 13-Jul-2020 (Bob Heckel--https://connor-mcdonald.com/2020/07/10/uniquely-random-or-randomly-unique/)
create table t ( pk number);

create sequence seq start with 1000000 maxvalue 9999999 cycle;

set timing on

begin
  for i in 1 .. 1000 loop
    insert into t values ( to_number(trunc(dbms_random.value(1000,9999))|| to_char(systimestamp,'FFSS')|| seq.nextval) );
  end loop;
end;

-- This identifier is “always” unique because in order to encounter a violation
-- we would need to generate the same sequence number as it cycles around, along
-- with the same random value from our random number generator, and chance upon
-- both of those repeated values at the same fraction of a second within a one minute.
select pk from t where rownum <= 20;
