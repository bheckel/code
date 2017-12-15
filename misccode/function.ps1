##############################################################################
#     Name: function.ps1
#
#  Summary: Demo of using functions in Powershell
#
#           To allow variables to roam around the shell after invocation, call
#           like this:
#
#           PS> . .\function.ps1
#
#           Otherwise they stay private to script
#
#  Adapted: Fri 08 Jan 2010 15:19:49 (Bob Heckel -- Mastering PowerShell)
# Modified: Tue 19 Jan 2010 10:01:40 (Bob Heckel -- PowerShell in Action)
##############################################################################

# Unrelated examples

function hello {
  "hello $args"
}
hello Bob
hello Bob Ted Carol Alice  # spaces usually separate arguments
$OFS = ','
hello Bob Ted Carol Alice
$OFS = ' '
hello Bob,Ted,Carol,Alice  # don't use commas unless want to pass a multi-valued arg

exit



Function TextOutput($txt) {
  $txt
}

TextOutput 'hello world'



Function MyPing {
  if ( $args -ne $NULL ) {
    "num args is $($args.count)"  # $() mandatory
    $args | ForEach-Object { $i++; "$i is Argument: $_" }
    ping.exe -n 2 $args
  } else {
    ping localhost
  }
}

###MyPing rtpsawn321
###MyPing



# Don't bother using RETURN statement, it's confusing.  Just know everything
# gets returned automatically.
Function VAT([double]$amount=0) {
  $factor = 0.19
  $total = $amount * $factor
  "Value added tax {0:C}" -f $total
  "Value added tax rate: {0:P}" -f $factor
}

###$result = VAT 130.67

###$result  # looks like strings but is an object

###$result.GetType().Name

# so this works too
###$result[0]



Function Debugging {
  Write-Host "`nDEBUG: Calculation will be performed"
  $a = 12 * 10
  Write-Host "DEBUG: $a"
  "`nResult is: $a`n"
  Write-Host "DEBUG: Done"
}
###$debugtext = Debugging  # only debug text prints

###$debugtext  # no debug text prints
