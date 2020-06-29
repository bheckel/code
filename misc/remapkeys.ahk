;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;     Name: remapkeys.ahk
;
;  Summary: Main AutoHotKey config file
;
;           Debug via :!cygstart % and #h then rightclick Compile this
;           .ahk when done
;
;  Created: Mon 05 Nov 2007 13:55:06 (Bob Heckel)
; Modified: Wed 31 Dec 2008 09:46:07 (Bob Heckel)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; For W2K where the icon fills up precious taskbar space
#NoTrayIcon
; and now since we can't kill this .ahk any other way:
#h::ExitApp

EnvGet, usr, USERNAME
if ( usr = "rsh86800" ) {
  ; Use the AppsKey as the missing Right Windows key on MS Natural 4000
  ; keyboard
  AppsKey::RWin
} else if ( usr = "Administrator" ) {
  ; Think (o)tto's baroque
  #o::
    Run, C:\cygwin\home\bheckel\baroque-shoutcast-playlist.pls
  ; Regain focus in Gmail
  #.::
    Click
  return
}

; Using the Windows ctl-alt combos doesn't always work so use this.
; Think (b)ash.
#b::
  Run, C:\cygwin\home\bheckel\code\misccode\cygwin.bat, C:\cygwin\home\bheckel
return

; VirtuaWin shortcut to get to main desktop
Capslock::#a
; But if you really want to use Capslock, press and hold Shift first
; TODO works sometimes others prevents the above remap from working
;;;+Capslock::Capslock

;;;#c::MsgBox %clipboard%
#c::
  ; 1 - display contents
  clip = %Clipboard%
  StringLen, mylen, clip
  ; Avoid displaying a massive clipboard:
  smclip := SubStr(clip, 1, 1000)
  MsgBox, 0, %mylen% chars (max display of 1000), %smclip%

  ; 2 - remove formatting info, turn all to text only
  ClipSaved := ClipboardAll
  tmpClipboard = %Clipboard%
  Clipboard = %tmpClipboard%
return
