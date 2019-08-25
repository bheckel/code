' This is fairly obsolete.  See emailnotify.xls for a complete example.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: notify_on_save.bas
'
'  Summary: Send modified spreadsheet to project leader via user's email
'           account each time spreadsheet is saved for revision-control
'           purposes.
'
'           Created for tbe2 to track MIS02 MIS03 directories.
'
'  Created: Wed Aug 13 13:05:29 2003 (Bob Heckel)
' Modified: Fri 22 Aug 2003 14:39:31 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'''''
' Paste this into ThisWorkbook
Option Explicit

Dim X As New EventClassModule
Const PRIME = "bqh0"          ' CDC user id (to receive emailed revisions)
Const SHEETNM = "notify"      ' name of sheet should be same as spreadsheet
                              ' (without the .xls)
Const RNG = "c5"              ' return cursor to this cell at close

' Run automatically on workbook open event.
Private Sub Workbook_Open()
  ' Allow for application events to be handled.  In this case, Before Save
  ' events.
  Set X.App = Application

  X.EmailUID = PRIME
  X.Sheetname = SHEETNM
  X.Homecell = RNG
End Sub
'''''


'''''
' Paste this into Class Module EventClassModule

Option Explicit
Public WithEvents App As Application
Public EmailUID As String
Public Sheetname As String
Public Homecell As String

Public Sub SendWrkbk(s)
  Dim fqp As String      ' current fully qualified path
  Dim drv As String      ' current drive letter (usually I)

  On Error Resume Next   ' do not bother user

  If IsNull(Application.MailSession) Then
    ' Guessing that the CDC standard uid will apply to most boxes.
    Application.MailLogon "MS Exchange Settings"
    Debug.Print "first session: " & Application.MailSession
  Else
    Debug.Print "existing session: " & Application.MailSession
  End If
  
  Debug.Print "prime- " & EmailUID
  Debug.Print "sheet- " & Sheetname
  
  ' Hold place for users navigating filesystem via Excel.
  fqp = ActiveWorkbook.Path
  Debug.Print "path- " & fqp
  drv = Left(fqp, 1)
  Debug.Print "drive- " & drv
  
  ThisWorkbook.SendMail Recipients:=EmailUID, Subject:=s
  
  ' Cosmetic.
  Sheets(Sheetname).Select
  Range(Homecell).Select
  
  ' This is mandatory since we're usually on a network drive.
  ChDrive drv
  ChDir fqp
End Sub


Private Sub App_WorkbookBeforeSave(ByVal Wb As Workbook, _
                                   ByVal SaveAsUI As Boolean, _
                                   Cancel As Boolean)
  On Error Resume Next  ' do not bother user
  
  Debug.Print "wbname- " & Wb.Name
  Debug.Print "wbpath- " & Wb.Path
  
  Dim whodunit As String
  
  whodunit = "Change detected: " & Date & " " & Time & ".  " & "User: " _
             & Application.UserName
  Debug.Print whodunit & " "


  
  ' In case user has multiple spreadsheets open, don't send anything but
  ' this one.
  If UCase(Wb.Name) = (UCase(Sheetname) & ".XLS") Then
    SendWrkbk whodunit
  Else
    Debug.Print "fail! wbpath: " & Wb.Path
    Debug.Print "fail! wbname: " & Wb.Name
    Debug.Print "fail! sheetname: " & Sheetname
  End If
End Sub
'''''
