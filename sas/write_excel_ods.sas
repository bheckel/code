
ods _all_ close;
ods tagsets.excelxp path="&reportlocation" file="&clientfolder. Extra Census Stats.xml" style=minimal
  options(absolute_column_width="20,8,8" sheet_interval='none' sheet_name='Census' autofit_heighT='YES' SUPPRESS_BYLINES='yes'
  Orientation="Landscape" ROW_HEIGHT_FUDGE='.5' EMBEDDED_TITLES='YES' skip_space='1,0,0,0,0'
  FitToPage="yes"
  );
title bold 'Number of Medications Per Patient Summary-Grouped';

proc print data=_LAST_(obs=max) width=minimum NOobs;
  format NumDrugs cntgrp.;
run;

ods tagsets.ExcelXP close;
