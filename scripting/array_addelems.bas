Dim origconfig As Variant
Dim configarray() As Variant
Dim j As Integer
Dim array_elem As Variant     
j = 0
origconfig = Dir("C:\local\bin\" & "*.orig.dat")  'Initialize.

While origconfig > ""
  ReDim Preserve configarray(j)
  configarray(j) = origconfig
  j = j + 1
  origconfig = Dir    'Open next file in directory, if there is one.
Wend

For Each array_elem In configarray
  lstDefaultDAT.AddItem array_elem
  debug.print array_elem
Next
