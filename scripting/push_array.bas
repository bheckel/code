''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: push
'
' Summary: Emulate Perl's push()
'
' Created: Thu, 09 Nov 2000 08:15:27 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' Sample calling sub.
Sub Kickoff
  Dim arr, pushme, elem, larger_arr

  arr = Array("emi", "blake", "kab")
  pushme = "bob"
  larger_arr = Push(arr, pushme)  
  j = 0
  For Each elem In larger_arr
    Debug.Print "(" & j & ") is " & elem
    j = j + 1
  Next
End Sub


Function Push(arr_in As Variant, push_elem As Variant) As Variant
  Dim i, j

  i = 0
  i = UBound(arr_in) + 1

  ' Make room for pushed element.
  ReDim Preserve arr_in(i)
  arr_in(i) = push_elem

  Push = arr_in
End Function
