#!/bin/bash

echo deprecated - see ~/bin/gsk
exit

# Bob Heckel 2010-03-09 

# Compare with %:t.baseline

############## TNS ################
# wl 166.71.56.4 parsxdmc003.corpnet1.com 2010-03-10 
# wd 199.28.73.10 clisxdmc001.corpnet1.com 2010-03-10 
ping wmservice

ls -l //Wmservice/enterprise/INFRA/APPS/ORACLE/NETWORK/ADMIN/Tnsnames.ora

echo 'tns'
tnsping usprd259; echo

echo 'tns long'; echo
tnsping '(ADDRESS=(COMMUNITY=TCPCOM)(PROTOCOL=TCP)(HOST=rtpsh005.corpnet2.com)(PORT=1521))'


############## Network ################
ipconfig /all; echo

echo 'lims prod short'
ping rtpsh005; echo
echo 'lims prod long'
ping rtpsh005.corpnet2.com; echo
echo 'lims prod raw IP'
ping 143.193.6.5; echo

###echo 'Primary Dns Suffix'
###ping us1auth.corpnet1.com; echo

###tracert us1auth.corpnet1.com; echo

###echo 'default gateway'
###ping zebndsenad1a1-vi-2014.corpnet2.com; echo

###echo 'dns.100->dmc002'
###ping zebsxdmc002.corpnet1.com; echo

###echo 'dns.101->dmc003'
###ping zebsxdmc003.corpnet1.com; echo

###echo 'primary WINS'
###ping rtpsxdw001.corpnet1.com; echo

###echo 'secondary WINS'
###ping KOPSXDW02.corpnet1.com; echo

###echo 'DHCP'
###ping rtpsxdw001.corpnet1.com; echo


############## Load ################
cat <<HEREDOC1
normal:
  2:50pm  up 3 days, 21:12,  0 users,  load average: 0.01, 0.05, 0.09
current:
HEREDOC1

ssh rtpsh005 uptime; echo

cat <<HEREDOC2
normal:
Average       11       0       2      86
current:
HEREDOC2

ssh rtpsh005 sar -u 10 3; echo


############## Memory ################
cat <<HEREDOC3
normal:
         procs           memory                   page                              faults       cpu
    r     b     w      avm    free   re   at    pi   po    fr   de    sr     in     sy    cs  us sy id
    1     0     0   285470  264869   60   14     0    0     0    0     0   1935  92569   564  13  4 83
    1     0     0   274412  264754   46   18     0    0     0    0     0   1142   5033   270   0  1 99
    1     0     0   274412  264754  115    7     0    0     0    0     0   1054   3645   229   2  0 98
current:
HEREDOC3

ssh rtpsh005 vmstat 5 3; echo


############## Users ################
ssh rtpsh005 UNIX95= ps -eo user,pid,pcpu,comm | sort -nrbk3 | head -20; echo

echo -n 'count of lims users: '
ssh rtpsh005 ps -ef | grep lms_client*|wc


############## App ################
echo
echo "rtpsh005 should be 1: "
ssh rtpsh005 ps -ae | grep lms_nmgr
echo
echo "rtpsh005 should be 3: "
ssh rtpsh005 ps -ae | grep java
echo
echo "rtpsh005 should be 2: "
ssh rtpsh005 ps -ef | grep lms_eval*
echo
echo "rtpsh005 should be 2: "
ssh rtpsh005 ps -ef | grep lms_schd*
echo
echo "rtpsh005 should be 4: "
ssh rtpsh005 ps -ef | grep lms_qucp*
echo
echo "rtpsh005 should be 1: "
ssh rtpsh005 ps -ef | grep lms_lmck*
echo
echo "rtpsh005 should be 1: "
ssh rtpsh005 ps -ef | grep daemonUCP*
echo


############## DB Login Speed ################
echo 'DB login test'
(cd $HOME/code/misccode/
echo "$fg_cyan"
date
echo "$normal"
sqlplus sasreport/sasreport@usprd259 @donothing
echo "$fg_cyan"
date
echo "$normal"
)


############## Filesystem ################
ssh rtpsh005 bdf
echo


############## Error files ################
echo "$fg_cyan ------------------------------------------------------------------------$normal"
echo 'Checking LIMS Result errors...'
ssh rtpsh005 find /home/gaaadmin/GAAAdapter/gaa/logs -name 'InspectionRes*error*' -mtime -7 -a -size +0 
echo

echo "$fg_cyan ------------------------------------------------------------------------$normal"
echo 'Checking LIMS /opt/QCServer/A.05.00/svr/files/Error.log for changes in last 3 days...'
ssh rtpsh005 find /opt/QCServer/A.05.00/svr/files -name 'Error.log' -mtime -3 -a -size +0 
echo

echo "$fg_cyan ------------------------------------------------------------------------$normal"
echo 'Checking LIMS /var/opt/ChemLMS/log/log.ERROR for changes in last 3 days...'
ssh rtpsh005 find /var/opt/ChemLMS/log/ -name 'log.ERROR' -mtime -3 -a -size +0
echo


############## MERPS ################
echo "$fg_cyan ------------------------------------------------------------------------$normal"
echo 'Checking LIMS /home/gaaadmin/GAAAdapter/gaa/send/Control_Input/ last modified times...'
ssh rtpsh005 ls -l /home/gaaadmin/GAAAdapter/gaa/send/Control_Input/
echo

echo "$fg_cyan ------------------------------------------------------------------------$normal"
echo 'Checking if LIMS /home/gaaadmin/GAAAdapter/gaa/send/Control_Input/InspectionPlan/ is clogged (s/b empty)...'
ssh rtpsh005 ls -l /home/gaaadmin/GAAAdapter/gaa/send/Control_Input/InspectionPlan/
echo

echo "$fg_cyan ------------------------------------------------------------------------$normal"
echo 'Checking if LIMS /home/gaaadmin/GAAAdapter/gaa/send/Control_Input/InspectionResults/ is clogged (s/b empty)...'
ssh rtpsh005 ls -l /home/gaaadmin/GAAAdapter/gaa/send/Control_Input/InspectionResults/
echo

echo "$fg_cyan ------------------------------------------------------------------------$normal"
echo 'Checking if LIMS /home/gaaadmin/GAAAdapter/gaa/receive/Output_Data/ (daemonUCP) is clogged...'
ssh rtpsh005 ls -l /home/gaaadmin/GAAAdapter/gaa/receive/Output_Data/
echo

