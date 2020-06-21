<%
' Run limsgist on the server.  Assumes this file exists in x:/sas_web_pages or 
' \\opsawn557\unit_test_files\
' (accessible via http://tpsawn321/links/runllg.asp?action=Run+LLG or
'  $ w3m -no-cookie -dump_head 'http://opsawn557/sas%20validation/runllg.asp?action=Run+LLG') and
' that Run_SAS.bat exists and looks something like this: 
' "d:\SAS Institute\SAS\V8\SAS.EXE" -config "d:\SAS institute\SAS\V8\LGI.cfg" -autoexec "d:\SAS_Programs\lelimsgist.sas" -altlog "d:\SQL_Loader\Logs\LGI.log" 
'
' Bob Heckel 2007-04-27 

Option Explicit
Dim FileSys
Dim WShShell
Dim RetCode
Dim t

' See if the form has been submitted
'''If Request.QueryString("action")="Run LLG" Then
If Request("action")="Run LLG" Then
  Set FileSys = Server.CreateObject("Scripting.FileSystemObject")
  Set WShShell = Server.CreateObject("WScript.Shell")
  '''RetCode = WShShell.Run("d:\sas_programs\Run_SAS.bat",1,true)
  RetCode = WShShell.Run("d:\sas_programs\Run_SASdebug.bat",1,true)
  t = Time()
  ' 0 == no err, 2 == SAS warning
  If RetCode = 0 Or RetCode = 2 Then
    Response.Write "LLG finished successfully " & t & " " & RetCode
  Else
    Response.Write "LLG has errors " & t & " " & RetCode
  End If
End if
%>

<html>
<head>
  <title>Run LLG http://tpsawn321/links/runllg.asp</title>
</head>
<body>
  <form action="runllg.asp" method="GET">
  <input  name=action type="submit" value="Run LLG">
  </form>
</body>
</html>
