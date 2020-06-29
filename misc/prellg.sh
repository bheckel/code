#!/bin/sh
##############################################################################
#     Name: prellg
#
#  Summary: Run during the 1st iteration of limsgist debugging to make sure
#           parameters are as expected.  After that, alias 'runllg' is faster.
#
#           Copies of runllg.asp on servers are temp copies, see ~/code/vb for
#           master.
#
#  Created: Thu 21 Dec 2006 15:42:32 (Bob Heckel)
# Modified: Tue 12 Feb 2008 12:07:40 (Bob Heckel)
##############################################################################

echo 'checking for limsgist currently running flag...'
if [ -e /cygdrive/x/SQL_Loader/LELimsGist.txt ]; then
  echo 'DO NOT PANIC: llg is probably running (LELimsGist.txt exists).  Exiting.'
  echo
  exit 1
else
  echo '...not currently running'
  echo
fi

# Usually -d but anything passed in will do
if [ $1 ];then  # we want something like LELimsGistVENT.sas to run
  echo running DEBUG so
  runllgasp=/cygdrive/x/SAS_Web_Pages/runllg-debug.asp
  # Edit this file for each new product e.g. LELimsGistVENT.sas LGIVENT.log
  runsasbat=/cygdrive/x/SAS_Programs/Run_SASdebug.bat
  ###runw3m="w3m -no-cookie -dump_source 'http://rtpsawn321/links/runllg-debug.asp?action=Run+LLG'|grep '^LLG'"
else  # we want normal LELimsGist.sas to run
  echo running NORMAL so
  runllgasp=/cygdrive/x/SAS_Web_Pages/runllg.asp
  runsasbat=/cygdrive/x/SAS_Programs/Run_SAS.bat
  ###runw3m=w3m -no-cookie -dump_source 'http://rtpsawn321/links/runllg.asp?action=Run+LLG'|grep '^LLG'
fi

echo $runllgasp will run this code:
echo

echo ------------------------
cat $runsasbat
echo
echo ------------------------
echo

ls -FloGg --color=auto /cygdrive/x/SQL_Loader/?e?ims*res01a*.sas7bdat
echo
cat /cygdrive/x/SQL_Loader/LimsGistTableCount.txt
echo
###df -h $x
echo -n 'are the SumRes, IndRes and metadata datasets closed? '
read
echo -n 'limgist run started '
date
# This tells d:\sas_web_pages\runllg.asp to run d:\SAS_Programs\Run_SAS.bat
# (or Run_SASdebug.bat) which then says 'run sas.exe on lelimsgist.sas' and
# put the LGI.log in \SQL_Loader.  Usually a lelimsgistCURRENT.sas would point
# to test sas7bdat indressumres files in sql_loader\
if [ $1 ];then
  w3m -no-cookie -dump_source 'http://rtpsawn321/links/runllg-debug.asp?action=Run+LLG'|grep '^LLG'
else
  w3m -no-cookie -dump_source 'http://rtpsawn321/links/runllg.asp?action=Run+LLG'|grep '^LLG'
fi



# Copies of runllg.asp on servers (sas_web_pages\) are temp copies, see
# ~/code/vb for master.  The below :r is likely obsolete
#################### runllg.asp ##########################
# <%
# 
# Option Explicit
# Dim FileSys
# Dim WShShell
# Dim RetCode
# Dim t
# 
# ' See if the form has been submitted
# '''If Request.QueryString("action")="Run LLG" Then
# If Request("action")="Run LLG" Then
#   Set FileSys = Server.CreateObject("Scripting.FileSystemObject")
#   Set WShShell = Server.CreateObject("WScript.Shell")
#   RetCode = WShShell.Run("d:\sas_programs\Run_SAS.bat",1,true)
#   '''RetCode = WShShell.Run("d:\sas_programs\Run_SASdebug.bat",1,true)
#   t = Time()
#   ' 0 == no err, 2 == SAS warning
#   If RetCode = 0 Or RetCode = 2 Then
#     Response.Write "LLG finished successfully " & t & " " & RetCode
#   Else
#     Response.Write "LLG has errors " & t & " " & RetCode
#   End If
# End if
# %>
# 
# <html>
# <head>
#   <title>Run normal LLG http://rtpsawn321/links/runllg.asp</title>
# </head>
# <body>
#   <form action="runllg.asp" method="GET">
#   <input  name=action type="submit" value="Run LLG">
#   </form>
# </body>
# </html>
#################### runllg.asp ##########################

#################### Run_SAS.bat #########################
# "d:\SAS Institute\SAS\V8\SAS.EXE" -config "d:\SAS institute\SAS\V8\LGI.cfg" -autoexec "d:\SAS_Programs\lelimsgist.sas" -altlog "d:\SQL_Loader\Logs\LGI.log"
#################### Run_SAS.bat #########################
