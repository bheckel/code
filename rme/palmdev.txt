Docs:
/c/PalmDev/Palm\ Documentation/Palm\ OS\ 5\ SDK\ \(68K\)\ Docs/
Demos:
/home/bheckel/code/misccode/palm


Installing prc tools for Palm development under Cygwin:
======================================================
/*{{{*/
See $HOME/pilotpgms/devinstall for installers, zips and tarballs.

Install PalmSource's SDK (e.g.Palm_OS_5_SDK__68K__R3.exe) to c:\PalmDev
(overriding their default name) via Win32 installer.  Ignore Metrowerks
errors.

(2005-06-06 not sure how to install Palm_OS_68K_SDK_Fall_2004_PRC-Tools.zip)

$ mount -tf "c:\PalmDev\Palm OS Support" /PalmDev  <---where the libs are

# See ~/pilotpgms/devinstall/cygwin.html
# Can be installed via cygwin's setup.exe if use this mirror:
# http://prc-tools.sourceforge.net/install otherwise do this:
$ cyginstall prc-tools-2.3-cygwin.tar.bz2  <---http://prc-tools.sourceforge.net
                                               gives you m68k-palmos-gcc

# Better to use http://prc-tools.sourceforge.net/ for docs - this is optional:
$ cyginstall prc-tools-htmldocs-2.3-cygwin.tar.bz2

# Neither prc-tools nor GCC has any built-in knowledge of what Palm OS SDKs
# and other development material you happen to have installed. You can use
# palmdev-prep to provide such knowledge: after running it, m68k-palmos-gcc
# will be able to find Palm OS-related headers and libraries automatically,
# i.e., without needing any extra -I and -L options, and will have a new
# -palmosN option for selecting which SDK to use.
#
# You should rerun palmdev-prep whenever you upgrade prc-tools or install or
# remove a Palm OS SDK or other development material. You should also rerun it
# using its -d SDK option when you want to change which SDK is to be used by
# default, i.e., in the absence of any -palmosN options.
$ palmdev-prep.exe  <---hook up libs, part of prc-tools-2.3-cygwin.tar.bz2

# pilrc is also available as unix sources you'd do this if the cygwin bz2
# didn't exist:
 $ tar xvfz pilrc_src.tgz  <---from http://www.ardiri.com, compiles Cygwin OOTB
 Compile per pilrc-3.0/README.txt --  
 $ unix/configure && make && make install
# But it does so just do this:
$ cyginstall pilrc-3.2-cygwin.tar.bz2

2005-06-06 OBSOLETE ----------------------------
x Unzip emulator-win.zip to new dir /c/PalmDev/emulator/ (get the debug version)
x
x Unzip ROMs enUS_release_41roms.zip to /c/PalmDev/emulator/ (get the debug
x version)
x
x Select emulator platform41_3c_enUS.rom for the m130, I think it's closest
-------------------------------------------------

Unzip palmOne_SDK_4_2_Treo_650_Simulator_CDMA_Sprint_Update_EN_Debug.zip into
C:\PalmDev

Chose c:/PalmDev/Palm_OS_54_Simulator/release/Simulator_Full_enUS_Release.rom
Run:
$ pose -autoload:hello.prc&
or
$ pose -autorunandquit:hello/hello.prc&

/*}}}*/


Compiling/Running:
=================
/*{{{*/
See $HOME/code/c/helloworld.palm.c

Usually want this in your Makefile:
CC = m68k-palmos-gcc
CFLAGS = -O2 -Wall

usually need .c .h .rcp .bmp Makefile in pwd
$ make    <---builds the .prc executable

2005-06-06 OBSOLETE ----------------------------
 $ pose&
 then install .prc into it via right click or, better, to autoinstall the app
 on pose:
 $ cd /c/PalmDev/emulator/autoload  <---may have to mkdir autoload
 $ ln -s ~/projects/shoplist/list.prc .
 $ pose&
 # This does not work:
 ###$ pose -load_apps hello.prc&   <---can list more than one .prc
 ... 
-------------------------------------------------

Run PalmSim_54_rel.exe (formerly pose and still symlinked that way)

/*}}}*/


Debugging (from UsingPalmOSEmulator.pdf):
========================================
Build (& link?) with -g in the Makefile/*{{{*/

$ m68k-palmos-gdb myapp        <---NOT myapp.rcp
or 
$ ddd --debugger 'm68k-palmos-gdb myapp' --gdb
then to get port 2000
$ pose -autoload:hello.prc&
then
(gdb) target palmos          
Ignore the Ctr-C stuff
Start the app in Pose (will be white screen until you step far enough into the
event loop)

This works will from inside Vim:
:!make && pose

/*}}}*/




  /* vim: set foldmethod=marker: */ 
