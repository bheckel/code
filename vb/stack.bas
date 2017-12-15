''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: stack.bas
'
'  Summary: Demo of how to build a simple LIFO stack data structure in VB.
'
'           Linked list steps:
'           1.  Create new node.
'           2.  Insert value into node.
'           3.  Make this new node point to whatever the current stacktop
'               pointer points to.
'           4.  Change the stacktop to now point to this new node.
'
'  Adapted: Tue 19 Aug 2003 12:51:10 (Bob Heckel -- CH06 p. 320 of 
'                                     VBA Developers Handbook)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'''''
' Put this in a new Class Module named StackItem:

' Keep track of the next stack item, and the contents of this item.
Public Guts As Variant
Public siNext As StackItem

' Constructor.  TODO is Class_Initialize a VBA keyword?
Private Sub Class_Initialize()
  ' Make sure object does not point to a real object yet.
  Set siNext = Nothing
  debug.print "construct StackItem"
End Sub

' Destructor.
Private Sub Class_Terminate()
  ' Release the reference to the object.
  Set siNext = Nothing
  debug.print "destruct StackItem"
End Sub
'''''


'''''
' Put this in a new Class Module named Stack:

Option Explicit
' From "VBA Developer's Handbook"
' by Ken Getz and Mike Gilbert
' Copyright 1997; Sybex, Inc. All rights reserved.
Dim siTop As StackItem

' Add a new item to the top of the stack.
Public Sub Push(ByVal v As Variant)
  Dim NewTop As New StackItem
      
  NewTop.Guts = v
  Set NewTop.siNext = siTop
  Set siTop = NewTop
End Sub


' Pops the top then returns the text of what was popped.
Public Function Pop() As Variant
  If Not IsStackEmpty Then
    ' Get the value from the current top stack element.
    Pop = siTop.Guts
    ' Get a reference to the new stacktop.
    Set siTop = siTop.siNext
  End If
End Function


Property Get IsStackTop() As Variant
  If IsStackEmpty Then
    IsStackTop = Null
  Else
    IsStackTop = siTop.Guts
  End If
End Property


' Is the stack empty?  It can only be empty if siTop is pointing to nothing.
Property Get IsStackEmpty() As Boolean
  IsStackEmpty = (siTop Is Nothing)
End Property


' Constructor.
Private Sub Class_Initialize()
  Set siTop = Nothing
  debug.print "construct Stack"
End Sub


' Destructor.
Private Sub Class_Terminate()
  Set siTop = Nothing
  debug.print "destruct Stack"
End Sub
'''''


'''''
' Put this in ThisWorkbook:
'''Dim stk As New Stack
'''
'''Sub test()
'''  ' Build one Stack (implicitly) and 4 StackItems:
'''  stk.Push "1st item"
'''  stk.Push "2nd item"
'''  stk.Push "3rd"
'''  stk.Push "4th item"
'''  Do While Not stk.IsStackEmpty
'''    Debug.Print stk.Pop
'''  Loop
'''  Set stk = Nothing
'''End Sub

' Better
Dim stk As New Stack

Sub test()
  ' Build one Stack (implicitly) and 4 StackItems:
  With stk
    .Push "1st item"
    .Push "2nd item"
    .Push "3rd"
    .Push "4th item"
  End With

  Do While Not stk.IsStackEmpty
    Debug.Print stk.Pop
  Loop

  Set stk = Nothing
End Sub
'''''
