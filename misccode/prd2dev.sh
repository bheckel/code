#!/bin/sh

# Refresh datapost dev with datapost prod

# platform-specific, save first
cp -v /cygdrive/x/DataPost/data/gsk/metadata/reference/lims/build_lims_mapping_ds.sas /cygdrive/x/temp/build_lims_mapping_ds.sas
cp -v /cygdrive/x/DataPost/data/gsk/metadata/reference/lims/lims_report_profile.sas7bdat /cygdrive/x/temp/lims_report_profileDEV.sas7bdat

cp -v /cygdrive/x/DataPost/data/gsk/metadata/reference/matl/build_material_mapping_ds.sas /cygdrive/x/temp/build_material_mapping_ds.sas
cp -v /cygdrive/x/DataPost/data/gsk/metadata/reference/matl/material_mapping_table.sas7bdat /cygdrive/x/temp/material_mapping_tableDEV.sas7bdat

cp -v /cygdrive/x/DataPost/data/gsk/metadata/reference/trends/trendlimits.sas7bdat /cygdrive/x/temp/trendlimitsDEV.sas7bdat

cp -v /cygdrive/x/DataPost/cfg/DataPost_User_Dependency_View.xslt /cygdrive/x/temp/DataPost_User_Dependency_View.xslt
###############################


# empty old
rm -fv /cygdrive/x/DataPost/cfg/*
rm -fv /cygdrive/x/DataPost/code/*
cd $x/datapost/data && find . -type f -print0|xargs -0 rm
cd -

# copy in new
cp -piv /cygdrive/z/DataPost/cfg/* /cygdrive/x/DataPost/cfg/
cp -piv /cygdrive/z/DataPost/code/* /cygdrive/x/DataPost/code/
cp -pRv /cygdrive/z/DataPost/data/* /cygdrive/x/DataPost/data/


# restore platform-specific
cp -pv /cygdrive/x/temp/build_lims_mapping_ds.sas /cygdrive/x/DataPost/data/gsk/metadata/reference/lims/build_lims_mapping_ds.sas
cp -pv /cygdrive/x/temp/lims_report_profileDEV.sas7bdat /cygdrive/x/DataPost/data/gsk/metadata/reference/lims/

cp -pv /cygdrive/x/temp/build_material_mapping_ds.sas /cygdrive/x/DataPost/data/gsk/metadata/reference/matl/build_material_mapping_ds.sas
cp -pv /cygdrive/x/temp/material_mapping_tableDEV.sas7bdat /cygdrive/x/DataPost/data/gsk/metadata/reference/matl/

cp -pv /cygdrive/x/temp/trendlimitsDEV.sas7bdat /cygdrive/x/DataPost/data/gsk/metadata/reference/trends/

cp -pv /cygdrive/x/temp/DataPost_User_Dependency_View.xslt /cygdrive/x/DataPost/cfg/
###############################


# cleanup
touch /cygdrive/x/DataPost/cfg/DEVDEVDEVDEVDEV; touch /cygdrive/x/DataPost/code/DEVDEVDEVDEVDEV; touch /cygdrive/x/DataPost/data/DEVDEVDEVDEVDEV

sed -i -e "s/zdatapost\./zdatapostd\./g" /cygdrive/x/datapost/cfg/DataPost_Configuration.xml
sed -i -e "s/zdatapost\./zdatapostd\./g" /cygdrive/x/datapost/cfg/DataPost_Results.xml
sed -i -e "s/<MappedDrivePrefix>Z:/<MappedDrivePrefix>X:/g" /cygdrive/x/datapost/cfg/DataPost_Configuration.xml /cygdrive/x/datapost/cfg/DataPost_Configuration.xml
###############################
