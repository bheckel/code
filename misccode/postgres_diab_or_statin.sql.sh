
psql -t -U bheckel -h db-0.twa.taeb.com reporting -c "
  select * from (
    select medicationname, filldate, prescriptionstatus, rxnbr, refillsremaining, dispensedquantity, dayssupply, fillnum, 
           case when ndc in('00002143301' ,'00002143380') then 1 else 0 end as diab,
           case when ndc in('00002143301' ,'00002143380') then 1 else 0 end as stat
    from rxfilldata_parent
    where clientid=8 and pharmacypatientid='$1'
    ) as t
  where diab=1 or stat=1;
;"

