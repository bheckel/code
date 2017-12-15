 /*                   ________________                */
options ls=180 ps=max validvarname=any; libname l '.';
 /*                                                                                               ______________________ */
libname DGM_DIST oracle user=dgm_dist_R password=xxx path=kuprd613 schema=dgm_dist readbuff=10000 preserve_col_names=yes;

PROC SQL;
   CREATE TABLE WORK.MB51_DATA AS 
   SELECT t1.PLANT_COD AS Plant, 
          t1.MAT_COD AS Material, 
          t2.MAT_DESC AS 'Material description'N, 
          t1.MAT_DOC_NUM AS 'Mat. doc.'n, 
          t1.BAT_MOV_TYP AS MvT, 
          t1.BAT_NUM AS Batch, 
          t1.PRCS_ORD_NUM AS Order, 
          t1.PRCHS_ORD_NUM AS PO, 
          t1.BAT_MOV_POST_DT AS 'Pstg date'n, 
          (CASE WHEN t1.BAT_MOV_QUANTITY = 'H' THEN t1.BAT_MOV_QUANTITY_VAL*-1 ELSE t1.BAT_MOV_QUANTITY_VAL END) AS Quantity, 
          t1.BAT_MOV_UOM AS EUn
      FROM GDM_DIST.VW_MERPS_MATERIAL_DOC t1, GDM_DIST.VW_MERPS_MATERIAL_INFO t2
     WHERE (t1.PLANT_COD = t2.PLANT_COD AND t1.MAT_COD = t2.MAT_COD) AND (t1.PLANT_COD = 'US01' AND t1.BAT_MOV_POST_DT > TODAY()-2 AND t1.MAT_COD IN('0446009', '0447005', '0633022'))
      ORDER BY t1.BAT_MOV_POST_DT DESC,
               t1.MAT_DOC_NUM DESC;
QUIT;

PROC SQL;
   CREATE TABLE l.MB51_DATA_FINAL AS 
   SELECT t1.Plant, 
          t1.Material, 
          t1.'Material description'n, 
          t1.'Mat. doc.'n, 
          t1.MvT, 
          t1.Batch, 
          t1.Order, 
          t1.PO, 
          t1.'Pstg date'n, 
          (SUM(t1.Quantity)) AS Quantity, 
          t1.EUn
      FROM WORK.MB51_DATA t1
      GROUP BY t1.Plant,
               t1.Material,
               t1.'Material description'n,
               t1.'Mat. doc.'n,
               t1.MvT,
               t1.Batch,
               t1.Order,
               t1.PO,
               t1.'Pstg date'n,
               t1.EUn;
QUIT;

ods CSVALL file='MB51_DATA_FINAL.csv'; proc print NOobs; run; ods CSVALL close;
