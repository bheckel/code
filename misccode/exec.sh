#!/bin/bash
##############################################################################
#     Name: exec.sh
#
#  Summary: Demo of exec builtin.
#
# Adapted: Thu 13 Sep 2001 13:17:40 (Bob Heckel--
#                       http://www.linuxdoc.org/LDP/abs/html/internal.html)
##############################################################################

# Using the exec builtin, the shell does not fork, and the command exec'ed
# replaces the shell. 
#
# When used in a script, therefore, it forces an exit from the script when the
# exec'ed command terminates. For this reason, if an exec appears in a script,
# it would probably be the final command.

exec echo "Exiting \"$0\"."   # Exit from script.

# The following lines never execute.

echo "This will never echo."

exit 0  # will not exit here
