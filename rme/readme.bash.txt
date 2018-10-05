
                 #~##~##~##~##~##~##~##~##~##~##~##~#~#~##~#
                 #    Bash Programming Quick Reference     #
                 #~##~##~##~##~##~##~##~##~##~##~##~#~#~##~#


Basics
======
Command interpreter is #!/bin/bash 
The #! line in a shell script will be the first thing the command interpreter
(sh or bash) sees. Since this line begins with a #, it will be correctly
interpreted as a comment when the command interpreter finally executes the
script. The line has already served its purpose - calling the command
interpreter.

You must make scripts executable.
$  chmod +x filename.sh
A script needs read, as well as execute permission for it to run, since the
shell needs to be able to read it.


Debugging Options 
  -n      Reads all commands, but does not execute them. 
          e.g. #!/bin/bash -n or $ bash -n test.sh

  -v      Displays all lines as they are read. 

  -x      Displays all commands and their arguments as they execute. This
          option is often referred to as the shell tracing option. 
          e.g.  $ ./filename -xv <---shows resolved variables preceded by '+'



Variables
=========

General:
-------

Variable assignment requires NO SPACES between the '='
  varname=value 

Access a variable by prepending a $
  echo $varname 


Array: declare -a variable: The variable is an array of strings.

Associative array: declare -A variable: The variable is an associative array of strings (bash 4.0 or higher).

Integer: declare -i variable: The variable holds an integer. Assigning values to this variable automatically triggers Arithmetic Evaluation.

Read Only: declare -r variable: The variable can no longer be modified or unset.

Export: declare -x variable: The variable is marked for export which means it will be inherited by any child process.


Commandline Arg Variables:
-------------------------

Values passed in from the command line as arguments are accessed as $# where
'#' is the index of the variable in the array of values being passed in.

#   _        _   must be spaces!!
if [ "$#" = 0 ]; then
  echo 'error: no arguments parms passed - requires at least one arg'
  exit 1
fi


Built in variables 
------------------
$?  
Stores the exit value of the last command that was executed.  

$0 
The name the script was invoked with. This may be a basename without directory
component, or a path name. This variable is not changed with subsequent shift
commands.
 
$1, $2, $3, ..., $9
The first, second, third, ... command line argument, respectively. The
argument may contain whitespace if the argument was quoted, i.e. "two words".

eval finalparm=\${$#}  Last parameter passed in saved to 'finalparm'

Notice that the shell provides variables for accessing only nine arguments.
Nevertheless, you can access more than nine arguments. The key to doing so is
the shift command, which discards the value of the first argument and shifts
the remaining values down one position. Thus, after executing the shift
command, the shell variable $9 contains the value of the tenth argument. To
access the eleventh and subsequent arguments, you simply execute the shift
command the appropriate number of times.  Or do ${10} ${11} etc.
Or
$ set a b c d; echo ${*:3:1}    # returns c
 
$# 
Number of command line arguments, NOT counting the invocation name $0
 
$@ 
The entire list of arguments, treated as a series of words.
"$@" is replaced with all command line arguments, enclosed in quotes, i.e.
"one", "two three", "four". Whitespace within an argument is preserved.
 
$* 
The entire list of arguments, treated as a single word.
$* is replaced with all command line arguments. Whitespace is not preserved,
i.e. "one", "two three", "four" would be changed to "one", "two", "three",
"four".  This variable is not used very often, "$@" is the normal case,
because it leaves the arguments unchanged. 

$$
The process id of the current process.

$-
Startup scripts may test the value of the `-' special parameter. It contains
the letter i when the shell is interactive. For example:

case "$-" in
  *i* )  echo This shell is interactive;;
  *   )  echo This shell is not interactive;;
esac

!$
End of previous command.
E.g.
grep foostr lookin_openiffound.txt
vi !$


Command substitution
====================
pi=$(echo "scale=10; 4*a(1)" | bc -l)
# Variable contains names of all *.txt files in current working directory.
textfile_listing=`ls *.txt`
textfile_listing=$(ls *.txt)   # alternative form of command substitution
# BUT both of these are unnecessary if you're trying to do something to each
# file in a directory:
for f in *; do
  command "$f"
done


A listing of commands within parentheses starts a nested subshell.  Variables
inside parentheses, are not visible to the rest of the script.  The parent
process, the script, cannot read variables created in the child process, the
subshell:

a=123
( a=321; )        
echo "a = $a"   # a = 123
# "a" within parentheses acts like a local variable.
 

# Quoting variable preserves whitespace:
foo="A B  C   D"
echo $foo      <---returns A B C D
echo "$foo"    <---returns A B  C   D

# Return the length of the parameter value
${#the_variable}   # e.g. 10

# Strip off suffix of filename
foo=file.tar.gz
echo ${foo%.*}    <---returns file.tar

# substr String Editing:
# Think # is on left side of keyboard so CUTAWAY left, % is on right so
# CUTAWAY right.
# E.g. assume the_var=amanuensis
# Cut shortest match from start of $the_variable
${the_var#n*}   
# XXXXuensis so $the_variable contains uensis

# Cut longest match from start of $the_variable
${the_var##n*}
# XXXXXXXsis so $the_var contains sis

# Cut shortest match from end of the_variable
${the_var%n*}
# amanueXXXX so $the_variable contains amanue

# Cut longest match from end of the_variable
${the_var%%n*}
# amaXXXXXXX so $the_var contains ama

# Like basename()
the_var=amanuensis.sas
echo ${the_var%.*}   <--- amanuensis


# Substitution (search and replace):
# E.g. remove the 'http://'
link=http://foo.com
link2=${link#http://}
# or
processlinkfromuser=${1#http://}

# or better:
x=abcabcabc
echo ${x//abc/xyz}  <--- xyzxyzxyz

echo ${x/abc/xyz}   <--- xyzabcabc

# Substring:
x=abcdefghij        
echo ${x:0:3}   <--- abc
echo ${x:5}     <---fghij


Defaults:
----------

# Test for empty variable and fill it if empty
test "x$f" = "x" && f=bar

# Since username2 probably hasn't been set, this will echo bqh0 otherwise it
# will echo whatever you set username2 to even if it's been set as username2=  
$ echo ${username2:-`whoami`}

# If parameter not set, set it to default, differs from last example because
# if  export username2=  has been run, it just echos null.
$ echo ${username2=`whoami`}

# Summary: both forms nearly equivalent. The ':' makes a difference only when
# $parameter has been declared and is null. 
 
# Use alternate value only if parm is set to something:
parm=foo
${parm+alt_value}  <---alt_value
${zarm+alt_value}  <---(nothing)

${parameter:+alt_value}
# If parameter set, use alt_value, else use null string.

${parameter?err_msg}
${parameter:?err_msg}
# If parameter set, use it, else print err_msg.

# Determine file's suffix (extension)
the_file=file.tar.gz
###the_ext=`expr "$the_file" : '.*\.\(.*\)'`    # portable to any shell
the_ext=${the_file##*.}                         # ksh/bash only
if [ $the_ext = 'gz' ];then
  echo $the_ext
fi


# If need to use wildcards, must use case statement (see
# ~/code/misccode/wildcard_using_case.sh).


Concatenation
=============
a=one
b=two
c="$a concatenated with $b"
echo $c
# or
for f in ${MATCHFILES[@]}; do
  if [ -s ${THE_DIR}$f ]; then
    CONCAT="$CONCAT ${THE_DIR}$f"
  fi
done


# Line continuation:
echo "ok to split"\
     "the line"
# or
echo ok to split\
     the line


Quote Marks
===========
Double quotes make the shell ignore whitespace and count it all as one
argument being passed or string to use. Special characters inside are still
noticed/obeyed.  Single quotes make the interpreting shell ignore all special
characters in whatever string is being passed. 

The backticks single quote marks (`command`) perform a different function. They
are used when you want to use the results of a command in another command. For
example, if you wanted to set the value of the variable contents equal to the
list of files in the current directory, you would type the following command:
contents=`ls`, the results of the ls program are put in the variable contents. 


Logic and comparisons
=====================
A command called test is used to evaluate conditional expressions, such as an
if-then statement that checks the entrance/exit criteria for a loop. 

test expression 
# or
[ expression ] 

... elif [[ "$HOSTNAME" = 'WL12H26564' || "$HOSTNAME" = 'WD12H01067' ]]; ...

Gotchas
-------
Assuming uninitialized variables (variables before a value is assigned to
them) are "zeroed out". An uninitialized variable has a value of "null", not
zero.

Mixing up = and -eq in a test. Remember, = is for comparing literal variables
and -eq for integers.


Numeric (integer) Comparisons 
=============================
Integer variables in Bash are actually signed long (32-bit) integers, in the
range of -2,147,483,648 to 2,147,483,647. An operation that takes a variable
outside these limits will give an erroneous result.

Bash does not understand floating point arithmetic. It treats numbers
containing a decimal point as strings (use bc in scripts that that need
floating point calculations or math library functions).


File Comparisons (file test)
============================
-e filename   Returns True if file, filename exist.
-d filename   Returns True if file, filename is a directory.  
-f filename   Returns True if file, filename is an ordinary file. 
-r filename   Returns True if file, filename can be read by the process. 
-s filename   Returns True if file, filename has a nonzero length. 
-w filename   Returns True if file, filename can be written by the process. 
-x filename   Returns True if file, filename is executable. 
-L filename   Returns True if file, filename is a symbolic link.


Expression Comparisons 
======================
!expression   Returns true if expression is not true 
expr1 -a expr2   Returns True if expr1 and expr2 are true. ( && , and ) 
expr1 -o expr2   Returns True if expr1 or expr2 is true. ( ||, or ) 

f1 -nt f2
 True if file f1 is newer than file f2.

f1 -ot f2
 True if file f1 is older than file f2.

-n s1
 True if string s1 has nonzero length.
 E.g.  if [ -n "$1" ]; then ...

-z s1
 True if string s1 has zero length.
 e.g.
 ISTHERE=`grep foostr /etc/profile`
 # Just using -n might be simpler than negation
 if [ ! -z "$ISTHERE" ]; then
   echo 'foostr is in profile'
 fi
 

s1 = s2
 True if string s1 is the same as string s2.

s1 != s2
 True if string s1 is not the same as string s2.

# It doesn't get more counter-intuitive than this!
n1 -eq n2
 True if integer n1 is equal to integer n2.

n1 -ge n2
 True if integer n1 is greater than or equal to integer n2.

n1 -gt n2
 True if integer n1 is greater than integer n2.

n1 -le n2
 True if integer n1 is less than integer n2.

n1 -lt n2
 True if integer n1 is less than or equal to integer n2.

n1 -ne n2
 True if integer n1 is not equal to integer n2.


To see the 'test' command in action, consider the following script:

test -d $1
echo $?

This script tests whether its first argument specifies a directory and
displays the resulting exit status, a zero or a non-zero value that reflects
the result of the test.

This double (multiple) conditional is an annoying quirk (but the if [ ... ];
then...  won't work unless you use 2 [ ... ]'s):
X=yes
Y=no
if test "$X" = 'yes' && test "$Y" = 'no'; then
  echo 'This is the way to get this statement to work.'
  echo 'Using brackets or leaving out the "test" will make it fail.'
fi

or

MUST use this (or it will fail with [:` errors if evals to empty)
if ! test -f $F1 && ! test -f $F2; then
Instead of this:
if [ !-f $F1 -a -f $F2  ]; then

-----
In a compound test, even quoting the string variable might not suffice:

  [ -n "$string" -o "$a" = "$b" ]  

may cause an error with some versions of Bash if $string is empty. The safe
way is to append an extra character to possibly empty variables: 

  [ "x$string" != x -o "x$a" = "x$b" ]    <---the "x's" cancel out
-----


# Test variable for empty.  TODO this isn't always true, see next e.g.
if ! [ -n "$FOO" ]; then
  echo "FOO is not empty."
else
  echo "FOO is empty."
fi

# This is better, I think
X=""    <---same
X=      <---same
        <---same
if test "$X";then
  echo not empty
else
  echo empty        <---prints
fi

e.g.
if ! test "$AVAILABLE"; then
  # Empty string, no files exist
  Usage
  exit 4
fi


Arithmetic Expansion (math, addition, subtraction, multiplication, division)
============================================================================

# Portable
z=`expr 2 + 1`         # $z is 3
# If need floating point division:
z=`echo "5 / 7" | bc -lwq`

i=`expr $i + 1`

# Bash only increment +1 like C++:
z=$(($z+1))            # double parenthesis
# Bash/ksh only:
let z=z+3


If...then 
=========

[ $# -lt 2 ] && echo "Usage: $0 arg1 arg2" && exit 1
#   _          _   must be spaces!!
if [ expression ]
  then
  commands
fi


# Better
if [ expression ];then
  commands
else
  commands
fi


[ $# -lt 2 ] && echo "Usage: $0 arg1 arg2" && exit 1


if [ expression ];then
  commands
elif [ expression2 ];then
  commands
else
  commands
fi


# Check for ARGV defaults
if [ "$@" ]; then
  LOGFILE=$1
else
  LOGFILE='/apache/logs/error_log'
fi
# or
if [ $# -lt 3 ]; then
  echo 'not enough args passed on command line'
fi

------------------------
# Multiple conditions OR (also works for AND):
# This DOESN'T work
if [ $the_dot = '.vimrc' || $the_dot = '.bashrc' ]; then
  echo $the_dot
fi

# But this does:
if [ $the_dot = '.vimrc' ] || [ $the_dot = '.bashrc' ]; then
  echo $the_dot
fi

# And this does:
if test $the_dot = '.vimrc' || test $the_dot = '.bashrc'; then
  echo $the_dot
fi

# And this does too:
if [ $the_dot = '.vimrc' -o $the_dot = '.bashrc' ]; then
  echo $the_dot
else
  echo $the_dot
fi

# And this probably works best of all for list conditions using IN
case "$the_dot" in
  '.vimrc' | '.bashrc' )  echo $the_dot
esac
------------------------



cd /var/log || {
  echo "Cannot change to necessary directory." >&2
  exit 1;
}


# read builtin --- the final variable gets the remainder of the line.
read yes_no
# Must use quotes around "$yes_no" so that this works when user just presses
# enter:
if [ "$yes_no" != 'n' ]; then
  echo 'Accept a carriage return or any letter but n'
fi


# Look for an affirmative yes or no by prompting user:
echo 'Would you like some foo with that?'
read yesno;
if [ $yesno = 'y' ]; then
  echo foo
else
  echo nofoo
fi
# Environment variable $REPLY holds the value of last "read" if and only if
# no variable is supplied.

# Iterate, read, a textfile (emulates cat in this case):
while read f; do echo $f; done <lookateachlineofthis.txt


Select
======
# Provides a menu interface (bash only).
OPTIONS="Hello Quit"
select opt in $OPTIONS; do
  if [ $opt = "Quit" ]; then
    echo done
    exit
  elif [ $opt = "Hello" ]; then
    echo Hello World
  else
    clear
    echo bad option
  fi
done


Case select 
===========
string1 is compared to str1 and str2. If one of these strings matches string1,
the commands up until the double semicolon (; ;) are executed. If neither str1
nor str2 matches string1, the commands associated with the asterisk are
executed. This is the default case condition because the asterisk matches all
strings. 

case string1 in
  str1)
    commands;;
  str2)
    commands;;
     *)
    commands;;
esac

E.g. allows ranges of characters in [square brackets].
read Keypress
case "$Keypress" in
  [a-z] ) echo "Lowercase letter";;
  [A-Z] ) echo "Uppercase letter";;
  [0-9] ) echo "Digit";;
  *     ) echo "Punctuation, whitespace, or other";;
esac  



Iteration (Loops)
=================
This executes once for each item in the list. This list can be a variable that
contains several words separated by spaces (such as output from ls or cat), or
it can be a list of values that is typed directly into the statement. Each
time through the loop, the variable var1 is assigned the current item in the
list, until the last one is reached. 

for loop:

for var1 in list
  do
    commands
  done

# or better:
for var1 in list; do
  commands
done

# or, if you have a list:
array1="$HOME/perllib $HOME/readme $HOME/bin $HOME/code"
for var1 in $array1; do
  commands
done

# or
# FYI, ${#array1} is the length of array1
array1=($HOME/perllib $HOME/readme $HOME/bin $HOME/code)
for var1 in "${array1[@]}"; do
  echo here is $var1
  echo
done

# or
echo ${array1[0]}      <---$HOME/perllib

# or
array2=([17]=seventeen [24]=twenty-four)
echo ${array2[17]}

# or, to process each thing passed via the command line (parameters are
# implicitly in $@):
for x; do
  echo $x
done

# or, to do a multiple copy:
FILE=$1
shift
for DEST in "$@"; do
  cp $FILE $DEST
done

# or to do something 15 times:
STRING="Soylent green is people."
for i in `echo "5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20"`
  do echo $STRING | cut -c$i
done

# or better
STRING="Soylent green is people."
for i in 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
  do echo $STRING | cut -c$i
done

# or best
STRING="Soylent green is people."
for i in `seq 5 20`
  do echo $STRING | cut -c$i
done

# or to iterate the number of chars in a string
str=bar
for i in `seq ${#str}`; do
  echo $i
done

# or to do something (i.e. loop) over clean filenames:
###for f in `echo *.txt`; do 
# Better
for f in *.txt; do 
  echo $f
done

# Better?
for i in $(ls); do
  echo item: $i
done

# or +1 C-like (but can't use $LIMIT, just LIMIT within the parens):
LIMIT=10
for (( a=1; a<=LIMIT ; a++ )); do
  echo -n "$a "
done 

# on the command line
for ((i=1;i<5;i++)); do echo "2^$i" | bc; done

# or C-like to the extreme (the comma chains together operations):
for (( a=1, b=1; a <= $LIMIT ; a++, b++ )); do
  echo -n "$a-$b "
done
 
# Complex 'in'
for h in `awk -F: '{print $6}' /etc/passwd`; do
  echo $h
done

# Break out of one (or N more) loops (look Ma, no GOTOs!)
for outerloop in 1 2 3 4 5; do
  echo "Outer $outerloop: "
  for innerloop in 10 20 30 40 50; do
    echo "  Inner $innerloop: "
    if [ "$innerloop" -eq 30 ]; then
      break 2 # break 2 "breaks" out of both inner and outer loops.
    fi
  done
done

# The classic RUShure?
echo -n Are you sure?
read yesno
if [ "$yesno" = 'y' ] || [ "$yesno" = 'Y' ]; then
  # do it
fi
# or
echo -n "Continue ([y]/n)? "
read goon
if [ "$goon" = 'n' ]; then
  exit 1
fi
# or
echo -n "Begin ([y]/n)? "
read yn
if [ "$yn" != 'n' ]; then
echo "yn is $yn"
  for f in main.html wiz.sas wiz2.sas
    do
      echo $f
      echo -n "Next ([y]/n)"?
      read goon
      if [ "$goon" = 'n' ]; then
        exit 2
      fi
    done
else
  exit 1
fi


-----
while loop

Portable:
while : ; do echo bob; sleep 6; done

while [ expression ]
do
  commands
done

# e.g.
while true; do
  sleep 10
done

# or
while : ; do
  sleep 10
done

# or
while [ 1 ]; do
  sleep 10
done

# e.g.
COUNTER=0
while [  $COUNTER -lt 10 ]; do
  echo The counter is $COUNTER
  let COUNTER = COUNTER + 1 
done


-----
until loop

until [ expression ]
do
  commands
done

# Pop each passed in parameter:
until [ -z "$1" ]  # Until all parameters used up...
do
  echo -n "$1 "
  shift
done


Functions
=========

function fname() {
  ...
}
# Better but parens now mandatory
fname() {
  ...
}


Call it by using the following syntax: fname 

Or, create a function that accepts arguments: 

fname2() {       <---Note: No PARAMS PASSED!
  local one=$1
  ...
}

And call it with: fname2 arg1 arg2 ... argN     <---Note: NO PARENS! and
                                                          NO COMMAS!
Which means $1 can confusingly be the first ARGV *and* arg1 (in this e.g.)


Errors:
=======

Try doublequoting the lvalue on an equality test statement if you get this:
  [: =: unary operator expected


Reserved Exit Codes:
--------------------

exit 0 
indicate success

1
catchall for general errors
let "var1 = 1/0"
miscellaneous errors, such as "divide by zero"

2
misuse of shell builtins, according to Bash documentation
Seldom seen, usually defaults to exit code 1
Also for certain syntax errors

126
command invoked cannot execute
permission problem or command is not an executable

127
"command not found"
possible problem with $PATH or a typo

128
invalid argument to exit
exit 3.14159
exit takes only integer args in the range 0 - 255

128+n
fatal error signal "n"
kill -9 $PPIDof script
$? returns 137 (128 + 9)

130
script terminated by Control-C
Control-C is fatal error signal 2, (130 = 128 + 2, see above)

255
exit status out of range
exit -1
exit takes only integer args in the range 0 - 255


Job Ctrl-z background Identifiers
=================================

Notation Meaning 
%N     Job number [N] 
%S     Invocation (command line) of job begins with string S 
%?S    Invocation (command line) of job contains within it string S 
%%     "current" job (last job stopped in foreground or started in background) 
%+     "current" job (last job stopped in foreground or started in background) 
%-     Last job 
$!     Last background process 


getopts
=======
How to handle command line switches:

while getopts vVf: the_option
do
  case "$the_option" in
     v | V )  vflag=on;;
     f     )  filename="$OPTARG";;
    \?     )  # unknown flag, can also use  * )
              echo >&2 \
              "Usage: $0 [-v] [-f filename]"
              exit 1;;
  esac
done
shift `expr $OPTIND - 1`    # move, pop, argument pointer to next


Redirection
===========
Toss errors to bit bucket
>/dev/null 2>&1

Child processes inherit open file descriptors. This is why pipes work. To
prevent an fd from being inherited, close it.

Redirect stdout to a file
ls -l > foo.txt

Redirect file descriptor i to j
i>&j
E.g. redirect stderr to stdout
2>&1

Redirect file descriptor 1 (stdout) to j (all stdout gets sent to file pointed
to by j)
>&j
 
Close input file descriptor n.
n<&-

Close stdin.
0<&-, <&-

Close output file descriptor n.
n>&-

Close stdout.
1>&-, >&-


Arrays
======
(see ~/code/misccode/array.sh)


Hashes (associative arrays)
===========================
DarkSlateGrey="#2f4f4f"
DimGrey="#696969"
Wheat="#706969"

#                Evaluates to DimGrey 
#                    ___________
BGColor=`eval echo "$"$(echo $1)""`
# Then `eval echo "$DimGrey"` evaluates to #696969

echo "$BGColor is the value of key $1"


Misc
=====
# Shell's printf uses no parentheses nor commas!
printf "%.2f matched\n" $TOT

history -a  # append this xterm history
history -n  # read in the other xterms appended history
