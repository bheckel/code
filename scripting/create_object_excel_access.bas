''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: create_object_excel_access.bas
'
'  Summary: Work with ActiveX (?) Excel object from within MS Access.
'
'  Adapted: Wed 07 Jan 2004 16:37:29 (Bob Heckel --
'                          http://www.mvps.org/access/modules/mdl0007.htm)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

'This code was originally written by Dev Ashish.
'It is not to be altered or distributed,
'except as part of an application.
'You are free to use it in any application,
'provided the copyright notice is left unchanged.
'
'Code Courtesy of
'Dev Ashish
'
Private Const SW_HIDE = 0
Private Const SW_SHOWNORMAL = 1
Private Const SW_NORMAL = 1
Private Const SW_SHOWMINIMIZED = 2
Private Const SW_SHOWMAXIMIZED = 3
Private Const SW_MAXIMIZE = 3
Private Const SW_SHOWNOACTIVATE = 4
Private Const SW_SHOW = 5
Private Const SW_MINIMIZE = 6
Private Const SW_SHOWMINNOACTIVE = 7
Private Const SW_SHOWNA = 8
Private Const SW_RESTORE = 9
Private Const SW_SHOWDEFAULT = 10
Private Const SW_MAX = 10

Private Declare Function apiFindWindow Lib "user32" Alias _
    "FindWindowA" (ByVal strClass As String, _
    ByVal lpWindow As String) As Long

Private Declare Function apiSendMessage Lib "user32" Alias _
    "SendMessageA" (ByVal Hwnd As Long, ByVal Msg As Long, ByVal _
    wParam As Long, lParam As Long) As Long
    
Private Declare Function apiSetForegroundWindow Lib "user32" Alias _
    "SetForegroundWindow" (ByVal Hwnd As Long) As Long
    
Private Declare Function apiShowWindow Lib "user32" Alias _
    "ShowWindow" (ByVal Hwnd As Long, ByVal nCmdShow As Long) As Long
    
Private Declare Function apiIsIconic Lib "user32" Alias _
    "IsIconic" (ByVal Hwnd As Long) As Long
    
Function fIsAppRunning(ByVal strAppName As String, _
        Optional fActivate As Boolean) As Boolean
    Dim lngH As Long, strClassName As String
    Dim lngX As Long, lngTmp As Long
    Const WM_USER = 1024
    On Local Error GoTo fIsAppRunning_Err
    fIsAppRunning = False
    Select Case LCase$(strAppName)
        Case "excel":       strClassName = "XLMain"
        Case "word":        strClassName = "OpusApp"
        Case "access":      strClassName = "OMain"
        Case "powerpoint95": strClassName = "PP7FrameClass"
        Case "powerpoint97": strClassName = "PP97FrameClass"
        Case "notepad":     strClassName = "NOTEPAD"
        Case "paintbrush":  strClassName = "pbParent"
        Case "wordpad":     strClassName = "WordPadClass"
        Case Else:          strClassName = vbNullString
    End Select
    
    If strClassName = "" Then
        lngH = apiFindWindow(vbNullString, strAppName)
    Else
        lngH = apiFindWindow(strClassName, vbNullString)
    End If
    If lngH <> 0 Then
        apiSendMessage lngH, WM_USER + 18, 0, 0
        lngX = apiIsIconic(lngH)
        If lngX <> 0 Then
            lngTmp = apiShowWindow(lngH, SW_SHOWNORMAL)
        End If
        If fActivate Then
            lngTmp = apiSetForegroundWindow(lngH)
        End If
        fIsAppRunning = True
    End If
fIsAppRunning_Exit:
    Exit Function
fIsAppRunning_Err:
    fIsAppRunning = False
    Resume fIsAppRunning_Exit
End Function

' Save the spreadsheet so that the MS Excel bug doesn't popup an "unable to file" message.
Function SaveExcel()
  Dim objXL As Object

  ' Do not disturb any other workbooks the user may have open.
  If fIsAppRunning("Excel") Then
    SaveExcel = -1
    Exit Function
  Else
    Set objXL = CreateObject("Excel.Application")
    With objXL.Application
      .Visible = False
      .Workbooks.Open "C:\cygwin\home\bqh0\projects\spawnspdsht\junk.xls"
    End With
  End If
    
  '''objXL.Application.Cells(1, 1).Value = "This is column A, row 1"
  objXL.ActiveWorkbook.Save
  objXL.Application.Quit
  Set objXL = Nothing
  
  SaveExcel = 1
End Function
