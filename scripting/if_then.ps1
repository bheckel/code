
If ( $a -gt 10 ) {
  "$a is larger than 10"
} ElseIf ( $a -eq 10 ) {
  "$a is exactly 10"
} Else {
  "$a is less than 10"
}


# If exactly 3 files contain the word 'spam', print the string
if (( dir *.txt | select-string spam ).Length -eq 3) {
  "Spam! Spam! Spam!"
}
