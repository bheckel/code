TODO not working to avoid timeout

MsgBox, begin-preventing timeout on this box by moving mouse every 20 min

Loop {
  IfGreater, A_TimeIdlePhysical, 900000, MouseMove, 1, 1, 100, R
  Sleep, 100000
}
