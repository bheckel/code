; NSIS SuperPimp Template
; Modified: Mon 30 Apr 2001 09:04:27 (Bob Heckel)
; NOTE: this .NSI script is designed for NSIS v1.3+

; [header]
Name "GenRad Service Pack 1.2"
Caption "Custom GenRad Applications Update"
;;;Icon "grsunb.ico"
;;;UninstallIcon "foo.ico"
OutFile "genrad_svcpk1.2.exe"
SilentInstall normal  ; silent|normal|silentlog
CRCCheck on  ; on|off
BGGradient off  ; [topcolor bottomcolor[textcolor|notext]]
InstallColors FF0000 00FF00  ; foreground|background
;;;UninstallText "foo"
;;;UninstallExeName foo.exe

; [license]
;;;LicenseText "foo"
;;;LicenseData foo.txt

; [component]
ComponentText "foo"
; If want user to take only one of your options, place InstType /NOCUSTOM
; the other InstType lines.
;;;InstType  ; /NOCUSTOM|install_type_name
;;;EnabledBitmap foo.bmp
;;;DisabledBitmap foo.bmp

; [directory]
DirShow hide  ; show|hide
DirText "foo"
InstallDir "c:\local"
;;;InstallDirRegKey "foor" "foos" "foon" ; rootkey subkey keyname

; [install page]
AutoCloseWindow false  ; true|false
ShowInstDetails show  ; hide|show|nevershow

; [compiler options]
Section ""  ; (default section)
SetOutPath "$INSTDIR"
;;;WriteRegStr HKEY_LOCAL_MACHINE "SOFTWARE\Solectron\GenRad Service Pack 1.2" "" "$INSTDIR"
SectionEnd  ; end of default section
SetOverwrite ifnewer  ; on|off|try|ifnewer
SetCompress auto  ; auto|force|off
SetDatablockOptimize on ; on if files are small  on|off
SetDateSave on ; on|off


; eof

