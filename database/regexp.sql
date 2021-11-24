with v as(
  --          tab
  select 'EMEA	AP' as ibcc_geo1 from dual
)
select REGEXP_REPLACE(v.IBCC_GEO1, '[[:cntrl:]]+', '') AS INVOICE_IBCC_GEO1
from v;
