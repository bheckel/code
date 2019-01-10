04-Feb-16
$ xinit -- -multiwindow
$ ssh -l bheckel -Y 10.12.19.40
$ /sas/sashome/SASManagementConsole/9.4/sasmc

---

# OBSOLETE
# Cygwin
$ startxwin
# in resulting xterm:
$ ssh -l bheckel -Y sas-01.twa.aetb.com

---

22-Jun-15 not working
Cygwin XDMCP access
XWin.exe -query sas-01.twa.taeb.com

---

12-Sep-13

$ startxwin # on Cygwin rxvt
$ xauth list  # on resulting Cygwin X xterm, this produced no output so need:
$ xauth add :0 . `mcookie`
$ xauth list
ZEBWLxxx29961/unix:0  MIT-MAGIC-COOKIE-1  7feb0dc7d3d1f0a695ab9e49ae2277e6
$ ssh -Y -l mdadmin trpsduxdcm3.corpnet2.com
% /usr/openwin/bin/xclock
Xlib: connection to "413.193.14.181:0.0" refused by server
Xlib: No protocol specified
% /usr/openwin/bin/xauth list
trpsduxdcm3/unix:10  MIT-MAGIC-COOKIE-1  e13e7724490eb4ea1c0a1b6acb558274
% /usr/openwin/bin/xauth add :10 . e13e7724490eb4ea1c0a1b6acb558274
% setenv DISPLAY localhost:10.0
% /usr/openwin/bin/xclock

---

14-Feb-13
# To run an X command after su, super chemlms-shell, etc:
$ startxwin  # in rxvt Cygwin
###$ ssh -Y rtps005  # insecure in xterm Cygwin
$ ssh -X rtps005  #  in xterm Cygwin                                 # 1
$ xclock  # works
$ xauth list                                                         # 2   
15.241.2.4:0  MIT-MAGIC-COOKIE-1  6e4a55704a314d645559743439486567
153.193.12.6:0  MIT-MAGIC-COOKIE-1  38426267724d366362504b743671416c
rtps005/unix:10  MIT-MAGIC-COOKIE-1  eec2e9bf7f90b92bd73d5c6950f8cf4e
$ echo $DISPLAY
localhost:10.0
$ super chemlms-shell                                                # 3
$ xclock  # fails
#                 ___________from list____________
$ xauth add :10 . eec2e9bf7f90b92bd73d5c6950f8cf4e                   # 4
$ export DISPLAY=localhost:10.0                                      # 5
$ xclock  # or menuUCP works

-----

2011-02-13 Canonical passwordless access using keys:
# Generate id_rsa.pub on your local, copy the resulting string to remote's
# authorized_keys
#
# If it doesn't already exist, create a new keypair on the machine that you will use ssh
$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/patrick/.ssh/id_dsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /Users/patrick/.ssh/id_dsa.
Your public key has been saved in /Users/patrick/.ssh/id_dsa.pub.
The key fingerprint is:
87:66:b7:a0:f6:0e:6a:71:2c:5d:ee:5f:17:2a:b7:2f patrick@localhost
The key's randomart image is:
+--[ RSA 20248----+
|                 |
|                 |
|                 |
|        ..       |
|     o oS o   .  |
|    o ++.+ . . . |
|     ++.  o + .  |
|    .o o.  +Eo   |
|   ..  .o.. .o.  |
+-----------------+
# Send your pubkey to the machine you will ssh into (this is the last time
# you'll be prompted for your pw):
$ cat ~/.ssh/id_rsa.pub | ssh bheckel@sdf.org 'cat - >> ~/.ssh/authorized_keys'
$ ssh -v rtpsh005  # should be password-free
#
# or
#
$ ssh bheckel@sdf.org 'cat >> .ssh/authorized_keys' < ~/.ssh/id_dsa.pub
# or if new box
$ ssh user@host "mkdir -p .ssh && cat >> .ssh/authorized_keys" < ~/.ssh/id_rsa.pub

$ ssh remotehost  # or  ssh bheckel@remotehost  or  ssh -l bheckel remotehost.com

# If you have protected your keys with a passphrase (which you should), then it
# is annoying to re-enter that all the time. You can avoid that by running your
# environment inside an ssh-agent and using ssh-add to enter the passphrase once.
# This is your LOCAL ssh process asking for your passphrase, not the ssh server
# on the remote side:
Need passphrase for /home/mah/.ssh/id_dsa (you@example.com).
Enter passphrase:

$ nohup ssh-agent $SHELL  # usually set in ~/.fluxbox/startup
$ ssh-add  # one time (after reboot) works for all subsequent logins (until reboot)
$ ssh-add -l  # to prove it worked

# Now
$ git add _bashrc && git commit -m 'mod' && git push origin master
# works w/o password

-----

2010-10-09 works on sdf as well

cygwin$ ssh-keygen -tdsa  #<--then copy the "ssh-dss AAA..." line generated in
.ssh/id_dsa.pub
cygwin$ chmod 400 .ssh/id_dsa

rtpsh004$ vi .ssh/authorized_keys  #<--then append paste here

# then just copy that same line to ushpam, rtpsh005's .ssh/authorized_keys

-----

2009-02-04

LIMS also uses id_dsa.pub

cygwin$ telnet rtpsh004
004$ mkdir .ssh
004$ vi .ssh/authorized_keys <---paste in cygwin's ~/.ssh/id_rsa.pub, make sure no blank empty line
004$ chmod 600 .ssh/authorized_keys

-----

2007-11-17 

Install sshd on Ubuntu 7:
$ sudo apt-get install openssh-server  # not sure it existed on bare install
$ sudo vi /etc/ssh/sshd_config  
# uncomment AuthorizedKeysFile %h/.ssh/authorized_keys
# and commentout  PermitRootLogin yes
$ sudo /etc/init.d/ssh restart  # ! not sshd

$ ssh -v ubuntu@192.168.80.131  # on sati to test

-----

2006-11-15
Setup nopassword freeshell access from sati as Administrator (not bheckel):

On sati:
$ ssh-keygen -tdsa  <---files created in ~Administrator/.ssh - just move all to
                         ~bheckel/.ssh

Basically just want this local .pub appended to authorized_keys on the remote
box:
$ catput ~/.ssh/id_dsa.pub (sdf 2007-03-04 but cygwin using id_rsa.pub)
$ ssh-copy-id -i ~/.ssh/id_rsa.pub yourusername@your.website.com
or
$ ssh-copy-id yourusername@your.website.com

On freeshell:
$ vi .ssh/authorized_keys
append the clipboard contents (after :se tw=999999)
$ chmod 600 .ssh/authorized_keys

-----

2005-04-03 restart sshd Solaris 10 (untested):
# svcadm restart network/ssh:default

2005-04-02 for root login, must set /etc/ssh/sshd.config (and maybe
/etc/default/login console setting), id_rsa.pub s/b copied to
/.ssh/authorized_keys

myLocalHost$ cat $HOME/.ssh/id_rsa.pub | ssh myRemoteHost \
'cat >> .ssh/authorized_keys && echo "Key copied"'

-----

For otaku (THIS MAY BE OBSOLETE)
On parsifal:
$ cd ~/.ssh
$ ssh-keygen -b512 -tdsa   <---accept all defaults, no passphrase
$ cat id_dsa.pub | putclip
On otaku:
$ vi ~/.ssh/authorized_keys
paste from Clipboard :wq
Then setup .muttprivate like this:
macro index z "! ssh -f -L 110:localhost:110 -l bheckel mail.freeshell.org sleep 500\nG" "Setup tunnel and fetch-mail"

-----

The .ssh/authorized_keys file contains the public keys on any remote user
accounts that we wish to automatically log in to. You can set up automatic
logins by copying the contents of the .ssh/identity.pub from the remote
account into our local .ssh/authorized_keys file. It is vital that the file
permissions of .ssh/authorized_keys allow only that you read and write it;
anyone may steal and use the keys to log in to that remote account. 

-----

The administrator at the remote host should have supplied you in advance with
its public key fingerprint, which you should add to your .ssh/known_hosts
file. If the remote administrator has not supplied you the appropriate key,
you can connect to the remote host, but ssh will warn you that it does have a
key and prompt you whether you wish to accept the one offered by the remote
host. Assuming that you're sure no one is engaging in DNS spoofing and you are
in fact talking to the correct host, answer yes to the prompt. The relevant
key is then stored automatically in your .ssh/known_hosts and you will not be
prompted for it again. If, on a future connection attempt, the public key
retrieved from that host does not match the one that is stored, you will be
warned, because this represents a potential security breach.

-----

To start the ssh daemon:
/usr/sbin/sshd
To restart the ssh daemon:
ps -auxw | grep sshd  <---find pid 123
kill -HUP 123

-----

Install on Solaris x86 2004-06-08 (prerequisite is zlib and ssl)
$ cd src
$ gunzip <openssl-0.9.7d.tar.gz | tar xvf -
$ cd openssl-0.9.7d
$ ./config --prefix=/opt/sfw/
$ make && make test
# make install

$ cd ..
$ gunzip <openssh-3.8p1.tar.gz | tar xvf -
$ cd openssh-3.8p1
$ ./configure --prefix=/opt/sfw/ --without-zlib-version-check
$ make
# make install
# vi /etc/group  <---add 'sshd::40002:bheckel'
# useradd -g sshd sshd
# /opt/sfw/sbin/sshd&   <---to run manually
To run at boot:
# cp -i /home/bheckel/src/openssh-3.8p1/contrib/solaris/opensshd.in /etc/init.d/
edit (piddir is a default that I didn't set):
prefix=/opt/sfw
etcdir=/opt/sfw/etc
piddir=/var/run
# ln /etc/init.d/opensshd.in /etc/rc3.d/S99sshd
# ln /etc/init.d/opensshd.in /etc/rcS.d/K00sshd
# ln /etc/init.d/opensshd.in /etc/rc1.d/K00sshd
# ln /etc/init.d/opensshd.in /etc/rc2.d/K00sshd
# ln /etc/init.d/opensshd.in /etc/rc3.d/K00sshd
