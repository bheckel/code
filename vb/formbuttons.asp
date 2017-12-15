<%
' Call a BAT file (that runs SAS) from ASP
' Adapted from r:\Unit_Test_Files\batchUTC_1.asp

Option Explicit
Dim FileSys
Dim WShShell
Dim RetCode

' See if the form has been submitted:

If Request.Form("action")="Run Batch" Then
  Set FileSys = Server.CreateObject("Scripting.FileSystemObject")
  Set WShShell = Server.CreateObject("WScript.Shell")

  RetCode = WShShell.Run("d:\unit_test_files\testUTC_1.bat",1,true)

  if RetCode = 0 Then
    Response.Write "Batch Program Finished "
  else
    Response.Write "Batch Program has Errors "
  end if
End If

If Request.Form("action")="Delete LELIMSGist.txt" Then
  Set FileSys = Server.CreateObject("Scripting.FileSystemObject")
  Set WShShell = Server.CreateObject("WScript.Shell")

  ' The .bat holds this:
  ' "d:\SAS Institute\SAS\V8\SAS.EXE" -config "d:\SAS institute\SAS\V8\LGI.cfg" -autoexec "d:\unit_test_files\testlaunch_1.sas" -altlog "d:\unit_test_files\UTC_1.log" -altprint "d:\unit_test_files\UTC_1.lst"
  RetCode = WShShell.Run("d:\unit_test_files\del_LELIMSGist.bat",1,true)
  
  if RetCode = 0 Then
    Response.Write "LELimsGist.txt has been deleted "
  else
    Response.Write "Batch Program has Errors "
  end if
End if
%>

<html>
<head>
  <title>Links Batch Run Page</title>
</head>
<!-- <FORM action="batchUTC_1.asp" method="POST"> -->
<FORM action="formbuttons.asp" method="POST">
<body>
  <p align="center"><font size="6" face="Times New Roman">Links UTC Run Page</font></p>
  <p align="center"><font face="Times New Roman" size="5">LINKS Test Area 1</font></p>
  <p><Input  name=action type="submit" value="Run Batch"></p>
  <p><Input  name=action type="submit" value="Delete LELIMSGist.txt"></p>
</body>
