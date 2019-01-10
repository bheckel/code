##############################################################################
gsk catalog search
Oracle Other Admin
##############################################################################

##############################################################################
# Check tnsnames.ora network problem:
$ cd $u/gsk && sqlplus -S sasreport/sasreport@usprd259 @donothing;

##############################################################################
03-Oct-12
USIM10007999544 restart CDE xdmcp exceed has to be done by root
##############################################################################

##############################################################################
# Which lims processes are throttling the box:
ssh rtpsh005 UNIX95= ps -eo user,pid,pcpu,comm | sort -nrbk3 | head -20; echo
##############################################################################

##############################################################################
vi scp://rsh86800@rtpsh005//opt/QCServer/A.05.00/svr/files/Inspec_Results-0511.log  # resends
vi scp://rsh86800@rtpsh005//opt/QCServer/A.05.00/svr/files/Error.log  # sai mapping
##############################################################################

##############################################################################
idoc SAP: we02, enter date ranges, find IDoc number, drill Inbound IDocs YQMPLANIN
##############################################################################

##############################################################################
ushpam may need to use 143.193.73.108 when DNS is borked
##############################################################################

##############################################################################
USIM10005535626
2011-02-04
easiest is to control client, map \\zebwl10d43164\share, explorer copy it to system32, DOS c:\WINDOWS\system32\regsvr32.exe c:\WINDOWS\system32\MSRDO20.DLL


\\rtpsawnv0111\Wireless\CHEM LMS FIX

14:00Caleb Owenxcopy "\\rtpdsntp015\CP_Desktop_Support\TECHS (file://rtpdsntp015/CP_Desktop_Support/TECHS) Folder\Caleb_Owen\1 - Software Installs\Fixes\CHEM LMS FIX\MSRDO20.DLL" "c:\WINDOWS\system32"
c:\WINDOWS\system32\regsvr32.exe c:\WINDOWS\system32\MSRDO20.DLL

those two commands I run.  (copy, then register the file
if you cant figure it out, send it our way... 
##############################################################################

##############################################################################
$ XWin.exe -query rtpsh005
$ XWin.exe -query rtpsh004
##############################################################################

##############################################################################
Wanda resolving agency
GMS-LABAPPS-SUPPORT-ZEB
Unix
SDCS-UNIX-SVROPS
##############################################################################


xcopy "\\rtpdsntp015\CP_Desktop_Support\TECHS Folder\Caleb_Owen\1 - Software Installs\Fixes\CHEM LMS FIX\MSRDO20.DLL" "c:\WINDOWS\system32"
c:\WINDOWS\system32\regsvr32.exe c:\WINDOWS\system32\MSRDO20.DLL


##############################################################################
# Twice monthly reboot restart @ 16:45 1st & 15th
su - pdba
ps -ef | grep daemonUCP
kill <PID> <PID> (or just the su -c parent)
/home/pdba/Scripts/start_daemonUCP.sh
# Want to see:
# pdba 4543 4541 0 Aug 1 ? 1:31 /opt/ChemLMS/A.05.00/bin/daemonUCP -username pdba: -dbname USPR
ps -ef | grep daemonUCP
##############################################################################

##############################################################################
# EOM archive scripts @ 23:59 last day of mo.
ssh rtpsh005
super chemlms-shell  # visudhi8
# Do on the day before reboot in the afternoon:
# Edit ~chemlms/eom_arch.sh for the last day of month 28, 29, 30 or 31.
vi ~chemlms/eom_arch.sh
nohup eom_arch.sh&
<CR>
<C-D>
<C-D>
<C-D>
# 'You have running jobs warning' is ok
# Confirm as rsh86800:
ps -ef|grep eom

# Confirm next day as chemlms:
ssh rtpsh005
super chemlms-shell
ls -lt /home/gaaadmin/GAAAdapter/gaa/send/Control_Processed/InspectionPlan/Archived/
ls -lt /home/gaaadmin/GAAAdapter/gaa/send/Control_Processed/InspectionResults/Archived/
ls -lt /home/gaaadmin/GAAAdapter/gaa/send/Data_Input/InspectionPlan/Archived/
ls -lt /home/gaaadmin/GAAAdapter/gaa/send/Data_Input/InspectionResults/Archived/
ls -lt /home/gaaadmin/GAAAdapter/gaa/receive/Output_Control/Archived/
ls -lt /home/gaaadmin/GAAAdapter/gaa/receive/Output_Data_Processed/Archived/
##############################################################################

##############################################################################
# Resend tickets:
# With Exceed running 005 passive from Cygwin:
ssh rtpsh005
./dd
# Paste the DISPLAY line that appears
e.g. export DISPLAY=143.193.14.202:0.0 && ./ee
# In the resulting xterm
super chemlms-shell 
menuUCP

pdba pdbaon05

# Paste in:
runmacro '/home/chemlms/Scripts/send_result.mcx'

./zm2 40032343-0zp3243-01
# paste reformatted output to input box

##############################################################################

##############################################################################
Zebra
$ super chemlms-shell
$ lpstat
$ disable MPS_MDPI20_PCL  # usually already down
# wait 30 sec
$ enable MPS_MDPI20_PCL
##############################################################################

##############################################################################
Successful automated result send:

$ vscp 'rsh86800@rtpsh005:/opt/QCServer/A.05.00/svr/files/Inspec_Results-0610.log' to see:
  23jun10-08:11:35 Results sent for 0ZM5211-040000773030-01

Results control file (80 bytes) rtpsh005\home\gaaadmin\GAAAdapter\gaa\send\Control_Processed\InspectionResults\Data-23jun10-08:11:35.txt
  InspectionResults,1,LIVE,EANCM5051150005235,,DAILY,Results-23jun10-08:11:35,Y,N

Results data file pipe delim    rtpsh005\home\gaaadmin\GAAAdapter\gaa\send\Data_Input\InspectionResults\Data-23jun10-08:11:35.txt
  %s/@TEST@//g  to see what was sent to SAP
  ...
  | L1008678 | Pass |  |  | @OPERATOR@ | Conforms       | @OPERATOR@ |  | @COMPONENT@ | MICRON5PARTICLESCHECK           |        |  |    |       |    |       | @QUALITATIVE@ | COMPLIES | @QUANTITATIVE@ |       | 
  | L1008612 | Pass |  |  | @OPERATOR@ |                | @OPERATOR@ |  | @COMPONENT@ | RATIOMIN                        |        |  | >= | 4.0   |    |       | @QUALITATIVE@ |          | @QUANTITATIVE@ | 6.3   | 
  | L1008614 | Pass |  |  | @OPERATOR@ |                | @OPERATOR@ |  | @COMPONENT@ | INDIVIDUALSFP80120              |        |  | >= | 18    |    |       | @QUALITATIVE@ |          | @QUANTITATIVE@ | 20    | 
  ...
##############################################################################

########
SAP Logon keypad 710
Client 700
SAP 008 - P02 [MERPS Production]
qe03
enter insplot with leading 0
0010
########

########
vscp 'rsh86800@rtpsh005:/opt/QCServer/A.05.00/svr/files/Inspec_Results-0410.log'
vscp 'rsh86800@rtpsh005:/opt/QCServer/A.05.00/svr/files/Inspec_Spec-0610.log'
vscp 'rsh86800@rtpsh005:/opt/QCServer/A.05.00/svr/files/Inspec_Lot-0610.log'
vscp 'rsh86800@rtpsh005:/var/opt/ChemLMS/log/log.ERRORS'
vi scp://rsh86800@rtpsh005//var/opt/ChemLMS/log/log.ERRORS  # system failures
vi scp://rsh86800@rtpsh005//opt/QCServer/A.05.00/svr/files/Error.log  # Darrell
########

########
Count users
ssh rtpsh005 ps -ef | grep lms_client*|wc
########

########
User password change: AdminClient Alt-P
########

########
Oracle 8 ODBC driver config Windows cmd
odbcad32

Use the "Zebulon" one:
00142253    ChemLMS QC Client - replaced by 144169 
########

##############################################################################
Misc unused
su - pdba -c 'commandUCP -dbname techops -username pdba: <<!! -macro /opt/QCServer/A.05.00/svr/macros/Utilities/MERPS/mLIMS_Inspec_Results.mcx bye'
activateuser "wml9432","New job function"
deactivateuser "wml9432","New job function"
lpstat -oMPS_MDPI23_PCL
##############################################################################



##############################################################################
2010-12-06 Also see QA51540

---
Coy and all,
Your LIMS "unusual error message" has been eradicted (cool word, huh!).  You should be good to go.

In SOP QA5140, pg 6 - there is a SpecManager step that must be performed on all users (copy QCCLIENT{STD,PDBA} to QCCLIENT{STD,PatronID}).  This had not been done for Coy.  So, the error message is telling you exactly what is wrong - that it can't find the macro in the user's library.

It would be great to see if Bob Heckel has the "power" in Exceed to do what I do - so we have a backup.  Either that or we need to get someone else in QA BSSS the access (it is quite painful to get this access as I remember - your request goes across the pond and gets bounced around a bit, and it was a long time ago when I got access so I am not sure of the process now!).


From: Robert Heckel 
Sent: Thursday, December 02, 2010 1:05 PM
To: Julie Bass
Cc: Patrick Williams; Crystal Coleman
Subject: RE: LIMS Error Messages

Hi Julie,

Trying to figure out an unusual error message.  Do you recall getting any errors when adding new LIMS user ck9450 (or kp835313 or spb38030) recently?

Thanks.

Bob

From: Patrick Williams 
Sent: Thursday, December 02, 2010 12:58
To: Robert Heckel
Subject: FW: LIMS Error Messages



Patrick Williams
GMS IT Systems Analyst
patrick.c.williams@gsk.com
Internal: 707 6876
External: 919 404 6876

From: Coy Kirby 
Sent: Thursday, December 02, 2010 9:43 AM
To: Patrick Williams
Subject: LIMS Error Messages

I get this one when I click on the LIMS icon:

                ---------------------------
Main Control Program
---------------------------
Evaluate error: 

ChemLMS CP Error: # 25300130 : The macro 'QCCLIENT{STD,CK9450}' cannot be found in the database.
---------------------------
OK   
---------------------------

Then this one when I click the above OK  button:

                ---------------------------
Main Control Program
---------------------------
Error starting the user's AutoStart macro
---------------------------
OK   
---------------------------

And the LIMS screen when I click the above OK button. 

                
---



---
When I could get in, this is how I did it...

$menuUCP
At the login panel, pdba - helpme33 - click OK.
You should be in the QC Client Server - PDBA menu
type specmanager in the command line
type qcclient{STD,pdba} in the Spec Selection box, hit Enter
Move the selection to the right via Insert button
Choose Actions/Copy from the word menu
Click on Appy
Type QCCLIENT in the Name box
Change the Library to the users MUDID
Click Apply
Click Clear to clear out the right side of the box
type qcclient{STD,MUDID} in the Spec Selection box, hit Enter
Move the selection to the right via Insert button
Choose RevisionMgmt/Approve
Whatever comes next, I think you can handle.

You will have to repeat this for all 6 MUDIDs.

If you need help or need me to come down there, I don't mind. Hate I can't do it on dev. Probably can't do it on test too!

Julie R. Bass
Group Mailbox = ZEB APPS-SUPPORT
Z01-E202F
919-269-1622
ZEB APPS-SUPPORT cell phone: 919-302-8231
 Robert S Heckel/Complementary/GMS

Robert S Heckel/Complementary/GMS 
16-Jul-2009 08:16	GMS-ITSYSTEMS-ZEB 919-404-6869 (x76869) 
 
To	 
Julie R Bass/GMS/GSK@GSK
 
cc	 
 
Subject	 
Re: 6 Users in ushpam - hit a snag 
 
 

Yes I can access it (as pdba) - want to tell me how to do it and I'll run the 6 users?

 Julie R Bass/GMS

Julie R Bass/GMS 
15-Jul-2009 20:15	Quality Control Z01-E202F 269-1622 
 
To	 
Robert S Heckel/Complementary/GMS/GSK@GSK
 
cc	 
 
Subject	 
6 Users in ushpam - hit a snag
 
 

I got the users started. There is one part of the configuration where I need to go into Exceed to copy QCCLIENT{STD,PDBA} and create QCCLIENT{STD,ms747707}, etc. for each of the users. I use specmanager to do this.

I tried getting into Exceed using jb9559. I had to set a new password. When I try to open a terminal, at the $ I usually type the following:
$super chemlms-shell

This then prompts me for my password and then I can type $menuUCP and get it.

I cannot do this in ushpam. When I type $super chemlms-shell, it says permission denied.

First, can you access specmanager down in Exceed? If not, who do I contact to get permissions?

Julie R. Bass
Group Mailbox = ZEB APPS-SUPPORT
Z01-E202F
919-269-1622
ZEB APPS-SUPPORT cell phone: 919-302-8231
---
##############################################################################


##############################################################################
Barebones start LIMS (assumes db running)
kill [lms_nmgr PID]
# if there is a cachefile in /opt/ChemLMS/A.05.00/db/cache/
#                ---------$LMS_HOME--
su - chemlms -c '/opt/ChemLMS/A.05.00/bin/rmcache USDEV259'
su - chemlms -c '/opt/ChemLMS/A.05.00/bin/lms_nmgr'  # network mgr
su - pdba -c 'commandUCP -dbname $ORACLE_SID -username pdba: -macro Utilities/mStartup.mcx'  # "servers"
##############################################################################


##############################################################################
cat ~rsh86800/dd:

#!/bin/ksh

if [ ! "$DT" ] ; then
  # Set up the terminal:
  if [ "$TERM" = "" ]
    then
      eval ` tset -s -Q -m ':?hp' `
    else
      eval ` tset -s -Q `
  fi

  stty erase "^H" kill "^U" intr "^C" eof "^D"
  stty hupcl ixon ixoff
  tabs


  # Set DISPLAY
  Thistty=`tty | sed 's:^/dev/::'`
  dis=`
    who -u |
    awk -v Thistty=$Thistty '$2 == Thistty {print $8}' |
    sed 's/:.*$//'
  `

  if [ -z "$dis" ]; then
    unset DISPLAY
  else
    export DISPLAY=$dis":0.0"
  fi

  # Run this by hand
  echo "export DISPLAY=$DISPLAY && ./ee"
fi
##############################################################################

Paths
/var/opt/ChemLMS/log
/usr/bin/X11/xterm
/home/gaaadmin/GAAAdapter/gaa/receive/Output_Data  # clogs if daemonUCP down
/sbin/rc*
/oracle/app/oracle/product/8.0.6/bin
/oracle/dba/dba_ora  (${ORADBA_HOME})
/oracle/dba/dba_ora/syslog
/etc/oratab
/sbin/init.d/chemlms
/var/adm/scripts/shutlims.sh
/sbin/init.d/dbora
/oracle/app/oracle/product/8.0.6/bin/tnsping0 ustst259  # as chemlms
/oracle/app/oracle/product/9208HP64DB1_PAR/bin/tnsping ustst259  # as chemlms
/opt/ChemLMS/A.05.00/bin/rmcache
/opt/ChemLMS/A.05.00/db/cache
/opt/QCServer/A.05.00/svr/files/Inspec_Spec-0709.log # julie IDoc error retries
/opt/QCServer/A.05.00/svr/macros/Utilities/  # mcx
/home/gaaadmin/GAAAdapter/gaa/logs

$ cat /home/gaaadmin/GAAAdapter/gaa/send/Data_Input/InspectionResults/Data-05may09-09:26:57.txt

ls -lt /home/gaaadmin/GAAAdapter/gaa/send/Control_Processed/InspectionPlan/Archived/  # if archive_files.sh and Compress_tars.sh works
ls -lt /home/gaaadmin/GAAAdapter/gaa/send/Control_Processed/InspectionResults/Archived/  # if archive_files.sh and Compress_tars.sh works
ls -lt /home/gaaadmin/GAAAdapter/gaa/send/Data_Input/InspectionPlan/Archived/  # if archive_files.sh and Compress_tars.sh works
ls -lt /home/gaaadmin/GAAAdapter/gaa/send/Data_Input/InspectionResults/Archived/  # if archive_files.sh and Compress_tars.sh works
ls -lt /home/gaaadmin/GAAAdapter/gaa/receive/Output_Control/Archived/  # if archive_files.sh and Compress_tars.sh works
ls -lt /home/gaaadmin/GAAAdapter/gaa/receive/Output_Data_Processed/Archived/  # if archive_files.sh and Compress_tars.sh works


vscp 'rsh86800@rtpsh005:/opt/QCServer/A.05.00/svr/files/Error.log'
vscp 'rsh86800@rtpsh005:/opt/QCServer/A.05.00/svr/files/Inspec_Results-0410.log'
vscp 'rsh86800@rtpsh005:/opt/QCServer/A.05.00/svr/files/Inspec_Results-0510.log'
vscp 'rsh86800@rtpsh005:/opt/QCServer/A.05.00/svr/files/Inspec_Results-0610.log'
vscp 'rsh86800@rtpsh005:/var/opt/ChemLMS/log/log.ERRORS'

\\rtpdsntp018\apps\LIMS
\\us3n73\Apps\LIMS


##############################################################################
QUERIES LIMS SASREPORT:
======================
-- want sampid for a study or batch:
$ sqlplus asreport/asreport@usprd259
select distinct sampid, sampname from result where sampname like 'SC10/0632%' order by sampname;
select distinct sampid, sampname from result where sampname = '8ZM9406-040000581383-01' order by sampname;
-- same, prompted
select distinct sampid, sampname from result where sampname like '&bchinspl' order by sampname;
select distinct sampid, sampname from result where sampname like '8ZM9406%' order by sampname;

-- want sampname given a sampid:
select distinct sampid, sampname from result where sampid = 154818 order by sampid;

-- products in LIMS
SELECT DISTINCT R.ResStrVal FROM Result R, Var V WHERE R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODCODEDESC$' ORDER BY R.ResStrVal;

-- Does this product exist in LIMS?
SELECT DISTINCT R.ResStrVal FROM Result R, Var V WHERE upper(R.ResStrVal) like '%RELEN%' and R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODCODEDESC$';

-- sampids for a product
SELECT DISTINCT R.SampId FROM Result R, Var V WHERE R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODCODEDESC$' AND upper(R.ResStrVal) like '%VENTOLIN%';

-- All approved samples for a product
select distinct ss.sampid, ss.sampname, ss.sampstatus
from samplestat ss
where sampid in (select distinct gw.sampid 
                 from gwproddesc gw
                 where upper(gw.prodcodedesc) like 'RELENZ%') and ss.sampstatus = 17

-- sampids for specific material code
SELECT DISTINCT R.Sampname, r.sampcreatets FROM Result R, Var V WHERE R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODUCTCODE$' AND upper(R.ResStrVal) = '4104501';

-- material product codes for a product (usually won't get everything)
SELECT distinct R.resstrval FROM Result R, Var V WHERE upper(R.ResStrVal) LIKE '%SERETIDE%' AND R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODUCTCODE$'

-- material product codes for a sample (faster)
select distinct prodcodedesc from gwproddesc where sampid=201962;

-- methods for a product
select distinct s.specname, s.dispname 
from result r, spec s
where r.specrevid=s.specrevid and r.sampid in(SELECT DISTINCT r.sampid FROM Result R, Var V 
                                              WHERE (upper(R.ResStrVal) like '%RELENZA%') and 
                                                    R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODCODEDESC$')

select count(*) from samplestat where EntryTs >= TO_DATE('01-FEB-05 00:00:00','DD-MON-YY HH24:MI:SS') and EntryTs <= TO_DATE('31-FEB-05 00:00:00','DD-MON-YY HH24:MI:SS')

select approved_dt from samp where samp_id=191173

-- Find almost done samples for a AHFA 60 dose
select s.sampid, s.sampstatus
from samplestat s
where sampid in (SELECT distinct r.sampid FROM Result R, Var V WHERE R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODCODEDESC$' AND upper(R.ResStrVal) like '%60ACTN%') AND s.sampstatus > 15

-- Min max available data dates for a product
select distinct min(r.sampcreatets), max(r.sampcreatets)
from result r, spec s
where r.specrevid=s.specrevid and r.sampid in(SELECT DISTINCT r.sampid FROM Result R, Var V
                                              WHERE (upper(R.ResStrVal) like '%LOVAZA%') and
                                                    R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODCODEDESC$')

-- Min max available data dates for a product by method
select distinct s.specname, min(r.sampcreatets), max(r.sampcreatets)
from result r, spec s
where r.specrevid=s.specrevid and r.sampid in(SELECT DISTINCT r.sampid FROM Result R, Var V
                                              WHERE (upper(R.ResStrVal) like '%LOVAZA%') and
                                                    R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODCODEDESC$')
group by s.specname

-- All products for a method (messy):
select distinct s.specname, s.dispname, r.resstrval
from result r, spec s, var v
where r.specrevid=s.specrevid and V.Name='PRODCODEDESC$' and specname = 'AM0612CUHPLC' and r.resstrval like '\\%

-- All batches for a method (messy):
select distinct s.specname, s.dispname, r.resstrval
from result r, spec s, var v
where r.specrevid=s.specrevid and V.Name='PRODCODEDESC$' and specname = 'AM0612CUHPLC' and r.resstrval like '%Z%

-- All results for a product and method:
select distinct s.specname, s.dispname, r.resstrval
from result r, spec s
where r.specrevid=s.specrevid and r.sampid in(SELECT DISTINCT r.sampid FROM Result R, Var V
                                              WHERE (upper(R.ResStrVal) like '%VALTREX%') and
                                                    R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODCODEDESC$'
                                              )
      and specname = 'AM0612CUHPLC'

##############################################################################
Single sample queries:

"sumres"

SELECT DISTINCT
  R.SampId,
  R.SampName,
  R.ResStrVal,
  R.SampCreateTS,
  S.SpecName,
  S.DispName,
  V.Name,
  V.DispName as DispName2,
  SS.SampStatus,
  PLS.ProcStatus
FROM
  ProcLoopStat PLS,
  Result R,
  SampleStat SS,
  Var V,
  Spec S
WHERE R.SampId IN (396292)
  AND R.SpecRevId = S.SpecRevId
  AND R.SpecRevId = V.SpecRevId
  AND R.VarId = V.VarId
  AND R.SampId = SS.SampId
  AND R.SampId = PLS.SampId
  AND R.ProcLoopId = PLS.ProcLoopId
  AND SS.CurrAuditFlag = 1
  AND SS.CurrCycleFlag = 1
  AND SS.SampStatus <> 20
  AND PLS.ProcStatus >= 16
  AND ((V.TYPE  = 'T' AND R.ResReplicateIx <> 0)  OR  (V.TYPE <> 'T' AND R.ResReplicateIx =  0)) 
  AND  R.ResSpecialResultType <> 'C'
  ORDER BY sampname, specname, name


"indres"

SELECT DISTINCT
  R.SampId,
  R.SampName,
  R.SampCreateTS,
  R.ResLoopIx,
  R.ResRepeatIx,
  R.ResReplicateIx,
  S.SpecName,
  S.DispName,
  V.Name,
  E.RowIx,
  E.ColumnIx,
  E.ElemStrVal,
  VC.ColName,
  SS.SampStatus,
  PLS.ProcStatus
FROM
  Element E,
  Result R,
  ProcLoopStat PLS,
  SampleStat SS,
  Var V,
  VarCol VC,
  Spec S
WHERE R.SampId IN (390037)
  AND R.SpecRevId = V.SpecRevId
  AND R.VarId = V.VarId
  AND R.ResId = E.ResId
  AND VC.ColNum = E.ColumnIx
  AND R.SpecRevId = VC.SpecRevId
  AND R.VarId = VC.TableVarId
  AND R.SampId = PLS.SampId
  AND R.ProcLoopId = PLS.ProcLoopId
  AND R.SampId = SS.SampId
  AND R.SpecRevId = S.SpecRevId
  AND SS.CurrAuditFlag = 1
  AND SS.CurrCycleFlag = 1
  AND SS.SampStatus <> 20
  AND PLS.ProcStatus >= 16
  AND ((V.TYPE =  'T' AND R.ResReplicateIx <> 0) OR (V.TYPE <> 'T' AND R.ResReplicateIx = 0))
  AND R.ResSpecialResultType <> 'C'
  AND v.name != 'SYSTEMSUITABILITYTBL'
  ORDER BY sampname, specname, name, colname


---

SAS

%macro m(prd, matnum);
  proc sql;
    CONNECT TO ORACLE AS myoralims (USER=asreport ORAPW=asreport PATH=usprd259);

    SELECT * FROM CONNECTION TO myoralims (
      SELECT count(R.SampId) as &prd
      FROM ProcLoopStat PLS, Result R, SampleStat SS, Var V, Spec S
      WHERE R.SampId IN (SELECT R.SampId
                         FROM Result R, Var V
                         WHERE R.ResStrVal in (&matnum)
                         AND R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODUCTCODE$')
        AND R.SampCreateTS > sysdate-1080
        AND R.SpecRevId = S.SpecRevId
        AND R.SpecRevId = V.SpecRevId
        AND R.VarId = V.VarId
        AND R.SampId = SS.SampId
        AND R.SampId = PLS.SampId
        AND R.ProcLoopId = PLS.ProcLoopId
        AND SS.CurrAuditFlag = 1
        AND SS.CurrCycleFlag = 1
        AND SS.SampStatus <> 20
        AND PLS.ProcStatus >= 16
        AND ((V.TYPE  = 'T' AND R.ResReplicateIx <> 0)  OR  (V.TYPE <> 'T' AND R.ResReplicateIx =  0))
        AND  R.ResSpecialResultType <> 'C'
    );

    DISCONNECT FROM myoralims;
  quit;
%mend;
/***%m(avandamet, %str('10000000047840'));***/
%m(avandaryl, %str('10000000017466','10000000064097','10000000017467','10000000017468','10000000064171','10000000064098','10000000017468','10000000064099', '10000000017501','10000000024705'));
%m(zyban, %str('4146344'));

---

- Search users full name
SELECT us_uid, us_nm, us_lnnm, us_cplv, gp_gid_ow, us_cpac, us_sumcpac, us_crts, us_uid_cr, usau_aucm, us_tblspc
FROM chemlms.usau
where us_lnnm like 'Ma%'
