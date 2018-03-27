#!/bin/bash

mintty.exe -i /Cygwin-Terminal.ico -p 0,0 -s 149,75 -e ssh -l bheckel sas-01.twa.taeb.com &
mintty.exe -i /Cygwin-Terminal.ico -p 980,0 -s 149,75 -e ssh -l bheckel sas-01.twa.taeb.com &
mintty.exe -i /Cygwin-Terminal.ico -p 2000,0 -w max -e ssh -l bheckel sas-01.twa.taeb.com &
