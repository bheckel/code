options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: attrib.sas
  *
  *  Summary: Demo of the attrib statement which fills all 4 of the available
  *           SAS variable attributes.
  *
  *           Mnemonic FILL (Format, Informat, Label, Length)
  *
  *  Created: Tue 10 Jun 2003 09:39:36 (Bob Heckel)
  * Modified: Tue 06 Mar 2007 15:16:29 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data sample;
   input density  crimerate  state $ 14-27  stabbrev $ 29-30;
   cards;
264.3 3163.2 Pennsylvania   PA
51.2 4615.8  Minnesota      MN
102.4 3371.7 New Hampshire  NH
120.4 4649.9 North Carolina NC
  ;
run;

data tmp;
  /* Must appear before SET to affect length */
  attrib state length=$3 label='foo bar'; 
  /* Must appear before SET to affect output positioning in the new ds */
  attrib stabbrev label='here only to make sure I am the 2nd vari displayed';
  set sample;
  attrib density crimerate format=BEST3.; 
run;

data tmp;
  /* Can combine >1 variable in an attrib statement. */
  attrib state label='State Lbl Demo' length=$12 
         stabbrev label='stabbrev Lbl Demo'
         state format=$40.
         ;
  set sample;
run;
 /* To view the labels */
 /*        ____        */
proc print LABEL; run;

proc contents; run;


endsas;
 /* TODO would we ever need to set informat this way??, better to leave it off?? */
data LINKS_Spec_File; 
   attrib prod_family 		       length=$40  format=$40. informat=$40.
          reg_prod_name 	       length=$200 format=$200.informat=$200.
          reg_meth_name          length=$200 format=$200.informat=$200.
          spec_grp               length=$40  format=$40. informat=$40.
          spec_typ               length=$10  format=$10. informat=$10.
          low_limit              length=$15  format=$15. informat=$15.
          upr_limit              length=$15  format=$15. informat=$15.
          txt_limit_a            length=$200 format=$200.informat=$200.
          txt_limit_b            length=$200 format=$200.informat=$200.
          txt_limit_c            length=$200 format=$200.informat=$200.
          stability_samp_product length=$40  format=$40. informat=$40.
          lab_tst_meth_spec_desc length=$40  format=$40. informat=$40.
          indvl_meth_stage_nm    length=$40  format=$40. informat=$40.
          meth_peak_nm           length=$40  format=$40. informat=$40.
          low_ctl                length=$15  format=$15. informat=$15.
          upr_ctl                length=$15  format=$15. informat=$15.
          short_meth_nm          length=$40  format=$40. informat=$40.
	  ;
  set advhfa AdvDisk Comb ImitFDT Ondan RetCaps Relenza RetTabs WSRTabs Zantac Ziagen Zofran;  
run;
