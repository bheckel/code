;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;     Name: max.ahk
;
;  Summary: Windows window toggler - maximizes or restores
;
;           Debug via :!cygstart % then rightclick 'Compile Script' this
;           .ahk
;
; Modified: Tue 02 Jun 2009 10:22:02 (Bob Heckel)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Use the AppsKey as the missing Right Windows key on MS Natural 4000
; keyboard
if ( usr = "rsh86800" ) {
  AppsKey::RWin
}

ToggleWinMax() {
  WinGet state, MinMax, A
  if state=1  ; maximized
    WinRestore A
  else WinMaximize A
}

#J::ToggleWinMax()  ; winkey-j

