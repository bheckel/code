''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: iterate_single_dir.bas
'
'  Summary: Iterate over all spreadsheets in a single directory.  Heather
'           Gay request.
'
'  Created: Thu 11 Jul 2002 09:26:52 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub Iterate()
  Dim sFile As String
  Const sPath = "C:\mydirectory\"
   
  sFile = Dir(sPath & "*.XLS")  ' initialize
  
  ' Prevent the screen from flashing during the open & close.
  Application.ScreenUpdating = False
  While sFile > ""
    Workbooks.Open FileName:=sPath & sFile
    ' ...do something to the open workbook...
    '''ActiveWorkbook.Save
    ActiveWorkbook.Close
    sFile = Dir    ' open next file in directory, if there is one.
  Wend
  Application.ScreenUpdating = True
End Sub
