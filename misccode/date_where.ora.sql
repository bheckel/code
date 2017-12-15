select * from activity_log where activity_dt=to_date('01/3/2005', 'MM/DD/YYYY')

update links_material
set matl_mfg_dt=to_date('01/3/2005', 'MM/DD/YYYY')
where batch_nbr='6ZM3436'
