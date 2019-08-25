Attribute VB_Name = "modMain"
Option Explicit
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Program Name: split_depts.bas
'
'      Summary: Toplevel pgm.  Takes large Matrix spdshts and breaks out
'               into several departmental spshts.
'
'      Created: Fri Jun 11 1999 10:37:55 (Bob Heckel)
'     Modified: Tue, 10 Aug 1999 10:32:51 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' Matrix report:
' TODO allow selection of spdsht with dialog box.
' Toggle. Also see modCopied for toggle.
'''Private Const MATRIXSPDSHT = "D:\matrixsplit\inst\spend_i.xls"
Private Const MATRIXSPDSHT = "D:\matrixsplit\eng\spend_e.xls"
' Indicates the last row of the desired selection:
Private Const ENDROWNAME = "TOTAL NET EXPENSE"

Sub SplitDeptsMain()
  'TODO format the end product.
  Dim i As Integer
  Dim sSpecificDeptName As String
  Dim sCroppedMatrixName As String
  Dim sActiveFocusDept As String
  
  Workbooks.Open FileName:=MATRIXSPDSHT
  ' Get array of 540xxxx depts.
  If Harvest(MATRIXSPDSHT) Then
    Beep
  Else
    MsgBox "Failure at Function Harvest"
  End If
  
 ' For each found deptno.
  For i = 0 To UBound(gDeptnos)
    Debug.Print gDeptnos(i)
    sActiveFocusDept = gDeptnos(i)
    
    ' Highlight a found deptno.
    '''If HighlightArea(i, ENDROWNAME, 5, 1) Then Beep
    If HighlightArea(sActiveFocusDept, ENDROWNAME, 5, 1) Then
      Beep
    Else
      MsgBox "Failure at Function HighlightArea"
    End If
    
    ' Now that a dept is highlighted, copy & paste into a newly created 540xxxx.xls
    sSpecificDeptName = gDeptnos(i) & ".xls"
    sCroppedMatrixName = Basename(MATRIXSPDSHT)
    If Copied(sSpecificDeptName, sCroppedMatrixName) Then
      Beep
    Else
      MsgBox "Failure at Function Copied"
    End If
  Next
  
  Workbooks(sCroppedMatrixName).Close SaveChanges:=False
End Sub
