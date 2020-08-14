
proc casutil;
/*    droptable casdata="products_clean2" incaslib="casuser" quiet; */
   load data=mysas.products_clean2;
quit;

proc fedsql sessref=Mysession;
create table casuser.customerTot{options replace=true} as
select city
     , count(city) as TotalCustomers
     , put(today(),nldate32.) as CurrentDate
   from casuser.mycustomers
   group by city
   having count(city)>2000
;
quit;

proc casutil;
   contents casdata="myjoin" incaslib="casuser";
quit;
