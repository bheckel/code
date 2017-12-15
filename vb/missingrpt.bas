''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: missingrpt.bas (embedded in missingrpt.mdb)
'
'  Summary: Automate file deletions and Access/Excel macro runs.  For Erica.
'
'  Created: Thu 28 Aug 2003 13:25:12 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

' Macro1 uses RunCode to call this Module.
' C:\cygwin\home\bqh0\projects\accessexcel>"c:\Program Files\Microsoft Office\Office10\MSACCESS.EXE" "\cygwin\home\bqh0\projects\accessexcel\missingrpt.mdb" /x Macro1

Function Sleep(seconds As Integer) As Boolean
  Dim start  As Single
  Dim finish As Single

  start = Timer
  finish = start + seconds
  Do Until Timer > finish
    DoEvents
  Loop
  Sleep = True
End Function


Function DeleteFiles()
  '''Kill ("Miss01.xls")
  '''Kill ("Miss02.xls")
End Function


Function OpenDB()
  Dim db, xl As String
  Dim oAcc As Access.Application
  Dim oExc As Object

  db = "c:\cygwin\home\bqh0\projects\accessexcel\db2.mdb"
  xl = "c:\cygwin\home\bqh0\projects\accessexcel\book1.xls"

  If Dir(db) <> "" Then
    Set oAcc = CreateObject("Access.Application")
    oAcc.OpenCurrentDatabase db, , "x"
    oAcc.Visible = True
    Sleep 2
    Set oAcc = Nothing
  Else
    MsgBox ("Database does not exist!")
  End If
  
  If Dir(xl) <> "" Then
    Set oExc = CreateObject("Excel.Application")
    oExc.Workbooks.Open (xl)
    Sleep 2
    oExc.Quit
    Set oExc = Nothing
  Else
    MsgBox ("Spreadsheet does not exist!")
  End If
End Function
