' For DataPost UTC
Sub simulateDP()
  fn = "c:\cygwin\home\bheckel\projects\datapost\tmp\valtrex_caplets\_utcproto\AM0612_Valtrex_CU.csv"
  Workbooks.Open (fn)
  bn = "AM0612_Valtrex_CU.csv"
  Workbooks(bn).Activate
  ' 5ZM0090-040000124969-01
  Set desc = ActiveWorkbook.ActiveSheet.Range("c1:c65535")

  fnum = FreeFile
  tmp = Environ("TEMP")
  Open tmp & "\utc4.2.1.1a.csv" For Output As #fnum
  Debug.Print "file created: " & tmp & "\utc4.2.1.1a.csv"

  prodcnt = 0
  restot = 0
  resavg = 0
  lastgrp = "none"
  
  Print #fnum, "description,count,result,average"
  
  For Each r In desc
    If lastgrp = r.Value And r.Cells(1, 4) = "Peak Info" Then ' existing group
      prodcnt = prodcnt + 1
      tmprestot = Val(r.Cells(1, 9))
      restot = restot + tmprestot
      resavg = restot / prodcnt
    ElseIf r.Cells(1, 4) = "Peak Info" Then ' new group
      If lastline <> "" And Not r.Cells(1, 1) Like "T0*" Then ' not on 1st row, not a T0 batch
        Print #fnum, lastline & "," & prodcnt & "," & Round(restot, 2) & "," & resavg
      End If
      prodcnt = 1
      tmprestot = Val(r.Cells(1, 9))
      restot = tmprestot
    End If
    
'    If r.Cells(1, 4) = "Analyst (Patron ID)" Then
'      ana = r.Cells(1, 7)
'    End If
'
'    If r.Cells(1, 4) = "Instrument Name" Then
'      ins = r.Cells(1, 7)
'    End If

    If r.Cells(1, 1) <> "" And Not r.Cells(1, 1) Like "T0*" Then
      ' Valtrex Caplets 1000 mg (Dartford)       / 5ZM0090-040000124969-0/ A                     / AM0612-HPLC Valacyclov/ 17-May-05
      lastline = r.Cells(1, 1).Offset(1, -2) & " / " & r.Cells(1, 1) & " / " & r.Cells(1, 2) & " / " & r.Cells(1, 3) & " / " & r.Cells(1, 5)
    End If
  
'    If lastgrp <> "none" And lastgrp <> r.Value Then
'      If ana <> "" And ins <> "" And r.Cells(1, 1) <> "" Then
'        Print #fnum, lastline & " : " & "analyst " & ana & " instrument " & ins
'      End If
'    End If
  
    lastgrp = r.Value
  Next

  ActiveWorkbook.Close
  Close #fnum
End Sub
