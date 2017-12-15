' http://www.winguides.com/scripting/reference.php?category=3
' http://msdn.microsoft.com/library/default.asp?url=/library/en-us/script56/html/wsconWSHBasics.asp
' $ notepad&; cscript notepad.vbs

set objShell = WScript.CreateObject("WScript.Shell")
set WshEnv = objShell.Environment("PROCESS")
Wscript.Echo WshEnv("PATH")

objShell.Run("%windir%\notepad.exe")

do until rc = True
  rc = objShell.AppActivate("notepad")
  Wscript.Sleep 1000
loop

objShell.SendKeys "ok"
objShell.SendKeys "%f"
objShell.SendKeys "s"
objShell.SendKeys "foo.txt{ENTER}"
objShell.SendKeys "^y"
Wscript.Sleep 4000  ' 1000 eq 1 second
objShell.SendKeys "%{F4}"

if rc = True then
  objShell.LogEvent 0, "Success notepad.vbs"
else
  objShell.LogEvent 2, "Failure notepad.vbs"
end if

Wscript.Echo "return code: " & rc
Wscript.Quit
