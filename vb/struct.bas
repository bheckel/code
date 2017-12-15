''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: struct.bas
'
' Summary: User defined type.  C-like struct in VB.
'
' Adapted: Tue 18 Jun 2002 16:29:57 (Bob Heckel -- John Walkenback Excel 2000
'                                    VBA Power Programming)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' This must go in a Module.
Type CustStruct
  Company As String * 25
  Contact As String * 15
  Region As Integer
End Type


Sub Struct
  Dim ManyCusts(1 To 10) As CustStruct

  ' One-based arrays.
  ManyCusts(1).Company = "Red Hat"
  ManyCusts(1).Contact = "Zippy"
  ManyCusts(1).Region = 42
  ManyCusts(2).Company = "Microsoft"
  ManyCusts(2).Contact = "Clippy"
  ManyCusts(2).Region = 42

  Debug.Print ManyCusts(1).Contact
  Debug.Print ManyCusts(2).Contact
End Sub

