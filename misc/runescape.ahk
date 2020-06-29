; Close an idle processor hogging Runescape window
Loop {
  IfGreater, A_TimeIdlePhysical, 7000, WinClose Untitled - Notepad
}
