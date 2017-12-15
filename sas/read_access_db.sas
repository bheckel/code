
options ls=180;

 /* Access database is in pwd */
proc import out=SAPData datatable="3_Table_Join" dbms=access replace;
  database="ONE-TIME EXTRACT FROM 2002 FORWARD.mdb";
run;

DATA SAPDATAx;
  FORMAT MATL_NBR $18. BATCH_NBR $10.;
  LENGTH MATL_NBR $18 BATCH_NBR $10;
  SET SAPDATA;
  RENAME   Description     =  Matl_Desc1
           Expiration_Date    =  Matl_Exp_Dt1
           Last_Goods_Rec_Dt  =  Matl_Mfg_Dt1
           ;
  Matl_Nbr=Material;
  Batch_Nbr=Batch;
  DROP Material Batch;
RUN;
proc contents;run;
proc print data=_LAST_(obs=5); run;
