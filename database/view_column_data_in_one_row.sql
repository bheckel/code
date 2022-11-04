-- Pipe-delimited shows all possible options of values within a column
select distinct listagg(distinct account_id, '|' ON OVERFLOW TRUNCATE '...') within group(order by account_id) as account_id,
                listagg(distinct adjust, '|' ON OVERFLOW TRUNCATE '...') within group(order by adjust) as adjust,
                listagg(distinct alliance_flg, '|' ON OVERFLOW TRUNCATE '...') within group(order by alliance_flg) as alliance_flg,
                listagg(distinct begin_date, '|' ON OVERFLOW TRUNCATE '...') within group(order by begin_date) as begin_date,
  from bdg_mkc_revenue_jmp_extract_2022
 group by 1;
