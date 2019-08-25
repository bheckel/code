''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: reformat_then_save_excel.bas
'
'  Summary: Simple cleanup and save of xls or CSV file (from tabdelim.sas)
'
'  Created: Wed 11 Jan 2006 12:41:29 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub Macro1()
    Rows("1:1").Select
    Selection.Font.Bold = True
    Range("A1").Select
    ActiveWindow.SplitRow = 1
    ActiveWindow.FreezePanes = True
    Columns("A:A").ColumnWidth = 29.57
    Columns("B:B").ColumnWidth = 23.71
    Columns("C:C").ColumnWidth = 15.14
    Columns("D:D").ColumnWidth = 12.71
    Columns("E:E").ColumnWidth = 13.43
    Columns("F:F").ColumnWidth = 13.29
    Columns("G:G").ColumnWidth = 14
    Columns("H:H").ColumnWidth = 11.57
    Columns("I:I").ColumnWidth = 12.86
    Columns("J:J").ColumnWidth = 10.29
    
    ChDir "C:\cygwin\home\bheckel\projects\pec\all"

    bknm = ActiveWorkbook.Name
    
    Application.DisplayAlerts = False   ' don't warn about overwriting
    ActiveWorkbook.SaveAs Filename:= _
        "C:\cygwin\home\bheckel\projects\pec\all\" & bknm, _
        FileFormat:=xlNormal, Password:="", WriteResPassword:="", _
        ReadOnlyRecommended:=False, CreateBackup:=False
    Application.DisplayAlerts = True
End Sub
