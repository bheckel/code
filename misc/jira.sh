#!/bin/bash

# Modified: 02-Jan-2024 (Bob Heckel)
# ln -s ~/code/misccode/jira.sh ~/bin
# jira.sh dma-33479 my_description

JIRA=${1:-99999999}
DESC=${2:-untitled}

TAG=${JIRA}_${DESC}

echo 'checking if already exists...'
if [ `find -L $HOME/onedrive -maxdepth 1 -name "${JIRA}*" | wc -l` -gt 0 ];then
  echo "${JIRA} already exists. Exiting."
  exit
else
  echo '...done'
fi

mkdir -p ~/onedrive/${TAG} && cd ~/onedrive/${TAG} && \
cp -i ~/onedrive/template_jira.sql ~/onedrive/${TAG}/${JIRA}.sql && \

echo '--  cd C:\Orion\workspace\orion-data\Source\SQL\2024OrionScripts\24.xOrionScripts' >> ${JIRA}.sql
echo '--  @'${JIRA}'_ddl_change.sql' >> ${JIRA}.sql
echo '--  vi "C:\Users\boheck\OneDrive - SAS\'${JIRA}'_'${DESC}'\'${JIRA}'.pck"' >> ${JIRA}.sql
echo '--  @"C:\Users\boheck\OneDrive - SAS\'${JIRA}'_'${DESC}'\'${JIRA}'.pck"' >> ${JIRA}.sql
#echo "DROP PACKAGE ORION${JIRA};" >> ${JIRA}.sql
echo >> ${JIRA}.sql

echo "-- ${DESC} https://esapps.sas.com/jira/browse/${JIRA}" >> ${JIRA}.sql
echo '' >> ${JIRA}.sql
echo "-- $ git checkout develop && git pull && git checkout -b feature/${JIRA} && git push --set-upstream origin feature/${JIRA} && git checkout feature/${JIRA}" >> ${JIRA}.sql
echo "-- $ git add . && git commit -m '"${JIRA}"' && git push" >> ${JIRA}.sql
echo "-- WITHOUT GITHUB PR/UI: gco && gpul && git checkout feature/${JIRA} && git merge develop && gpul && gco && git merge --squash feature/${JIRA} && git add . && git commit -m '${JIRA}: XXXXXXXXXX' && git push && git branch -D feature/${JIRA} && git fetch -p && git push origin --delete feature/${JIRA}" >> ${JIRA}.sql
echo "-- AFTER GITHUB PR/UI: git checkout develop && git pull && git branch -d feature/${JIRA} && git fetch -p" >> ${JIRA}.sql
echo "-- Pushed and ran ${JIRA}_ddl_change.sql on ORNDBDEV01RW and ORNDBTST01RW" >> ${JIRA}.sql
echo "--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> ${JIRA}.sql
echo >> ${JIRA}.sql

# echo "${JIRA} ${DESC}" > ${TAG}.html
# echo "<a href=https://esapps.sas.com/jira/browse/DMA-${JIRA}>jira</a>" >> ${TAG}.html

# TAG2=${TAG//-}
cygstart -x /cygdrive/c/Users/boheck/OneDrive\ -\ SAS/${TAG}
