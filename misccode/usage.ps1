##############################################################################
#     Name: wordcount.ps1 (s/b symlinked as heredoc.ps1)
#
#  Summary: Count number of words in a textfile.  Demo file parsing and hashes.
#
#  Adapted: Fri 15 Jan 2010 10:32:46 (Bob Heckel -- Windows PowerShell in Action)
##############################################################################
  

if ($args.count -gt 0) {
@"
  Usage for Get-Spelling:
  Copy some text into the clipboard, then run this script. It
  will display the Word spellcheck tool that will let you
  correct the spelling on the text you've selected. When you are
  done it will put the text back into the clipboard so you can
  paste it back into the original document.
"@  # must be at col 1!
  exit 0
}
