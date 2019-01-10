S/b symlinked as readme.jobtrac.txt


R341 (closest), R343 are current printers 2004-07-21

Return codes:
000 <COMP>  <---no error
004 <COMP>  <---SAS warning
008 <COMP>  <---SAS abend error


CDC JCL:
MSGCLASS=A  print
MSGCLASS=K  hold queue
SYSOUT=A    print
SYSOUT=0    hold queue


Delete a PDS (FTP may be faster):
=3.4
Find it
/
5


Allocate space for a large file (e.g. to be FTP'd, etc.)

=3.2
View a similar PDS (attributes will stay for next run as a starting point) as
a template by typing name 
e.g. 'bhb6.mormed.yr2001' (<---quotes!) on Data Set Name line
F3
==> A
Type new PDS name on Data Set Name line
Press enter
Volume Serial and ??? s/b blank
Press enter
"Data set allocated" message should appear at top left
Verify:
=3.4


Use BlueZone to transfer upload a big new (DOS ff) file (with automatic
allocation unlike BlueZone FTP):
=6
Click Transfer:Configure:TSO fill in name (w/o BQH0), local path, use ff=dos,
Text, CR/LF for SAS code uploads.
Click Transfer:Send (to MF)  e.g. should send this:
IND$FILE PUT pgm.lib(wvautops) ASCII CRLF
TODO how to transfer directly to DWJ2.... instead of BQH0 first?
TODO a 255 byte file ended up with a blank trailing line.  Better to FTP into
known wide enough files (e.g. BQH0.BYTES255, etc.)



TSO's brain damaged EDIT text line editor:
=========================================
Usually say 'text' when prompted "ENTER DATA SET TYPE-" or call file foo.TEXT
to avoid the prompt.

help KEYWORD
edit foo
(press enter to toggle modes INPUT (insert) and EDIT (command))
list [20 30]                <---print line range or all
l[ist] *                    <---print current line
l                           <---to list whole file
l *                         <---to list current line
down 5
up 2
bottom
top
i 66                        <---insert new line after line 65
change 'foostr' 'barstr'    <---on current line
c 10,50 'old'               <---you fill in 'new' if found
c 10,50 'old' 'okthn' all   <---change in one swoop
delete [20 30]              <---current line is del w/o parms
find 'foostr'               <---search from current line down (case sensitive)
                                shift-F5 to find again
f 'mystr'                   <---to find it
l *                         <---to see it
renum                       <---reset numbers
save
end [nosave]
end-                        <---to discard changes




ISPF Editor:
===========

To max down:
===> m<F8>      <---press 'm' then F8 key

To go up 3:
===> up 3

To go down 3:
===> down 3

To go to a specific line number:
===> l 42

To mark (does not save after exit):
.a   <---in the 000001 area
To jump to it:
===> l .a

To insert:
i

To insert lines before line 1 (if planning to edit by hand):
r
(delete the copied line)
i5
(or whatever)

To insert lines before line 1 (if planning to insert existing code):
b               <---on first line, press enter, see a pending message
===> copy jcl   <---will insert jcl code above first line or after an 'a'.  
                    Just 'copy' works by dumping you into a copy menu.  This
                    is the same as vi's :r command.

To copy replicate current line:
r

To delete:
  Single line:
d
  Multi line:
dd    
  ...
dd

To copy:
  Single line:
c
  Multi line:
cc    

To move:
  Single line:
m        <---on line to be moved
a or b   <---above or below where to move line to
  Multi line:
mm
a, b or o   <---where to move suspended line(s) to (above, below or on-top-of)

To uppercase a block:
ucc
...
ucc

To indent shift (caution: will wipe out data that goes too far left):
)     <---block uses ))
To outdent:
(     <---block uses ((
see  <3  >3  or  <<3  >>3  for safer alternative

To break (split) a line:
ts     <---then move cursor to desired char, press enter

To join (flow) lines:
tf     <---will automatically flow from current line TO THE NEXT BLANK LINE

To turn on freeform power typing wordwrap (can't have cursor on last line):
te

Find and change, search and replace, substitute lines:
c bf19.vscp2000.pgmlib bqh0.pgm.lib all

Type  cols  in a 000001 area to get a ruler above that line.

To do vi's  :f newfile  mark an area with mm and mm then
===> create mynewfil     <---only need to use mynewfil for creating PDS,
                             sequential will popup a panel


Fast immediate complete exit:
===> ;;l
Fast immediate useless partial exit from TSO:
===> ;;


To see your current editor settings (must be in ISPF editor):
===> profile


To avoid ISPF auto capitalization:
===> caps off


To turn on ISPF hexadecimal display:
===> hex on   <---then read it top to bottom e.g. A is C1 in EBCDIC hex
000001 AABB        
       CCCC44444444
       112200000000



To clear the ISPF screen of highlighting, messages, etc.:
===> reset


To save ISPF contents (auto saves when press enter):
===> save


Like :q!
===> cancel


To go back one panel:
===> end      <---or F3 if mapped


To go to the Primary Option Menu
===> return   <---or F4 if mapped


To undo last action:
===> undo


To turn on ruler:
===> col on      <---or col off
Better
===> col

To rename one file (using ncftp is easier):
=3.1
r
Member
New name

To rename one or more files:
===> =3.4
/ or r in front of each file to rename

To turn off all uppercasing:
===> caps off


To copy a file, assumes you don't want to do =2 on a new (or one that has been 
d9999) file then a ===> copy 'foo(bar)'
===> =3.3
Option
c
Type the from name e.g.
DWJ2
MOR1999
LIBRARY
<CR>
Type the to name e.g.
BQH0
MOR1999
LIBRARY
Confirm:
1.  use source's allocation


To move a file a.k.a. member e.g. 'MISC.BOB.JCL(BQH0JUNK)' 
('move' is not visible from panels):
===> =3.1
- Press enter after specifying Project, Group and Type (the PDS)
- Find your target to be moved, move cursor then press enter to display
  the member list
- Move cursor to the _ of your desired member
- Press enter
- Select Move (#7)
- Type 'bqh0.pgm.trash' to move it to that PDS.


JobTrac:
=======
* To add a new JobTrac job:
Assumes job has been =3.3 copied from e.g. hdg7.pgm.lib(runmor1) to JOBTRAC's
PDF e.g.  'misc.jobtrac.jcl(hdg7mor1)', using naming convention [userid]xxxx,
and containing the proper jobcard e.g. //HDG7FAGE ... (probably want to 
edit directly in misc.jobtrac.jcl).  

Jobcard e.g. //HDG7FAGE *must* be the same as the filename e.g.
MISC.JOBTRAC.JCL(HDG7FAGE) !!

1. Select Option 'J' on the ISPF main menu (it is not visible).
2. On the Jobtrac menu select GSO
3. Put an 's' next to the MISC member (or just rest cursor), press enter
4. Then
   IF YOUR JOB IS NOT NEW:
   Scroll to the bottom looking for your entries.  Put an 's' next to the
   member you want to select, press enter (F3 to exit one level) 

   IF YOUR JOB IS NEW:
   Max down
   Put an 'i' (insert) to the left of an existing member you want to insert
   new entry after,
   NOT AT THE top '===>' !!
   Type e.g. BQH0HG01 and make sure time says 2000 (8pm).     
   Process Period: :MTWTFSS or :..W....
   Press enter.  Press F3

   (quit to abandon if screw up)

5. When finished, enter 'ENDSAVE' to keep or 'CANCEL' to delete on the command
   line to exit.
6. F3   <---back to Jobtrac menu
7. F3   <---back to ISPF menu
8. Add this job to the user's list at ~/projects/jobtrac/


* To UPDATE an existing JobTrac job:
=3.3 copy
===> C
Enter names on the "To Other Partitioned or Sequential..." lines.
e.g. 'hdg7.graph3d.lib(rungenrl)' <CR>
     'misc.jobtrac.jcl(hdg7genr)'
Should say 'HDG7GENR replaced' on success.
May have to =2 and change the jobtrac version's jobcard to HDG7....

* To Purge a running JobTrac job:
=j
b=misc
p   <---in front of job to kill (may get error, ignore it, go back with a 's'
                                 to confirm the purge)


* To view run dates for completed jobs:
=j
out      <---sysout capture
hdg7     <---event/prefix

* Date pattern example:
PROCESS PERIOD ===> :M.W.F..


Use =j then j=hdg7 then type over time to reschedule

-------------------------end JobTrac-----------------------------------


To get more detail from the =d.h panel, place a '?'<CR> in the NP field.  Then
F11 to scroll right.



To release (print) a job to the mainframe printer queue:
From =d.h hold queue
NP                C       DEST
--                -       ----
O                 A       R328

From =d.o output queue (takes a few seconds to start)
NP                C       DEST
--                -       ----
                          R328


To find unusualy unprintable nonprinting control characters:
===> f p'.'

Find foo in reverse:
===> f foo prev


Common DS List pattern:
bf19.rix01*.mormer*

-----

To print directly from commandline:
dsprint 'bf01.dpj1.ispslib(smormer)' r328

-----

To download a =d.h file:
xdc        <---instead of c or s
Data set name  ===> 'BQH0.JUNK'
Member name ===>                        <---blank
<CR>       <---name it JUNK (JUNK2 if > 80 col wide) in bqh0, then ftp

-----

To delete a job from held output queue:
p       <---purge
c       <---same thing

//c     <---to do a range block delete series multiple of jobs
...
...
//

-----

To see only specific jobs in the =d.h queue:
===> filter jobname BQH0*03
===> filter off

-----

Settings for keymaps and scripts are in ~/misc (backup COPIES are in
~/code/misccode)
Keymappings:
*  =-=-> Erase EOF
Esc =-=-> Reset

-----

BlueZone Power Keys:
Use View:Properties:Power Keys
Pick the button number 
1  2  3  4  5  6  7
8  9  10  11  12  13  14
Fill in the boxes.  If it's a script, scroll down to Script::Play in the
Function listbox, fill in "Optional Filename" inputbox.

To map keyboard key:
Key Mappings in Functions: select Command Button 9 in Key Mappings: select New
Click the picture of the key you want.

-----

Determine what colors mean in SDSF:
===> set screen
Show commands in SDSF:
===> set action
===> set action off

-----

Search for a string:
=3.14
no quotes around search text required
Other Partitioned, Sequential or VSAM Data Set:
Data Set Name . . .
  'BHB6.ZQQ8.PGM.LIB(*)'

-----

Sort the default listing of =2
===> sort changed
===> sort size
Or if in =3.4 use
===> sort referred
===> sort created

-----

MSGCLASS=K (keep in held queue) indicates don't print JCL to printer
MSGCLASS=A (autoprint) indicates print all JCL to printer

-----

Goto specific line in SDSF:
===> locate 66

-----

Grant rw permission to all of my files to hdg7:
=6
tss permit(hdg7) dsn(bqh0) access(all)   <---Top Secret
PE[RMIT]  'dataset name'  ID(userid)  AC(READ)   <---RACF

Check it:
tss whohas dsn(bqh0)

-----

Maybe...
Allow SAS Log to autoprint by removing the WTR1=A
Or, better, change SYSOUT=A to 0
//STEP1N    EXEC SAS,TIME=60,OPTIONS='MSGCASE,MEMSIZE=0',WTR1=A
//SASLIST DD SYSOUT=A,OUTPUT=*.PRINT,
//           RECFM=FBA,LRECL=132,BLKSIZE=132
//SASLOG  DD DUMMY
//GEOG DD DISP=SHR,DSN=DWJ2.GEOG9501
//WORK DD SPACE=(CYL,(150,150),,,ROUND)
//SYSIN     DD *
Or, maybe change                         _
//&USR JOB (&ACCT,&BOX),&USERID,MSGCLASS=A,TIME=2,CLASS=D,
to                                       _
//&USR JOB (&ACCT,&BOX),&USERID,MSGCLASS=K,TIME=2,CLASS=D,
did somebody say festering pile of .... ?


-----

2004-12-06 see below for better approach-
OS390 Z03 Unix Services
http://publibz.boulder.ibm.com/cgi-bin/bookmgr_OS390/BOOKS/bpxza430/21.4.1.2?DT=20020710163526
Copy a sequential dataset to the Unix side (not sure the convert is
necessary):
=6
OPUT 'bqh0.junk' '/u/bqh0/temp1.txt' TEXT CONVERT(YES)
OPUT 'bf19.alx0301.mormer' '/u/bqh0/temp2.txt' TEXT CONVERT(YES)

Or (better) from within OMVS shell (fully qualified /u/bqh0 REQUIRED):
               case insensitive
$ tso "oput 'bf19.dex0301.mormer' '/u/bqh0/junkdex'"
             ^^^^^^^^^^^^^^^^^^^

Copy BQH0.JUNK to ~
$ tso -t "oput JUNK 'junkbob'"


-----

Exit the @main screen with a LOGOFF

-----

For SCL/AF see readme.sas.txt

-----

Compress a PDS (only works on partitioned data sets):
When you look at it in TSO, DSLIST (3.4) you can see the percent used and the
number of extents (XT):

Command - Enter "/" to select action                  Tracks %Used XT  Device  
-------------------------------------------------------------------------------
         BQH0.SAS.INTRNET.PDS                             15   33   2  3390    

When the XT column reaches 16 and the %Used is 100, you will get errors. You
can compress it from the 3.4 screen by entering a / in the Command column and
then enter the number 12.


-----

Create a SAS dataset library (or format library) directory:
 .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .

                              Data Set Information                              
 Command ===>                                                                   
                                                                    More:
+ 
 Data Set Name . . . . : BQH0.SASLIB                                            
                                                                                
 General Data                           Current Allocation                      
  Management class . . : FILES           Allocated cylinders : 6                
  Storage class  . . . : BASE            Allocated extents . : 1                
   Volume serial . . . : PRM037 +                                               
   Device type . . . . : 3390                                                   
  Data class . . . . . : SAS6           Current Utilization                     
   Organization  . . . : PS              Used cylinders  . . : 0                
   Record format . . . : FS              Used extents  . . . : 0                
   Record length . . . : 27648                                                  
   Block size  . . . . : 27648                                                  
   1st extent cylinders: 6                                                      
   Secondary cylinders : 2                                                      
   Data set name type  :                 SMS Compressible  . : NO               
                                                                                
   Creation date . . . : 2003/03/24      Referenced date . . : ***None***       
   Expiration date . . : ***None***                                             
  F1=Help      F2=Split     F3=Exit      F7=Backward  F8=Forward   F9=Swap      
 F12=Cancel                                                                     



Tracks
If data set is < 800KB, specify TRKS.
Cylinders
If data set is > 800KB, specify CYLS.

There are 28KB per block.
There are ? blocks per track.
There are usually 56KB per track.
There are usually 15 tracks per cylinder.
Therefore 850KB per cylinder.


BLKSIZE must be a multiple of LRECL


//* OUTPUT A DIRECTORY LISTING OF BF19 FILE NAMES TO A DATASET:                 
//STEP1     EXEC PGM=IDCAMS                                                  
//SYSPRINT  DD DSN=BQH0.BF19.DATASET,DISP=OLD                                
//SYSIN     DD *                                                             
 LISTC LEVEL(BF19)



~*~*~*~*~*~*~*~*~*~*
TSO commands (can be performed prior to typing @main or at =6, use PA1, not
F1, to abort the scroll):
============

help help            <---meta-help
h                    <---available commands
h foocmd             <---specific help

cancel BQH0SMOX(JOB14357) purge  <---kill stuck printing job (can't do in =d.o)

listc[at]                    <---like an ls from pwd BQH0
listds WTCLIST.TXT           <---like a weak ls -l
listds pgm.lib m[embers]     <---like ls BQH0.PGM.LIB shows PDS'
NOT WORKING:
listc entries('bqh0.pgm.*') all
listc level('bqh0.pgm')

Unix's cat:
list junk                    <---work the same syntactically
list pgm.lib(junk)           <--- "    "    "       "

ren[ame] MYTRASH NEWTRASH
ren[ame] PGM.LIB(DELME) PGM.LIB(DELETEME)

del NEWTRASH              <---delete top-level no warning!
del PGM.LIB(BOBTRASH)     <---delete PDS member no warning! Note no BQH0!
del (foo bar baz)         <---multiple

!!! do not use MVS' COPY command !!!
smc fds(PGM.LIB(DELME)) tds(PGM.LIB(DELME2))    <---copy (no alloc required)
smc fds(TEST3) tds(PGM.LIB(TEST4))              <---copy (no alloc required)
smc fds('BQH0.PGM.TRASH(JUNK)') tds('BQH0.PGM.TRASH(JUNKTXT)') <---copy (no alloc required)
alloc dsn(TEST4) new catalog unit(sysda) space(5,20) recfm(f,b) lrecl(80)
Easier if you have an existing sample to model:
alloc dataset('DWJ2.LATEBF19.INTRN') like('DWJ2.LATEBF19.CLOSED')

smc fds(TEST3) tds(TEST4)                       <---copy (alloc required 1st!)

alloc dsn(test3) new catalog unit(sysda) space(5,20) recfm(f,b) lrecl(80)
Creates:
                              Data Set Information                              
 Command ===>                                                                   
                                                                    More:     + 
 Data Set Name . . . . : BQH0.TEST3                                             
                                                                                
 General Data                           Current Allocation                      
  Management class . . : FILEL           Allocated kilobytes : 41,007           
  Storage class  . . . : BASE            Allocated extents . : 1                
   Volume serial . . . : LSMS56                                                 
   Device type . . . . : 3390                                                   
  Data class . . . . . : DEFAULT        Current Utilization                     
   Organization  . . . : PS              Used kilobytes  . . : 0                
   Record format . . . : FB              Used extents  . . . : 0                
   Record length . . . : 80                                                     
   Block size  . . . . : 27920                                                  
   1st extent kilobytes: 41007                                                  
   Secondary kilobytes : 163840                                                 
   Data set name type  :                 SMS Compressible  . : NO               
                                                                                
   Creation date . . . : 2003/08/15      Referenced date . . : ***None***       
   Expiration date . . : ***None***                                             
                                                                                
  F1=Help      F2=Split     F3=Exit      F7=Backward  F8=Forward   F9=Swap      
 F12=Cancel                                                                     
~*~*~*~*~*~*~*~*~*~*



-----

To run a job from =6
sub 'bqh0.pgm.lib(foopgm)'


-----

Who has a dataset open locked in use read only?
=3.4
e
F1
F1


-----

To cd in FTP on the mainframe side:
cd "//'dwj2.vscp.pgmlib'"
To the HFS side
cd /


-----

MAKEP alternative to make files permanent on CDC mainframe (avoid migration):
Can't be set via =3.2 allocation panes (e.g. FILES is default)!
AM2 2 yrs from last reference
AM3
AM5
AM10
AM15
AMP permanent
LC to view MANAGEMENTCLASS attribs


-----

Toggle bottom of screen help
PFSHOW [ON|OFF]

Change attributes colors, etc.
CUAATTR


-----

HFS

 The following examples use the cp command. The same syntax applies with mv.

 1. To specify -P params for a non-existing sequential target:

      # I can't get this to work, just leave out the -P "..." stuff and it
      # works cp file "//'turbo.gammalib'"
      cp -P "RECFM=U,space=(500,100)"file "//'turbo.gammalib'"

 2. To copy file f1 to a fully qualified sequential data set 
    'turbo.gammalib' and treat it as a binary:

      cp -F bin f1 "//'turbo.gammalib'"

 3. To copy all members from a fully qualified PDS 'turbo.gammalib' to an 
    existing UNIX directory dir:

      cp "//'turbo.gammalib'" dir

 4. To drop .c suffixes before copying all files in UNIX directory dir to an 
    existing PDS 'turbo.gammalib':

      cp -S d=.c dir/* "//'turbo.gammalib'"

 5. To copy a single file from HFS to MVS
     
       cp tryaccess.sas "//'bqh0.pgm.trash(tryacc)'"

