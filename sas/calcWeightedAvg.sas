
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Utility macro
 *  INPUT:            Dataset to add weighted avg to and variable to use for 
 *                    weighting
 *  PROCESSING:       Calculated weighted average
 *  OUTPUT:           Input dataset with wgt avg added
 *******************************************************************************
 */

/*  %calcWeightedAvg(&DS112, Bulk_Density_gmL_50_tamps); */
%macro calcWeightedAvg(ds, wgtThisVar);
  data tmp(keep=Batch Material Quantity &wgtThisVar API_Date_of_Manufacture Vendor_Lots);
    set &ds;
  run;

  proc sort data=&ds NODUPKEY;
    by Batch Material Vendor_Lots;
  run;

  /* Calc weighted averages */
  proc means data=tmp maxdec=3 mean NOprint;
    class Batch;
    weight Quantity;
    var &wgtThisVar;
    id Material;
    output out=tmp2;
  run;

  data tmp2;
    set tmp2(rename=(&wgtThisVar=&wgtThisVar.WtAvg));
    if Batch ne '' and _STAT_ eq 'MEAN';
  run;
    
  proc sql;
    create table &ds(drop=&wgtThisVar) as
    select v.*, l.&wgtThisVar.WtAvg
    from &ds v LEFT JOIN tmp2 l ON v.Batch=l.Batch
    order by Batch, Material, Process_order
    ;
  quit;
%mend calcWeightedAvg;
