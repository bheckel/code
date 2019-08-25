
Option Explicit


' Establish an ordered array of items by opening the init file
' and reading/counting all the section names that do not start with ";".
Sub ParseConfigdat(filename As String)
  Dim retBuffer As String
  Dim sectionNamesBuffer As String
  Dim bufLen, retLen As Integer

  Debug.Print "Loading profile from " & filename

  ' First get [section] names.
  retBuffer = String(NAMEBUFSIZE * 1024, 0)
  bufLen = NAMEBUFSIZE * 1024
  retLen = GetPrivateProfileSectionNames(retBuffer, bufLen, filename)
  sectionNamesBuffer = Left(retBuffer, retLen)

  Debug.Print "Profile Loaded Successfully"

  ' DEBUG ONLY
  dim herestr
  herestr = BreakOnEqualSign(BreakOnSpaces(GetKeyValuePair("automation")))
'''    herestr = BreakOnSpaces("automation")
    Debug.Print herestr
  
End Sub


Function GetSectionNames(sectionnames as String) As String()
  Dim sectarray() As String

  ' Place individual sections into array.
  sectarray = Split(sectionnames, Chr$(0))

  ' Return array of section names.
  GetSectionNames = sectarray
End Function
  

' Single line containing all key/value pairs for a passed section.
' TODO not sure if needed...
'''Function GetLineAllPairsOfSect(sect as String) As String
'''  Dim i as Integer
'''  '''Dim keyval as Variant
'''  Dim line_of_pairs As Variant
'''  Dim sectionNames(MAXELEMS) As String   ' MAXELEMS is set to 3 in this app (ports, bw, autom)
'''
'''  i = 0
'''  ' Now get key=value pairs, one line per section.
'''  '''For Each keyval In sectarray
'''    ' Elim blank lines at end of config.dat
'''    If keyval <> "" Then
'''      '''Debug.Print segment & "---" & GetINIValue(segment, "PARSEMODE", "error")
'''      '''Debug.Print keyval & "---" & GetKeyValuePair(keyval)
'''      ' Each section gets one long line containing all key=value pairs.  To be split below.
'''      sectionNames(i) = GetKeyValuePair(keyval)
'''      '''Debug.Print "getkeyvaluepair: " & sectionNames(i)
'''      i = i + 1
'''    End If
'''  '''Next keyval
'''  
'''  For Each line_of_pairs In sectionNames
'''    '''call a sub to pwrsplt then call another subsub to split key=values
'''    '''PowerSplit Chr$(0), longline, cleanarr()
'''    ' DEBUG
'''    BreakOnSpaces (line_of_pairs)
'''  Next line_of_pairs
'''End Function


' Single line containing all key/value pairs for a passed section.
Function GetKeyValuePair(ByVal sect As String) As String
  ' Retrieve string value of a key from a specified section of the init file
  Dim retBuffer As String
  Dim bufLen, retLen As Integer
  
  retBuffer = String(1024, 0) ' pre-extend return buffer
  bufLen = 1024
  retLen = GetPrivateProfileSection(sect, retBuffer, bufLen, CONFIGDAT)
  If (retLen > 0) Then
    GetKeyValuePair = Left(retBuffer, retLen)
  Else
    GetKeyValuePair = Default
  End If
End Function


' TODO not sure if need this funct
'''Public Function GetINIValue(ByVal sect As String, key As String, default As String)
'''  ' Retrieve string value of a key from a specified section of the init file
'''  Dim retBuffer As String
'''  Dim bufLen, retLen As Integer
'''
'''  retBuffer = String(1024, 0) ' pre-extend return buffer
'''  bufLen = 1024
'''  retLen = GetPrivateProfileString(sect, key, default, retBuffer, bufLen, CONFIGDAT)
'''  '''Debug.Print retLen
'''  If (retLen > 0) Then
'''    '''Debug.Print "buff " & retBuffer
'''    GetINIValue = Left(retBuffer, retLen)
'''  Else
'''    GetINIValue = default
'''  End If
'''End Function


' Key=Value on each line.  Actually breaking on Null strings.
Function BreakOnSpaces(keyvalstr As String) As String
  Dim keyvalelems(MAXLINES) As String     ' TODO does PowerSplit have to know num of elements??
  Dim ctr As String
  Dim pair As Variant
  
  ctr = PowerSplit(Chr$(0), keyvalstr, keyvalelems())
  
  '''For Each pair In keyvalelems()
    '''If pair <> "" Then
    '''Debug.Print "pair: " & pair
      '''BreakOnEqualSign(pair)
      '''BreakOutKeys(pair)
      '''BreakOutValues(pair)
    '''End If
  '''Next pair
End Function


' Key and Value on alternating lines.
Function BreakOnEqualSign(keyvalstr As String)
  ' TODO does PowerSplit have to know num of elements??
  Dim keyvalelems(MAXLINES) As String     
  Dim ctr As String
  Dim keyorval As Variant
  
  ctr = PowerSplit("=", keyvalstr, keyvalelems())
  
  For Each keyorval In keyvalelems()
    If keyorval <> "" Then
      Debug.Print "keyorval: " & keyorval
    End If
  Next keyorval
End Function


' Keys only.
Function BreakOutKeys(keyvalstr As String)
  Dim keyvalelems(MAXLINES) As String
  Dim ctr As String
  Dim key As Variant
  Dim i as Integer
  
  ctr = PowerSplit("=", keyvalstr, keyvalelems())
  
  i = 0
  For Each key In keyvalelems()
    If key <> "" Then
      If i Mod 2 = 0 Then
        Debug.Print "key: " & key
      End If
    End If
    i = i + 1
  Next key
End Function


' Values only.
Function BreakOutValues(keyvalstr As String)
  Dim keyvalelems(MAXLINES) As String
  Dim ctr As String
  Dim value As Variant
  Dim i as Integer
  
  ctr = PowerSplit("=", keyvalstr, keyvalelems())
  
  i = 0
  For Each value In keyvalelems()
    If value <> "" Then
      If i Mod 2 <> 0 Then
        Debug.Print "value: " & value
      End If
    End If
    i = i + 1
  Next value
End Function


' Split a string into fields, return as an array of fields
Function PowerSplit(Delim As String, StrData As String, elements() As String)
  Dim ap, tp, dp As Integer

  ap = 0
  tp = 0
  dp = InStr(1, StrData, Delim)

  If dp = 0 Then
    ' first and only field is the whole string
    elements(ap) = StrData
  Else
    Do While dp > 0
      elements(ap) = Mid(StrData, tp + 1, dp - tp - 1)
      tp = dp
      ap = ap + 1
      dp = InStr(dp + 1, StrData, Delim)
    Loop
    elements(ap) = Mid(StrData, tp + 1, Len(StrData) - tp)
  End If

  PowerSplit = ap + 1
End Function


Function FileExists(path As String) As Boolean
  On Error GoTo ERRORTRAP
  
  FileLen (path)
  FileExists = True
  Exit Function
    
ERRORTRAP:
  FileExists = False
  Exit Function
End Function
