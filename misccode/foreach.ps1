##############################################################################
#     Name: foreach.ps1
#
#  Summary: Another Powershell loop construct.  Usually better than FOR
#
#  Adapted: Fri 15 Jan 2010 10:32:46 (Bob Heckel -- Windows PowerShell in Action)
##############################################################################
 
foreach ( $f in dir *.txt ) {
  $c += 1; $l += $f.length
  ###"DEBUG $foreach"
}
$c
"total length all textfiles in this directory: $l"


# Same (also note $f, $c and $l scope that requires this line)
###$f = ''; $c = 0; $l = 0;
$f = ''; $c = $l = 0;
###dir *.txt | Foreach-Object { $c += 1; $l += $_.length }
dir *.txt | foreach { $c += 1; $l += $_.length }
$c
"total length all textfiles in this directory: $l"


#              BEG                   END
gps svchost |%{$t=0}{$t+=$_.handles}{$t}
