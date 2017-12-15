''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: modbit_fiddle.bas
'
' Summary: Demo of bit manipulation in VB.
'          See bit_fiddle.bas.
'
' Adapted: Tue, 26 Dec 2000 11:46:14 (Bob Heckel --
'          http://www.sbnsoftware.com/Tutorials/BitsTutorial.htm)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

' In order to manipulate the bits in the map, we need a consistent way to
' address a bit as a single unit. 
' Given a logical bit, this fn returns the byte offset and bit offset.
' An easy example is logical bit 20.
'
'87654321  87654321  87654321  etc.  <--bit position
'........  ........  ...x....  etc.  <--the bit map array
'    1         2         3     etc.  <--byte position
'
' TODO is next line correct or is using integer division??
' so 20 is byte # 3 (20/8=2.5; 2.5+1=3.5; it's a long so 3.5 == 3 truncated)
' and 20 is bit # 5 (20%8=4; 9-4=5)
Public Sub GetOffset(LogicalBit As Long, ByteOff As Long, BitOff As Byte)
  ByteOff = (LogicalBit \ 8) + 1
  BitOff  = (LogicalBit Mod 8)
   
  If BitOff = 0 Then          ' Check for zero wrap.
    ByteOff = ByteOff - 1     ' Adjust byte offset.
    BitOff = 1                ' Force bit offset to 1.
  Else
    BitOff = 9 - BitOff       ' Compute bit offset.
  End If
End Sub


' Sets bits in byte x according to bit set in bitmask.
Public Sub SetBit(x As Byte, bitmask As Byte)
  Dim tmp As Byte

  '                                                5 
  ' E.g. for 20, bitmask is 5 ........ ........ ..._....
  '                      i.e. 00000000 00000000 00010000 in binary
  tmp = 2 ^ (bitmask - 1)     ' Compute bit offset (i.e. which bit to flip).
  x = x Or tmp                ' Add in bit (i.e. flip it).
  ' which is 00010000  tmp
  '          00000000    x
  '          --------
  '          00010000  so now it's set.
End Sub


' Clears bit in x according to bit set in bitmask
Public Sub ClearBit(x As Byte, bitmask As Byte)
  Dim tmp As Byte

  tmp = 2 ^ (bitmask - 1)     ' Compute bit offset.
  tmp = tmp Xor 255           ' Invert the mask.
  ' which is 00010000 tmp
  '          11111111 255
  '          --------
  '          11101111
  x = tmp And x               ' Clear out bit.
  ' which is 11101111 tmp
  '          00010000  16
  '          --------
  '          00000000
End Sub


' Tests bits in x and returns true if all bits set in bitmask are set. False
' if not
Public Function TestBit(x As Byte, bitmask As Byte) As Boolean
  Dim tmp As Byte
  Dim tmp1 As Byte

  tmp = 2 ^ (bitmask - 1)     ' Compute bit offset.
  tmp1 = x And tmp            ' Get rid of unwanted bits.
  If tmp = tmp1 Then          ' Check for single bit set.
    TestBit = True
  Else
     TestBit = False
  End If
End Function
