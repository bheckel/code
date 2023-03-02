#!/bin/bash

# Modified: 23-Jan-2023 (Bob Heckel)
# ln -s ~/code/misccode/jira.sh ~/bin
# jira.sh 33479 my_description

JIRA=${1:-99999999}
DESC=${2:-untitled}

TAG=${JIRA}_${DESC}

echo 'checking if already exists...'
#cd ~/onedrive && find . -maxdepth 1 -name "*${JIRA}*"
if [ `find -L $HOME/onedrive -maxdepth 1 -name "*${JIRA}*" | wc -l` -gt 0 ];then
  echo "${JIRA} already exists. Exiting."
  exit
else
  echo '...done'
fi

mkdir -p ~/onedrive/dma-${TAG} && cd ~/onedrive/dma-${TAG} && \
cp -i ~/onedrive/template_jira.sql ~/onedrive/dma-${TAG}/${JIRA}.sql && \

#cp -i ~/onedrive/template_jira.pck ~/onedrive/orion-${TAG}/ORION${JIRA}.pck && \
#sed -i "s/99999/${JIRA}/" ORION${JIRA}.pck && \

echo '--  cd C:\Orion\workspace\orion-data\Source\SQL\2023OrionScripts\23.xOrionScripts' >> ${JIRA}.sql
echo '--  @DMA-'${JIRA}'_ddl_change.sql' >> ${JIRA}.sql
echo '--  vi "C:\Users\boheck\OneDrive - SAS\dma-'${JIRA}'_'${DESC}'\DMA'${JIRA}'.pck"' >> ${JIRA}.sql
echo '--  @"C:\Users\boheck\OneDrive - SAS\dma-'${JIRA}'_'${DESC}'\DMA'${JIRA}'.pck"' >> ${JIRA}.sql
#echo "DROP PACKAGE ORION${JIRA};" >> ${JIRA}.sql
echo >> ${JIRA}.sql

echo "-- ${DESC} https://esapps.sas.com/jira/browse/DMA-${JIRA}" >> ${JIRA}.sql
echo '' >> ${JIRA}.sql
echo "-- $ git checkout develop && git pull && git checkout -b feature/DMA-${JIRA} && git push --set-upstream origin feature/DMA-${JIRA} && git checkout feature/DMA-${JIRA}" >> ${JIRA}.sql
echo "-- $ git add . && git commit -m 'DMA-"${JIRA}: "' && git push" >> ${JIRA}.sql
echo "-- AFTER GITHUB PR/UI: git checkout develop && git pull && git branch -d feature/DMA-${JIRA} && git fetch -p && git branch -a" >> ${JIRA}.sql
echo "-- WITHOUT GITHUB PR/UI: gco && gpul && gco ${JIRA} && git merge develop && gpul && gco && git merge --squash feature/DMA-${JIRA} && git add . && git commit -m 'DMA-${JIRA}: XXXXXXXXXX' && git push && git branch -D feature/DMA-${JIRA} && git fetch -p && git push origin --delete feature/DMA-${JIRA}" >> ${JIRA}.sql
echo "-- Pushed and ran DMA-${JIRA}_ddl_change.sql on ORNDBDEV01RW and ORNDBTST01RW" >> ${JIRA}.sql
echo "--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> ${JIRA}.sql
echo >> ${JIRA}.sql

echo "${JIRA} ${DESC}" > ${TAG}.html
echo "<a href=https://esapps.sas.com/jira/browse/DMA-${JIRA}>jira</a>" >> ${TAG}.html

cygstart -x /cygdrive/c/Users/boheck/OneDrive\ -\ SAS/dma-${TAG}
