''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: recordset.access.bas
'
'  Summary: Demo of using a query to return data from a record.
'
'  Created: Thu 01 Apr 2004 16:04:36 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

Function GetNextNumber(TblName As String) As Long
  Dim rst As Recordset
   
  Set rst = CurrentDb.OpenRecordset("select max(anum) as maxid from " & TblName & " where city='raleigh' and state='NC'")

  If Not (rst.EOF And rst.BOF) Then
    GetNextNumber = rst("MaxID") + 1
  Else
    GetNextNumber = 1
  End If
End Function
