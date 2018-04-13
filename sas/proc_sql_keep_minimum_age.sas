data t;
input pharmacypatientid storeid age;
cards;
1 2 40
1 2 42
2 3 45
;
run;

proc sql;
  create table t2 as
  select a.*
  from  t a left join t b on (a.storeid=b.storeid and a.pharmacypatientid=b.pharmacypatientid and a.age>b.age)
  where b.storeid is null and b.pharmacypatientid is null
  ;
quit;

proc sql;
  create table t2 as
  select *
  from  t
  group by pharmacypatientid
  having age = min(age)
  ;
quit;

title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;
