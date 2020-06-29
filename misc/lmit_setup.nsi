;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    Name: lmit.nsi
;
; Summary: Create an installer that will 1- install putty.exe into the normal
;          Windows Program Files location then 2- create shortcuts to
;          map_to_daeb.bat and putty @Vitalnet.
;
;          The target machine is a statistician's desktop PC.
;
;          Assumptions: These files exist:
;                       c:\cygwin\home\bqh0\bin\putty.exe
;                       K:\CABINETS\EVERYONE\Vitalnet\map_to_daeb.bat
;                       PuTTY has been configured with a Saved Session called
;                       'Vitalnet'
;
;          NOTE: this .NSI script is designed for NSIS v1.8+
;
; Created: Wed Jul 03 13:11:54 2002 (Bob Heckel)
; Modified: Fri Jul 05 15:48:20 2002 (Bob Heckel)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Name "LMIT Applications Setup"
Caption "LMIT Applications (including Vitalnet)"
OutFile "lmit_setup.exe"
; The default installation directory, InstallDir, becomes $INSTDIR
; This is needed to house the uninstaller.
;;;InstallDir "$PROGRAMFILES\Lockheed Martin IT"
; Not sure why you'd need this:
;;;InstallDirRegKey HKEY_LOCAL_MACHINE \
  ;;;               "SOFTWARE\Lockheed Martin IT\LMIT" \
  ;;;               "UninstallString"
DirShow hide ; make this show if you want to let the user change it
; Some default compiler settings (uncomment and change at will):
;;;SetCompress auto ; (can be off or force)
;;;SetDatablockOptimize on ; (can be off)
;;;CRCCheck on ; (can be off)
;;;AutoCloseWindow false ; (can be true for the window go away automatically at end)
;;;ShowInstDetails hide ; (can be show to have them shown, or nevershow to disable)
;;;SetDateSave off ; (can be on to have files restored to their orginal date)


; Default section.  Empty string makes it hidden.
Section "" 
  ; TODO how to check for already inst?? does it matter??
  ; 1.  Install PuTTY.
  CreateDirectory "$PROGRAMFILES\Putty\"
  ; Sets $OUTDIR for the 'File' command.
  SetOutPath "$PROGRAMFILES\Putty\"
  ; Not sure why you'd need this:
  ;;;WriteRegStr HKEY_LOCAL_MACHINE "SOFTWARE\Lockheed Martin Information Technology\LMIT" "" "$INSTDIR"
  ; Install this file to $OUTDIR
  File "c:\cygwin\home\bqh0\bin\putty.exe"
  ; PuTTY Start Menu config:
  CreateDirectory "$SMPROGRAMS\Putty\"
  CreateShortCut "$SMPROGRAMS\Putty\PuTTY.lnk" "$OUTDIR\putty.exe"

  ; 2.  Create shortcuts to run Vitalnet.
  CreateDirectory "$SMPROGRAMS\Lockheed Martin IT\Vitalnet\"
  CreateShortCut "$SMPROGRAMS\Lockheed Martin IT\Vitalnet\View_Vitalnet_Output.lnk" \
                 "K:\CABINETS\EVERYONE\Vitalnet\map_to_daeb.bat"
  CreateShortCut "$SMPROGRAMS\Lockheed Martin IT\Vitalnet\Vitalnet.lnk" \
                 "$OUTDIR\putty.exe" "@Vitalnet"
  CreateShortCut "$DESKTOP\View_Vitalnet_Output.lnk" \
                 "K:\CABINETS\EVERYONE\Vitalnet\map_to_daeb.bat"
  CreateShortCut "$DESKTOP\Vitalnet.lnk" \
                 "$OUTDIR\putty.exe" "@Vitalnet"

  ; TODO how to keep this filename from showing instead of text description?
  WriteUninstaller "$SMPROGRAMS\Lockheed Martin IT\lmit-uninst.exe"
SectionEnd ; end of default section


; Begin uninstall section.  Not removing PuTTY.
UninstallText "This will uninstall Lockheed Martin IT Applications from your system"
Section Uninstall
  ; This works b/c/ the uninstaller is transparently copied to the system 
  ; temporary directory for the uninstall.
  Delete "$SMPROGRAMS\Lockheed Martin IT\lmit-uninst.exe"
  Delete "$SMPROGRAMS\Lockheed Martin IT\Vitalnet\View_Vitalnet_Output.lnk"
  Delete "$SMPROGRAMS\Lockheed Martin IT\Vitalnet\Vitalnet.lnk"
  RMDir "$SMPROGRAMS\Lockheed Martin IT\Vitalnet\"
  RMDir "$SMPROGRAMS\Lockheed Martin IT\"
  Delete "$DESKTOP\View_Vitalnet_Output.lnk"
  Delete "$DESKTOP\Vitalnet.lnk"
SectionEnd ; end of uninstall section

; eof
