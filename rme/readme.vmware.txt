s/b symlinked as readme.vmplayer.txt
------------------------------------


2007-06-10 delusion has 192.168.80.128 and sati can p/u the hostname
automatically (somehow)


----

For VMPlayer install see ~/zips/vmplayer.zip (nested OS.zip includes
instructions .html) The .vmx file is set w/ cdrom pointing to an .iso (hard
drive or cdrom) during install then switched after (this is not mentioned in
the how to doc)

Backups of .vmx in ~/computer


-----
During the Linux installation, select the standard VGA16 X server. Select the
"Generic VGA compatible/Generic VGA" card from the list in the Choose a Card
screen. 

Select the Generic Monitor entry from the list in the Monitor Setup screen. 

Select the Probe button from the Screen Configuration dialog and select OK
from the Starting X dialog. When Linux is installed, the generic X server will
be replaced with the accelerated X server included in the VMware Tools
package. 

See VMWare help files on how to install vmtoolbox in Linux.

-----


From www.VMware.com
Windows 9x Guest Operating System Performance Tips 

This document offers advice for configuring a Windows 95 or Windows 98 guest
operating system for better performance inside a VMware virtual machine. 

Note: This document pertains to the guest operating system that is running
inside a VMware virtual machine. It does not describe actions that should be
taken on the host. 

Guest operating system selection---
Make certain you have selected the correct guest operating system in the
Configuration Editor (Settings > Configuration Editor > Guest OS). 

VMware Tools---
Make certain VMware Tools for Windows is installed. VMware Tools provides an
optimized SVGA driver and sets up the VMware Tools applet to run automatically
when the system starts. Among other things, the VMware Tools applet allows you
to synchronize the virtual machine's clock with the host computer's clock,
which can improve performance for some functions. You can install VMware Tools
by choosing Settings > VMware Tools Install... from the VMware menu. 

DMA mode for IDE disks---
Windows 95 OSR2 and later (including Windows 98) can use direct memory access
(DMA) for faster access to IDE hard disks. However, this feature may not be
enabled by default.  You can turn on DMA access using the Device Manager.
Right-click My Computer and choose Properties from the pop-up menu. Click the
+ sign beside Disk Drives to show your virtual machine's individual drives.
Right-click the entry for each IDE drive to bring up its properties dialog.
Under Settings, check the box labelled DMA and accept any warning Windows
displays. Restart Windows for the new settings to take effect. 

Full-screen mode---
Run your virtual machine in full-screen mode. Click the Full-Screen button on
the VMware tool bar. 

Swap file usage---
In your system.ini file, in the [386enh] section, add the following line:
Conservative Swap File Usage = 1 

Disconnect CD-ROM, /dev/rtc---
Using the Devices menu, disconnect your CD-ROM drive if you do not need to use
it. If you are using a Linux host, also disconnect /dev/rtc. Disconnecting
these devices will reduce CPU usage.  Note: The time synchronization feature
in VMware Tools does not rely on /dev/rtc. 

Graphics acceleration---
Turn off graphics hardware acceleration. Right-click My Computer and choose
Properties from the pop-up menu. Click the Performance tab. Click the Graphics
button (under Advanced Settings), then move the Hardware Acceleration slider
to None. 

Visual effects---
Windows 98 has a number of visual effects, designed to be attractive, that
place unnecessary demands on the graphics emulation in VMware. Some users have
seen performance improvements when they turn off these special effects.  To
modify these settings, right-click on the desktop of your virtual machine,
then select Properties from the pop-up menu. Click the Effects tab and uncheck
the item labelled "Animate windows, menus, and lists." Also, if you have "Show
window contents while dragging" checked, try unchecking that item.  

==============================================================================

Follow these instructions to manually install the basic host-only network adapter on Windows 2000 (RC1 or later versions): 

Bring up the Control Panel (Start > Settings > Control Panel)
  
Bring up the Add/Remove Hardware wizard from the Control Panel
Note: You must have sufficient privileges to do this.
  
Click Next to continue past the Welcome screen.
  
Select Add/Troubleshoot a Device and click Next.
  
Wait while Windows searches for new Plug and Play devices, then select Add a New Device from the Choose a Hardware Device screen and click Next.
  
Select "No, I want to select the hardware from a list" and click Next.
  
Select Network Adapters from the list and click Next.
  
Select VMware, Inc. from the manufacturers list on the Select Network Adapter screen to get the list of available host-only network adapters, then select VMware Virtual Ethernet Adapter (basic host-only support for VMnet1) and click Next.
  
Click Next on the screen titled Start Hardware Installation
  
Click Yes when prompted that the Microsoft digital signature is not present for the software about to be installed.
  
Click Finish on the screen that indicates the adapter has been installed.  
Note: By default, Windows 2000 will set up each host-only adapter to obtain an IP address from a DHCP server. VMware will not work with this default setting. To configure VMware software for proper host-only operation, you must manually assign a static IP address to the VMnet DHCP server by completing the remaining steps below. 


Locate the file vmnetdhcp.conf; this is the configuration file used by the VMnet DHCP server. The file should be in the C:\WINNT\SYSTEM32 directory; otherwise, use the Windows 2000 Search facility to find it. 

View the contents of vmnetdhcp.conf using a program such as Notepad. 

The text file should have one entry for each VMnet Ethernet adapter that has been installed on the system. Look for the entry in the file that corresponds to the host-only adapter you just installed. The entry should be the last one in the file and look similar to:
          # added for VMnet1 at 08/24/99 16:26:44
          subnet 172.16.154.0 netmask 255.255.255.0 {
                  range 172.16.154.128 172.16.154.254;
                  option domain-name-servers 172.16.154.1;
                  option broadcast-address 172.16.154.255;
          }

The network address indicated to the right of the subnet designator in the last entry will most likely be different from the one indicated in the above example (172.16.154.0). For now, simply identify the subnet address within the last entry of your file; this address will be modified manually and assigned as the IP address of the host-only adapter in the next step. Do not modify the address within the configuration file. 


Manually assign the IP address and subnet mask for the host-only adapter: Open the Control Panel, double-click the Network and Dial-up Connections icon. 
Note: If you see multiple Local Area Connection icons, identify the one that corresponds to the VMware Virtual Ethernet Adapter (basic host-only support VMnet1). To do this, right-click on each icon, select Properties from the pop-up menu and look in the Connect Using field for the appropriate adapter name. 

From the Local Area Connection Properties dialog box for the VMware Virtual Ethernet Adapter, select Internet Protocol (TCP/IP) and click the Properties button. Change the default setting from "Obtain an IP address automatically" to "Use the following IP address." Enter the subnet address identified in the previous step in the IP address field, but replace the .0 portion of the address with a .1 (for example, if the subnet address in the entry is 172.16.154.0, enter the new derived address of 172.16.154.1 in the IP address field). Enter 255.255.255.0 in the Subnet mask field and leave the remaining fields blank. Click OK. Click OK again to close the Local Area Connection Properties panel. Click the Close button to close the Local Area Connection Status panel. 

Finally you will need to start or restart the VMnet DHCP service if you intend to have DHCP dynamically assign IP addresses to guest operating systems that use host-only networking. To start the service bring up the Services control panel via the Control Panel. 


Bring up the Control Panel (Start > Settings > Control Panel) 

Double-click the Administrative Tools item. 

Double-click the Services icon. 

Select the VMnet DHCP Server item in the list. 

Select the Start item from the Action pull-down menu. 
If the new adapter is the second or third host-only adapter to be added, then you will already have a VMnet DHCP Server service running and you will need to stop it first before starting it again. This is done by selecting a Stop action at Step 20 before the Start. 



-------

To run an xterm using Linux VM as the (X)server on parsifal:

VMWare DHCP Service on parsifal must be running for Samba.  parsifal is export
DISPLAY=172.16.187.1:0.0 as far as VMWare is concerned.

ZoneAlarm must have 172.16.187.129 added to Trusted (right click on the Alerts
& Logs blocked).

Start the Linux.vmx but don't need login (blank screensaver may be running).
Wait until VMWare has sucked up almost all the memory on parsifal.
Open red.xs
At this point, you should also have access to red via Explorer \\red
since Samba should be running (id: bheckel pw: rhrhrh)


To transfer files from parsifal to Linux VM (assumes Samba is running):
Browse to \\red\bheckel in Explorer then drop 'n' drag
or from Cygwin:
$ cp .bashrc //red/bheckel
I've been Committing Linux VMs when I'm done.

-------

Have to start VMWare DHCP Service on parsifal first!!
To transfer files to Win98 VM box from parsifal:
Enable FTP access:
$ login_toggle
$ net start inetd
ftp from VM box as bheckel:
$ ftp 172.16.187.1
...
$ net stop inetd
Stop VMWare DHCP Service.

I've been Discarding Win98 and W2K VMs when I'm done.


-------

Easiest:
From parsifal, access red via
$ telnet 172.16.187.129
