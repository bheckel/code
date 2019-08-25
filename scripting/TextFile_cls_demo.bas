Attribute VB_Name = "basFileTest"
Option Explicit

' From "VBA Developer's Handbook"
' by Ken Getz and Mike Gilbert
' Copyright 1997; Sybex, Inc. All rights reserved.

' Examples from Chapter 5

Private Sub DocTest()
    Dim objDoc As New Document
    
    ' Create a new instance of the TextFile class
    ' and copy a pointer to it into the
    ' Document object's SaveFile property
    Set objDoc.SaveFile = New TextFile
    
    ' We can now reference the TextFile object
    ' through the SaveFile property
    objDoc.SaveFile.Path = "C:\AUTOEXEC.BAT"
    If objDoc.SaveFile.FileOpen() Then
        MsgBox objDoc.SaveFile.Text, vbInformation
        objDoc.SaveFile.FileClose
    End If
End Sub

Sub FileTest()
    On Error GoTo HandleError
    
    Dim objFile As TextFile
    
    ' Create new instance of TextFile class
    Set objFile = New TextFile
    
    ' Set the Path property
    objFile.Path = "C:\AUTOEXEC.BAT"
    
    ' Try to open the file--if successful,
    ' read until the end of the file,
    ' printing each line
    If objFile.FileOpen() Then
        Do Until objFile.EOF
            Debug.Print objFile.Text
            objFile.ReadNext
        Loop
        objFile.FileClose
    End If
    
    ' Destroy class instance
    Set objFile = Nothing
    
ExitProc:
    Exit Sub
HandleError:
    MsgBox Err.Description, 16, Err.Number
    Resume ExitProc
End Sub

