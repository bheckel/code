#!/bin/bash

# TODO how to specify files with spaces beyond -print0 and -0 ?
find /Drugs/Cron -type f -name '*.sas' -o -name '*.sh' -o -name '*.expect' -o -name '*.pl' | xargs tar cfz ~/bkups/backup.Cron.`date +%d%b%y`.tgz
find /Drugs/EGP -type f -name '*.egp' | xargs tar cfz ~/bkups/backup.EGP.`date +%d%b%y`.tgz
# find /Drugs/HealthPlans -type f -name '*.egp' -o -name '*.sas' | xargs tar cfz ~/bkups/backup.HealthPlans`date +%d%b%y`.tgz
find /Drugs/Macros -type f -name '*.sas' | xargs tar cfz ~/bkups/backup.Macros.`date +%d%b%y`.tgz
find /Drugs/Personnel/bob -type f -name '*.sas' -o -name '*.sh' -o -name '*.txt' -o -name 'Session.vim' -o -name '*.log' -o -name '*.lst' -o -name '*.pdf' -o -name '*.sql'| xargs tar cfz ~/bkups/backup.bob.`date +%d%b%y`.tgz
find /Drugs/RFD -type f -name '*.egp' -o -name '*.sas' | xargs tar cfz ~/bkups/backup.RFD.`date +%d%b%y`.tgz

find ~ -maxdepth 1 -type f -name 'template_*' | xargs tar cfz ~/bkups/backup.template.`date +%d%b%y`.tgz
find ~/bin -maxdepth 1 -type f | xargs tar cfz ~/bkups/backup.bin.`date +%d%b%y`.tgz

find ~/bkups -mtime +180|xargs rm -v

###scp ~/backup.bob.`date +%d%b%y`.tgz ~/backup.Macros.`date +%d%b%y`.tgz ~/backup.Cron.`date +%d%b%y`.tgz ~/backup.EGP.`date +%d%b%y`.tgz bheckel@talon3://Drugs/bheckel/
