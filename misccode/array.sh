#!/bin/bash

################################################

# bash array (note no commas)
matchfiles=(match.direct.out \
            match.minor.out \
            match.fuzzy.out)

# Concatenate to do a Perl-like push() onto an array.  Bash-specific!  Curlies
# required.
for f in ${matchfiles[*]}; do
  echo $f
  if [ -e "$f" ]; then
    FILES="$FILES $f"
  fi
done
echo $FILES


################################################


###dir_arr=($HOME/perllib $HOME/readme $HOME/bin)
# Less convenient assignment:
dir_arr[0]=$HOME/perllib
dir_arr[1]=$HOME/readme 
dir_arr[2]=$HOME/bin

echo ${dir_arr[0]}
echo

for the_suffix in ${dir_arr[@]}; do
  let i=$i+1
  balls[$i]=`basename $the_suffix`
  echo ${balls[$i]}
done
echo


################################################
# Yet another way of assigning array variables but to specific elements:
foo=([17]=seventeen [24]=twenty-four)

echo -n "foo[17] = "
echo ${foo[17]}

# Blank.
echo -n "foo[18] = "
echo ${foo[18]}

echo -n "foo[24] = "
echo ${foo[24]}



###########################
# Adapted: Mon 24 Sep 2001 14:24:37 (Bob Heckel --
#                          http://www.linuxdoc.org/LDP/abs/html/arrays.html)
# Permits declaring an array without specifying its size.
declare -a colors

echo "Enter your favorite colors (separated from each other by a space):"

# Special option to 'read' command, allowing assignment of elements in an
# array.
read -a colors

# Special syntax to extract number of elements in array.
# element_count=${#colors[*]} works also.
#
# The "@" variable allows word splitting within quotes
# (extracts variables separated by whitespace).
element_count=${#colors[@]}
echo "$element_count colors entered"

index=0

# Print each array element.
while [ "$index" -lt "$element_count" ]; do    
  # List all the elements in the array.
  echo ${colors[$index]}
  let "index = $index + 1"
done

# Doing it (better) with a "for" loop instead:
#   for i in "${colors[@]}";  do
#     echo "$i"
#   done

# Again, list all the elements in the array, but using a more elegant method.
  echo ${colors[@]}
# echo ${colors[*]} works also.

echo $colors is shorthand for ${colors[0]}


###########################


Line[1]="I do not know which to prefer,"
Line[2]="The beauty of inflections"
Line[3]="Or the beauty of innuendoes,"
Line[4]="The blackbird whistling"
Line[5]="Or just after."

echo "number of elements in array:" ${#Line[*]} 

Attrib[1]=" Wallace Stevens"
Attrib[2]="\"Thirteen Ways of Looking at a Blackbird\""

for index in `seq 5`
  do
    printf "   %s\n" "${Line[index]}"
  done

for index in 1 2
  do
    printf "        %s\n" "${Attrib[index]}"
  done


###########################


# Load results of a command into an array:

cmdarray=( $(echo "foo bar") )
for f in ${cmdarray[*]}; do
  echo $f
done;
