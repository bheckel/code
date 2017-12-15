
function Get-CheckSum($path) {
  $sum=0
  get-content -encoding byte -read 10kb $path | % {
    foreach ($byte in $_) { $sum += $byte }
  }
  $sum
}

Get-CheckSum 'junk1'
Get-CheckSum 'junk2'
