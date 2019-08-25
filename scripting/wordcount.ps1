##############################################################################
#     Name: wordcount.ps1
#
#  Summary: Count number of words in a textfile.  Demo file parsing and hashes.
#
#  Adapted: Fri 15 Jan 2010 10:32:46 (Bob Heckel -- Windows PowerShell in Action)
##############################################################################
  
$s = gc $PSHOME/about_Assignment_operators.help.txt

$s = [string]::join(" ", $s)

$words = $s.split(" `t", [StringSplitOptions]::RemoveEmptyEntries)

$uniq = $words | sort -uniq

$uniq.length

# Same:
# Split string into hash.  Word is key, count is value. 
$words | % { $h = @{} } { $h[$_] += 1 }

$h.PSBase.keys.count

$freq = $h.PSBase.keys | sort { $h[$_] }

$freq[-1]  # most frequent
$h['the']  # count of 'the'

-1..-10 | %{ $freq[$_]+" "+$h[$freq[$_]]}

# Same
$freq2 = $words | group | sort count
$freq2[-1]
$freq2[-1..-10]
