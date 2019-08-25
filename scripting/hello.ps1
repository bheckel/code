
# 'echo' in cmd
###Write-Output -inputobject 'hello world'
Write-Output -i 'hello world'

write 'simpler hello world'

'simplest hello world of all time'

$PSHOME  # no echo, print, etc. needed


# cd e:\cygwin\home\bheckel\code\misccode
# ./hello
$text = Read-Host 'Your entry'  # ':' is added for you by PS
$text



function helloworld { 
  $test=1; $script:test2=2; $global:test3=3; echo ok
  ###$test=1; $script:test2=2; $global:test3=3; $test4=$1; echo ok
  write $test
  write $test2
  write "available after execution: $test3"
  ###write $test4

  Get-Date

  $test.GetType().Name
  (1.234).GetType().Name
  (Get-Date).GetType().Name
}

###helloworld(4)
###helloworld
