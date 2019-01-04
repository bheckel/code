19-Jul-12
restart a downed XDMCP

$ /usr/dt/bin/dtconfig -e
done
desktop auto-start enabled.
$ /sbin/init.d/dtlogin.rc start 

----

2009-11-13

GSK Install
Set Display and Video from Multiple to Single pane Mode

Set Network and Communnication to XDMCP Broadcast
Configure...
Checkbox Host List File - edit to add rtpsh005.corpnet2.com etc

-----

Solaris CDE in a single window:

This line in an .xs file doesn't allow use of Exit button in CDE w/o an error:
DISPLAY=@d;export DISPLAY;/usr/dt/bin/Xsession


This is better:
From Xconfig
Communication
XDMCP-broadcast 
Configure
all checkboxes s/b checked except "Select First..."
edit xdmcp.txt
add 1 hostname per line e.g. rtpsh005 (don't need ip address)
OK til exit Xconfig
Start:Programs:Exceed:Exceed (XDMCP-broadcast)
If any Solaris box in xdmcp.txt is running, it'll be detected and show up on the list

