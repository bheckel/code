#!/bin/bash

# ln -s ~/code/misccode/jira.sh ~/bin
# jira.sh 33479 existingcust_flaginout

mkdir -p ~/onedrive/orion-$1_$2
cp -i ~/onedrive/template_t.sql ~/onedrive/orion-$1_$2/t.sql
cp -i ~/onedrive/template_project.prj ~/onedrive/orion-$1_$2/$1.prj
cp -i ~/onedrive/template_project.dsk ~/onedrive/orion-$1_$2/$1.dsk
cd ~/onedrive/orion-$1_$2 && vim t.sql -c ':mksession!'
