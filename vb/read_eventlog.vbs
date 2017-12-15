' EventID12.vbs
' VBScript Event Log example to check the Event ID.
' Version 1.9
' Guy Thomas 1st August 2010
' Adapted: Fri 06 Sep 2013 12:55:18 (Bob Heckel)

Option Explicit

Dim objFso, objFolder, objWMI, objEvent ' Objects
Dim strFile, strComputer, strFolder, strFileName, strPath ' Strings
Dim intEvent, intNumberID, intRecordNum, colLoggedEvents

' --------------------------------------------
' Set your variables
intNumberID = 5 ' Event ID Number
intEvent = 1
intRecordNum = 1

strComputer = "."
strFileName = "\Event12.txt"
strFolder = "C:\temp"
strPath = strFolder & strFileName

' ----------------------------------------
' Section to create folder to hold file.
Set objFso = CreateObject("Scripting.FileSystemObject")

If objFSO.FolderExists(strFolder) Then
    Set objFolder = objFSO.GetFolder(strFolder)
Else
   Set objFolder = objFSO.CreateFolder(strFolder)
   Wscript.Echo "Folder created " & strFolder
End If
Set strFile = objFso.CreateTextFile(strPath, True)

'--------------------------------------------
' Next section creates the file to store Events
' Then creates WMI connector to the Logs

Set objWMI = GetObject("winmgmts:" _
& "{impersonationLevel=impersonate}!\\" _
& strComputer & "\root\cimv2")
Set colLoggedEvents = objWMI.ExecQuery _
("Select * from Win32_NTLogEvent Where Logfile = 'Application'" )

Wscript.Echo " Press OK and Wait 30 seconds (ish)"
' -----------------------------------------
' Next section loops through ID properties
intEvent = 1
For Each objEvent in colLoggedEvents
If objEvent.EventCode = intNumberID Then

'strFile.WriteLine ("Record No: ")& intEvent
' strFile.WriteLine ("Category: " & objEvent.Category)
strFile.WriteLine ("Computer Name: " & objEvent.ComputerName)
strFile.WriteLine ("Event Code: " & objEvent.EventCode)
' strFile.WriteLine ("Message: " & objEvent.Message)
' strFile.WriteLine ("Record Number: " & objEvent.RecordNumber)
strFile.WriteLine ("Source Name: " & objEvent.SourceName)
strFile.WriteLine ("Time Written: " & objEvent.TimeWritten)
strFile.WriteLine ("Event Type: " & objEvent.Type)
'strFile.WriteLine ("User: " & objEvent.User)
strFile.WriteLine (" ")
intRecordNum = intRecordNum +1
End if
IntEvent = intEvent +1
Next
Wscript.Echo "Check " & strPath & " for " &intRecordNum & " events"

WScript.Quit

' End of Guy's example VBScript
