
 /* rsh86800 13-Aug-12 original version of this is not available */

options compress=yes;

%macro readin;
  proc import OUT=&sheetds 
              DATAFILE= "LINKS_MethodsandSpecs.xls" 
              DBMS=EXCEL2000 REPLACE;
              RANGE="&worksheet.$"; 
              GETNAMES=YES
              ;
  run;
  quit;

  /* spec_precision is numeric on some sheets, character on others, this avoids
   * failure below by forcing numeric
   */
  data &sheetds(drop=spec_precision);
    set &sheetds;

    sp = spec_precision + 0;
  run;
%mend;

%let worksheet=Advair Diskus;
%let sheetds=AdvDisk;
%readin;

%let worksheet=Advair Diskus Tres;
%let sheetds=AdvDiskTres;
%readin;

%let worksheet=Advair Diskus Ware;
%let sheetds=AdvDiskWare;
%readin;

%let worksheet=Advair HFA 120;
%let sheetds=AdvHFA120;
%readin;

%let worksheet=Advair HFA 60;
%let sheetds=AdvHFA60;
%readin;

%let worksheet=Advair HFA 60 MDIC;
%let sheetds=AdvHFA60MDIC;
%readin;

%let worksheet=Advair HFA 120 MDIC;
%let sheetds=AdvHFA120MDIC;
%readin;

%let worksheet=CombivirTablets;
%let sheetds=Comb;
%readin;

%let worksheet=ImitrexFDT;
%let sheetds=ImitFDT;
%readin;

%let worksheet=Ondansetron;
%let sheetds=Ondan;
%readin;

%let worksheet=Relenza;
%let sheetds=Relenza;
%readin;

%let worksheet=Relenza Canada;
%let sheetds=RelenzaCanada;
%readin;

%let worksheet=Relenza Mexico;
%let sheetds=RelenzaMexico;
%readin;

%let worksheet=Relenza Japan;
%let sheetds=RelenzaJapan;
%readin;

%let worksheet=RetrovirCapsules;
%let sheetds=RetCaps;
%readin;

%let worksheet=RetrovirTablets;
%let sheetds=RetTabs;
%readin;

%let worksheet=Seretide Diskus;
%let sheetds=SeretideDiskus;
%readin;

%let worksheet=Ventolin;
%let sheetds=Ventolin;
%readin;

%let worksheet=Ventolin Canada;
%let sheetds=VentolinCanada;
%readin;

%let worksheet=WellbutrinSRTablets;
%let sheetds=WSRTabs;
%readin;

%let worksheet=ZantacTablets;
%let sheetds=Zantac;
%readin;

%let worksheet=ZiagenTablets;
%let sheetds=Ziagen;
%readin;

%let worksheet=ZofranTablets;
%let sheetds=Zofran;
%readin;

/***libname OUT '\\rtpsawn321\d$\sql_loader\metadata';***/
libname OUT '.';

 /* if list num vars like meth_ord_num here, it won't work */
data LINKS_Spec_File; 
  attrib prod_family 		        length=$40  format=$40.    informat=$40.
         reg_prod_name 	        length=$200 format=$200.   informat=$200.
         reg_meth_name          length=$200 format=$200.   informat=$200.
         spec_grp               length=$40  format=$40.    informat=$40.
         spec_typ               length=$10  format=$10.    informat=$10.
         low_limit              length=$15  format=$15.    informat=$15.
         upr_limit              length=$15  format=$15.    informat=$15.
         txt_limit_a            length=$200 format=$200.   informat=$200.
         txt_limit_b            length=$200 format=$200.   informat=$200.
         txt_limit_c            length=$200 format=$200.   informat=$200.
         stability_samp_prod    length=$40  format=$40.    informat=$40.
         lab_tst_meth_spec_desc length=$40  format=$40.    informat=$40.
         indvl_meth_stage_nm    length=$40  format=$40.    informat=$40.
         meth_peak_nm           length=$40  format=$40.    informat=$40.
         low_ctl                length=$15  format=$15.    informat=$15.
         upr_ctl                length=$15  format=$15.    informat=$15.
         short_meth_nm          length=$40  format=$40.    informat=$40.
         prod_market            length=$40  format=$40.    informat=$40.
         ;
  set AdvDisk AdvDiskTres AdvHFA120 AdvHFA60 AdvHFA60MDIC AdvHFA120MDIC Comb ImitFDT Ondan Relenza RelenzaCanada RelenzaMexico RelenzaJapan RetCaps RetTabs SeretideDiskus Ventolin VentolinCanada WSRTabs Zantac Ziagen Zofran;
run;


data OUT.LINKS_Spec_File;
  /* 14-Aug-12 Not sure if this ordering matters */
  retain prod_family reg_prod_name meth_ord_num reg_meth_name short_meth_nm
         spec_grp spec_typ low_limit upr_limit sp txt_limit_a 
         txt_limit_b txt_limit_c stability_samp_prod lab_tst_meth_spec_desc
         indvl_meth_stage_nm meth_peak_nm low_ctl upr_ctl
         ;
  set LINKS_Spec_File;
  rename spec_grp=spec_group
         spec_typ=spec_type
         stability_samp_prod=stability_samp_product
         sp=spec_precision
         ;
run;

proc contents data=OUT.LINKS_Spec_File;run;
