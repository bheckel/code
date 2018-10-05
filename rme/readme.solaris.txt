
2007-03-04 
# groupadd -g 1234 tux
# useradd -g 1234 -u 1234 -s /usr/bin/bash -d /export/home/tux -m tux
64 blocks
# passwd tux
New Password: ++++++++
Re-enter new Password: ++++++++
passwd: password successfully changed for tux

----

$ ifconfig pcelx0 plumb

----

Eight partitions (view details via prtvtoc):
Slice 0 == / i.e. root filesystem
Slice 1 == swap partition (conventional but not mandatory)
Slice 2 == entire disk (for backup, etc., it's a symbolic representation)
Slice 3 == customer use
Slice 4 == customer use
Slice 5 == /opt (conventional but not mandatory)
Slice 6 == /usr (conventional but not mandatory)
Slice 7 == /export/home (conventional but not mandatory)
Slice 8 ???

/dev/dsk/c1t4d0s5  is the 5th slice on the slave drive attached to the 2nd IDE
                   controller (d0 never changes)


Blastwaves
http://www.ibiblio.org/pub/solaris/csw/stable/i386/5.8/



(i dont think this applies to solaris 10)
The /home problem is because /home is an automount point, not a real
directory. You can create a home account in /export/home/user and then add
them to /etc/auto_home to automount the home directory in /home. If you want
the cheap way you can just add this entry and any /home/blah lookup will
result in a mount attempt:

* localhost:/export/home/&

---better explanation:

On solaris, /home is by default auto-mounted so that you can have home
directories hosted on any machine: it mounts it via NFS when you log in and
unmounts it when you log out. You can:

 * disable the auto mounter for /home: comment out the line that starts /home
   in /etc/auto_master
 * create your home directories under /export/home which is exported via NFS
   and is where the auto mounter points to
 * change /etc/auto_home to specify where it should look for home directories


-----


The following steps may be used to change the IP address of a Solaris system:

1. Change the host's IP in /etc/hosts for the change to take effect after
reboot.

2. Change /etc/defaultrouter with the address of the host's new default
gateway, if applicable.

3. If you are using variable length subnet masks (VLSM), add the host's
network number and subnet mask to /etc/netmasks.

4. Run ifconfig interface ip_address netmask broadcast_address for the IP
address change to take effect immediately. The netmask and broadcast_address
should be specified if you are using variable length subnet masks (VLSM), but
may be omitted otherwise.

Solaris 10 additional instructions:
5. Change the host's IP in /etc/inet/ipnodes for the change to take effect
after reboot.
