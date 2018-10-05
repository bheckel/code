
04-Feb-16 Cygwin/X
$ xinit -- -multiwindow
# Wait for white default xterm then use it:
$ xclock
$ ssh -l bheckel -Y sas-01.twa.taeb.com
$ /sas/sashome/SASManagementConsole/9.4/sasmc
# see also readme.ssh.txt for secure (-X) access

---

$ ssh-keygen -b 4096 -f cygupload

$ sftp -i ~/.ssh/cygupload cygwin@cygwin.com

https://sourceware.org/cygwin-apps/package-upload.html

Also, please create a !mail file at the top level of your area with the
email address where any upset errors should be sent.

Remember also that you need to create a !ready file somewhere above the
directory holding the packages that you want to end up in the release.
So, if you have uploaded x86 and x86_64 packages put the !ready at the
"root" level.  If you have uploaded x86 and are working on x86_64 you
can put the !ready in the x86 directory and then put another !ready in
the x86_64 directory when you're done.  Putting the !ready directly in
the package directory should work too.

---

30-Apr-13 offline laptop protection:

.....................................

.bashrc

if [ -e /cygdrive/u/code/misccode/_bashrc ];then
  source /cygdrive/u/code/misccode/_bashrc
else
  # An occasional copy from $u/code/misccode/_bashrc
  source ${HOME}/.bashrc.local
fi

.....................................

.vimrc

if has('win32unix')
  " Cygwin - online
  if filereadable('/cygdrive/u/code/misccode/_vimrc')
    source /cygdrive/u/code/misccode/_vimrc
  else " Cygwin - offline
    echo 'sourcing vimrc.local'
    " An occasional copy from $u/code/misccode/_vimrc
    source $HOME/.vimrc.local
  endif
elseif has('win32')
  " Gvim - online
  if filereadable('u:\code\misccode\_vimrc')
    source u:/code/misccode/_vimrc
  else " Gvim - offline
    echo 'sourcing vimrc.local'
    " An occasional copy from $u/code/misccode/_vimrc
    source $HOME/.vimrc.local
  endif
else
  echo 'unknown OS'
endif

.....................................

---

25-Apr-13
Dump symbols:
$ touch empty_source_file.c
$ cpp -dM empty_source_file

---

26-Mar-12
# On gsk
mount -f u:/code /home/rsh86800/code
mount -m >> /etc/fstab

---

2011-04-16
# On sati
mount -f "C:\Dropbox\My Dropbox\Public\USB\cygwin\home\bheckel\code" /home/bheckel/code
mount -m >> /etc/fstab

-----

2010-03-06
$ mount -f "C:\Users\bheckel_2\Documents\My Dropbox\Public\USB\cygwin\home\bheckel" /home/bheckel

-----

2009-12-16
Workbox with Lexar USB as primary code source:
mount -f -u "e:/cygwin/home/bheckel/code" /home/bheckel/code

-----


2008-12-31
sshd installation on dukkha
install openssh via setup.exe
/usr/bin/ssh-host-config   <---say no to privsep
/usr/bin/ssh-user-config
net start sshd

-----


2007-03-04
sshd installation on delusion vm
install openssh via setup.exe
/usr/bin/ssh-host-config   <---say no to privsep
cygrunsrv -S sshd

-----

Must have system mounts for cron - to convert:

eval "`mount -m | sed -e 's/ -u / -s /g' -e 's/$/;/'`"  #<---untested

which is the same (but easier) as this:

$ mount
C:\cygwin\bin on /usr/bin type user (binmode)
C:\cygwin\lib on /usr/lib type user (binmode)
C:\cygwin on / type user (binmode)
c: on /cygdrive/c type user (binmode,noumount)
k: on /cygdrive/k type user (binmode,noumount)
l: on /cygdrive/l type user (binmode,noumount)
x: on /cygdrive/x type user (binmode,noumount)
$ mount -m > mounts.bat
$ cat mounts.bat
mount -f -u -b "C:/cygwin/bin" "/usr/bin"
mount -f -u -b "C:/cygwin/lib" "/usr/lib"
mount -f -u -b "C:/cygwin" "/"
mount -u -b --change-cygdrive-prefix "/cygdrive"
$ umount -A
bash: history: /home/bheckel/.bash_history: cannot create: No such file or directory
bash: wc: command not found
bash: sed: command not found

Edit mounts to change -u to -s then run the BAT from cmd


-----

2006-11-24 W2K, 2006-12-08 WinXP
$ cygrunsrv -I cron -p /usr/sbin/cron -a -D -1 /var/log/cron.log -2 /var/log/cron.log
$ cygrunsrv -S cron  # <---use this instead of: net start cron   <---get Service errors but cron.exe starts and works
$ crontab -e


-----

2006-11-24 USB
,--- *
| @echo off
|
| set Path=%Path%;\cygwin\bin
|
| REM  umount -c; umount -A
| reg delete "hklm\software\cygnus solutions" /f > nul 2>&1
| reg delete "hkcu\software\cygnus solutions" /f > nul 2>&1
|
| mount -xfub --change-cygdrive-prefix /cygdrive
| mount -xfub %~d0\cygwin     /
| mount -xfub %~d0\cygwin/bin /usr/bin
| mount -xfub %~d0\cygwin/lib /usr/lib
| mount -xfub %TEMP%          /tmp
`---

-----

2006-07-16 parsifal
export DISPLAY=192.168.0.104:0.0
/usr/X11R6/bin/xhost +192.168.0.104
startx
# test
/usr/X11R6/bin/xclock

-----

2005-04-24

To avoid mystery stackdumps, had to roll back to cygwin 1.5.12 from .15 then
ssh had to roll back too (cdc and parsifal)

-----

2005-04-15

You can strace a program from a DOS prompt.  Cd into the cygwin bin directory,
and issue a command such as:

strace -f -o strace.log -w --mask=all -b 204800 bash.exe --login -i

-----

2005-04-06 Windows telnet doesn't work under rxvt, use inetutils pkg's telnet

-----

2005-04-02 Installing on cdc, be careful dotfiles don't get put in Documents and
Settings\Bob Heckel...edit /etc/passwd's idea of what "home" is if needed

-----

Start FTP server:
uncomment /etc/inet.d line
start CYGWIN inetd Service

-----

termcap is required to make vim 'go away' on exit.

/usr/bin/ssmtp-config        <---to set up mutt ssmtp (see readme.cron.txt too)

/usr/sbin/makewhatis         <--to get apropos/man -k working
                                After initial run here, must be run after
                                each (post-installation) tarball is unpacked

May want to use ResHack to change /bin/rxvt.exe (not /usr/bin/rxvt.exe) to the
cywin.ico icon.  Want to change the first icon in ResHack, Icon 1 / 0, Action
: Replace Icon then File : Save


-------
06/22/01 strangeness -- had to redo mkpasswd -l > /etc/passwd, add
CYGWIN=ntsec env vari to W2K widget otherwise get "Can't change uid" error on
ftp login.  But now think CYGWIN is necessary (it may be harmful).


------
2006-10-26 better to use this, NOT chere package

Bash Prompt Here (W2K) 2005-08-16:
No external files required but other (worse?) versions are in ~/zips

2008-11-06
HCR->Directory->Shell  add new key
                     ->cygwin_bash  add new value  &bash Prompt Here , add new key
                                  ->command  add new value  c:\cygwin\bin\rxvt.exe -geometry 80x45+305+100 -fn "Andale Mono-13" -sl 2500 -e /bin/bash -i

===========
2008-11-06 unable to Import this WinXP, may want to delete this section
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\Directory\shell\rxvt]
@="bash Prompt Here"

[HKEY_CLASSES_ROOT\Directory\shell\rxvt\command]
@="c:\\cygwin\\bin\\rxvt.exe -geometry 80x45+305+100 -fn \"Andale Mono-13\" -sl 2500 -e /bin/bash -i"
===========

or if by hand, just create new keys per above and paste this into the final value:
c:\cygwin\bin\rxvt.exe -geometry 80x45+305+100 -fn "Andale Mono-13" -sl 2500 -e /bin/bash -i


-----
To create password and group files.
$ mkpasswd -l > /etc/passwd
$ mkgroup -l > /etc/group


-----

03/21/02 mount configuration on parsifal:
c:\cygwin\bin on /usr/bin type system (binmode)
c:\cygwin\lib on /usr/lib type system (binmode)
c:\cygwin on / type system (binmode)
a: on /a type system (binmode)
a: on /mnt/floppy type system (binmode)
c: on /c type user (textmode)
d: on /d type system (binmode)
d: on /mnt/cdrom type system (binmode)
r: on /r type system (binmode)

-----

After each new installation:
Since Cygwin has changed its //c //d to mean network, do this:
mount c: /c
mount a: /a
mount a: /mnt/floppy  <---after mkdir /mnt/floppy
mount i: /i
etc...
(ignore warnings)

-----

You need the DLL to get the whole POSIX functionality. If you're
only using Win32 API calls you can build using the -mno-cygwin
option.

-----

Uninstallation:
Setup has no automatic uninstall facility. Just delete everything manually:

Cygwin shortcuts on the Desktop and Start Menu
Remove any services you might have installed ("cygrunsrv -R ssh")
The registry tree `Software\Cygnus Solutions' under HKEY_LOCAL_MACHINE and/or
HKEY_CURRENT_USER.  Use  umount -A  to do this.
Anything under the Cygwin root folder, `C:\cygwin' by default.
Anything created by setup in its temporary working directory.

-----

Start Xserver:
$ /usr/X11R6/bin/startxwin.sh
or better
$ cp /etc/X11/xinit/xinitrc ~/.xinitrc
then
$ startx
$ /usr/X11R6/bin/xhost.exe +158.111.250.128  <---adds daeb's IP address
$ ssh daeb
$ export DISPLAY=158.111.250.170:0.0         <---my DHCP W2K box's address
$ xclock

2011-03-22
Start Cygwin/X in multiwindow mode - startxwin
Start Cygwin/X in windowed mode - startx


-----
2004-03-02
Must  $ passwd -l >| /etc/passwd  if vim can't see swapfiles (and d won't use
customizations).


-----
2006-12-07
Search which package an executable came from:
http://cygwin.com/cgi-bin2/package-grep.cgi?grep=top.exe


-----
2004-12-31
Sample link:
http://mirrors.rcn.net/pub/sourceware/cygwin/release/libiconv/libiconv2/setup.hint


-----
2006-12-07 more complicated than what I did to get cron working
http://severna.homeip.net/cygwin.php

    * Run cygwin setup.exe and install cron under the Admin section.
    * Create the crontab file:

      cat < /etc/crontab >> EOF
      root@pingu # cat /etc/crontab
      SHELL=/bin/bash
      PATH=/sbin:/bin:/usr/sbin:/usr/bin
      MAILTO=root
      HOME=/home/YourUserNameWithoutSpaces

      # run-parts
      01 * * * * root run-parts /etc/cron.d/cron.hourly
      02 4 * * * root run-parts /etc/cron.d/cron.daily
      22 4 * * 0 root run-parts /etc/cron.d/cron.weekly
      42 4 1 * * root run-parts /etc/cron.d/cron.monthly
      EOF

    * Create the cron folders:

      mkdir -p /etc/cron.d/cron.hourly /etc/cron.d/cron.daily /etc/cron.d/cron.weekly /etc/cron.d/cron.monthly

    * Register the cron service:

      cygrunsrv -I cron -p /usr/sbin/cron -a -D

    * Register your crontab file:

      crontab -l # check to see what is currently in use (should be empty)
      crontab /etc/crontab
      crontab -l # should list your new crontab entries

    * Start the cron service:

      net start cron
