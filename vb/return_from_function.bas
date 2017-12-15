''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: return_from_function.bas
'
' Summary: Demo of returning more than one value from a Function.
'
'  Created: Thu 18 Jul 2002 10:34:38 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub Main()
  Dim sVar1 As String, sVar2 As String
  
  sVar1 = "one"
  sVar2 = "two"
  
  ' sVar1 and sVar2 are passed by reference.
  Transform sVar1, sVar2
  Debug.Print "Returned as " & sVar1 & " and "; sVar2
End Sub

Function Transform(foo1 As String, foo2 As String)
  Debug.Print "Passed into Function as " & foo1 & " and "; foo2
  foo1 = "changed"
  foo2 = "also prestochangeod"
End Function
