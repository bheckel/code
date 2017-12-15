
 '*******************************************************************************
 '                       MODULE HEADER
 '------------------------------------------------------------------------------
 '  PROGRAM NAME:     ADO.vbs
 '
 '  CREATED BY:       Bob Heckel (rsh86800)
 '                                                                            
 '  DATE CREATED:     04-Sep-13
 '                                                                            
 '  SAS VERSION:      8.2
 '
 '  PURPOSE:          Extraction of ADO data via DataLink Integrator
 '
 '  INPUT:            Path and system type
 '
 '  PROCESSING:       Run DataLink Integrator to extract data, save output
 '
 '  OUTPUT:           XML file
 '------------------------------------------------------------------------------
 '                     HISTORY OF CHANGE
 '-------------+---------+--------------------+---------------------------------
 '     Date    | Version | Modification By    | Nature of Modification
 '-------------+---------+--------------------+---------------------------------
 '  04-Sep-13  |    1.0  | Bob Heckel         | Original. CCF ?????.
 '-------------+---------+--------------------+---------------------------------
 '******************************************************************************

Option Explicit
On Error Resume Next

Function RunDLI()
  Dim Obj_ADOTrns
  Dim Str_DataLinkDLLInformation
        
  Set Obj_ADOTrns = CreateObject("DataLink.Microsoft.ADO.Net.Adapter.Instance")

  Str_DataLinkDLLInformation = Str_DataLinkDLLInformation & "DataLink.Microsoft.ADO.Net.Adapter.dll v" & Obj_ADOTrns.Version
  ' DEBUG
  '''Call MsgBox(Str_DataLinkDLLInformation,vbInformation,"DataLink Integrator - DLL Version Information")

  Obj_ADOTrns.XMLHeader = "<?xml version=""1.0""?>"
  Obj_ADOTrns.UseFileIO = 1
  Obj_ADOTrns.ConnectionString = Wscript.Arguments(0) & "_ADO_" & Wscript.Arguments(1) & ".con"
  Obj_ADOTrns.SQLQuery = Wscript.Arguments(0) & "_ADO_" & Wscript.Arguments(1) & ".qry"
  Obj_ADOTrns.XMLOutputFileOverwrite = 1
  Obj_ADOTrns.Execute(Wscript.Arguments(0) & "_ADO_" & Wscript.Arguments(1) & ".xml")

  Set Obj_ADOTrns = Nothing
End Function

Function WipeOld()
  Dim strFilespec
  Dim Obj_FSO

  strFilespec = Wscript.Arguments(0) & "_ADO_" & Wscript.Arguments(1) & ".xml"

  Set Obj_FSO = CreateObject("Scripting.FileSystemObject")

  If Obj_FSO.FileExists(strFilespec) Then
    Obj_FSO.DeleteFile strFilespec
  End If
End Function

' DEBUG
'''Call MsgBox("starting")
' Make sure silent failures don't read last run's xml input by accident
Call WipeOld()
Call RunDLI()
' DEBUG
'''Call MsgBox("ending " & Err.Description)

If Err.Number <> 0 Then
  Dim WshError
  Set WshError= CreateObject("WScript.Shell")
  WshError.LogEvent 1, "Error from " & WScript.Fullname & " " & WScript.ScriptFullName & " " & Err.Number & ": " & Err.Description

  ' DEBUG
  Call Msgbox("Error Number: " & Err.Number & VBCRLF & VBCRLF & _
    "Error Description: " & Err.Description , _
    16, _
    "ADO_" & WScript.Arguments(1) & ".vbs: Error launching DataLink Integrator")
End If
