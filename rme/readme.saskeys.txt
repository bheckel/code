
                               Enterprise Guide
                               ================
run: F3
select vertical block of code: Alt+mousemove
set bookmark: Ctl+F2 (return to bookmark: F2)
comment out: Ctl+/
uncomment out: Ctl+Shift+/
tidy format: Ctrl+i

SAS Enterprise Guide settings options http://support.sas.com/resources/papers/proceedings14/SAS331-2014.pdf

---



                                Enhanced Editor
                                ===============

Collapse all folding blocks:              Alt + Ctrl + Number pad - 
Collapse current line:                    Alt + Number pad - 
Comment the selection with line comments: Ctrl + / 
Undo the Comment:                         Ctrl + Shift + / 


---

                               Display Manager
                               ===============

F11 or Home to get to commandline.

Shift-F7 Shift-F8 to move up/down.

Widen window (command not needed) cursor on edge start, press enter, move
cursor to new spot, press enter.


Command ===>
?          recall previously *typed* commandline history command (not same as 
            RECALL !! more like F3 in DOS or ESC k in bash)
BY[E]      exit SAS
CAS[CADE]  show all windows
CLE[AR]    clear the current window
DIR        show contents of 'Work'
END        closes or "closes" current window
ENDS[AS]   exit SAS
FILE 'BQH0.JUNK' [R] save current window contents to a file [quietly overwrite]
HELP       context-sensitive
INCLUDE 'BQH0.PGM.LIB(JUNK)' read in code to current window
KEYS       show available function keys (may be mapped to F11)
LOG        takes you to Log Window
MSG        popup message window
NEXT       cycle thru open windows (usually F8 is mapped)
NOTE[PAD]  scratch area (maintained across sessions)
NUM        show numbers (toggles line numbers)
OPTIONS    show SAS system options
OUT[PUT]   takes you to Output Window
PROG       takes you to Non-Enhanced Program Editor Window
PG[M]      takes you to Non-Enhanced Program Editor Window
WPG[M]     takes you to Enhanced Program Editor Window - why not EPGM??!!
REC[ALL]   brings back your submitted code (NOT same as '?')
SUB[MIT]   run job
TILE       tiles all windows (RESIZE puts you back where you were)
VAR        show properties of _LAST_
ZO[OM]     goes fullscreen (and unzooms if you type ZOOM again)!!!!!!!!!!!!!!

F9 Keys Window
===> up 42
===> down 42   or press enter 42 times

-----


 /* Mainframe */
=6
sas609
sas90


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Program Editor
COPIED FROM SAS HELP SCREENS
Thu, 11 Nov 1999 10:32:29 (Bob Heckel)
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C<n>    

The C (copy) command copies one or n lines to another location in  the file.    

To copy lines, type C on the number of the line to be copied and an   A on the
number of the line the copied line is to be after, a B on  the number of the
line it is to be before, or an O on the number of  the line it is to
overlay.    

Specify n number of lines to be copied by following C with a number  and a
blank space. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CC    

The CC (copy block) command copies a block of lines to another  location in
the file indicated by a target line command. 

To copy blocks of lines, type CC on the numbers of the first and  last lines
of the block to be copied and an A on the number of the  line the copied block
is to be after, a B on the number of the line  it is to be before, or an  O on
the number of the line on which  overlaying is to begin. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CCL    

The CCL (case lower block) command sets all characters in a  designated block
of lines to lowercase. 

Type CCL on the line numbers of the first and last lines of the  block of
lines to be converted to lowercase. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CL<n>    

The CL (case lower) command sets all characters on a line to  lowercase.    

Specify n number of lines to be lowercased by following the CL with  a number
and a blank space. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CU<n>    

The CU (case upper) command sets all characters on a line to  uppercase.    

Specify n number of lines to be uppercased by following the CU with  a number
and a blank space. 


+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
DD    

The DD (delete block) command deletes a block of lines.  Type DD on  the line 
numbers of the first and last numbers of the block of  lines to be deleted. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
D<n>    

The D (delete) command deletes one or n lines.    

Indicate D on the line number of the line to be deleted.  By  default, one
line is deleted.  To delete more than one line, follow  D with a number and a
blank space. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
I<n>    

The I (insert) command inserts one or n new lines after the current  line.  To
insert more than one line, follow I with a number and a  blank space. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
IA<n>    

The IA (insert after) command inserts one or n new lines after the  current
line.  To insert more than one line, follow IA with a  number and a blank
space. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
IB<n>    

The IB (insert before) command inserts one or n new lines before  the current
line.  To insert more than one line, follow IB with a  number and a blank
space. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
JC<n>    

The JC (justify center) command centers text.    

You can specify a number to indicate a position other than the  center of the
line to be used for centering the text. 

Note:
The JC command honors the current  BOUNDS setting, if bounds  are set, 
instead of the line size. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
JJC<n>    

The JJC (justify center block) centers the text of a designated  block of
lines.  Type JJC on the line numbers of the first and last  lines of the block
of lines to be centered. 

You can specify a number to indicate a position, other than the  center of the
line, to be used for centering the text. 

Note:
The JJC command honors the current  BOUNDS setting, if bounds  are set, 
instead of the line size. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
JL<n>    

The JL (justify left) command aligns a line of text at the left  margin.  You
can specify n to indicate a left boundary other than  the margin of a window. 

Note:
The JL command honors the current  BOUNDS setting, if bounds  are set, 
instead of the line size. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
JR<n>    

The JR (justify right) command aligns a line of text at the right  margin.
You can specify n to indicate a right boundary other than  the margin of a
window. 

Note:
The JR command honors the current  BOUNDS setting, if bounds  are set, 
instead of the line size. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
M<n>    

The M (move) command moves one or n lines to another location in  the file 
indicated by a target line command. 

Type M on the number of the line to be moved and an  A on the number  of the
line the moved line is to be after, a B on the number of the  line it is to be
before, or an  O on the line it is to overlay. 

To move more than one line, follow M with a number and a blank  space.    


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
MM    

The MM (move block) command moves a block of lines to another  location in the
file indicated by a target line command. 

To move a block of lines, type MM on the numbers of the first and  last lines
of the block of lines to be moved and an A on the number  of the line the
moved block is to be after, a B on the number of  the line it is to be before,
or an  O on the number of the line on  which overlaying is to begin. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
MCL    

The MCL command lowercases all marked text in the text editor,  including
multiple blocks and multiple lines of marked text that  are separated by
unmarked text.  After you mark the text, you can  issue the command from any
numeric field to lowercase all marked  text in the text editor. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
MCU    

The MCU command uppercases all marked text in the text editor,  including
multiple blocks and multiple lines of marked text that  are separated by
unmarked text.  After you mark the text, you can  issue the command from any
numeric field to uppercase all marked  text in the text editor. 

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
TC    

The TC (text connect) command connects two lines together.    

Type TC on the number of the first line you want flowed with the  following
line.    


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
TF <A> <n>    

You can use the TF command to move text into space left at the  ends of
lines.    

You can use the following arguments with the TF command:   

no argument  

flows text to the first blank line or to the end of text,  whichever comes
first, honoring left and right boundary settings. 

A  

flows a paragraph to the end of the text be removing trailing  blanks
continuing over but not deleting blank lines. 

n  

specifies a right boundary to temporarily override the right  boundary set by
the  BOUNDS command.   


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
><n>    

The > (shift right) command shifts text one or more spaces to the  right.    

Type >, or > followed by a number and a blank space, on the number  of the line 
whose text is to be shifted. 

Note:
The > command allows no loss of text.  Text is shifted to  the amount 
specified or the border, whichever comes first. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
TS<n>    

The TS (text split) command moves text following the current cursor  position
to the line immediately following the split line. 

Note:
The TS command honors the current  BOUNDS setting instead  of the line 
size, when the AUTOFLOW option is ON. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>><n>    

The >> (shift right block) command shifts a block of lines one or  more spaces
to the right. 

Type >>, or >> followed by a number and a blank space, on the  numbers of the
first and last lines of the block of lines to be  shifted. 

   Note:  The >> command allows no loss of text.  Text is shifted
          to the amount specified or the border, whichever comes
          first.


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
<<n>    

The < (shift left) command shifts text one or more spaces to the  left.    

Type <, or < followed by a number and a blank space, on the number  of the line 
whose text is to be shifted. 

Note:
The < command allows no loss of text.  Text is shifted  to the amount 
specified or the border, whichever comes  first. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
<<<n>    

The << (shift left block) command shifts a block of lines one or  more spaces
to the left. 

Type <<, or << followed by a number and a blank space, on the  numbers of the
first and last lines of the block of lines to be  shifted. 

Note:
The << command allows no loss of text.  Text is shifted  to the amount 
specified or the border, whichever comes  first. 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
))<n>    

The )) (shift right block) command shifts a block of lines one or  more spaces
to the right. 

Type )), or )) followed by a number and a blank space, on the  numbers of the
first and last lines of the block of lines to be  shifted. 

   Note:  The )) command differs from the >> command in that it
          allows the loss of text.  If shifting moves text past the
          end of the current line, those characters are lost.


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
((<n>    

The (( (shift left block) command shifts a block of lines one or  more spaces
to the left. 

Type ((, or (( followed by a number and a blank space, on the  numbers of the
first and last lines of the block of lines to be  shifted. 

   Note:  The (( command differs from the << command in that it
          allows the loss of text.  If shifting moves text past the
          beginning of the current line, those characters are lost.



See also readme.sasaf.txt
