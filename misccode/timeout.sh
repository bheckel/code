#!/bin/bash
##############################################################################
#     Name: timeout.sh
#
#  Summary: Demo of timing out.
#
#          Admittedly, this is a kludgy implementation of timed input,
#          but pretty much as good as can be done with Bash.
#
#          If you need something a bit more elegant...
#          consider writing the application in C or C++,
#          using appropriate library functions, such as 'alarm' and 'setitimer'.
#
#  Adapted: Fri 07 Sep 2001 15:21:29 (Bob #  Heckel--
#                http://www.linuxdoc.org/LDP/abs/html/internalvariables.html)
##############################################################################

TIMELIMIT=3  # Three seconds in this instance.

PrintAnswer() {
  if [ "$answer" = TIMEOUT ]; then
    echo $answer
  else       # Don't want to mix up the two instances. 
    echo "Your favorite veggie is $answer"
    kill $!  # Kills no longer needed TimerOn function running in background.
             # $! is PID of last job running in background.
  fi
}  


TimerOn() {
  # Waits 3 seconds, then sends sigalarm to script.
  sleep $TIMELIMIT && kill -s 14 $$ &
}  


Int14Vector() {
  answer="TIMEOUT"
  PrintAnswer
  exit 14
}  

trap Int14Vector 14   # Timer interrupt (14) subverted for our purposes.

echo "What is your favorite vegetable "
TimerOn
read answer
PrintAnswer

exit 0
