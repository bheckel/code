##############################################################################
#     Name: msgbox.ps1
#
#  Summary: Powershell message box using Windows Scripting Host
#
#  Adapted: Fri 15 Jan 2010 10:32:46 (Bob Heckel -- Windows PowerShell in Action)
##############################################################################

# Must be 1st executable line in script
###param($msg='hello world')
param($msg = $(throw "error: you must specify a message"))

$wshell = new-object -com WScript.Shell
$wshell.Popup("$msg")
