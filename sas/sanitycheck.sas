options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: specificchecker.sas
  *
  *  Summary: Sanity-checks
  *
  *  Created: Wed 20 Apr 2011 15:46:33 (Bob Heckel)
	* Modified: Wed 30 Apr 2014 12:45:00 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter ls=max;

%let DRV=c;
%let PLAT=datapostdemo;

libname l (
  "&DRV:/&PLAT/data/GSK/Zebulon/MDI"
  "&DRV:/&PLAT/data/GSK/Zebulon/MDI/VentolinHFA"
  "&DRV:/&PLAT/data/GSK/Zebulon/MDPI"
  "&DRV:/&PLAT/data/GSK/Zebulon/MDPI/AdvairDiskus"
  "&DRV:/&PLAT/data/GSK/Zebulon/MDPI/SereventDiskus"
  "&DRV:/&PLAT/data/GSK/Zebulon/SolidDose"
  "&DRV:/&PLAT/data/GSK/Zebulon/SolidDose/Bupropion"
  "&DRV:/&PLAT/data/GSK/Zebulon/SolidDose/Lamictal"
  "&DRV:/&PLAT/data/GSK/Zebulon/SolidDose/Methylcellulose"
  "&DRV:/&PLAT/data/GSK/Zebulon/SolidDose/Valtrex"
  "&DRV:/&PLAT/data/GSK/Zebulon/SolidDose/Wellbutrin"
  "&DRV:/&PLAT/data/GSK/Zebulon/SolidDose/Zyban"
);

 /*               EDIT                   */
/***proc freq data=l.B21_0001E_ZEB01_VHFA; run;***/
/***proc freq data=l.ods_0108e_sd; run;***/
proc freq data=l.ols_0017t_sereventdiskus; run;

/***proc compare base=l.ODS_0302E_AdvairDiskus compare=l.ODS_0302E_AdvairDiskusBEFORE; run;***/
