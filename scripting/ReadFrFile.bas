'TODO add formal header.
'Reads SEQUENTIALLY from an existing file e.g.
'John
'Doe
'Blow
Dim MyFileNo as Integer
Dim GetValues() as String
Dim i as Integer
Dim j as Integer

MyFileNo = FreeFile
Open "C:\todel\testvb5.dat" for Input as MyFileNo
  Do Until EOF(MyFileNo)
    i = i + 1
    Redim Preserve GetValues(i)
    Line Input #MyFileNo, GetValues(i)
  Loop
Close MyFileNo

For j = LBound(GetValues) To UBound(GetValues)
 Debug.Print GetValues(j) 
Next j


