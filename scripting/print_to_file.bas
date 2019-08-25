''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: print_to_file.bas
'
'  Summary: Demo of writing (printing) to a file.
'
'  Adapted: Tue 10 Dec 2002 10:50:44 (Bob Heckel -- MS VBA Help)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

Sub WriteToDisk
  Dim fnum As Integer

  fnum = FreeFile

  Open "c:\temp\testfile" For Output As #fnum

  ' Print text to a file.
  Print #fnum, "This is a test"
  Print #fnum,                              ' blank line
  Print #fnum, "Zone 1"; Tab ; "Zone 2"     ' print in two print zones
  Print #fnum, "Hello" ; " " ; "World"      ' separate strings with space
  Print #fnum, Spc(5) ; "5 leading spaces " ' print five leading spaces
  Print #fnum, Tab(10) ; "Hello"    ' Print word at column 10.

  ' Assign Boolean, Date, Null and Error values.
  Dim MyBool, MyDate, MyNull, MyError
  MyBool = False : MyDate = #February 12, 1969# : MyNull = Null
  MyError = CVErr(32767)
  ' True, False, Null, and Error are translated using locale settings of 
  ' your system. Date literals are written using standard short date 
  ' format.
  Print #fnum, MyBool ; " is a Boolean value"
  Print #fnum, MyDate ; " is a date"
  Print #fnum, MyNull ; " is a null value"
  Print #fnum, MyError ; " is an error value"
  Close #fnum
End Sub
