options NOdate NOcenter ls=180;

*%let MATCODES='10000000107766','10000000097337','10000000107768';  /* 97953 */
%let MATCODES='10000000118073','10000000118074','10000000118075';  /* 97978 */
%let DRV=c;


 /* Material code appears in 8 places, here are 4 of them: */
%macro m;
  %let USERNAME=;
  %let PASSWORD=;
  %let DATABASE=;

  libname GDMLIB oracle user=&USERNAME password=&PASSWORD path=&DATABASE schema=gdm_dist;
  libname DPLIB "&DRV:\DataPost\data\GSK\Metadata\Reference\MATL" access=READONLY;

  proc sql;
    create table lift as
      SELECT DISTINCT  mrp_mat_id, material_description
      FROM             GDMLIB.vw_lift_rpt_results_nl
      WHERE            site_name='Zebulon' AND mrp_mat_id in(&MATCODES) and test_status='Approved'
    ;

    create table merps as
      SELECT DISTINCT  mat_cod, mat_desc, prod_brand_name, prod_strength
      FROM             GDMLIB.vw_merps_material_info
      WHERE            site_name='Zebulon' AND mat_cod in(&MATCODES)
    ;

    create table merps2 as
      SELECT DISTINCT   mat_cod
      FROM              GDMLIB.vw_merps_material_batch
      WHERE             site_name='Zebulon' AND mat_cod in(&MATCODES)
    ;
  quit;

  title;

  data _null_;
    file PRINT;
    put '1. checking GDM vw_lift_rpt_results_nl...';
  run;
  proc print data=lift(obs=max) width=minimum; run;

  data _null_;
    file PRINT;
    put '2. checking GDM vw_merps_material_info...';
  run;
  proc print data=merps(obs=max) width=minimum; run;

  data _null_;
    file PRINT;
    put '3. checking GDM vw_merps_material_batch...';
  run;
  proc print data=merps2(obs=max) width=minimum; run;

  data _null_;
    file PRINT;
    put "4. checking DP material_mapping_table on &DRV....";
  run;
  proc print data=DPLIB.material_mapping_table(obs=max) width=minimum; where mat_cod in(&MATCODES); run;

  data _null_;
    file PRINT;
    put 'now run 5-8 via $u/gsk/compare_matcod_across_systems.sh';
  run;
%mend;
%m;
