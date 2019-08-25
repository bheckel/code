''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: collection.bas
'
'  Summary: Demo of VB/VBA collections.
'
'           A collection is an object that contains a group of related
'           objects.
'            
'           It is designated by a plural noun.
'
'           E.g. Worksheets collection is an object that contains all the
'           Worksheet objects in a Workbook.  It is an array so Worksheets(1)
'           is the first Worksheet object in the workbook.  You could also
'           have said Worksheets("Sheet1") if you knew the name.
'
'           Collections are easily traversed with For Each-Next
'           constructs.
'
'  Created: Thu Jan 28 1999 14:19:23 (Bob Heckel -- Adapted from VBA Help)
' Modified: Fri Jun 21 15:03:40 2002 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' TODO clean up this mess
Option Explicit
'Put (and uncomment) this in a separate class module (ok default name Class1):
'Public InstanceName

Sub ClassNamer()
  'A Collection object is an ordered set of items that can be referred
  'to as a unit.  Displays as "Item 1 , Item 2", etc.
  Dim MyClasses As New Collection   ' Create a Collection object.
  Dim i as Byte     ' Counter for individualizing keys.
  Dim Msg As String      ' Variable to hold prompt string.
  Dim TheName, MyObject, NameList ' Variants to hold information.
  
  Do
    Dim Inst As New Class1  ' Create a new instance of Class1.
    i = i + 1 ' Increment i, then get a name.
    Msg = "Please enter a name for this object." & Chr(13) _
           & "Press Cancel to see names in collection."
    TheName = InputBox(Msg, "Name the Collection Items")
    Inst.InstanceName = TheName ' Put name in object instance.
    ' If user entered name, add it to the collection.
    If Inst.InstanceName <> "" Then
      ' Add the named object to the collection.
      'CStr() coerces an expression to a string data type.
      'Now if user enters e.g. 43, it becomes "43"
      MyClasses.Add Item:=Inst, key:=CStr(i)
    End If
    ' Clear the current reference in preparation for next one.
    Set Inst = Nothing
  Loop Until TheName = ""
  
  For Each MyObject In MyClasses  ' Create list of names.
    NameList = NameList & MyObject.InstanceName & Chr(13)
  Next MyObject
  ' Display the list of names in a message box.
  MsgBox NameList, , "Instance Names In MyClasses Collection"

  For i = 1 To MyClasses.Count  ' Remove name from the collection.
    MyClasses.Remove 1  ' Since collections are reindexed
                        ' automatically, remove the first
  Next                  ' member on each iteration.
End Sub
