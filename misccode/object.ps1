# PowerShell is an object-based shell rather than an object-oriented language
# so we will rarely need to do something like the pocketknife example below:
#
# Canonical 'give me a foo object with these parms' e.g.:
#   verb-noun ...
# > get-foo   -option1 -option2 bar
#
# not New foo()


$pocketknife = New-Object Object

# Add properties (NoteProperty):

Add-Member -memberType NoteProperty -name Color -value Red -inputObject $pocketknife

Add-Member -Me NoteProperty -In $pocketknife -Na Weight -Value 55

Add-Member -inputObject $pocketknife NoteProperty Manufacturer Swiss

# Specifying directly through the pipeline:
$pocketknife | Add-Member NoteProperty Blades 3

$pocketknife  # all

### echo `n
"`n"

Write-Output 'mfg by'
Write-Output '______'

$pocketknife.Manufacturer
Write-Output `n

# Add methods (ScriptMethod):

Add-Member -memberType ScriptMethod -In $pocketknife -name cut -Value { "I'm whittling now" }
$pocketknife.cut()

Add-Member -in $pocketknife ScriptMethod screw { "Phew...it's in!" }
$pocketknife.screw()

# Specifying directly through the pipeline:
$pocketknife | Add-Member ScriptMethod corkscrew { "Pop! Cheers!" }
$pocketknife.corkscrew()
