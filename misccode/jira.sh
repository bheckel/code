#!/bin/bash

# ln -s ~/code/misccode/jira.sh ~/bin
# jira.sh 33479 existingcust_flaginout

JIRA=${1:-99999999}
DESC=${2:-untitled}

TAG=${JIRA}_${DESC}

mkdir -p ~/onedrive/orion-${TAG} && cd ~/onedrive/orion-${TAG} && \
cp -i ~/onedrive/template_t.sql ~/onedrive/orion-${TAG}/t.sql && \
cp -i ~/onedrive/template_bulkcollect.pck ~/onedrive/orion-${TAG}/ORION${JIRA}.pck && \
sed -i "s/99999/${JIRA}/" ORION${JIRA}.pck && \
echo "@C:\Orion\workspace\data\Source\SQL\ OrionScripts\ORION-${JIRA}_ddl_change.sql" >> t.sql
echo >> t.sql
echo "-- git pull && git checkout -b feature/ORION-$JIRA && git push --set-upstream origin feature/ORION-$JIRA" >> t.sql
echo "--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> t.sql
echo >> t.sql

# vim t.sql -c ':mksession!'

echo "${JIRA} ${DESC}" > ${TAG}.html
echo "<a href=https://esapps.sas.com/jira/browse/ORION-${JIRA}>jira</a>" >> ${TAG}.html
cygstart ${TAG}.html

cp -i ~/onedrive/template_project.prj ~/onedrive/orion-${TAG}/${TAG}.prj && \
cp -i ~/onedrive/template_project.dsk ~/onedrive/orion-${TAG}/${TAG}.dsk && \
cygstart "C:\Users\boheck\OneDrive - SAS\orion-${TAG}\\${TAG}.prj"
