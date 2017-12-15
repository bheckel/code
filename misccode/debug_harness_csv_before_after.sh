#!/bin/sh

[ -z "$1" ] && echo "specify output .txt name" && exit 1

[ -e $1.txt ] && rm -i $1.txt

head -n1     /cygdrive/c/DataPost/data/GSK/Zebulon/MDPI/AdvairDiskus/ods_0001t_AdvairDiskus.csv|sed 's/,/\n/g' |nl
# good
grep 4ZP3957 /cygdrive/c/DataPost/data/GSK/Zebulon/MDPI/AdvairDiskus/ods_0001t_AdvairDiskus.csv|awk -F, '{print $3, $10, $13, $14, $20}'|grep 'Stage 1-2 - FP' > $1.txt
# bad
grep 4ZP3810 /cygdrive/c/DataPost/data/GSK/Zebulon/MDPI/AdvairDiskus/ods_0001t_AdvairDiskus.csv|awk -F, '{print $3, $10, $13, $14, $20}'|grep 'Stage 1-2 - FP' >> $1.txt
echo
head -n1     /cygdrive/c/DataPost/data/GSK/Zebulon/MDPI/AdvairDiskus/ols_0016t_advairdiskus.csv|sed 's/,/\n/g' |nl
grep 4ZP3957 /cygdrive/c/DataPost/data/GSK/Zebulon/MDPI/AdvairDiskus/ols_0016t_advairdiskus.csv|awk -F, '{print $6, $17, $23, $24}'|grep 'Stage 1-2 - FP' >> $1.txt
grep 4ZP3810 /cygdrive/c/DataPost/data/GSK/Zebulon/MDPI/AdvairDiskus/ols_0016t_advairdiskus.csv|awk -F, '{print $6, $17, $23, $24}'|grep 'Stage 1-2 - FP' >> $1.txt
