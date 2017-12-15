
Set objShell = WScript.CreateObject("WScript.Shell")

objShell.Run "Notepad.exe"

Do Until Success = True
  Success = objShell.AppActivate("Notepad")
  Wscript.Sleep 1000
Loop

objShell.SendKeys "This is a {t 5}est."
