#!/bin/bash

file="$HOME/.secrets/007" 

echo "File location: $file" 

# Shortest match deleted
echo "Filename: ${file#*/}" 
# Longest match deleted
echo "## is greedy Filename: ${file##*/}" 

# Shortest match deleted
echo "Directory of file: ${file%/*}" 
# Longest match deleted
echo "%% is greedy Directory of file: ${file%%/*}" 

echo "Other file location: ${other:-There is no other file}" 

echo "assign default Using file if there is no other file: ${other:=$file}" 

echo "Other filename: ${other##*/}" 

echo "Other file location length: ${#other}"

echo "substr ${file:25:4}"

echo "regex substitution ${file/crets/XXX}"
echo "greedy regex substitution ${file//c/XXX}"
