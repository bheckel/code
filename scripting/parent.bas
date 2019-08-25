''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: parent.bas
'
' Summary: Demo of the Excel object model.
'
' Adapted: Sun, 25 Feb 2001 14:08:49 (Bob Heckel -- from John Walkenbach
'                               http://www.j-walk.com/ss/excel/tips/index.htm)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

Function SheetName(ref) As String
  SheetName = ref.Parent.Name
End Function


Function WorkbookName(ref) As String
  WorkbookName = ref.Parent.Parent.Name
End Function


Function AppName(ref) As String
 AppName = ref.Parent.Parent.Parent.Name
End Function


Sub x()
  Dim ranger As Range
  Dim parent_of_ranger As String
  Dim parent_of_parent_of_ranger As String
  Dim parent_of_parent_of_parent_of_ranger As String

 Set ranger = ActiveSheet.Range("a2:a4")

 parent_of_ranger = SheetName(ranger)
 debug.print parent_of_ranger

 parent_of_parent_of_ranger = WorkbookName(ranger)
 debug.print parent_of_parent_of_ranger

 parent_of_parent_of_parent_of_ranger = AppName(ranger)
 debug.print parent_of_parent_of_parent_of_ranger
End Sub
