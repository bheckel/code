options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: diff_datasets.sas
  *
  *  Summary: Quick non-PROC COMPARE approach for small datasets.
  *
  *  Created: Thu 02 Aug 2012 12:53:37 (Bob Heckel)
  * Modified: Wed 22 Aug 2012 11:39:48 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%macro m(pth, ds, seq);
  libname l "&pth";

  data &ds;
    set l.&ds;
/***    keep prod_family reg_prod_name meth_ord_num reg_meth_name short_meth_nm spec_group spec_type;***/
  run;
/***  proc sort; by prod_family reg_prod_name meth_ord_num reg_meth_name short_meth_nm spec_group spec_type; run;***/
  proc export data=&ds OUTFILE= "TMPDIFF_&ds&seq..csv" DBMS=CSV replace; run;
%mend;
%m(C:\datapost\data\GSK\Metadata\Reference\LIMS, lims_report_profile, 1);
/***%m(U:\incidents_enhancements\97441lamictalmoistureUOM, lims_report_profile, 2);***/
%m(Y:\datapost\data\GSK\Metadata\Reference\LIMS, lims_report_profile, 2);


endsas;
vi -d TMPDIFF_*
