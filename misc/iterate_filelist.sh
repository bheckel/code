#!/bin/bash

pth='/cygdrive/x/datapost/code'

f=( 
  $pth/dpv2.bat
  $pth/catalog2.sas7bcat
  $pth/DataPost_DataView.sas
  $pth/DataPost_Extract.sas
  $pth/DataPost_Graph.sas
  $pth/DataPost_Transform.sas
  $pth/DataPost_Trend.sas
  $pth/gdm_*.map
  $pth/lims_*
  $pth/merps_*.map
  $pth/merps_0001e.sas
  $pth/ods_*
  $pth/ols_*
  $pth/../cfg/DataPost_Configuration.map
  $pth/../cfg/DataPost_Configuration.xslt
  $pth/../cfg/DataPost_PreProcessXML.xslt
  $pth/../cfg/DataPost_User_Dependency_View.xslt
  $pth/../cfg/DataPost_Filenames.txt
  $pth/../cfg/DataPost_Configuration.xml
  $pth/../data/GSK/Metadata/Reference/LIMS/lims_report_profile.sas7bdat
  $pth/../data/GSK/Metadata/Reference/MATL/material_mapping_table.sas7bdat
  $pth/../data/GSK/Metadata/Reference/MERPS/*.sas7bdat
  $pth/../data/GSK/Metadata/Reference/Trends/trendlimits.sas7bdat
)
for x in ${f[@]}; do
  i=$(($i+1))
  touch -d '08 May 2012 12:34' $x
  echo "...processed $i $x"
done

exit 0
