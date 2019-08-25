Option Explicit
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: modGlobal.bas
'
' Summary: Globals for tabbed configuration utility allows reads/writes to a
'          centralized INI-format file.  Also see modUtils.bas, frmMain.bas,
'          modErrorHandler.bas
'
'          Use Project Properties to set DEBUGFLAG = 1 during debugging,
'          DEBUGFLAG = 0 for release.
'
' Created: Tue, 26 Sep 2000 14:11:56 (Bob Heckel -- parts adapted from Mark
'                                     Hewett's ToolManager)
' Modified: Wed, 13 Dec 2000 13:29:38 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

#If DEBUGFLAG Then
  Public Const LOCALBIN     = "P:\Projects\grtweak\"
  Public Const CONFIGDAT    = "P:\Projects\grtweak\config.dat"
  Public Const CONFIGDATBAK = "P:\Projects\grtweak\config.dat.bak"
  Public Const CONFIGDIR    = "P:\Projects\grtweak\"
#Else
  Public Const LOCALBIN     = "C:\local\bin"
  Public Const CONFIGDAT    = "C:\local\bin\config.dat"
  Public Const CONFIGDATBAK = "C:\local\bin\config.dat.bak"
  Public Const CONFIGDIR    = "C:\local\bin\"
#End If
Public Const ORIGDATS     = "\*.orig.dat"

' Max [segment] size, including comments.
Public Const BUFFERSZ = 2048
' Issue warning of a too large config.dat before it blows the buffer.
Public Const WARNSIZE = 4300

' Each [segment] in config.dat.
' Must be same as tabTweak.Caption
Public Const TAB1 = "Ports"
Public Const TAB2 = "BoardWatch"
Public Const TAB3 = "Automation"
Public Const TAB4 = "Grsuite"
' Determine if changes were made by user.
Public DIRTY As Boolean        
' Determine if this is a Revert operation.
Public SECONDPASS As Boolean   

Public Dict As New Dictionary
Public tmp_dict As New Dictionary
' Store TAB1's changed widget values.
Public DictChangedPort As New Dictionary 
' Store TAB2's changed widget values.
Public DictChangedBw As New Dictionary 
' Store TAB3's changed widget values.
Public DictChangedAutom As New Dictionary 
' Store TAB4's changed widget values.
Public DictChangedGrsuite As New Dictionary 

Declare Function GetPrivateProfileSectionNames Lib "kernel32" Alias "GetPrivateProfileSectionNamesA" _
    (ByVal lpReturnBuffer As String, _
     ByVal nSize As Long, _
     ByVal lpFileName As String) As Long

Declare Function GetPrivateProfileSection Lib "kernel32" Alias "GetPrivateProfileSectionA" _
    (ByVal lpAppName As String, _
    ByVal lpReturnedString As String, _
    ByVal nSize As Long, _
    ByVal lpFileName As String) As Long

Declare Function WritePrivateProfileString Lib "kernel32" Alias "WritePrivateProfileStringA" _
   (ByVal lpApplicationName As String, _
    ByVal lpKeyName As Any, _
    ByVal lpString As Any, _
    ByVal lpFileName As String) As Long
