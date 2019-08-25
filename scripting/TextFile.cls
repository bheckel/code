VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "TextFile"
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

' From "VBA Developer's Handbook"
' by Ken Getz and Mike Gilbert
' Copyright 1997; Sybex, Inc. All rights reserved.

' TextFile class from Chapter 5

' Private variables for properties implemented
' using property procedures
Private mstrPath As String
Private mhFilehnd As Long
Private mintOpenMode As Integer
Private mfIsOpen As Boolean
Private mstrCurrentLine As String

' Class constants
Private Const tfOpenReadOnly = 0
Private Const tfOpenReadWrite = 1
Private Const tfOpenAppend = 2
Private Const tfOpenReadOnlyExists = 3

Public Function FileOpen()
    On Error GoTo HandleError
    
    ' If a file is already open, close it
    If Me.IsOpen Then
        Me.FileClose
    End If
    
    ' Get next available file handle
    mhFilehnd = FreeFile
    
    ' Open file based on file open mode property
    Select Case Me.OpenMode
        Case tfOpenReadOnly
            Open Me.Path For Binary Access Read As mhFilehnd
        Case tfOpenReadWrite
            Open Me.Path For Binary Access Read Write As mhFilehnd
        Case tfOpenAppend
            Open Me.Path For Append Access Read Write As mhFilehnd
        Case tfOpenReadOnlyExists
            Open Me.Path For Input Access Read As mhFilehnd
    End Select
    
    ' Set IsOpen property variable and return value
    mfIsOpen = True
    FileOpen = True
    
    ' Read first line into buffer
    Me.ReadNext
    
ExitProc:
    Exit Function
HandleError:
    FileOpen = False
    Resume ExitProc
End Function

Public Sub FileClose()
    Close Me.Handle
    mfIsOpen = False
End Sub

Public Function ReadNext() As Boolean
    On Error GoTo HandleError
    
    Dim hFile As Long
    
    If Me.IsOpen Then
        hFile = Me.Handle
        If Not VBA.EOF(hFile) Then
            Line Input #hFile, mstrCurrentLine
            ReadNext = True
        End If
    End If
    
ExitProc:
    Exit Function
HandleError:
    Select Case Err.Number
        Case 62
            ' Just ignore
        Case Else
            ReadNext = False
    End Select
    Resume ExitProc
End Function

Property Get Text() As String
    Text = mstrCurrentLine
End Property

Property Get EOF() As Boolean
    If Me.IsOpen Then
        EOF = VBA.EOF(Me.Handle)
    End If
End Property

Property Get Path() As String
    ' Return the path of the file from the
    ' Private class variable
    Path = mstrPath
End Property

Property Let Path(ByVal strPath As String)
    ' Set the path property of the file--
    ' If a file is already open, close it
    If Me.IsOpen Then
        Me.FileClose
    End If
    mstrPath = strPath
End Property

Property Get Handle() As Long
    ' Get the OS file handle if a file
    ' is open
    If Me.IsOpen Then
        Handle = mhFilehnd
    End If
End Property

Property Get OpenMode() As Integer
    ' Retrieve the open mode of the file
    OpenMode = mintOpenMode
End Property

Property Let OpenMode(ByVal intMode As Integer)
    ' Set the open mode of the file only if
    ' a file is not already open
    If Not Me.IsOpen Then
        mintOpenMode = intMode
    End If
End Property

Property Get IsOpen() As Boolean
    ' Return value of private variable indicating
    ' whether a fiile is currently open
    IsOpen = mfIsOpen
End Property

Private Sub Class_Initialize()
    ' Set default file open mode property
    Me.OpenMode = tfOpenReadOnlyExists
End Sub

Private Sub Class_Terminate()
    ' If a file is still open then close it
    ' before terminating
    If Me.IsOpen Then
        Me.FileClose
    End If
End Sub

Public Function Exists() As Boolean
    ' Return existance of file based on
    ' a directory search
    Exists = (Len(Dir$(Me.Path)) > 0)
End Function

