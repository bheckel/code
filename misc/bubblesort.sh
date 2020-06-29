#!/bin/bash
# bubble.sh: Bubble sort, of sorts.
# Adapted: Mon 24 Sep 2001 15:33:44 (Bob Heckel --
#                           http://www.linuxdoc.org/LDP/abs/html/arrays.html)

# Recall the algorithm for a bubble sort. In this particular version...
#
# With each successive pass through the array to be sorted,
# compare two adjacent elements, and swap them if out of order.
# At the end of the first pass, the "heaviest" element has sunk to bottom.
# At the end of the second pass, the next "heaviest" one has sunk next to bottom.
# And so forth.
#
# This means that each successive pass needs to traverse less of the array.
# You will therefore notice a speeding up in the printing of the later passes.

# Swaps two members of the array.
exchange() {
  # Temporary storage for element getting swapped out.
  local temp=${Countries[$1]} 
  Countries[$1]=${Countries[$2]}
  Countries[$2]=$temp
}  

# Declare array, optional here since it's initialized below.
declare -a Countries 

Countries=(Netherlands Ukraine Zaire Turkey Russia Yemen Syria Brazil \
           Argentina Nicaragua Japan Mexico Venezuela Greece England \
           Israel Peru Canada Oman Denmark Wales France Kenya Qatar 
           Liechtenstein Hungary)
# Couldn't think of one starting with X (darn!).

clear
echo "0: ${Countries[*]}"  # List entire array at pass 0.
number_of_elements=${#Countries[@]}
let "comparisons = $number_of_elements - 1"
count=1 # Pass number.

while [ "$comparisons" -gt 0 ]          # Beginning of outer loop
do
  index=0  # Reset index to start of array after each pass.
  while [ "$index" -lt "$comparisons" ] # Beginning of inner loop
  do
    if [ ${Countries[$index]} \> ${Countries[`expr $index + 1`]} ]
    # If out of order...
    # Recalling that \> is ASCII comparison operator.

    # if [[ ${Countries[$index]} > ${Countries[`expr $index + 1`]} ]]
    # also works.
    then
      exchange $index `expr $index + 1`  # Swap.
    fi  
    let "index += 1"
  done # End of inner loop

  # Since "heaviest" element floats to bottom, we need to do one less
  # comparison each pass.
  let "comparisons -= 1" 
  echo
  echo "$count: ${Countries[@]}"  # print resultant array at end of each pass
  echo
  let "count += 1"     # increment pass count

done   # end of outer loop

exit 0
