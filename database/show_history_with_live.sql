select *
  from (select 'LIVE'
               src,
               b.opportunity_id,
               b.h_version,
               b.updated,
               b.actual_updated,
               b.updatedby,
               b.actual_updatedby,
               b.retired_time,
               b.audit_source
          from opportunity_base b
         where b.opportunity_id = 69
        UNION ALL
        select 'HIST' src,
               b.opportunity_id,
               b.h_version,
               b.updated,
               b.actual_updated,
               b.updatedby,
               b.actual_updatedby,
               b.retired_time,
               b.audit_source
          from opportunity_hist b
         where b.opportunity_id = 69)
 order by actual_updated asc
