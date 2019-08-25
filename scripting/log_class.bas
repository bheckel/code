''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: log_class.bas
'
' Summary: From "VBA Developer's Handbook"
'          by Ken Getz and Mike Gilbert
'          Copyright 1997; Sybex, Inc. All rights reserved.
'
' Adapted: Thu 18 Jul 2002 15:19:28 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

'''''''''''''''''''''''''''''
' This goes in a Class Module named Log
Private mstrFile As String
Private mfActive As Boolean
Private mlngOptions As Long
Private mintSeverityLevel As Integer
Private Const conLogDateTime = 1
Private Const conLogSeverity = 2


' Prints information to a log file.
' Text: The text to print
' Severity: Severity level of the information
Public Sub Output(Text As Variant, Optional Severity As Integer = 9)
  Dim hFile As Long
  Dim varText As Variant
  Dim varExisting As Variant
  
  ' Only process this if the log is active.
  If mfActive Then
    ' Build up text
    varText = Text
    ' E.g. 0010 is 2
    '      0011 is 3
    '      ----
    '  AND 0010 is 2
    If mlngOptions And conLogDateTime Then
      varText = Now & vbTab & varText
    End If
    If mlngOptions And conLogSeverity Then
      varText = Severity & vbTab & varText
    End If

    ' Process the log information if Severity
    ' meets or exceeeds SeverityLevel
    If Severity >= mintSeverityLevel Then
      ' If SeverityLevel is -1 then put up a message
      ' rather than writing text to the file
      If mintSeverityLevel = -1 Then
        MsgBox varText, vbInformation, "Log"
      Else
        ' Get file handle
        hFile = FreeFile
    
        ' Open file for append
        Open mstrFile For Append Access Write As hFile
        
        ' Print the output
        Print #hFile, varText
        '''Print #hFile, Chr$(13) & Chr$(10)
        
        ' Close the file
        Close hFile
      End If
    End If
  End If
End Sub


Property Get File() As String
  ' Return the file name
  File = mstrFile
End Property

Property Let File(FileName As String)
  ' Store file name
  mstrFile = FileName
  ' Set the Active flag
  mfActive = True
End Property


Property Get Active() As Boolean
  Active = mfActive
End Property

Property Let Active(fActive As Boolean)
  mfActive = mfActive
End Property


Property Get Options() As Long
  Options = mlngOptions
End Property

Property Let Options(lngOptions As Long)
  mlngOptions = lngOptions
End Property


Property Get SeverityLevel() As Integer
  SeverityLevel = mintSeverityLevel
End Property

Property Let SeverityLevel(intLevel As Integer)
  mintSeverityLevel = intLevel
End Property


Private Sub Class_Initialize()
  mlngOptions = conLogDateTime + conLogSeverity
End Sub


Public Sub Reset()
  On Error GoTo HandleError
  
  ' Delete the current log file if it exists
  If Len(Dir$(mstrFile)) > 0 Then
      Kill mstrFile
  End If
  
ExitHere:
  Exit Sub
HandleError:
  mfActive = False
  Err.Raise vbObjectError + 8001, "Log::Reset", Err.Description
  Resume ExitHere
End Sub



'''''''''''''''''''''''''''''
' This goes in a Normal Module named Module1
Global gLog As Log



'''''''''''''''''''''''''''''
' This goes in a ThisWorkbook window
Option Explicit

' Test harness for the Log class.
Sub Main()
  Set gLog = New Log  ' instantiate a Log class
  
  ' Conditional compilation (the instrumented approach).
  ' Set DEBUGGING = 1 in Tools:VBAProject Properties to activate.
  #If DEBUGGING Then
    gLog.File = "c:\logdroppings"
    gLog.SeverityLevel = 5
    gLog.Options = 1  ' show date/time stamp only
    '''gLog.Options = 3  ' show date/time stamp and sev num (DEFAULT)
  #End If
  ProcessDemo "foostring"
  
  #If DEBUGGING Then
    '''gLog.SeverityLevel = -1  ' use MsgBoxes instead
    gLog.Options = 2  ' show prepended severity number only
    ' TODO not working
    '''gLog.Active = False
  #End If
  ProcessDemo "anotherstring"
End Sub

Sub ProcessDemo(strFile As String)
  '                text           severity
  gLog.Output "Entering process", 5
  gLog.Output "Before: strFile = " & strFile
  strFile = "altered beast"
  gLog.Output "After: strFile = " & strFile, 7
End Sub
