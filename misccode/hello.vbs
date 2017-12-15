' $ cscript hello.vbs
Set WshShell = WScript.CreateObject("WScript.Shell")
age = InputBox("Please type your age.")
newage = age + 5
WshShell.Popup "In 5 years, you will be " & newage & "."
