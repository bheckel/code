##############################################################################
#     Name: switch.ps1
#
#  Summary: Powershell switch control (i.e. non-cmdlet) statement
#
#  Adapted: Fri 15 Jan 2010 10:32:46 (Bob Heckel -- Windows PowerShell in Action)
##############################################################################
 
# Scalars:

switch ( 4 ) {
  1 { "One" }
  2 { "two" }
  2 { "also two" }  # both 2s print
  3 { "Three" }
  4 { "four" }
  {$_ -gt 3} { 'large' }
  default {"none of the above"}
}


switch ( 'abc' ) {
  a   { 'just a' }
  ABC { 'abc case insensitive, use -c(ase) if needed' }
  # silent exit if no match anything
}


switch -wildcard ( 'NFL' ) {
  a   { 'just a' }
  ABC { 'abc case insensitive, use -c(ase) if needed' }
  n*  { "$_ starts with n" }
}


# See regex.ps1 for capturing, etc.
switch -regex ( 'NFL' ) {
  a       { 'just a' }
  ABC     { 'abc case insensitive, use -c(ase) if needed' }
  '..l$'  { "$_ three chars ends with l" }
}



# Collections:


switch ( 1,2,3,4,5,6 ) {
  ###{$_ % 2} {"Odd $_"; continue}  # stop matching, go to top of loop
  {$_ % 2} {"Odd $_"; break}  # exit switch
  4        {"FOUR"}
  default  {"Even $_"}
}


$dll=$txt=$log=0
switch -wildcard (dir c:\temp) {
  *.dll {$dll+=$_.length; continue}
  *.txt {$txt+=$_.length; continue}
  *.log {$log+=$_.length; continue}
}
"found DLL: $dll TXT: $txt LOG: $log"


switch -regex -file c:\windows\windowsupdate.log {  # -file  gives non-slurp, may be more efficient
  'START.*Finding updates.*AutomaticUpdates' {$au++}
  'START.*Finding updates.*Defender'         {$du++}
  'START.*Finding updates.*SMS'              {$su++}
}
"Automatic:$au Defender:$du SMS:$su"
