There is a directory on 'devshare' called 'Misc/Ghost'.

In that directory are two files: GHOSTIDE.DSK and DOSIMAGE.EXE.  From a
console window in that directory, use the DOSIMAGE program to make a bootable
Ghost disk, like so:

dosimage restore GHOSTIDE.DSK a:

You should be able to use this to boot your system at home and make/restore
partition backups to/from your CD-RW.  The user interface may not be
intuitively obvious at first, so to MAKE a backup, select PARTITION *TO*
IMAGE.  To RESTORE a backup, select PARTITION *FROM* IMAGE.

I use "fast" compression and get about 1 Gb per CD-R at anywhere from 90-180
Mb/sec.
