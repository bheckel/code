VERSION 5.00
Begin VB.Form frmSplitter 
   Caption         =   "RSH Splitter"
   ClientHeight    =   5685
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4470
   Icon            =   "frmSplitter.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   4000
   ScaleMode       =   0  'User
   ScaleWidth      =   2865.385
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton cmdGlue 
      Caption         =   "&Glue"
      Height          =   495
      Left            =   3000
      TabIndex        =   6
      Top             =   2040
      Width           =   1215
   End
   Begin VB.CommandButton cmdExit 
      Caption         =   "&Exit"
      Height          =   495
      Left            =   3000
      TabIndex        =   4
      Top             =   4800
      Width           =   1215
   End
   Begin VB.CommandButton cmdSplit 
      Caption         =   "&Split"
      Height          =   495
      Left            =   3000
      TabIndex        =   3
      Top             =   1200
      Width           =   1215
   End
   Begin VB.FileListBox File1 
      Height          =   3600
      Left            =   120
      TabIndex        =   2
      Top             =   1800
      Width           =   2415
   End
   Begin VB.DirListBox Dir1 
      Height          =   1215
      Left            =   120
      TabIndex        =   1
      Top             =   480
      Width           =   2415
   End
   Begin VB.DriveListBox Drive1 
      Height          =   315
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   2415
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      BorderStyle     =   1  'Fixed Single
      Caption         =   "RSH Splitter v1.0"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   3000
      TabIndex        =   5
      Top             =   240
      Width           =   1215
   End
End
Attribute VB_Name = "frmSplitter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

'To use Yes/No box with dialogs.dll class.
Dim dlg As clsDialogs

Function NoOfBytesRip(lngLOFbytes As Long) As Byte
  'How many pieces to break file into, based on its size.
  Select Case lngLOFbytes
  Case lngLOFbytes = 0
    MsgBox "Empty file."
    NoOfBytesRip = 0
  Case lngLOFbytes < 100
    NoOfBytesRip = 1
  Case lngLOFbytes >= 100 And lngLOFbytes < 200
    NoOfBytesRip = 2
  Case lngLOFbytes >= 200 And lngLOFbytes < 300
    NoOfBytesRip = 3
  Case Else
    MsgBox "This one's a monster."
    NoOfBytesRip = 4
  End Select
End Function

Function Split(strInfile As String) As Boolean
  On Error GoTo Bomb
  Dim strOutfile As String
  Dim intFreefileno As Integer
  Dim lngWhereSplit As Long
  Dim i As Long
  Dim x As String
  Dim strTemp As String
  Dim intNextFree As Integer
  Dim bytHowManyTemps As Byte
  Dim j As Long
  
  MousePointer = 11
  
  intFreefileno = FreeFile
  Open strInfile For Binary As intFreefileno
  i = LOF(intFreefileno)
  bytHowManyTemps = NoOfBytesRip(i)
  lngWhereSplit = i / bytHowManyTemps
  MsgBox "Bytes div by " & bytHowManyTemps & " is " & lngWhereSplit
  
  For j = 1 To bytHowManyTemps
    'Taking half (or whatever) file in one big chunk, no For Next, etc. needed.
    x = String(lngWhereSplit, " ")
    Get intFreefileno, , x
    
    strTemp = "C:\temp.split" & j & ".txt"
    intNextFree = FreeFile
    Open strTemp For Binary As intNextFree
    Put intNextFree, , x
    MsgBox "Finished creating " & j
    Close intNextFree
  Next j
  
  Close intFreefileno
  MousePointer = 0
  Split = True
  Exit Function
  
Bomb:
  Split = False
End Function

Private Sub cmdExit_Click()
  Dim x As Integer
  
  x = dlg.YNBox("Ready to Leave?", "Depart from Splitter?")
  If x = vbYes Then
    End
  Else
    MsgBox "Excellent decision."
  End If
End Sub

Private Sub cmdSplit_Click()
  Dim x As String
  Dim strPath As String
  
  strPath = Dir1.Path & "\" & File1.filename
  x = Split(strPath)
  If x = False Then
    MsgBox "Error in splitsville."
  End If
End Sub

Private Sub Dir1_Change()
  'Synchronize Files with Directory control.
  File1.Path = Dir1.Path
End Sub

Private Sub Drive1_Change()
  'Synchronize Directory with Drive control.
  Dir1.Path = Drive1.Drive
End Sub

Private Sub Form_Load()
  Set dlg = New clsDialogs
End Sub

Private Sub Form_Unload(Cancel As Integer)
  Set dlg = Nothing
End Sub
