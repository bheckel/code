
Const path As String = "c:\cygwin\home\bheckel\projects\datapost\tmp\valtrex_caplets\_utcproto"


Function Basename(ByVal sFullPath As String) As String
  Dim lPos As Long, lStart As Long
  Dim sFilename As String

  ' Start at first char, usually c as in c:\...
  lStart = 1
  Do
    ' Move left to right, find location of \ until we can't go further rightward
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
  ' 5ZM0090-040000124969-01
  Set desc = ActiveWorkbook.ActiveSheet.Range("c1:c6553")

  prodcnt = 0
  restot = 0
  lastgrp = "none"
  
  For Each r In desc
    If lastgrp = r.Value And r.Cells(1, 4) = "Peak Info" Then ' existing group
      prodcnt = prodcnt + 1
      tmprestot = Val(r.Cells(1, 9))
      restot = restot + tmprestot
    ElseIf r.Cells(1, 4) = "Peak Info" Then ' new group
      If lastgrp <> "none" Then ' not on 1st row
        Debug.Print lastline & " : " & prodcnt & " items, " & Round(restot, 2) & " checksum"
      End If
      prodcnt = 1
      tmprestot = Val(r.Cells(1, 9))
      restot = tmprestot
    End If
    
    If r.Cells(1, 4) = "Analyst (Patron ID)" Then
      ana = r.Cells(1, 7)
    End If
          
    If r.Cells(1, 4) = "Instrument Name" Then
      ins = r.Cells(1, 7)
    End If

    If r.Cells(1, 1) <> "" Then
      ' Valtrex Caplets 1000 mg (Dartford)       / 5ZM0090-040000124969-0/ A                     / AM0612-HPLC Valacyclov/ 17-May-05
      lastline = r.Cells(1, 1).Offset(1, -2) & " / " & r.Cells(1, 1) & " / " & r.Cells(1, 2) & " / " & r.Cells(1, 3) & " / " & r.Cells(1, 5)
    End If
  
    If lastgrp <> "none" And lastgrp <> r.Value Then
      If ana <> "" And ins <> "" And r.Cells(1, 1) <> "" Then
        Debug.Print lastline & " : " & "analyst " & ana & " instrument " & ins
      End If
    End If
  
    lastgrp = r.Value
  Next

  ActiveWorkbook.Close
End Sub

Sub IndLookupTSRtoBatchUTC(fn)
  Workbooks.Open (fn)
  bn = Basename(fn)
  Workbooks(bn).Activate
  Set tsr = ActiveWorkbook.ActiveSheet.Range("c1:c65535")
  
  For Each r In tsr
    If r.Cells(1, 1).Offset(1, -2) Like "Val*" And r.Value Like "T*" And r.Cells(1, 7) Like "?ZM????" Then
      Debug.Print r.Value; " " & r.Cells(1, 7)
    End If
  Next

  ActiveWorkbook.Close
  'Compare with SAS Log "!!!For UTC-Before Map: TSR to mfg_batch map verification:"
End Sub

Sub PALookupILUTC(fn)
  Workbooks.Open (fn)
  bn = Basename(fn)
  Workbooks(bn).Activate
  Set il = ActiveWorkbook.Worksheets("4117344").Range("a1:a65535")
  ' TODO                              ...
  
  For Each r In il
    If r.Value <> "" Then
      Debug.Print r.Cells(1, 3) & ""; r.Cells(1, 2) & " "; r.Cells(1, 4) & " " & r.Value
    End If
  Next

  ActiveWorkbook.Close
  'Compare with SAS Log "!!!For UTC-IL Map:"
End Sub

Sub IndRulesUTC(fn)
' Probably won't use this, using Log instead
  Workbooks.Open (fn)
  bn = Basename(fn)
  Workbooks(bn).Activate
  Set sc = ActiveWorkbook.ActiveSheet.Range("c1:c65535")
  
  For Each r In sc
    If r.Value Like "SC*" Then
      Debug.Print r.Value
    End If
  Next

  ActiveWorkbook.Close
End Sub

Sub SumAggUTC(fn)
  Workbooks.Open (fn)
  bn = Basename(fn)
  Workbooks(bn).Activate
  Set desc = ActiveWorkbook.ActiveSheet.Range("c1:c65535")

  prodcnt = 0
  restot = 0
  lastgrp = "none"
  
  For Each r In desc
    If lastgrp = r.Value And r.Cells(1, 4) = "Peak Info" Then ' existing grp cont.
      prodcnt = prodcnt + 1
      tmprestot = Val(r.Cells(1, 9))
      restot = restot + tmprestot
      avg = restot / prodcnt
    ElseIf r.Cells(1, 4) = "Peak Info" Then ' start new grp
      prodcnt = 1
      tmprestot = Val(r.Cells(1, 9))
      restot = tmprestot
    End If
    
    If lastgrp <> r.Value Then
      If lastgrp <> "none" And r.Cells(1, 2) = "A" And r.Cells(1, 4) = "Peak Info" Then
        Debug.Print lastgrp & " average: " & Round(avg, 2) & " " & r.Cells(1, 2) & " " & bn
      End If
    End If
    
    lastgrp = r.Value
  Next

  ActiveWorkbook.Close
End Sub

Private Sub btnIndExtract_Click()
  Call IndExtractUTC("C:\cygwin\home\bheckel\projects\datapost\tmp\VALTREX_Caplets\_utcproto\AM0612_Valtrex_CU.csv")
  ' TODO each meth - do they all use "Peak Info" or do we need parameterization?
End Sub

Private Sub btnIndLookup_Click()
  Call IndLookupTSRtoBatchUTC("C:\cygwin\home\bheckel\projects\datapost\tmp\VALTREX_Caplets\_utcproto\GSK_ID_All.csv")
  Call PALookupILUTC(path & "\mapping process_order to inspection_lot to mfg_batch.xls")
  ' TODO other ind lookups
End Sub

Private Sub btnIndRules_Click()
  ' probably just do manually
  'Call IndRulesUTC("c:\cygwin\home\bheckel\tmp\30Jul08_1217443168\AM0656_AM0613_Valtrex_Dissolution.csv")
End Sub

Private Sub btnSumAggUTC_Click()
  Call SumAggUTC("C:\cygwin\home\bheckel\projects\datapost\tmp\VALTREX_Caplets\_utcproto\AM0612_Valtrex_CU.csv")
  ' TODO each meth's .csv
End Sub

