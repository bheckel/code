''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: range.bas
'
' Summary: Demo of the Range object in Excel VBA.  Plus a demo of the Parent
'          hierarchy.
'
'  Adapted: Thu 20 Jun 2002 08:56:04 (Bob Heckel -- Excel2000 Power
'                                     Programming VBA John Walkenbaugh)
' Modified: Fri 06 Dec 2002 14:28:54 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

Sub BadExample
  ' Do not need to Select prior to using an object.
  Range("a1").Select
  Selection.Copy
  Range("b1").Select
  ActiveSheet.Paste
  Application.CutCopyMode = False
End Sub


Sub WordyAllPurpose
  ' Usually don't need the Excel.Application part.
  Excel.Application.Workbooks("Book1").Sheets("Sheet1").Range("a1").Copy _
  Excel.Application.Workbooks("Book1").Sheets("Sheet1").Range("b1")
End Sub 


Sub QuickNDirty
  Range("a1").Copy Range("b1")
End Sub 
  

' Better
Sub ObjectVariables
  Dim rng1 As Range
  Dim rng2 As Range
  Dim rng3 As Range
  Dim r as Range

  ' Explicit.
  Set rng1 = Workbooks("Book1").Sheets("Sheet1").Range("a1")
  ' Shorthand.
  Set rng2 = Range("b1")
  Set rng3 = Range("c1:d2")

  rng1.Copy rng2

  ' One benefit of using object variables:
  ' Displays "Sheet1"
  Debug.Print rng2.Parent.Name
  ' Displays "Book1"
  Debug.Print rng2.Parent.Parent.Name
  ' Displays "Microsoft Excel"
  Debug.Print rng2.Parent.Parent.Parent.Name

  For Each r in rng3
    Debug.Print r
  Next
End Sub
