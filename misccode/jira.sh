#!/bin/bash

# ln -s ~/code/misccode/jira.sh ~/bin
# jira.sh 33479 existingcust_flaginout

JIRA=${1:-99999999}
DESC=${2:-untitled}

TAG=${JIRA}_${DESC}

mkdir -p ~/onedrive/orion-${TAG} && cd ~/onedrive/orion-${TAG} && \
cp -i ~/onedrive/template_t.sql ~/onedrive/orion-${TAG}/${JIRA}.sql && \

# cp -i ~/onedrive/template_t.pck ~/onedrive/orion-${TAG}/ORION${JIRA}.pck && \
cp -i ~/onedrive/template_t.pck ~/onedrive/orion-${TAG}/ORION${JIRA}.pck && \
# sed -i "s/99999/${JIRA}/" ORION${JIRA}.pck && \
sed -i "s/99999/${JIRA}/" ORION${JIRA}.pck && \

echo '--  cd C:\Orion\workspace\data\Source\SQL\xOrionScripts\' >> ${JIRA}.sql
echo '--  @ORION-'${JIRA}'_ddl_change.sql' >> ${JIRA}.sql
echo '--  @"C:\Users\boheck\OneDrive - SAS\orion-'${JIRA}'_'${DESC}'\ORION'${JIRA}'.pck"' >> ${JIRA}.sql
echo "--  DROP PACKAGE ORION${JIRA};" >> ${JIRA}.sql
echo >> ${JIRA}.sql

echo "-- ${DESC} https://esapps.sas.com/jira/browse/ORION-${JIRA}" >> ${JIRA}.sql
echo '' >> ${JIRA}.sql
echo "-- $ git checkout develop && git pull && git checkout -b feature/ORION-${JIRA} && git push --set-upstream origin feature/ORION-${JIRA} && git checkout feature/ORION-${JIRA}" >> ${JIRA}.sql
echo "-- $ git add . && git commit -m ' ORION-"${JIRA}: "' && git push" >> ${JIRA}.sql
echo "-- WITH GITHUB UI: git branch -d feature/ORION-${JIRA} && git fetch -p && git branch -a" >> ${JIRA}.sql
echo "-- WITHOUT GITHUB UI: git checkout develop && git pull && git merge --no-ff feature/ORION-${JIRA} && git push && git branch -d feature/ORION-${JIRA} && git fetch -p && git push origin --delete feature/ORION-${JIRA}" >> ${JIRA}.sql
echo "-- Pushed and ran ORION-${JIRA}_ddl_change.sql on ESD" >> ${JIRA}.sql
echo "--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> ${JIRA}.sql
echo >> ${JIRA}.sql

# vim t.sql -c ':mksession!'

echo "${JIRA} ${DESC}" > ${TAG}.html
echo "<a href=https://esapps.sas.com/jira/browse/ORION-${JIRA}>jira</a>" >> ${TAG}.html
# cygstart ${TAG}.html

# cp -i ~/onedrive/template_project.prj ~/onedrive/orion-${TAG}/${TAG}.prj && \
# cp -i ~/onedrive/template_project.dsk ~/onedrive/orion-${TAG}/${TAG}.dsk && \
# cygstart "C:\Users\boheck\OneDrive - SAS\orion-${TAG}\\${TAG}.prj"
cygstart -x /cygdrive/c/Users/boheck/OneDrive\ -\ SAS/orion-${TAG}
# cygstart "C:\Users\boheck\Oracle\sqldeveloper\sqldeveloper\bin\sqldeveloper64W.exe"
