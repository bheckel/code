#!/bin/bash
##############################################################################
#     Name: read.sh
#
#  Summary: Demo of the shell's read builtin.
#
#  Adapted: Wed 12 Sep 2001 10:54:54 (Bob Heckel--
#                        http://www.linuxdoc.org/LDP/abs/html/internal.html)
##############################################################################

# see also gitall

echo -n "Enter the value of variable 'var1': "
# Note no '$' in front of var1, since it is only being set.
read var1
echo "simple: var1 = $var1"
echo

#########

# A single 'read' statement can set multiple variables.
echo -n "Enter two words (separated by a space or tab): "
read var2 var3
# If you input only one value, the other variable(s) will remain unset (null).
echo "mult input read: var2 = $var2      var3 = $var3"
echo

#########

# Normally, inputting a \ suppresses a newline during input to a read. The -r
# option causes an inputted \ to be interpreted literally.
echo "Enter a string terminated by a \\, then press <ENTER>."
echo "Then, enter a second string, and again press <ENTER>."
read var4     # the "\" suppresses the newline, when reading "var4"

#     var1 = first line second line
echo "line continuation: var4 = $var4"

# For each line terminated by a "\",
# you get a prompt on the next line to continue feeding characters into var1.

echo; echo

#########

echo "Enter another string terminated by a \\ , then press <ENTER>."
read -r var5  # -r causes the "\" to be read literally.

#                        var2 = first line \
echo "literal backslash: var2 = $var5"

# Data entry terminates with the first <ENTER>.
echo 

#########
 
# Echo keystrokes without hitting ENTER.
read -s -n1 -p "Press a letter key: " keypress
echo; echo "Keypress was "\"$keypress\""."

# -s option means do not echo input.
# -n N option means accept only N characters of input.
# -p option means echo the following prompt before reading input.
# Using these options is tricky, since they need to be in the correct order.
