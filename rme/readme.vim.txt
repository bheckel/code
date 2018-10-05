" C:\Users\boheck\.vimrc
if has('unix')
  source /c/cygwin64/home/boheck/dotfiles/_vimrc
else
  source c:/cygwin64/home/boheck/dotfiles/_vimrc
endif

---
mkdir -p .vim/syntax && cp ~/code/sas/sas.vim .vim/syntax/

---

sudo vi /usr/share/vim/vim74/syntax/syncolor.vim

on Ubuntu comment out 14-Jan-18
" SynColor Comment	term=bold cterm=NONE ctermfg=Cyan ctermbg=NONE gui=NONE guifg=#80a0ff guibg=NONE

---

10-Jul-15

wget 'http://ftp.gnu.org/pub/gnu/ncurses/ncurses-5.9.tar.gz'
tar xfz ncurses-5.9.tar.gz
cd ncurses-5.9
./configure --prefix=/mnt/nfs/home/bheckel/usr/local --without-cxx
make
make install

wget 'ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2'
tar xfj vim-7.4.tar.bz2
cd vim74
export LDFLAGS=-L/mnt/nfs/home/bheckel/usr/local/lib
./configure --prefix=/mnt/nfs/home/bheckel/usr/local --with-tlib=ncurses
make
make install

---

05-Oct-12

"Open With Vim" Win7: need to set HOME c:\cygwin\home\rsh86800 for .vimrc to be read
or use a redirection in C:\Program Files (x86)\Vim\_vimrc

source c:\cygwin64\home\bob.heckel\dotfiles\_vimrc


-----

2005-03-08 adapted from vimtips

Compare to C and shell(bash), some vim specifics about vim-script:

1. A function name must be capitalized.

2. How to reference the parameters
   fu! Hex2dec(var1, var2)
    let str=a:var1
    let str2=a:var2
   You must prefix the parameter name with "a:", and a:var1 itself is
   read-only, in c, you reference the parameter directly and the parameter is
   writable.

3. How to implement variable parameter
   fu! Hex2dec(fixpara, ...)
     a:0 is the real number of the variable parameter when you invoke the
     function, with :Hex2dec("asdf", 4,5,6), a:0=3, and a:1=4 a:2=5 a:3=6 you
     can combine "a:" and the number to get the value

       while i<a:0
         exe "let num=a:".i
         let i=i+1
       endwhile

   In c, the function get the real number by checking the additional parameter
   such as printf family, or by checking the special value such as NULL.

4. Where is the vim-library
   yes, vim has its own function-library, just like *.a in c
   :help functions

5. can I use += or ++ operator?
   No

6. How can I assign a value to a variables and fetch its value?
   let var_Name=value
   let var1=var2
   Like it does in c, except you must use let keyword

7. Can I use any ex-mode command in a function?
   Just use it directly, as if every line you type appears in the familar : 

8. Can I call a function recurse?
   Yes

9. Can I call another function in a function?
   Yes

10. Must I compile the function?
    No, you needn't and you can't, just :so script_name, after this you can
    call the function freely.

11. Is it has integer and char or float data type?
    No, like perl, vim script justify the variable type depend upon the
    context
     :let a=1
     :let a=a."asdf"
     :echo a
     you'll get `1asdf'
     :let a=1
     :let a=a+2
     :echo a
   you'll get 3

12. Must I append a `;' in every statement?
    No
    ; is required in C, and optional in shell for each statement in a alone
    line.  But is forbidden in vim.  if you want combine several statements in
    a single line, use `|'.  Every statement appearing in a function should be
    valid in ex-mode(except for some special statement).

-----

To install Vim on Debian potato, first, as root:
$ apt-get install libncurses5-dev
Debian splits the headers into -dev (development) packages because most users
do not need them.  This cuts down on downloads and on disk usage.


-----


From: agelman1@san.rr.com (agelman1@san.rr.com)
Subject: Re: VI/VIM don't save/restore screen under xterm 
Newsgroups: comp.editors
Date: 1999/09/23 

On Wed, 22 Sep 1999 09:32:41 GMT, "T.E.Dickey"
<dickey@shell.clark.net> wrote:

>Anatoly Gelman <anatoly.gelman@c-cube.com> wrote:
>> Can some kind soul help me solve this problem. When
>> invoked in xterm window, vi (or vim) do not
>> restore original screen after exit, the screen is
>> left overwritten with remains of edited text. However
>> "less" utility is able to restore the screen.
>
>xterm supports an escape sequence for the "alternate screen".  some
>platforms have it in the vendor's termcap/terminfo, some don't.
>(some users dislike it, other's don't).
>
>on Solaris, you don't - but can make your own copy of the terminfo
>(man tic, infocmp), and install it locally.  Add to smcup and rmcup
>the strings \E[?47h and \E[?47l

It worked. I've grabbed the output of "infocmp xterm",
attached the two lines as you suggested (followed by commas)
and compiled with "tic -v file".


-----

2004-05-10
To compile Vim on Solaris x86 v8 after installing Bonus software:
Did not edit any files, just this configure command:
$ cd vim62/src
$ ./configure --prefix=/opt/sfw --enable-gui=no --with-compiledby=bheckel --disable-xsmp --disable-xsmp-interact --disable-acl --disable-gpm --with-x=no

Otherwise, we get this error during make:
ld.so.1: ./vim: fatal: libXpm.so.4: open failed: No such file or directory
Killed

make
make test
make install
