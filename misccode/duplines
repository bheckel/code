#!/bin/sh

# dup - Will search for duplicate lines in a file

if [ -z "$1" ]; then
 echo
 echo "syntax: dup [filename]"
 echo
 exit
fi

file=$1

echo -n "Searching Dups..."
cat /dev/null > $file.n
while read line
do
  found=`grep "$line" $file.n`
  if [ -n "$found" ]; then
    echo -n "."
  else
    echo "$line" >> $file.n
  fi 
done < $file
old=`wc -l $file | awk '{ print $1 }'`
new=`wc -l $file.n | awk '{ print $1 }'`

echo "`expr $old - $new` dups found"
echo "Newfile: $file.n"
