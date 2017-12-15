
Loop {
  ;;;IfGreater, A_TimeIdlePhysical, 3600000, DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
  IfGreater, A_TimeIdlePhysical, 20000, DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
  ;;;Sleep, 100000
  Sleep, 10000
}
