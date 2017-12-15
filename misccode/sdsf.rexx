/* rexx */
/***********************************************************************
   Author: Bill Schoen  WSCHOEN at KGNVMC, schoen@vnet.ibm.com

   Title: sdsf utility
          This uses SDSF in batch mode to implement a similar dialog

   PROPERTY OF IBM
   COPYRIGHT IBM CORP. 1998

   Adapted: Wed Apr 20 17:26:17 2005 (Bob Heckel)
***********************************************************************/
parse value ''  with term lines cols
do i=1 to __environment.0
   if substr(__environment.i,1,5)='PATH=' then
      path=substr(__environment.i,6)
   if substr(__environment.i,1,5)='TERM=' then
      term=substr(__environment.i,6)
   if substr(__environment.i,1,8)='COLUMNS=' then
      cols=substr(__environment.i,9)
   if substr(__environment.i,1,6)='LINES=' then
      lines=substr(__environment.i,7)
   if substr(__environment.i,1,13)='_BPX_SHAREAS=' then
      shras=substr(__environment.i,14)
end

pref='!'
pager='less'
msg='Enter command:'
sdsfmin=20  /* min screen size sdsf allows */

msg=''
parse arg input
do forever
   call clear
   say msg
   say 'Enter command:'
   say '   da        - Display active users in the sysplex'
   say '   i         - Display jobs in the JES2 input queue'
   say '   o         - Display jobs in the JES2 output queue'
   say '   h         - Display jobs in the JES2 held output queue'
   say '   st        - Display status of jobs in the JES2 queues'
   say '   pref[ix]  - Set SDSF prefix'
   say '   End or x  - Exit (from any screen)'
   say '   ? or HELP - Help'
   msg=''
   if input<>'' then
      do
      cmdline=input
      say cmdline
      input=''
      end
    else
      parse pull cmdline
   if cmdline='' then iterate
   parse upper var cmdline cmd rest
   if pos(substr(cmd,1,1),'?XDIOHSPE')=0 then
      do
      msg='Invalid command'
      iterate
      end
   cmd1=substr(cmd,1,1)
   select
     when cmd='?' | cmd='HELP' then
       do
       call help
       iterate
       end
     when cmd1='I' then nop
     when cmd1='O' then nop
     when cmd1='H' then nop
      
     when cmd1='E' then
       do
       if abbrev('END',cmd,1) then
          exit 0
       msg='Invalid command'
       iterate
       end
     when cmd1='P' then
       if abbrev('PREFIX',cmd,4) then
          do
          parse var rest pref .
          iterate
          end
       else
          do
          msg='Invalid command'
          iterate
          end
     when cmd1='D' then
       cmd='DA'
     when cmd1='S' then
       cmd='ST'
     /* can't get this to work as 'q' but probably better as 'x' bobh */
     when cmd='X' then 
       exit 0
     otherwise
       msg='Invalid command'
       iterate
   end

   sx=0
   do forever
      if sx=0 then
         do
         m.1=cmd
         viewcmd=cmd
         if pref<>'!' then
            do
            m.2='PREFIX' pref
            m.3='OWNER *'
            m.0=3
            end
          else
            m.0=1
         sz=1000      /* capture up to 1000 lines */
         call dosdsf
         if m.0>sz then
            i=m.0-sz
          else
            i=1
         do i=i to m.0
            if m.i='' then leave
            call say strip(substr(m.i,8),'t')
         end
         say.1=translate(say.1,' ','06'x)
         do i=1 to sx
            last.i=say.i
         end
         last.0=sx
         end
      if cmd1='H' | cmd1='O' then
         row=output(1,2,9,1)
       else
         row=output(0,2,9,1)
      if row=-1 then     /* blank line - refresh */
         do
         sx=0
         iterate
         end
      if row=0 then      /* end command          */
         leave
          
      /* number selected */
       
      parse var say.row jb ji . . . . . sz .
      call clear
      call job jb ji,sz,row-2,strip(say.row)
      cmd=viewcmd
      sx=last.0
      do i=1 to sx
         say.i=last.i
      end
      cmd=viewcmd
      iterate
   end
end
 
job:
 
   arg jn ji .,sz .,jobrow,line
   sx=0
   filesz=space(translate(sz,' ',','),0)
   jbi.=''
   if cmd1='H' then
      hdmap='Jobname,1,8  Lines,62,9      Jobid,10,8    Status,93,16',
            'Owner,19,8   PrnMode,137,6   Class,33,1    Created,189,10',
            'Forms,79,8   Max_RC,257,10   Dest,41,17'
   else /* cmd1='O' */
      hdmap='Jobname,1,8  Lines,65,9      Jobid,10,8    Status,112,16',
            'Owner,19,8   PrnMode,204,6   Class,33,1    Created,219,10',
            'Forms,35,8   Max_RC,272,10   Dest,44,17'
   do jbi=1 by 1 while hdmap<>''
      parse var hdmap tag ',' hdo ',' hdl hdmap
      jbi.jbi= left(strip(tag),8) '=' strip(substr(line,hdo,hdl))
   end
   jbi.0=jbi-1
   do forever
      do ji=1 to jbi.0
         jj=ji+1
         say left(jbi.ji,39) jbi.jj
         ji=ji+1
      end
      say
      say 'Commands: V=View  SAVE  PURGE  HOLD  RELEASE ',
          'P=set Pager('pager')  Q=End'
      parse pull cmdline
      parse upper var cmdline cmd .
      select
        when cmd='X' then
          exit 0
           
        when cmd='?' then
          do
          call help
          end

        when cmd='V' then
          call view

        when cmd='SAVE' then
          do
          parse var cmdline . fn .
          if fn='' then
             say 'Missing file name'
           else
             call view
          end

        when cmd='PURGE' then
          do
          call purge 'P'
          last.0=0
          return
          end

        when cmd='HOLD' then
          do
          call purge 'H'
          last.0=0
          return
          end

        when cmd='RELEASE' then
          do
          if cmd1='H' then
             call purge 'O'
           else
             call purge 'A'
          last.0=0
          return
          end

        when cmd='P' then
          do
          parse var cmdline . pager
          end

        when cmd='Q' then 
          return
           
        otherwise
          nop
      end
      say
      say
   end
   return

purge:
   arg purgecmd .
   sz=20
   m.1=viewcmd
   m.2='DOWN' jobrow
   m.3='SET CONFIRM OFF'
   m.4= 'F' jn
   m.5='++'purgecmd
   m.0=5
   call dosdsf
   return

view:
   if sx=0 then
      do
      sz=sdsfmin
      m.1=viewcmd
      m.2='DOWN' jobrow
      m.3= 'PRINT FILE SDSFDD'
      m.4= 'F' jn
      m.5='++XC'
      m.0=5
      if bpxwdyn('alloc fi(sdsfdd) new space(50,50) cyl',
                 'msg(2)')<>0 then
         do
         say 'Temp data set allocation failed'
         address syscall 'sleep 6'
         return
         end
      call dosdsf
      address mvs 'execio * diskr sdsfdd (fini stem say.'
      call bpxwdyn 'free fi(sdsfdd)'
      sx=say.0
      if filesz>sx then
         do
         /* TODO wtf ? */
         say 'Warning: file truncated'
         address syscall 'sleep 3'
         end
      end
   if cmd='SAVE' then
      do
      address syscall 'writefile' fn 777 'say.'
      if retval=-1 then
         say 'Error saving file:' errno errnojr
       else
         say 'Saved to' fn
      end
    else
      if pager='' then
         call output 0,1,0,0
       else
         call pg
   return
    

dosdsf:
   if sdsfmin>sz+3 then
      sdsflns=sdsfmin
    else
      sdsflns=sz+3
   if m.0=0 then return
   call bpxwdyn 'alloc fi(isfout) space(1,3) cyl new msg(2)'
   call bpxwdyn 'alloc fi(isfin) space(1,1) tracks new msg(2)'
   address mvs 'execio' m.0 'diskw isfin (fini stem m.'
   prm='++' || sdsflns',300'     /* cols */
   address linkmvs 'sdsf prm'
   m.0=0
   address mvs 'execio * diskr isfout (fini stem m.'
   call bpxwdyn 'free fi(isfout)'
   call bpxwdyn 'free fi(isfin)'
   return 0

say:
   if sx=0 then say.=''
   sx=sx+1
   say.sx=arg(1)
   return

output:
   arg nsel,iln,lfixed,tfixed
   cln=iln
   ccol=1
   brdr=3
   if nsel then
      lbrdr=4
    else
      lbrdr=0
   selnm=''
   if nsel then
      nselm='Enter=refresh or select number'
    else
      nselm=''
   do forever
      call clear
      if tfixed then
         say copies(' ',lbrdr) || substr(say.1,1,lfixed) ||,
             substr(say.1,ccol+lfixed,cols-lfixed-lbrdr)
      if cln>sx then cln=sx
      do oi=cln to cln+lines-brdr
         if nsel then 
            selnm=right(oi-1,lbrdr-1)' '
         if oi>sx then
            say
          else
            say selnm || substr(say.oi,1,lfixed) ||,
                substr(say.oi,ccol+lfixed,cols-lfixed-lbrdr)
      end
      say 'L=Left R=Right U=Up D=Down Q=End F=Find' nselm
      pgline='Lines' cln-tfixed 'to',
             min(sx-tfixed,cln+lines-brdr-tfixed) 'of' sx-tfixed '    '
      address syscall 'write 1 pgline'
      pull pgcmdfull
      pgarg=strip(substr(pgcmdfull,2))
      pgcmd=substr(pgcmdfull,1,1)
      select
        when pgcmdfull='X' then
          exit 0
        when pgcmd='?' then
          do
          call help
          iterate
          end
        when pgcmd='R' then
          ccol=ccol+cols-lfixed-lbrdr
        when pgcmd='L' then
          do
          ccol=ccol-cols+lfixed+lbrdr
          if ccol<1 then ccol=1
          end
        when pgcmd='U' then
          do
          if datatype(pgarg,'W')=0 then
             if pgarg='M' then
                pgarg=cln
              else
                pgarg=lines-brdr
          cln=cln-pgarg
          if cln<=tfixed then cln=tfixed+1
          end
        when pgcmd='D' then
          do
          if datatype(pgarg,'W')=0 then
             if pgarg='M' then
                pgarg=sx-lines+brdr-cln
              else
                pgarg=lines-brdr
          cln=cln+pgarg
          if cln<=tfixed then cln=tfixed+1
          end
        when pgcmd='Q' then
          leave
        when pgcmd='F' then
          if datatype(pgarg,'W') & pgarg>0 then
             cln=pgarg+iln-1
           else
             do
             if pgarg='' then
                pgarg=lastfind
              else
                lastfind=translate(strip(pgarg))
             do pgi=cln+1 to sx
                if pos(lastfind,translate(say.pgi))=0 then
                   iterate
                cln=pgi
                leave
             end
             end
        otherwise
          if nsel & datatype(pgcmdfull,'W') then
             do
             pgcmd=pgcmdfull+tfixed
             if pgcmd>1 & pgcmd<=sx then
                return pgcmd
             end
           else
           if nsel & pgcmdfull='' then
              return -1
      end
   end
   return 0
    
pg:
   address syscall
   'pipe pipe.'
   fd.0=pipe.1
   fd.1=1
   fd.2=2
   pgpg=pager
   do pgi=1 by 1 while pgpg<>''
      parse var pgpg p.pgi pgpg
   end
   p.0=pgi-1
   ev.1='_BPX_SHAREAS=YES'
   ev.2='TERM='term
   ev.3='LINES='lines
   ev.4='COLUMNS='cols
   ev.5='PATH='path
   ev.0=5
   'spawnp' p.1 '3 fd. p. ev.'
   if retval=-1 then
      do
      say 'Error running' p.1 ':' errno errnojr
      'close' pipe.1
      'close' pipe.2
      return
      end
   'close' pipe.1
   'sigaction' sigpipe sig_ign 0 'ph pf'
   address mvs 'execio' sx 'diskw' pipe.2 '(fini stem say.'
   do until retval=-1
      'wait st.'
   end
   sx=0
   return

clear:
   call terminfo 1,0
   address syscall
   if term='dumb' then
      do
      'write 1 esc_f'
      return
      end
   p.1='/bin/tput'
   p.2='clear'
   p.0=2
   'spawn' p.1 0 'fd. p. __environment.'
   do until retval=-1
      'wait st.'
   end
   return
    
terminfo: procedure expose lines cols
   parse arg ladj,cadj
   bf='0000000000000000'x
   address syscall 'ioctl 1 1074307944 bf'
   lines=c2d(substr(bf,1,2))
   cols=c2d(substr(bf,3,2))
   if lines=0 | cols=0 then
      do
      lines=24
      cols=80
      end
   lines=lines-ladj
   cols=cols-cadj
   return
 
help: procedure expose lines cols path term __environment. esc_f sigpipe sig_ign
   sx=0
   call clear
   do i=1 to sourceline(),
        while sourceline(i)<>'<help>'
   end
   do i=i+1 to sourceline(),
        while sourceline(i)<>'<end>'
      call say sourceline(i)
   end
   pager='pg -p (Page...%d)'
   call pg
   return
    
/*
<help>
Help for sdsf utility
---------------------
 
This utility uses SDSF in batch mode to provide similar types of function.

Syntax:
======
        sdsf
    or  sdsf <initial command>
     
 
Notation:
========
 
  Commands may be mixed case.  Uppercased letters in the command syntax
  indicate the minimum abbreviation.
   
  Arguments within <> are to be entered without the < and >.
   
  
The following commands are available anywhere:
=============================================
 
  ?    lists this help file using the pg utility
  Q    end current display and return to previous display
  X    exits the utility immediately
   
    
         
Prefix command:
==============
          
  syntax:   PREFix            Sets the SDSF prefix to null
       or   PREFix <prefix>   Sets the SDSF prefix to <prefix>
          
  Use this to change the filtering of data in the various displays.
  The prefix is set to null by default.  When null, the SDSF PREFIX
  command is not generated.
          
  SDSF batch mode may have different authorization characteristics under
  batch mode than when run under TSO in your installation.  This can
  prevent the PREFIX command from working as you might expect.
    
          
Selecting SDSF commands from the initial panel:
==============================================

  The commands DA, H, I, O, and ST may be followed by one or more class
  identifiers.  For example, OA will send the command OA to SDSF which
  filters on class A.
          
           
DA command
==========
 
  Displays active jobs.  The data is presented in scrollable tabular
  format.  See "Internal pager" below for navigation help.  Jobs cannot
  be selected from this list to perform additional operations.
   
    
ST command
==========
 
  Displays job status.  The data is presented in scrollable tabular
  format.  See "Internal pager" below for navigation help.  Jobs cannot
  be selected from this list to perform additional operations.
   
    
I command
=========
 
  Displays input queue.  The data is presented in scrollable tabular
  format.  See "Internal pager" below for navigation help.  Jobs cannot
  be selected from this list to perform additional operations.
   
    
O command
=========
 
  Displays output queue.  The data is presented in scrollable tabular
  format.  See "Internal pager" below for navigation help.
   
  Enter a blank line to refresh the display.
  Enter a number to select the corresponding job.
       
  After a job is selected you can set an external pager and view the
  sysout file.  If no external pager is selected, the internal pager
  is used.  Valid commands for a selected job are:

      V        view the sysout data set using the specified pager
      P        set a pager.  Follow P with the pager command line.
               If the command line is blank the internal pager is used.
               If an external pager is used, sdsf will pipe data into
               the pager's stdin file.
      SAVE     save the sysout data set.  Follow SAVE with the file name.
      RELEASE  release the job for output.  After the release command
               is entered, sdsf returns to a refreshed job list.
      PURGE    purge the job from the system.  After the purge command 
               is entered, sdsf returns to a refreshed job list.
      HOLD     hold the job.  After the hold command is entered, sdsf 
               returns to a refreshed job list.
           
            
H command
=========
 
  Displays held output queue.  The data is presented in scrollable tabular
  format.  See "Internal pager" below for navigation help.
   
  Enter a blank line to refresh the display.
  Enter a number to select the corresponding job.
       
  After a job is selected you can set an external pager and view the
  sysout file.  If no external pager is selected, the internal pager
  is used.  Valid commands for a selected job are:

      V        view the sysout data set using the specified pager
      P        set a pager.  Follow P with the pager command line.
               If the command line is blank the internal pager is used.
               If an external pager is used, sdsf will pipe data into
               the pager's stdin file.
      SAVE     save the sysout data set.  Follow SAVE with the file name.
      RELEASE  release the job for output.  After the release command
               is entered, sdsf returns to a refreshed job list.
      PURGE    purge the job from the system.  After the purge command 
               is entered, sdsf returns to a refreshed job list.
      HOLD     hold the job.  After the hold command is entered, sdsf 
               returns to a refreshed job list.
           
            
Internal pager
==============
            
  The internal pager is used for the tabular displays and, if no other
  pager is selected, to view sysout files.  The internal pager accepts
  the following commands:
   
    U      scroll up.  An amount can be specified as a number or M for
           Max.  Spaces are not needed between U and the amount.
             
    D      scroll down.  An amount can be specified as a number or M for
           Max.  Spaces are not needed between D and the amount.
             
    L      scroll left screen width.
             
    R      scroll right screen width.
             
    F      find string or locate line.  Find has three forms:
 
            F                 repeat previous find
            F <number>        position to line <number>
            F <string>        position to next line containing <string>
                                search is not case sensitive
        
<end>
*/
