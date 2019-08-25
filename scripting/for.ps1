##############################################################################
#     Name: for.ps1
#
#  Summary: Powershell loop.  foreach is usually better.
#
#  Adapted: Fri 15 Jan 2010 10:32:46 (Bob Heckel -- Windows PowerShell in Action)
##############################################################################
 
for ( $($result=@(); $i=0); $i -lt 5; $i++ ) {
  $result += $i
}
"$result"



$svchosts = get-process svchost
for ( $($total=0;$i=0); $i -lt $svchosts.count; $i++ ) {
  $total += $svchosts[$i].handles
}
"sum of handles used by 'svchost' process: $total"
