xxCxx START:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-: {{{1

/* Zero out a high order bit (used to display negative, parity, etc.).
 * AND'ing with 0111 1111 leaves all bits but the first one
 * untouched.
 */
ch = ch & 127;

/* Turn on ECHO by using an OR */
flags |= ECHO;
/* Turn off ECHO by using an AND and an invert */
flags &= ~ECHO;

Any bit AND'ed with a 0 yields a 0.
Any bit OR'ed with a 0 yields itself.

/*  If variable ptrX "holds the ADDRESS of a MEMORY LOCATION containing an
 *  int", what it really means is that variable ptrX holds the ADDRESS of the
 *  first byte of the memory used for the int being pointed to.  That is one
 *  reason why variable ptrX, acting as a pointer, must point to a specific
 *  type.  The system needs to know HOW MANY bytes to handle as part of the
 *  data being pointed to. 
 */

/* Increment p, the POINTER.  * binds less tightly than ++  
 * Same as *(p++) 
 */
*p++

/* Increment the VALUE pointed to by p, the pointer.
 * Force * to bind more tightly than ++ 
 */
(*p)++
/* Normally *p++ is the same as *(p++), above forces it otherwise. */

/* Same--the contents of the object i locations past the one pointed to by p 
 * They're equivalent and valid if either p is a pointer or if it is an array.
 */
*(p+i)   /* pointer arithmetic */
p[i]

/* Iterate over a string approach 1 -- array */
for ( i=0; str[i]!='\0'; i++ ) { puts(str[i]); }

/* Iterate over a string approach 2 -- pointer */
while ( *str != '\0' ) { puts(*str++); }

/* Iterate over a string approach 3 -- terse pointer */
while ( *str ) { puts(*str++); }

// Go to the end of a string (e.g. to allow concatenation, etc.)
while ( *str ) str++;

/* Declare pointer to constant int, which means that although the pointer
 * can be modified (to point to different locations), the location pointed to
 * (that is, *pci1) can not be modified. 
 *
 * It can be used to document (and enforce) a pointer parameter which a
 * function promises not to use to modify the location in the caller. 
 */
const int *pci1;        /* or int const *pci1 */

/* Declares a pointer-to-int which cannot be modified (it cannot be set to
 * point anywhere else), although the value it points to (*pci2) can be
 * modified. 
 */
int * const pci2;

/* Copy the value pointed to by p2 to the value pointed to by p1 ... */
*p1 = *p2
/* ... compare with setting p1 to point wherever p2 points. */
p1 = p2

If you have a pointer named ptr that has been initialized to point to the
variable var, the following are true:
 1.  *ptr and var both refer to the CONTENTS of var (that is, whatever value
     the program has stored there). 
 2.  ptr and &var refer to the ADDRESS of var. 

int x[] and int *x both mean "pointer to int" 

/* Use line number as informative exit code (view via shell's $?). */
perror(argv[0]);
exit(__LINE__);

// Legitimate floating-point constant values are: 1e4 (exponent), 1.0001,
// 47.0, 0.0, and -1.159e-77. 

// Initialize array to zeros.  Compiler will use the first initializer for the
// first array element, and then use zero for all the elements without
// initializers (may be more efficient than using a for loop).
int arr[6] = {0};

// Size of an array idiom.  does the trick in a way that doesn't need to be
// changed if the array size changes.  Size of entire array divided by the
// size of 1st element.
int n = sizeof a / sizeof *a;
// or
int n = sizeof a / sizeof a[0];   
// or
#define ARRAY_SIZE(a) (sizeof(a) / sizeof(a[0]))

// Definition  - the place where the variable is created or assigned storage.
// Declaration - the placeS where the nature of the variable is stated but no storage is allocated.

// Must allocate space before copying source string to destination.  This
// assumes that you don't preallocate dest this way:  char dest[80];
char *dest;
dest = (char *)malloc(strlen(source) +1);
strcpy(dest, source);   /* ok now */

/* Safe error trap for malloc which itself requires *some* memory on failure */
#define MALLOC(x,y) do { y malloc(x); if (!y) abort(1); } while(0)

/* Pointers to structs. */
ptr_mystruct->title
/* eliminates the need for the ugly */
(*ptr_mystruct).title
/* In both cases, we are evaluating the element title of the structure pointed
 * to by ptr_mystruct 
 */
/* Pointers to structs summary: */
// Element 'title' of structure 'ptr_movies'   
movies.title    
// Element 'title' of structure pointed to by 'movies'
movies->title   // same as the ugly (*movies).title 
// Value pointed to by element 'title' of structure 'movies'
*movies.title   // same as the ugly *(movies.title) 

Find out which shared libraries a program requires (List Dynamic Dependencies):
$ ldd /usr/bin/w3m

External (global) variables initialize to 0. Local variables init to garbage.

// Minimum C macro
#define MIN(x,y) ((x) <= (y) ? (x) : (y))

// Compare two strings:
char *name = "Choice 1";
if ( strcmp(name, "Choice 1") == 0 ) {
  // You've found a match
}

// Super debugger.  Looks like this: DEBUG: ascii.c, 51, Jul  9 2002, 15:04:43
printf("\nDEBUG: %s, %d, %s, %s\n", __FILE__, __LINE__, __DATE__, __TIME__);

// const member function:
void show() const;   // promises not to change invoking object

// Determine if odd number:
int odd = (fmid - bmid) & 1;

// Assuming a struct named Point exists, use this to simplify typing:
typedef struct Point Point;

// Ragged array of ptrs to null terminated strings.
char* mystrings[] = {"how", "now", "brown", "cow"};

// Comment out a section of code (will skip main()):
#ifdef BOBHDEBUG;  main(); #endif

// Good declaration of an array (assumes  #define MAXSTRINGLEN 42  earlier):
char array[MAXSTRINGLEN+1] = { 0 };

xxCxx END:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:

---


GCC options you should know 

By Anurag Phadke <cbca@mantraonline.com> 
Posted: ( 2001-01-09 10:22:13 EST by FreeOS ) 

Using the GNU Compiler Collection (GCC) isn't for the faint of heart or those
used to the friendlier Windows IDEs. There are a huge number of command line
options available for GCC. This article brings you the most commonly used and
most useful options. 

Writing a thousand line code is better than having to debug it. The mistakes
can vary from a missing ";" error to major errors of logic. At the end of the
day, code that refuses to run is merely a temp file waiting to be deleted! 

Given below are the most often used gcc options. Though a lot more exist,
these are the most commonly used ones (26 to be specific) and can make
debugging easier. 

For more information refer to the man pages type "man gcc" at the command
line. GCC offers a host of options, some even for the AMD-K62 processor. 

The common syntax is gcc [option] [filename]. All options listed below are
case sensitive. The option -v differs completely from -V . Also options may be
put together in pairs. So, -vc is different from -v -c. 

1) Extensions do matter: The extension given to a file determines its type and
the way it should be compiled. 

.c => c source file - preprocess, combine and assemble. 
.m => objective-c source file - preprocess, combine and assemble. 
.i => pre-processed C file - compile and assemble. 

2) -x language [c, c++, objective-c etc.] - Compiles the file with respect to
the given option. A file with '.m' extension can be compiled as a '.c'
extension file using the command "gcc -x c filename.m". If no language is
specified the file is compiled depending upon the extension. 

3) -c : Compiles without linking. All successfully compiled binaries are saved
as "filename.o". 

4) -S : Stop after compilation and generate the assembly code. This code will
be saved in a file with the extension ".s". A extract of the assembler code is
given below. 

main: 
pushl %ebp 
movl %esp,%ebp 
subl $8,%esp 
addl $-12,%esp 
pushl $.LC0 

5) -o filename: The compiled binary is saved with specified filename. If not
specified, the default is the save the binary as a file named a.out in the
directory. 

6) -v : Provides the release number of your compiler. Useful if one is getting
an unexplainable error. The compiler may be a old version. 

7) -pipe : For a big program involving a lot of inter linked files and
functions, temporary files tend to get created while compilation. When this
option is specified, the compiler makes use of pipes rather than creating
temporary files. The output of each function is piped to the next. The swap
space is used instead. 

8) -ansi : Turns off features of gnu C which are incompatible with ANSI C.
This does not put a complete ban on non-ANSI programs. Certain Turbo C
features will work. A "-pedantic" option is required to force strict
conformance to the ANSI standard. 

9) -ffreestanding : Compiles in a freestanding environment. This makes use of
the '-fno-builtin' option along with main having no special requirement. 

10) -funsigned-char: Declares character S as unsigned. Since character is
machine specific, this serves to avoid confusion and common program errors
when run on various platforms. For example, suppose a Windows compiler takes a
defined character [syntax : char a;] as signed, while the Linux takes it as
unsigned. Now, suppose you are having a 
"if -else" statement -- if (a==0) { /*statements*/ }. Different compilers have
different defaults for the signedness of char. Specifying whether a char
should be signed or unsigned, removes ambiguity. For example, on the Windows
compiler, this statement will be executed considering character as signed
while on Linux they are executed considering character as unsigned. This shall
result in dubious results because Windows will interpret the object
differently. "-fsigned-char" declares a character as signed. 

Pre-processor options 

1.) -E : Do only preprocessing, no compiling or assembling. Output results to
standard output file a.out. Some of the options like -imacros work in tandem
with -E and require -E to be present along with it. 

2.) -include file : Compiles the file first. The options such as -D, -U are
compiled first, regardless of the order in which they are listed. The -include
and -imacros get compiled in accordance to the way they appear at the command
line. 

3.) -imacros : Compiles macros irrespective of the output. The only aim here
is to compile the macro and make it available to the program. 

4.) -C : Do not discard comments (used with -E option) 

5.) -P : Do not generate "#line" commands (used with -E option) 

6.) -M : Describes the dependencies of each object file. 

Linker options 

1.) -laddition : Use library bearing the name addition. Searches a list of
standard directories for the library named addition. A "-L
/place/where/library/exists" searches the directory specified. 

Directory options 

1.) -Idirectory : Append a list of directories to the standard directory list. 

2.) -I- : Specifying -I after -I- searches for #include directories. If -I- is
specified before, it searches for #include "file" and not #include . 

Warning messages 

1.) -w : Inhibit all warning messages. 

2.) -W : Print extra warning messages. For example, a function not returning a
value, a defined variable not being used. The warning messages issued over
here do not imply that the program has not compiled successfully. It just
helps to make a perfect program. Code can be cleaned up as you will be
notified of unused variables. 

3.) -Wswitch : Warn when 'switch' command is used. There are more options
here. The man page is the best resource for these additional switches. 

Debugging options (Kill those bugs) 

1.) -g : Produce extra debugging information in the native O.S. format. This
information is of use to only the GNU Debugger (GDB). 

-gstab gives debugging information in stab format. 

2.) -gdwarflevel : Request debugging information along with level. Default
level is set to 2. 

Level 1 : Minimal amount of code to backtrack. 
Level 3 : Maximum amount of code to backtrack. 

3.) -save-temps : Store the temporary generated files, permanently in the
current directory. The files are named on basis of the source file. 

4.) -O (0 or 1 or 2 or 3) 

0: Do not optimize. 
1: Optimize. Requires a little more time and a lot of memory. 
2 and 3 : Memory hogs but essential when dealing with large functions. 


© 1998-2001 FreeOS.com (I) Pvt. Ltd. All rights reserved.  

---


See also ~/code/c/gdb-refcard-letter.pdf

Sample session:
$ gcc -g t.c
$ gdb a.exe


(gdb) prompt essential commands

b[reak] main          <---or 'b MyFunc'  or 'b 1'
run <cmdline parms>   <---to the breakpoint just set
c[ontinue]      <---start execution from current point (but not at top??)
l[ist]          <---'l -' for prev or list 620,630
u[ntil] 623     <---or u 623
p[rint] arr[0]@5
info args       <---parms passed to function
disp[lay] str   <---show str's value after each step (in its scope)
s[tep]          <---use ret[urn] if we fall in a hole
n[ext]          <---step over - make sure to use this when stepping around cout
finish          <---leave a function call
return          <---leave a function call immediately
bt              <---which func are we in?
x str           <---show str's address and value at that address
kill            <---stop running current code
q[uit]          <---to stop and leave gdb


To see where a program died:
	gdb a.out core
	where
	...
