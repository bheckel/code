
Do {
  $input = Read-Host "enter a web address"
  if ($input -like "www.*.*") {
    # Input correct, no further query:
    $furtherquery = $false
  } else {
    Write-Host -Fore "Red" "Please give a valid web address. E.g. www.foo.com"
    $furtherquery = $true
  }
} While ($furtherquery)
