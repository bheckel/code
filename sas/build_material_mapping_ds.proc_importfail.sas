 /* Save xlsx as v95 Excel! */

 /* !Must have each mat_cod preceded by a single quote or get 1E13 problem! */
 /* !Must have each mat_cod preceded by a single quote or get 1E13 problem! */
 /* !Must have each mat_cod preceded by a single quote or get 1E13 problem! */

libname l '.';
libname demo 'X:\DataPostDEMO\data\GSK\Metadata\Reference\MATL';

proc import datafile="Material_Mapping_Table.xls" 
            out=Material_Mapping_Table REPLACE;
run;

 /* Occasionally userland will have hidden fields in the xls so drop F: */
data Material_Mapping_Table(drop=TMPmat_cod F:);
  set Material_Mapping_Table(rename=(mat_cod=TMPmat_cod));
  /* Remove the single quote that forced char instead of 1E13 default */
  mat_cod=substr(TMPmat_cod, 2);
  if mat_cod ne '';
/***  put mat_cod=;***/
run;

proc sort; by mat_desc; run;
data l.Material_Mapping_Table;
  retain mat_cod mat_desc long_product_name short_product_name_level1 short_product_name_level2 short_product_name_level3;
  set Material_Mapping_Table;
run;

proc contents; run;
proc print data=_LAST_(obs=15); run;
proc export data=l.Material_Mapping_Table OUTFILE='TMPMaterial_Mapping_Table.csv' DBMS=CSV REPLACE; run;
proc export data=DEMO.Material_Mapping_Table OUTFILE='TMPdemoMaterial_Mapping_Table.csv' DBMS=CSV REPLACE; run;

endsas;
vi -d TMPMaterial_Mapping_Table.csv TMPdemoMaterial_Mapping_Table.csv #cp material_mapping_table.sas7bdat /cygdrive/c/datapost/data/GSK/Metadata/Reference/MATL && cp -i material_mapping_table.sas7bdat /cygdrive/x/datapostdemo/data/GSK/Metadata/Reference/MATL
