
$data = get-content junk.txt |
foreach { 
 $h = @{}
 $h.level, [int]$h.lower, [int]$h.upper = $_.split()
 $h
}

$data.length
$data[0]
"`n"
$data[0].level
"`n"
$data[1].upper.gettype().fullname



# junk.txt:
# quiet 0 25
# normal 26 50
# loud 51 75
# noisy 75 100
