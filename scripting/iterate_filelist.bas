''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: iterate_filelist.bas
'
'  Summary: Do something to a list of files.  For tbe2.  Also exists in
'           open_spdshts.xls
'
'  Created: Fri 05 Sep 2003 12:18:19 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

Sub IterateFileList()
  Dim arr As Variant
  Dim f As Variant
  
  arr = Array("c:\temp\junk.xls", "c:\temp\junk2.xls")
  For Each f In arr
    Debug.Print f
    Workbooks.Open Filename:=f, UpdateLinks:=1
    Application.ScreenUpdating = False
    Application.DisplayAlerts = False
    ActiveWorkbook.Save
    ActiveWorkbook.Close
    Application.ScreenUpdating = True
    Application.DisplayAlerts = True
  Next
End Sub
