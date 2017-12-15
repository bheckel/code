options compress=yes;

%macro readin;

/*
proc access dbms=xls;
   create work.acc.access;
   path="k:\links_method_file\LINKS_MethodsandSpecs.xls";
   worksheet="&worksheet";
   getnames=no;
   skiprows=1;
   rename 1=prod_family 2=reg_prod_name 3=meth_num 4=reg_meth_name 5=spec_group
   6=spec_type  7=low_limit  8=upr_limit 9=spec_precision 10=txt_limit_a 11=txt_limit_b
   12=txt_limit_c  13=stability_samp_product 14=lab_tst_meth_spec_desc 15=indvl_meth_stage_nm
   16=meth_peak_nm 17=CTL_Low  18=CTL_upr;
   *format 1=$10. 2=$10. 5=$15.;
   mixed=yes;
   create work.V&dataname..view;
   select all;
   list all;
run;

data &dataname; set Vdataname; run;*/

PROC IMPORT OUT=&dataname 
            DATAFILE= "LINKS_MethodsandSpecs.xls" 
            DBMS=EXCEL2000 REPLACE;
     RANGE="&worksheet.$"; 
     GETNAMES=YES;
RUN;
quit;

%mend;

proc datasets;
delete LINKS_Spec_File advhfa AdvDisk Comb ImitFDT Ondan Relenza RetCaps RetTabs Ventolin WSRTabs Zantac Ziagen Zofran;
run;

%let worksheet=Advair HFA;
%let dataname=AdvHFA;

%readin;

%let worksheet=Advair Diskus;
%let dataname=AdvDisk;

%readin;

%let worksheet=CombivirTablets;
%let dataname=Comb;

%readin;

%let worksheet=ImitrexFDT;
%let dataname=ImitFDT;

%readin;

%let worksheet=Ondansetron;
%let dataname=Ondan;

%readin;

%let worksheet=Relenza;
%let dataname=Relenza;

%readin;

%let worksheet=RetrovirCapsules;
%let dataname=RetCaps;

%readin;

%let worksheet=RetrovirTablets;
%let dataname=RetTabs;

%readin;

%let worksheet=Ventolin;
%let dataname=Ventolin;

%readin;
%let worksheet=WellbutrinSRTablets;
%let dataname=WSRTabs;

%readin;

%let worksheet=ZantacTablets;
%let dataname=Zantac;

%readin;

%let worksheet=ZiagenTablets;
%let dataname=Ziagen;

%readin;

%let worksheet=ZofranTablets;
%let dataname=Zofran;

%readin;

libname OUT '\\rtpsawn321\d\sql_loader\metadata';

 /* if list num vars like meth_ord_num here, it won't work */
data LINKS_Spec_File; 
   attrib prod_family 		 length=$40  format=$40.  informat=$40.
          reg_prod_name 	 length=$200 format=$200. informat=$200.
          reg_meth_name          length=$200 format=$200. informat=$200.
          spec_grp               length=$40  format=$40.  informat=$40.
          spec_typ               length=$10  format=$10.  informat=$10.
          low_limit              length=$15  format=$15.  informat=$15.
          upr_limit              length=$15  format=$15.  informat=$15.
          txt_limit_a            length=$200 format=$200. informat=$200.
          txt_limit_b            length=$200 format=$200. informat=$200.
          txt_limit_c            length=$200 format=$200. informat=$200.
          stability_samp_prod    length=$40  format=$40.  informat=$40.
          lab_tst_meth_spec_desc length=$40  format=$40.  informat=$40.
          indvl_meth_stage_nm    length=$40  format=$40.  informat=$40.
          meth_peak_nm           length=$40  format=$40.  informat=$40.
          low_ctl                length=$15  format=$15.  informat=$15.
          upr_ctl                length=$15  format=$15.  informat=$15.
          short_meth_nm          length=$40  format=$40.  informat=$40.
	  ;
  set AdvHFA AdvDisk Comb ImitFDT Ondan RetCaps Relenza RetTabs Ventolin WSRTabs Zantac Ziagen Zofran;  
run;


data OUT.LINKS_Spec_File;
  retain prod_family reg_prod_name meth_ord_num reg_meth_name short_meth_nm
         spec_grp spec_typ low_limit upr_limit spec_precision txt_limit_a 
	 txt_limit_b txt_limit_c stability_samp_prod lab_tst_meth_spec_desc
	 indvl_meth_stage_nm meth_peak_nm low_ctl upr_ctl
	 ;
  set LINKS_Spec_File;
  rename spec_grp=spec_group
         spec_typ=spec_type
	 stability_samp_prod=stability_samp_product
	 ;
run;

proc contents data=OUT.LINKS_Spec_File;run;
