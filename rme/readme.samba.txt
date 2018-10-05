2007-02-25 after editing /etc/samba/smb.conf:
$ sudo /etc/init.d/samba restart


---


2007-02-18 Ubuntu

$ sudo apt-get install samba
$ sudo /etc/init.d/samba stop
$ sudo mv /etc/samba/{smb.conf,smb.conf.ORIG}
$ sudo vi /etc/samba/smb.conf  <---see below for pasted in changed version
$ sudo mkdir /home/samba
$ sudo chmod 0777 /home/samba
$ sudo /etc/init.d/samba start
$ sudo smbpasswd -L -a bheckel
$ sudo smbpasswd -L -e bheckel
$ ifconfig
$ cd /home/samba
$ vi icanwriteherenow.txt

Map s: as \\samsara\MyFiles in Windows (if hosts has the 192... map to
samsara), using bheckel and bheckel's ubuntu pw.  Can't browse to it via
Explorer, can only map.

/etc/samba/smb.conf:
[global]
    ; General server settings
    netbios name = samsara
    server string =
    workgroup = HECKNET
    announce version = 5.0
    socket options = TCP_NODELAY IPTOS_LOWDELAY SO_KEEPALIVE SO_RCVBUF=8192 SO_SNDBUF=8192

    passdb backend = tdbsam
    security = user
    null passwords = true
    username map = /etc/samba/smbusers
    name resolve order = hosts wins bcast

    wins support = no

    printing = CUPS
    printcap name = CUPS

    syslog = 1
    syslog only = yes

; NOTE: If you need access to the user home directories uncomment the
; lines below and adjust the settings to your hearts content.
;[homes]
    ;valid users = %S
    ;create mode = 0600
    ;directory mode = 0755
    ;browseable = no
    ;read only = no
    ;veto files = /*.{*}/.*/mail/bin/

; NOTE: Only needed if you run samba as a primary domain controller.
; Not needed as this config doesn't cover that matter.
;[netlogon]
    ;path = /var/lib/samba/netlogon
    ;admin users = Administrator
    ;valid users = %U
    ;read only = no

; NOTE: Again - only needed if you're running a primary domain controller.
;[Profiles]
    ;path = /var/lib/samba/profiles
    ;valid users = %U
    ;create mode = 0600
    ;directory mode = 0700
    ;writeable = yes
    ;browseable = no

; NOTE: Inside this place you may build a printer driver repository for
; Windows - I'll cover this topic in another HOWTO.
[print$]
    path = /var/lib/samba/printers
    browseable = yes
    guest ok = yes
    read only = yes
    write list = root
    create mask = 0664
    directory mask = 0775

[printers]
    path = /tmp
    printable = yes
    guest ok = yes
    browseable = no

; Uncomment if you need to share your CD-/DVD-ROM Drive
;[DVD-ROM Drive]
    ;path = /media/cdrom
    ;browseable = yes
    ;read only = yes
    ;guest ok = yes

[MyFiles]
    path = /home/samba/
    browseable = yes
    read only = no
    guest ok = no
    create mask = 0644
    directory mask = 0755
    force user = bheckel
    force group = bheckel

-----

Solaris daeb Samba 3.0.4 2004-06-30:
./configure --prefix=/opt/samba

Must be sure at least  chmod 755 $TMP

To debug:
/opt/samba/bin/testparm 
tail -f /opt/samba/var/log.smbd


-----

Files must be 777 to view via Explorer?

Debian daeb (same on Solaris):
  /etc/samba/smb.conf
  Start/stop daemons.
  /etc/init.d/samba start
  /etc/init.d/samba stop
  /etc/init.d/samba restart
  But not working.  
  kill -15 12345 doesn't work (keeps respawning).
  And kill -9 won't ever kill nmbd (only smbd)!

OBSOLETE daeb 2004-02-18
Reinstalled via apt-get to map entire box from root.  Hacked /etc/init.d/samba
to not load nmbd.

Using encrypted passwords now (as root) the9Fisu:
/usr/sbin/smbpasswd -U bheckel

Test:
c:> net use x: \\daeb\all /user:bheckel the9Fisu /persistent:no



OBSOLETE................
Adding a samba share:
As root vi /opt/samba/lib/smb.conf (or /etc/smb.conf)
Add something like this to the bottom:
# A publicly accessible directory, but read only.
[gr8xprog_zip]
comment = Opera
path = /gr8xprog_zip
public = yes
writable = yes  # writable only if the Unix permissions allow it (e.g. 777)
printable = no

May need to (as root):
$ /usr/sbin/samba start
Daemons will update every few minutes.  No need to HUP.
For permanent fix, use /etc/rc.d/init.d/sambastart
then symlink to rc3.d (start) and rc0.d (stop)

-----

Linux RH 6.1 via VMWare 2.0

Use Xteq on W2K to set clear text passwords.

$ rpm -Uvh /mnt/cdrom/RedHad/RPMS/samba-2.0.5a-12.i386.rpm # ignore the other 2
$ vi /etc/smb.conf  
# Change this:
workgroup = MYGROUP
# to this:
workgroup = WORKGROUP
$ testparm  # to syntax check THIS IS IMPORTANT IF RUNNING /etc/init.d/samba
                              start DOES ABSOLUTELY NOTHING
$ smbclient -L localhost -U%   # another check
$ /usr/sbin/samba start

# Try:
c:\> net use r: \\emiake\bobhome /persistent:no /user:bheckel rhrhrh
# or this if it fails:
c:\> net use * \\emiake\bheckel /persistent:no /user:bheckel rhrhrh
c:\> net view \\emiake\            # to see all shares

-----

Appears that you need parent dir shared before doing subdirs

-----

smbd 
A daemon that allows file and printer sharing on an SMB network and provides
authentication and authorization for SMB clients.

nmbd 
A daemon that looks after the Windows Internet Name Service (WINS), and
assists with browsing.

-----

Installation on GenRad server:
As root (to use gcc, gunzip, etc.), 
PATH=$PATH:/usr/local/gnu/bin
export PATH

cp samba.foo.tar.gz /usr/local/src

gunzip samba.foo.tar.gz

tar xvf samba.foo.tar

cd samba-2.07/source

Edit source/configure to point to /opt/samba instead of /usr/local/samba
./configure

make

make install

cp /usr/local/src/samba.foo/examples/smb.conf /opt/samba/lib
Edit similar to hpLfs01

To test syntax
/opt/samba/bin/testparm ../lib/smb.conf

Start daemons
/opt/samba/bin/smbd -D
/opt/samba/bin/nmbd -D




!==
!== UNIX_INSTALL.txt for Samba release 2.0.5a 22 Jul 1999
!==
HOW TO INSTALL AND TEST SAMBA
=============================

STEP 0. Read the man pages. They contain lots of useful info that will
help to get you started. If you don't know how to read man pages then
try something like:

	nroff -man smbd.8 | more

Other sources of information are pointed to by the Samba web 
site, http://samba.org/samba.

STEP 1. Building the binaries

To do this, first run the program ./configure in the source
directory. This should automatically configure Samba for your
operating system. If you have unusual needs then you may wish to run
"./configure --help" first to see what special options you can enable.

Then type "make". This will create the binaries.

Once it's successfully compiled you can use "make install" to install
the binaries and manual pages. You can separately install the binaries
and/or man pages using "make installbin" and "make installman".

Note that if you are upgrading for a previous version of Samba you
might like to know that the old versions of the binaries will be
renamed with a ".old" extension. You can go back to the previous
version with "make revert" if you find this version a disaster!

STEP 2. The all important step

At this stage you must fetch yourself a coffee or other drink you find
stimulating. Getting the rest of the install right can sometimes be
tricky, so you will probably need it.

If you have installed samba before then you can skip this step. 

STEP 3. Create the smb configuration file. 

There are sample configuration files in the examples subdirectory in
the distribution. I suggest you read them carefully so you can see how
the options go together in practice. See the man page for all the
options.

The simplest useful configuration file would be something like this:

   workgroup = MYGROUP

   [homes]
      guest ok = no
      read only = no

which would allow connections by anyone with an account on the server,
using either their login name or "homes" as the service name. (Note
that I also set the workgroup that Samba is part of. See BROWSING.txt
for defails)

Note that "make install" will not install a smb.conf file. You need to
create it yourself. You will also need to create the path you specify
in the Makefile for the logs etc, such as /usr/local/samba.

Make sure you put the smb.conf file in the same place you specified in
the Makefile.

For more information about security settings for the [homes] share please
refer to the document UNIX_SECURITY.txt

STEP 4. Test your config file with testparm

It's important that you test the validity of your smb.conf file using
the testparm program. If testparm runs OK then it will list the loaded
services. If not it will give an error message.

Make sure it runs OK and that the services look resonable before
proceeding. 

STEP 5. Starting the smbd and nmbd. 

You must choose to start smbd and nmbd either as daemons or from
inetd. Don't try to do both!  Either you can put them in inetd.conf
and have them started on demand by inetd, or you can start them as
daemons either from the command line or in /etc/rc.local. See the man
pages for details on the command line options. Take particular care 
to read the bit about what user you need to be in order to start Samba.
In many cases you must be root.

The main advantage of starting smbd and nmbd as a daemon is that they
will respond slightly more quickly to an initial connection
request. This is, however, unlilkely to be a problem.

Step 5a. Starting from inetd.conf

NOTE; The following will be different if you use NIS or NIS+ to
distributed services maps.

Look at your /etc/services. What is defined at port 139/tcp. If
nothing is defined then add a line like this:

netbios-ssn     139/tcp

similarly for 137/udp you should have an entry like:

netbios-ns	137/udp

Next edit your /etc/inetd.conf and add two lines something like this:

netbios-ssn stream tcp nowait root /usr/local/samba/bin/smbd smbd 
netbios-ns dgram udp wait root /usr/local/samba/bin/nmbd nmbd 

The exact syntax of /etc/inetd.conf varies between unixes. Look at the
other entries in inetd.conf for a guide.

NOTE: Some unixes already have entries like netbios_ns (note the
underscore) in /etc/services. You must either edit /etc/services or
/etc/inetd.conf to make them consistant.

NOTE: On many systems you may need to use the "interfaces" option in
smb.conf to specify the IP address and netmask of your interfaces. Run
ifconfig as root if you don't know what the broadcast is for your
net. nmbd tries to determine it at run time, but fails on some
unixes. See the section on "testing nmbd" for a method of finding if
you need to do this.

!!!WARNING!!! Many unixes only accept around 5 parameters on the
command line in inetd. This means you shouldn't use spaces between the
options and arguments, or you should use a script, and start the
script from inetd.

Restart inetd, perhaps just send it a HUP. If you have installed an
earlier version of nmbd then you may need to kill nmbd as well.

Step 5b. Alternative: starting it as a daemon

To start the server as a daemon you should create a script something
like this one, perhaps calling it "startsmb"

#!/bin/sh
/usr/local/samba/bin/smbd -D 
/usr/local/samba/bin/nmbd -D 

then make it executable with "chmod +x startsmb"

You can then run startsmb by hand or execute it from /etc/rc.local

To kill it send a kill signal to the processes nmbd and smbd.

NOTE: If you use the SVR4 style init system then you may like to look
at the examples/svr4-startup script to make Samba fit into that system.


STEP 6. Try listing the shares available on your server

smbclient -L yourhostname 

Your should get back a list of shares available on your server. If you
don't then something is incorrectly setup. Note that this method can
also be used to see what shares are available on other LanManager
clients (such as WfWg).

If you choose user level security then you may find that Samba requests
a password before it will list the shares. See the smbclient docs for
details. (you can force it to list the shares without a password by
adding the option -U% to the command line. This will not work with
non-Samba servers)

STEP 7. try connecting with the unix client. eg:

smbclient //yourhostname/aservice

Typically the "yourhostname" would be the name of the host where you
installed smbd. The "aservice" is any service you have defined in the
smb.conf file. Try your user name if you just have a [homes] section
in smb.conf.

For example if your unix host is bambi and your login name is fred you
would type:

smbclient //bambi/fred

STEP 8. Try connecting from a dos/WfWg/Win95/NT/os-2 client. Try
mounting disks. eg:

net use d: \\servername\service

Try printing. eg:

net use lpt1: \\servername\spoolservice
print filename

Celebrate, or send me a bug report!

WHAT IF IT DOESN'T WORK?
========================

If nothing works and you start to think "who wrote this pile of trash"
then I suggest you do step 2 again (and again) till you calm down.

Then you might read the file DIAGNOSIS.txt and the FAQ. If you are
still stuck then try the mailing list or newsgroup (look in the README
for details). Samba has been successfully installed at thousands of
sites worldwide, so maybe someone else has hit your problem and has
overcome it. You could also use the WWW site to scan back issues of
the samba-digest.

When you fix the problem PLEASE send me some updates to the
documentation (or source code) so that the next person will find it
easier. 

DIAGNOSING PROBLEMS
===================

If you have instalation problems then go to DIAGNOSIS.txt to try to
find the problem.

SCOPE IDs
=========

By default Samba uses a blank scope ID. This means all your windows
boxes must also have a blank scope ID. If you really want to use a
non-blank scope ID then you will need to use the -i <scope> option to
nmbd, smbd, and smbclient. All your PCs will need to have the same
setting for this to work. I do not recommend scope IDs.


CHOOSING THE PROTOCOL LEVEL
===========================

The SMB protocol has many dialects. Currently Samba supports 5, called
CORE, COREPLUS, LANMAN1, LANMAN2 and NT1.

You can choose what maximum protocol to support in the smb.conf
file. The default is NT1 and that is the best for the vast majority of
sites.

In older versions of Samba you may have found it necessary to use
COREPLUS. The limitations that led to this have mostly been fixed. It
is now less likely that you will want to use less than LANMAN1. The
only remaining advantage of COREPLUS is that for some obscure reason
WfWg preserves the case of passwords in this protocol, whereas under
LANMAN1, LANMAN2 or NT1 it uppercases all passwords before sending them,
forcing you to use the "password level=" option in some cases.

The main advantage of LANMAN2 and NT1 is support for long filenames with some
clients (eg: smbclient, Windows NT or Win95). 

See the smb.conf manual page for more details.

Note: To support print queue reporting you may find that you have to
use TCP/IP as the default protocol under WfWg. For some reason if you
leave Netbeui as the default it may break the print queue reporting on
some systems. It is presumably a WfWg bug.


PRINTING FROM UNIX TO A CLIENT PC
=================================

To use a printer that is available via a smb-based server from a unix
host you will need to compile the smbclient program. You then need to
install the script "smbprint". Read the instruction in smbprint for
more details.

There is also a SYSV style script that does much the same thing called
smbprint.sysv. It contains instructions.


LOCKING
=======

One area which sometimes causes trouble is locking.

There are two types of locking which need to be performed by a SMB
server. The first is "record locking" which allows a client to lock a
range of bytes in a open file. The second is the "deny modes" that are
specified when a file is open.

Samba supports "record locking" using the fcntl() unix system
call. This is often implemented using rpc calls to a rpc.lockd process
running on the system that owns the filesystem. Unfortunately many
rpc.lockd implementations are very buggy, particularly when made to
talk to versions from other vendors. It is not uncommon for the
rpc.lockd to crash.

There is also a problem translating the 32 bit lock requests generated
by PC clients to 31 bit requests supported by most
unixes. Unfortunately many PC applications (typically OLE2
applications) use byte ranges with the top bit set as semaphore
sets. Samba attempts translation to support these types of
applications, and the translation has proved to be quite successful.

Strictly a SMB server should check for locks before every read and
write call on a file. Unfortunately with the way fcntl() works this
can be slow and may overstress the rpc.lockd. It is also almost always
unnecessary as clients are supposed to independently make locking
calls before reads and writes anyway if locking is important to
them. By default Samba only makes locking calls when explicitly asked
to by a client, but if you set "strict locking = yes" then it will
make lock checking calls on every read and write. 

You can also disable by range locking completely using "locking =
no". This is useful for those shares that don't support locking or
don't need it (such as cdroms). In this case Samba fakes the return
codes of locking calls to tell clients that everything is OK.

The second class of locking is the "deny modes". These are set by an
application when it opens a file to determine what types of access
should be allowed simultaneously with its open. A client may ask for
DENY_NONE, DENY_READ, DENY_WRITE or DENY_ALL. There are also special
compatability modes called DENY_FCB and DENY_DOS.

You can disable share modes using "share modes = no". This may be
useful on a heavily loaded server as the share modes code is very
slow. See also the FAST_SHARE_MODES option in the Makefile for a way
to do full share modes very fast using shared memory (if your OS
supports it).


MAPPING USERNAMES
=================

If you have different usernames on the PCs and the unix server then
take a look at the "username map" option. See the smb.conf man page
for details.
