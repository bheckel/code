#!/bin/bash
##############################################################################
#     Name: keypress.bash.sh
#
#  Summary: Don't require a carriage return.
#
#  Adapted: Sun 06 Nov 2005 12:26:50 (Bob Heckel -- November 2005 
#                                     Shell Corner: Reading Function and
#                                     Cursor Keys in a Shell Script)
##############################################################################
  
# The field separator is set to an empty string so that read doesn't ignore a
# leading space (it's a valid keystroke, so we want it); the -r option
# disables backslash escaping; -s turns off echoing of keystrokes; -n1 tells
# bash to read a single character only.
#
# The -d '' option tells read not to regard a newline (or any other character)
# as the end of input; this allows a newline to be stored in a variable. We
# have told read to stop after the first key (-n1) is received so it doesn't
# read forever.
#
# The last argument uses _KEY to store the character if no variable name is
# given on the command line. It uses ${@:-_KEY} to add options and/or a
# variable name to the list of arguments. (Note that if you use an option
# without including a variable name, the keystroke will be stored in $REPLY.) 
_key() {
  IFS= read -r -s -n1 -d '' "${@:-_KEY}"
}


while :
do
  printf "\n\n"
  printf "\t%d. %s\n" 1 "Do something" \
                      2 "Do something else" \
                      3 "Quit"
  _key
  case $_KEY in
     1) printf "\n%s\n\n" Something ;;
     2) printf "\n%s\n\n" "Something else" ;;
     3) break ;;
     *) printf "\a\n%s\n\n" "Invalid choice; try again"
        continue
        ;;
  esac
  printf ">>> %s " "Press any key to continue"
  _key
done
