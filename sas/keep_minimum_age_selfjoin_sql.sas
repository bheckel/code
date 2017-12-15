
/* Keep only the records with the minimum age when there are more than one */
proc sql;
  create table t as
  select a.*
  from  l.rxfilldata_extra a left join l.rxfilldata_extra b on (a.storeid=b.storeid and a.pharmacypatientid=b.pharmacypatientid and a.age>b.age)
  where b.storeid is null and b.pharmacypatientid is null
  ;
quit;
