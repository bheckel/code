
Function Basename(ByVal sFullPath As String) As String
  Dim lPos As Long, lStart As Long
  Dim sFilename As String

  ' Start at first char, usually c as in c:\...
  lStart = 1
  Do
    ' Move left to right, find location of \ until can't go further rightward.
    lPos = InStr(lStart, sFullPath, "\")
    If lPos = 0 Then
      sFilename = Right(sFullPath, Len(sFullPath) - lStart + 1)
    Else
      lStart = lPos + 1
    End If
  Loop While lPos > 0

  Basename = sFilename
End Function


Sub IndExtractUTC(fn)
  Workbooks.Open (fn)
  bn = Basename(fn)
  Workbooks(bn).Activate
  Set desc = ActiveWorkbook.ActiveSheet.Range("c1:c50000")

  prodcnt = 0
  restot = 0
  
  For Each r In desc
    If r.Value Like "5ZM0090-*" And r.Cells(1, 4) = "Peak Info" Then
     prodcnt = prodcnt + 1
     tmprestot = Val(r.Cells(1, 9))
     restot = restot + tmprestot
     lastline = r.Cells(1, 1) & " / " & r.Cells(1, 2) & " / " & r.Cells(1, 3) & " / " & r.Cells(1, 5)
    ElseIf r.Value Like "5ZM0090-*" And r.Cells(1, 4) = "Analyst (Patron ID)" Then
      ana = r.Cells(1, 7)
    ElseIf r.Value Like "5ZM0090-*" And r.Cells(1, 4) = "Instrument Name" Then
      ins = r.Cells(1, 7)
    End If
  Next
  'IndExtractUTC = True
  Debug.Print lastline & " : " & prodcnt & " items, " & restot & " checksum" _
            & ana & ins

  ActiveWorkbook.Close
End Sub


Private Sub CommandButton1_Click()
  'Call Openthem
  'Call Indextract("foobar")
  Call IndExtractUTC("c:\cygwin\home\bheckel\tmp\30Jul08_1217443168\AM0612_Valtrex_CU.csv")
End Sub
