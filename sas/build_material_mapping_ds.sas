 /* 
  * build_material_mapping_ds.sas
  *
  * 1-run this on a workstation
  *
  * 2-after optional diff, copy the resulting .sas7bdat to DataPost\data\GSK\Metadata\Reference\MATL\
  *
  */
libname l '.';
libname REFMATL 'Z:\DataPost\data\GSK\Metadata\Reference\MATL' access=readonly;

filename MDES '\\Bredsntp002\uk_gms_wre_data_area\GDM Reporting Profiles\DATAPOST\Verified\ZEB_MATERIAL_REPORTING_PROFILE.csv';

data csv;
  infile MDES delimiter=',' MISSOVER LRECL=32767 DSD firstobs=2;
  input MAT_COD :$80.
        MAT_DESC :$80.
        LONG_PRODUCT_NAME :$80.
        SHORT_PRODUCT_NAME_LEVEL1 :$80.
        SHORT_PRODUCT_NAME_LEVEL2 :$80.
        SHORT_PRODUCT_NAME_LEVEL3 :$80.
        ;
run;

 /* There should not be dups but file is maintained by userland... */
proc sort NOdupkey; by mat_cod mat_desc long_product_name short_product_name_level1 short_product_name_level2 short_product_name_level3; run;
 /* There should be leading zeros for these Diskus mat codes but file is maintained by userland... */
data csv;
  set csv;
  if mat_cod in('695009','695017','695025','696005','696013','696021','697001','697017','697028') then do;
    mat_cod = '0' || trim(left(mat_cod));
  end;
run;

data l.material_mapping_table;
  retain mat_cod mat_desc long_product_name short_product_name_level1 short_product_name_level2 short_product_name_level3;
  set csv;
run;

/***proc contents; run;***/
/***proc print data=_LAST_(obs=max) width=minimum; run;***/

 /* To allow a diff of what changed (if desired) */
proc export data=l.material_mapping_table OUTFILE='TMPnewMaterial_Mapping_Table.csv' DBMS=CSV REPLACE; run;
proc export data=REFMATL.material_mapping_table OUTFILE='TMPprodMaterial_Mapping_Table.csv' DBMS=CSV REPLACE; run;



endsas;
cp /cygdrive/x/DataPostDEMO/data/GSK/Metadata/Reference/MATL/material_mapping_table.sas7bdat $u/bkup/material_mapping_table.`date +%d%b%y`.sas7bdat && vi -d TMPMaterial_Mapping_Table.csv TMPdemoMaterial_Mapping_Table.csv #cp material_mapping_table.sas7bdat /cygdrive/c/datapost/data/GSK/Metadata/Reference/MATL && cp -i material_mapping_table.sas7bdat /cygdrive/x/datapostdemo/data/GSK/Metadata/Reference/MATL #&& touch $u/tmp/mdes.timestamp
