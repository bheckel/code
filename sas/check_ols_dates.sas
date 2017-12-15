
 /* Compare with gsk.sh MAXTSTDT qry */

options NOcenter ls=80 ps=max;

%macro ckods(pth, fn);
  libname l "&pth" access=readonly;

  title "max test_date &fn";
  proc sql;
    SELECT long_product_name format=$12.,short_product_name_level2 format=$12.,short_product_name_level3 format=$12.,MAX(test_date) as td format=date9.
    FROM l.&fn
    GROUP BY long_product_name,short_product_name_level2,short_product_name_level3
    ;
  quit;
%mend;

*%ckods(z:/datapost/data/gsk/zebulon/mdi/advairhfa, ols_0004t_advairhfa);
*%ckods(z:/datapost/data/gsk/zebulon/mdi/albuterol, ols_0014t_albuterol);
*%ckods(z:/datapost/data/gsk/zebulon/mdpi/advairdiskus, ols_0016t_advairdiskus);
*%ckods(z:/datapost/data/gsk/zebulon/mdpi/floventdiskus, ols_0028t_floventdiskus);
*%ckods(z:/datapost/data/gsk/zebulon/mdpi/sereventdiskus, ols_0017t_sereventdiskus);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/avandamet, ols_0023t_avandamet);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/avandaryl, ols_0024t_avandaryl);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/bupropion, ols_0002t_bupropion);
%ckods(z:/datapost/data/gsk/zebulon/soliddose/lamictal, ols_0006t_lamictal);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/lotronex, ols_0009t_lotronex);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/lovaza, ols_0007t_lovaza);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/methylcellulose, ols_0011t_methylcellulose);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/ratiolamotrigine, ols_0027t_ratio_lamotrigine);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/retigabine, ols_0012t_retigabine);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/retrovir, ols_0020t_retrovir);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/rosiglitazone, ols_0025t_rosiglitazone);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/trizivir, ols_0021t_trizivir);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/valtrex, ols_0018t_valtrex);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/wellbutrin, ols_0003t_wellbutrin);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/zantac, ols_0022t_zantac);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/zofran, ols_0008t_zofran);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/zovirax, ols_0010t_zovirax);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/zyban, ols_0005t_zyban);
