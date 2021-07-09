--  set serveroutput on
declare 
  oldhsh number;
  newhsh number;
begin
  SELECT sum(ora_hash(rate)) into oldhsh from currency_exchange_rates_master;
  execute immediate 'drop table z_cerm_check purge';
  execute immediate 'create table z_cerm_check as SELECT sum(ora_hash(rate)) sumhsh from currency_exchange_rates_master';
  SELECT sum(ora_hash(rate)) into newhsh from currency_exchange_rates_master;
  if oldhsh != newhsh then
    DBMS_OUTPUT.put_line('change');
  else
    DBMS_OUTPUT.put_line('no change');
  end if;
end;
