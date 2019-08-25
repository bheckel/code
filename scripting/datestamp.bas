'VB_Name
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Program Name: datestamp.bas
'
'      Summary: Provide a date stamp for Claire's matrix split macro.
'               Usage: Datestamp()  returns text e.g. 'September
'               1999 Close Month'
'               Datestamp("a2") prints e.g. 'September 1999 Close Month' to
'               the specified cell address.
'
'               Assumes this is run during Day 6 - 10 of NT Financial Close.
'
'      Created: Mon, 11 Oct 1999 14:23:02 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub harness()
  Call Datestamp
  Debug.Print Datestamp
  Call Datestamp("a2")
End Sub

' Variant required for Optionals.
Function Datestamp(Optional sWhere as Variant)
  Dim sCurrentday As String
  Dim bCurrentYear As String
  Dim bPreviousMo As Byte

  sCurrentday = Date
  bCurrentYear = Year(sCurrentday)
  ' Go back one month since you're reporting for the previous mo's close data.
  bPreviousMo = Month(sCurrentday) - 1
  
  Select Case bPreviousMo
    Case Is = 1
      Datestamp = "January " & bCurrentYear & " Close Month"
    Case Is = 2
      Datestamp = "February " & bCurrentYear & " Close Month"
    Case Is = 3
      Datestamp = "March " & bCurrentYear & " Close Month"
    Case Is = 4
      Datestamp = "April " & bCurrentYear & " Close Month"
    Case Is = 5
      Datestamp = "May " & bCurrentYear & " Close Month"
    Case Is = 6
      Datestamp = "June " & bCurrentYear & " Close Month"
    Case Is = 7
      Datestamp = "July " & bCurrentYear & " Close Month"
    Case Is = 8
      Datestamp = "August " & bCurrentYear & " Close Month"
    Case Is = 9
      Datestamp = "September " & bCurrentYear & " Close Month"
    Case Is = 10
      Datestamp = "October " & bCurrentYear & " Close Month"
    Case Is = 11
      Datestamp = "November " & bCurrentYear & " Close Month"
    Case Is = 0
      Datestamp = "December " & bCurrentYear & " Close Month"
    Case Else
      MsgBox "An error has occurred in Function Datestamp."
  End Select

  If Not IsMissing(sWhere) Then
    Range(sWhere).Value = Datestamp
  End If
    
End Function
  
