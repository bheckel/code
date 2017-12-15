
 /* Compare dataset's levels with database's levels */
proc sql;
  create table lnks as
  select distinct samp_id, specname, resstrval 
  from v
  where (specname like 'ITEMC%'  and varname like 'PRODCODED%') or 
        (specname like 'MISC%' and varname like 'ITEMCODEDE%')
  order by samp_id
  ;
quit;

libname ORA oracle user=pks password=pks path=usdev100;
proc sql;
  select distinct l.samp_id, specname, s.prod_nm,s.prod_level format=$8.,
         resstrval format=$52. 
  from lnks l JOIN ORA.samp s  ON l.samp_id=s.samp_id
  ;
quit;
