
$pattern = "^ERROR:"  # regex
$file = Get-Content junk.txt
$file | Select-String $pattern
