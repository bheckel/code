#!/bin/bash

# This is a continuation of $u/gsk/compare_matcod_across_systems.sas

MATCODES=(10000000107766 10000000097337 10000000107768)  # 97953
###MATCODES=(10000000118073 10000000118074 10000000118075)   # 97978
DRV=c

echo "config is $DRV"
echo
echo '5. checking MDES matmap...'
for x in ${MATCODES[@]}; do
  grep --color=always "$x" '//Bredsntp002/uk_gms_wre_data_area/GDM Reporting Profiles/DATAPOST/Verified/ZEB_MATERIAL_REPORTING_PROFILE.csv'
done
echo

echo '6. checking cfg ExtractComment...'
for x in ${MATCODES[@]}; do
  grep ExtractComment /cygdrive/$DRV/datapost/cfg/DataPost_Configuration.xml | grep --color=always "$x"
done
echo

echo '7. checking cfg CDATA...'
for x in ${MATCODES[@]}; do
  grep -v ExtractComment /cygdrive/$DRV/datapost/cfg/DataPost_Configuration.xml | grep --color=always "$x"
done
echo

# optional
echo '8. checking OLS...'
for x in ${MATCODES[@]}; do
  echo -n "$x count is "
  # find datapost/ -name '*.csv' -a -not -name 'TR*.csv'|grep OLS
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/MDI/advairhfa/OLS_0004T_AdvairHFA.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/MDI/albuterol/OLS_0014T_Albuterol.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/MDPI/AdvairDiskus/OLS_0016T_AdvairDiskus.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/MDPI/FloventDiskus/Copy of OLS_0028T_FloventDiskus.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/MDPI/FloventDiskus/OLS_0028T_FloventDiskus.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/MDPI/SereventDiskus/Copy of OLS_0017T_SereventDiskus.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/MDPI/SereventDiskus/OLS_0017T_SereventDiskus.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/MDPI/SereventDiskus/OLS_0017T_SereventDiskus.pre97487dups.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/SolidDose/Avandamet/OLS_0023T_Avandamet.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/SolidDose/Avandaryl/OLS_0024T_Avandaryl.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/SolidDose/Bupropion/OLS_0002T_Bupropion.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/SolidDose/Ezogabine/OLS_0013T_Ezogabine.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/SolidDose/Lamictal/OLS_0006T_Lamictal.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/SolidDose/Lovaza/OLS_0007T_Lovaza.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/SolidDose/Methylcellulose/OLS_0011T_Methylcellulose.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/SolidDose/Ratiolamotrigine/OLS_0027T_Ratio_Lamotrigine.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/SolidDose/Retigabine/OLS_0012T_Retigabine.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/SolidDose/Retrovir/OLS_0020T_Retrovir.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/SolidDose/Rosiglitazone/OLS_0025T_Rosiglitazone.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/SolidDose/Trizivir/OLS_0021T_Trizivir.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/SolidDose/Valtrex/OLS_0018T_Valtrex.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/SolidDose/Wellbutrin/OLS_0003T_Wellbutrin.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/SolidDose/zantac/OLS_0022T_Zantac.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/SolidDose/Zofran/OLS_0008T_Zofran.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/SolidDose/Zovirax/OLS_0010T_Zovirax.csv"
  # grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/SolidDose/Zyban/OLS_0005T_Zyban.csv"
  grep -c "$x" "/cygdrive/$DRV/datapost/data/GSK/Zebulon/MDPI/FloventDiskus/OLS_0028T_FloventDiskus.csv"
done
