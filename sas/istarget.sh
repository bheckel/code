#!/bin/bash

(cd /tmp && /sas/sashome/SASFoundation/9.4/sas ~/bin/istarget.sas)

less /tmp/istarget.lst
 rm /tmp/istarget.log /tmp/istarget.lst
