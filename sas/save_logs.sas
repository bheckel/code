
libname MATMAP "e:/datapost/data/GSK/Metadata/Reference/MATL";
libname l 'E:\DataPostDEMO\data\GSK\Zebulon\MDPI\AdvairDiskus';
options fullstimer;
%macro m;
  %let dtt=&SYSDATE.&SYSPROCESSID;
  %let curlog="e:/temp/&dtt..log";

  proc printto log=&curlog NEW;
    proc sql;
      create table olsfinal as
      select a.*,
             b.long_product_name,
             b.short_product_name_level1,
             b.short_product_name_level2,
             b.short_product_name_level3
      from l.ols a LEFT JOIN MATMAP.material_mapping_table b  ON a.material_description=b.mat_desc and a.mrp_mat_id=b.mat_cod
      order by a.mrp_batch_id, a.long_test_name
      ;
    quit;
  proc printto;run;
%mend; %m;
