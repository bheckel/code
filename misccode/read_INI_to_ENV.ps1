##############################################################################
#     Name: read_INI_to_ENV.ps1
#
#  Summary: Demo of pushing INI file contents to PowerShell's environment vars.
#
#  Adapted: Fri 29 Jan 2010 12:59:47 (Bob Heckel -- PowerShell In Action)
##############################################################################

###$f = ${c:LIFT.ini}  # slurp - assumes .ini in PWD
$f = ${C:\cygwin\home\bheckel\projects\datapost\tmp\VALTREX_Caplets\CODE\util\LIFT.ini}  # slurp

$f | %{ $k,$v=$_.split('='); set-item -path env:$k -value $v }

ls env:l*
