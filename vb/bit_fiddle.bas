''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: bit_fiddle.bas
'
' Summary: Demo of bit manipulation in VB.
'          See modbit_fiddle.bas
'          Needs a form containing a text box(Text1) and button(Command1).
'
' Adapted: Tue, 26 Dec 2000 11:46:14 (Bob Heckel --
'          http://www.sbnsoftware.com/Tutorials/BitsTutorial.htm)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

Private Sub Command1_Click()
  Const ArraySize = 100             'Size (in bytes) of the Bit Map.
  Const MaxBits = ArraySize * 8
  Dim BitArray(ArraySize) As Byte   'Define the bit map (array).
  Dim ByteOffset As Long
  Dim BitOffset As Byte
  Dim i As Long
  Dim logicalbit_pos As Long        ' Used as index into the bit map.
  Dim t_or_f As Boolean
  
  ' Initialize the Bit Array
  For i = 1 To ArraySize
    BitArray(i) = 0
  Next i
  Command1.Caption = "oknow"
  logicalbit_pos= Text1.Text
  Call GetOffset(logicalbit_pos, ByteOffset, BitOffset)
  Debug.Print "Absolute position in the "; Chr(13); _
              "byte array for logical bit "; logicalbit_pos; "is: "; _ 
              ByteOffset; BitOffset

  Call SetBit(BitArray(ByteOffset), BitOffset)
  t_or_f = TestBit(BitArray(ByteOffset), BitOffset)    ' Initializes to False.
  debug.print "set---True if set, False if not: "; t_or_f

  Call ClearBit(BitArray(ByteOffset), BitOffset)
  t_or_f = TestBit(BitArray(ByteOffset), BitOffset)
  debug.print "clear---True if set, False if not: "; t_or_f
End Sub

