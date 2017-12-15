''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: array.bas
'
'  Summary: Pass array to another sub.  VB uses () instead of [] !
'
'  Created: Tue, 30 Nov 1999 12:54:55 (Bob Heckel)
' Modified: Sat 13 Mar 2004 12:12:01 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit
' Option Base   ' affects Array() default is 0


Sub SendArr()
  ' Specify bounds later, "dynamic" array.
  Dim aArr() As Variant
  ' Specifying bounds now, "fixed size" array.
  Dim aArr2(2 To 4) As Variant

  ' Can only use the Array() function on aArr()
  aArr = Array("zero", "one", "two")
  ReceiveArr(aArr)

  aArr2(2) = "thre"
  aArr2(3) = "fou"
  aArr2(4) = "fiv"
  ReceiveArr(aArr2)

  ' Can't do this to aArr2 b/c it's already dimensioned.
  ReDim aArr(0 To 2)
  ' Old array data tossed.  We'd use ReDim Preserve aArr(0 To 5) to add more
  ' elements and leave the old ones in place.
  aArr(0) = "presto"
  aArr(1) = "changeo"
  aArr(2) = "voila"
  ReceiveArr(aArr)
End Sub


Sub ReceiveArr(aArrIn As Variant)
  Dim e As Variant
  Dim i As Integer

  Debug.Print "element 2: " & aArrIn(2)

  ' Can only read elements, can't write them with a For Each.  And must use
  ' Variant type for e
  For Each e In aArrIn
    Debug.Print "for each element: " & e
  Next

  ' Better
  '     starting at element #2
  For i = 2 to UBound(aArrIn)
    '     ^
    Debug.Print "for element: " & aArrIn(i)
  Next
End Sub


Sub ReDimAnArray()
  Dim population() As Long
  Dim ct As Integer

  ct = 100
  ' Mandatory since you're giving ct as an arg.
  ReDim population(ct) As Long

  population(50) = 1000

  MsgBox population(50)
End Sub
