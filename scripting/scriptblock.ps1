##############################################################################
#     Name: array.ps1
#
#  Summary: Powershell ScriptBlock - add functionality to Powershell
#
#           TODO not working
#
#  Adapted: Fri 15 Jan 2010 10:32:46 (Bob Heckel -- Windows PowerShell in Action)
##############################################################################
 
$s = 'foobar'

$sb = {
  $a = [char[]] $this
  [array]::reverse($a)
  [string]::join('',$a)
}

add-member -in $s scriptmethod reverse $sb

$s.Reverse()
