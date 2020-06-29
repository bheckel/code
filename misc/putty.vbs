
' $ cscript putty.vbs

Set objShell = WScript.CreateObject("WScript.Shell")

Do Until Success = True
  Success = objShell.AppActivate("putty")
  '''Wscript.Sleep 1000
Loop

' Run the last command executed.
objShell.SendKeys "{ESC}k{ENTER}"
