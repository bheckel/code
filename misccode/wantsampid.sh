#!/bin/sh

# Either give it a parm or let SQLPLUS prompt you

(
cd ~/code/misccode
sqlplus sasreport/sasreport@usprd259 @wantsampid $1
)
###echo 'cd $u; sqlplus sasreport/sasreport@usprd259 @do.sql 18830; st do.csv'
echo 'now $ doo 321000 or $ doi 321000'
