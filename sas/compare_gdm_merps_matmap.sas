options NOcenter ls=max;

%let USERNAME=dgm_distr_;
%let PASSWORD=lsice45reda;
%let DATABASE=kuprd631;

libname GDMLIB oracle user=&USERNAME password=&PASSWORD path=&DATABASE schema=gdm_dist;
libname DPLIB 'X:\DataPost\data\GSK\Metadata\Reference\MATL';
libname l '.';

proc sql;
  create table gdmmatmap as
    SELECT DISTINCT  a.material_description as gdmdesc, b.mat_desc as matmapdesc, b.mat_cod
    FROM             GDMLIB.vw_lift_rpt_results_nl a JOIN DPLIB.material_mapping_table b ON a.mrp_mat_id=b.mat_cod
    WHERE            site_name='Zebulon' AND test_end_date IS NOT NULL AND test_status='Approved' AND a.material_description ne b.mat_desc
  ;

  create table gdmmatmapmerps as
    SELECT a.mat_cod, b.mat_desc as merpsdesc, a.gdmdesc, a.matmapdesc
    FROM   gdmmatmap a JOIN GDMLIB.vw_merps_material_info b ON a.mat_cod=b.mat_cod
    WHERE  b.plant_cod='US01' AND a.matmapdesc ne a.gdmdesc
    ORDER BY a.gdmdesc
  ;

  create table gdmmatmapmerps2 as
    SELECT a.mat_cod, b.mat_desc as merpsdesc, a.gdmdesc, a.matmapdesc
    FROM   gdmmatmap a JOIN GDMLIB.vw_merps_material_info b ON a.mat_cod=b.mat_cod
    WHERE  b.plant_cod='US01' AND a.matmapdesc ne b.mat_desc
    ORDER BY a.gdmdesc
  ;
quit;

title 'matmapdesc ne gdmdesc';
proc print data=gdmmatmapmerps(obs=max) width=minimum; var mat_cod matmapdesc gdmdesc merpsdesc; run;

title 'matmapdesc ne merpsdesc';
proc print data=gdmmatmapmerps2(obs=max) width=minimum; var mat_cod matmapdesc merpsdesc gdmdesc; run;



endsas;
 /* MERPS and LIFT disagree: */
proc sql;
  SELECT DISTINCT  a.material_description, b.mat_desc
  FROM     GDMLIB.vw_lift_rpt_results_nl a JOIN GDMLIB.VW_MERPS_MATERIAL_INFO b ON a.MRP_MAT_ID=b.MAT_COD
  WHERE    test_end_date IS NOT NULL AND test_status='Approved' and a.MATERIAL_DESCRIPTION ne b.mat_desc
  ORDER BY material_description
  ;
quit;
