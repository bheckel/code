# as root:
apt-get update
apt-get fluxbox
apt-get --fix-missing install xfe



##############################################################################
begin OLD:
begin OLD:
begin OLD:

Debian daeb box (since it was installed strangely):
At boot prompt
rescue root=/dev/sda1

or F1 F3 for help


2002-07-05
Commented out the nmbd daemon in /etc/init.d/samba shell script so that daeb
is invisible on the NT Network.  Copied smb.conf to
~/code/misccode/daeb-smb.conf


2002-07-05
For testing Vitalet
$ adduser vnetusr  <---adduser is better than useradd   pw is x


2002-07-19
Determined that exim is run via inetd and the rc.d script can recognize that
and prevent trying to run 2 exims.

Check to see if exim is running:
$ telnet daeb smtp

Booting daeb based on it's lack of LILO:
Restarting via the power button dumps you into Rescue Mode.
At the boot prompt:
  rescue root=/dev/sda1
(F1 or F3 might give additional details)
Then need to run vnet_each_home_dir.sh since /tmp is wiped out on each reboot.


-----

Install a .deb file if you have it on your disk:
dpkg -i /path/deb-file

See http://packages.debian.org for packages available.
Allow http:// access to packages (as root):
vi /etc/apt/sources.list   <---uncomment an http:// line first
$ apt-get update


Install:
"apt-get install <something>" for installing packages or sets of packages 
from cd-rom or servers (servers must be first enabled by editing sources.list)
E.g.
$ apt-get install libncurses-dev

"dpkg -i <something>" for installing single packages that you downloaded

Search:
apt-cache search <something>   <---instead of dselect for searching packages on 
                                   your cd-rom set or configured download sites

Upgrade:
$ apt-get -u upgrade    <---does ALL packages on your box

Get info on specific pkg:
$ apt-cache show lynx

Get dependencies on specific pkg:
$ apt-cache depends lynx

Remove a program: 
$ apt-get remove packagename 

-----

See /etc/inittab for runlevels

-----

2002-09-23
Added MySQL and Apache to rc.d (see readme.mysql.txt or
~/code/misccode/runlevels_linux.htm)

2002-09-25
Added a kill lpd (printer control) to rc.d
daeb:/etc/rc0.d# ln -s ../init.d/lpd K20lpd


-----

2003-12-01

Repartitioned /usr/local/ehdp to /home to use the 16GB second hard drive.

-----

Setup users as root:
Use Cygwin's crypt to get password (dAebrpt5) encrypted
$ mkdir /etc/skel/public_html  <---everyone needs a web dir
$ chmod 755 /etc/skel/public_html
$ useradd -g daebstat -m -p N6lPzsXhb5TLg dwj2
To remove
$ userdel -r phy9

-----

FTP daemon runs from inetd
                 set umask
                 _________
/usr/sbin/in.ftpd -u 022


-----

Debian install 2002-11-21

cd /tmp
tar xvfz retroclient-60.tar
./Install.sh

Had to copy the resulting rcl script to /usr/local/dantz/client and set
RETROSPECT_HOME manually.
$ export RETROSPECT_HOME=/usr/local/dantz/client
$ /usr/local/dantz/client/rcl start             <---start daemon shell script
$ /usr/local/dantz/client/retrocpl -readonly    <---binary

Manually find client in Win2K Retrospect, set volume for /home
As root:
$ cd /etc/init.d
$ ln -s /usr/local/dantz/client/rcl retrospect

$ cd ../rc0.d && ln -s ../init.d/retrospect K20retrospect
$ cd ../rc6.d && ln -s ../init.d/retrospect K20retrospect

$ cd ../rc2.d && ln -s ../init.d/retrospect S20retrospect
$ cd ../rc3.d && ln -s ../init.d/retrospect S20retrospect
$ cd ../rc4.d && ln -s ../init.d/retrospect S20retrospect
$ cd ../rc5.d && ln -s ../init.d/retrospect S20retrospect

2002-12-30 TODO
Problem: 7 copies of Retrospect are running after reboot.  Deleted all but
/etc/rc3.d/S20retrospect symlink but don't think I needed to.  Looks like
running $ /usr/local/dantz/client/retroclient -daemon spawns 5 processes.
