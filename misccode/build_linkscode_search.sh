#!/bin/sh

# Modified: Mon 08 Jun 2009 09:20:42 (Bob Heckel)

# S/b symlinked as ~/bin/build_search

# Build and fill a dir with xsource code (to be searched later).

###xsource=x:
xsource=//rtpsawn321/d
###wsource=w:
wsource=//rtpsawn323

# e.g. 09Apr07
today=`date +%d%b%y`

root=$HOME/search

srchdir=$root/$today

if [ ! -d $srchdir ];then
  mkdir $srchdir
fi

cp -p $xsource/SAS_Programs/LACtlTblMenu.sas $srchdir/
cp -p $xsource/SAS_Programs/LACtlTblUpd.sas $srchdir/
cp -p $xsource/SAS_Programs/LELimsGist.sas $srchdir/
cp -p $xsource/SAS_Programs/LRBatchAnalysis.sas $srchdir/
cp -p $xsource/SAS_Programs/LRMDPI_Reports.sas $srchdir/
cp -p $xsource/SAS_Programs/LRQuery.sas $srchdir/
cp -p $xsource/SAS_Programs/LRReport.sas $srchdir/
cp -p $xsource/SAS_Programs/LRStAnalysis.sas $srchdir/
cp -p $xsource/SAS_Programs/LRStudyRpt.sas $srchdir/
cp -p $xsource/SAS_Programs/LRXLSData.sas $srchdir/

cp -p $xsource/Auto_Call/LEGist.sas $srchdir/
cp -p $xsource/Auto_Call/LELimsIndRes.sas $srchdir/
cp -p $xsource/Auto_Call/LELimsSumRes.sas $srchdir/
cp -p $xsource/Auto_Call/LeGenealogy.sas $srchdir/
cp -p $xsource/Auto_Call/LeMetadata.sas $srchdir/

cp -p $xsource/SAS_Web_Pages/MDPI_AssemblyEntryForms.asp $srchdir/
cp -p $xsource/SAS_Web_Pages/MDPI_BlendingEntryForms.asp $srchdir/
cp -p $xsource/SAS_Web_Pages/MDPI_CofAEntryForms.asp $srchdir/
cp -p $xsource/SAS_Web_Pages/MDPI_FillingEntryForms.asp $srchdir/
cp -p $xsource/SAS_Web_Pages/AddUser.asp $srchdir/
cp -p $xsource/SAS_Web_Pages/AdminPages.asp $srchdir/
cp -p $xsource/SAS_Web_Pages/Level_A.asp $srchdir/
cp -p $xsource/SAS_Web_Pages/Level_B.asp $srchdir/
cp -p $xsource/SAS_Web_Pages/LINKS_Login.asp $srchdir/
cp -p $xsource/SAS_Web_Pages/MDPI_Admin.asp $srchdir/
cp -p $xsource/SAS_Web_Pages/MDPI_Menus.asp $srchdir/
cp -p $xsource/SAS_Web_Pages/Sys_Admin.asp $srchdir/
cp -p $xsource/SAS_Web_Pages/User_Admin.asp $srchdir/
cp -p $xsource/SAS_Web_Pages/User_Homepage.asp $srchdir/

cp -p $wsource/SQL_Loader/Metadata/LINKS_MethodsandSpecs.xls $srchdir/
###cp -p $wsource/SQL_Loader/Metadata/New_LINKS_spec_file.sas $srchdir/
cp -p $wsource/SQL_Loader/Metadata/links_spec_file.sas7bdat $srchdir/

cp -p $wsource/SQL_Loader/Logs/LGI.log $srchdir/LGI.prod.log

# Make it easy to just search the 'curr' dir
cp -p $srchdir/* $root/curr
