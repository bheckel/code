#!/bin/bash

# ln -s ~/code/misccode/jira.sh ~/bin
# jira.sh 33479 existingcust_flaginout

JIRA=${1:-untitled}

mkdir -p ~/onedrive/orion-$1_$2
cd ~/onedrive/orion-$1_$2

cp -i ~/onedrive/template_t.sql ~/onedrive/orion-$1_$2/t.sql
cp -i ~/onedrive/template_project.prj ~/onedrive/orion-$1_$2/$JIRA.prj
cp -i ~/onedrive/template_project.dsk ~/onedrive/orion-$1_$2/$JIRA.dsk
cp -i ~/onedrive/template_pkg.pck ~/onedrive/orion-$1_$2/ORION$JIRA.pck

echo >> t.sql
echo "git checkout -b feature/ORION-$JIRA && git push --set-upstream origin feature/ORION-$JIRA" >> t.sql
echo >> t.sql
vim t.sql -c ':mksession!'
echo "$JIRA" >> $JIRA.html

cygstart $JIRA.html
cp ~/onedrive/template_project.prj ~/onedrive/orion-$1_$2/$JIRA.prj
cygstart "C:\Users\boheck\OneDrive - SAS\orion-$1_$2\\$JIRA.prj"
