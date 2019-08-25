##############################################################################
#     Name: define_word.ps1
#
#  Summary: Look up a word using IE.  There are better ways to do this but
#           this is a good demo of controlling Internet Explorer programmatically.
#
#  Adapted: Fri 15 Jan 2010 10:32:46 (Bob Heckel -- Windows PowerShell in Action)
##############################################################################

param($word = $(throw "You must specify a word to look up."), [switch] $visible)

[void] [Reflection.Assembly]::LoadWithPartialName("System.Web")

$ie = new-object -com "InternetExplorer.Application"
$ie.Visible = $visible
$ie.Navigate2("http://en.wiktionary.org/wiki/" + [Web.HttpUtility]::UrlEncode($word))

while ($ie.ReadyState -ne 4) {
  start-sleep 1
}

$bodyContent = $ie.Document.getElementById("bodyContent").innerHtml
$showText=$false
$lastWasBlank = $true
$gotResult = $false

switch -regex ($bodyContent.Split("`n")) {
  '^\<DIV class=infl-table' {
    $showText = $true
    continue
  }
  '^\<DIV|\<hr' {
    $showText = $false
  }
  '\[.*edit.*\].*Translations' {
    $showText = $false
  }
  {$showText} {
    $line = $_ -replace '\<[^>]+\>', ' '
    $line = ($line -replace '[ \t]{2,}', ' ').Trim()
    if ($line.Length) {
      $line
      $gotResult = $true
      $lineWasBlank = $false
    } else {
      if (! $lineWasBlank) {
        $line
        $lineWasBlank = $true
      }
    }
  }
}

if (! $gotResult) {
  "No Answer Found for: $word"
}
if (! $visible) {
  $ie.Quit()
}
