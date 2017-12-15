
options NOcenter ls=max ps=max NOlabel;

%macro ckods(pth, fn);
  libname l "&pth" access=readonly;

  title "&fn";
/***  proc sql ; select distinct recorded_text from l.&fn; quit;***/
/***  proc contents data=l.&fn; run;***/
/***  proc sql ; select distinct long_test_name, count(long_test_name) from l.&fn group by long_test_name; quit;***/
/***  proc sql ; select distinct mrp_batch_id, material_description, fill_batch_number, alt_batch_number from l.&fn order by mrp_batch_id; quit;***/
/***  proc sql ; select mrp_batch_id, material_description, fill_batch_number, recorded_text from l.&fn where mrp_batch_id in ('2ZP1715','2ZP0578','2ZP0577') order by mrp_batch_id; quit;***/
/***  proc sql ; select distinct material_description from l.&fn order by material_description; quit;***/
  proc sql ; select distinct mrp_mat_id from l.&fn; quit;
/***  proc sql ; select count(*) from l.&fn; where long_test_name = ''; quit;***/
%mend;

*%ckods(y:/datapost/data/gsk/zebulon/mdi/advairhfa, ols_0004t_advairhfa);
*%ckods(y:/datapost/data/gsk/zebulon/mdi/albuterol, ols_0014t_albuterol);
*%ckods(z:/datapost/data/gsk/zebulon/mdpi/advairdiskus, ols_0016t_advairdiskus);
*%ckods(z:/datapost/data/gsk/zebulon/mdpi/sereventdiskus, ols_0017t_sereventdiskus);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/avandamet, ols_0023t_avandamet);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/avandaryl, ols_0024t_avandaryl);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/bupropion, ols_0002t_bupropion);
*%ckods(c:/datapost/data/gsk/zebulon/mdpi/floventdiskus, ols_0028t_floventdiskus);
*%ckods(x:/datapostdemo/data/gsk/zebulon/mdpi/floventdiskus, ols_0028t_floventdiskus);
*%ckods(y:/datapost/data/gsk/zebulon/soliddose/lamictal, ols_0006t_lamictal);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/lotronex, ols_0009t_lotronex);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/lovaza, ols_0007t_lovaza);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/methylcellulose, ols_0011t_methylcellulose);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/ratiolamotrigine, ols_0027t_ratio_lamotrigine);
*%ckods(y:/datapost/data/gsk/zebulon/soliddose/retigabine, ols_0012t_retigabine);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/retrovir, ols_0020t_retrovir);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/rosiglitazone, ols_0025t_rosiglitazone);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/trizivir, ols_0021t_trizivir);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/valtrex, ols_0018t_valtrex);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/wellbutrin, ols_0003t_wellbutrin);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/zantac, ols_0022t_zantac);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/zofran, ols_0008t_zofran);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/zovirax, ols_0010t_zovirax);
*%ckods(z:/datapost/data/gsk/zebulon/soliddose/zyban, ols_0005t_zyban);
*%ckods(C:\cygwin\home\rsh86800\tmp\1364492306_28Mar13, ols_0016t_advairdiskus);
%ckods(X:\DataPostDEMO\data\GSK\Zebulon\MDPI\FloventDiskus, ods_0005t_FloventDiskus);
%ckods(X:\DataPostDEMO\data\GSK\Zebulon\MDPI\FloventDiskus, ols_0028t_floventdiskus);
