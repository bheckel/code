/* rexx */
/***********************************************************************
   Author: Bill Schoen  WSCHOEN at KGNVMC, schoen@vnet.ibm.com

   Title: sysout utility
          This uses SDSF in batch mode to obtain sysout for a job
   Syntax:  sysout [-copvw] [-t time] [jobid]
   Options:
     v    show job information for all your jobs or [jobid]
     w    wait for job completion
     o    print job output to stdout
     c    print job completion code to stdout
     p    purge job
     t <time>  set maximum wait time in seconds

   PROPERTY OF IBM
   COPYRIGHT IBM CORP. 1998

   2004-07-07 Bob Heckel sub 'bqh0.pgm.lib(include)' && sysout -v
***********************************************************************/

parse value 'v   w   t   o   c   p ' with,
             lcv lcw lct lco lcc lcp  .
ccuse=1
ccok=0
ccrunning=2
ccbadid=3
ccnonzero=4
argx=getopts('vwocp','t')
if argx=0 | argx<__argv.0 | __argv.0=1 then
   signal usage
if 0 then
   do
   usage:
   call sayerr 'Usage:  sysout [-covw] [-t time] [jobid]'
   exit ccuse
   end
if argx=__argv.0 then
   jobs=translate(__argv.argx)
 else
   jobs=''
if opt.lct='' then
   opt.lct=999999
sleep=10
sdsfmin=20
msg=''
sx=0
call time 'E'

again:

m.1='PREFIX *'
m.2='OWNER' userid()
m.3='ST'
m.4='ARR JOBID FIRST'
m.5='ARR Q A JOBID'
m.6='ARR MAX A Q'
if jobs<>'' then
   do
   m.7='FILTER JOBID =' jobs
   m.0=7
   end
 else
   m.0=6
sz=1000
call dosdsf
if m.0>sz then
   i=m.0-sz
 else
   i=1
do i=i to m.0
   if m.i='' then leave
   call say strip(substr(m.i,8),'t')
end
row=0
do i=0 to sx
   last.i=say.i
end
lx=sx
jx=0
do i=2 to lx
   parse var last.i jbnm jbi st 30 cc 40
   jx=jx+1
   j.jx.1=jbi
   j.jx.2=strip(cc)
   j.jx.3=strip(st)
   j.jx.4=i
   j.jx.5=left(jbnm,8)
end

if opt.lcv<>'' then
   do
   iot.lcv=''
   say 'Job id   Job name Max_RC    Queue'
   do i=1 to jx
      say j.i.1 j.i.5 left(j.i.2,9) j.i.3
   end
   end
if jobs='' then exit ccok

if opt.lcw<>'' then
   if j.1.3<>'PRINT' then
      do
      address syscall 'sleep' sleep
      parse value time('E') with s '.'
      if s>opt.lct then
         do
         call sayerr 'Job' jobs 'not on print queue'
         exit ccrunning
         end
      signal again
      end

if jx<>1 then
   do
   if jx<1 then
      call sayerr 'Job' jobs 'not found'
    else
      call sayerr 'Job' jobs 'not unique'
   exit ccbadid
   end

if opt.lcc<>'' then
   say j.1.2

if opt.lco<>'' then
   if j.1.1=jobs then call job j.1.5 j.1.1

if opt.lcp<>'' then
   do
   sz=sdsfmin
   m.1='ST'
   m.2='FILTER JOBID =' j.1.1
   m.3='SET CONFIRM OFF'
   m.4= 'F' j.1.5
   m.5='++P'
   m.0=5
   call dosdsf
   end

if opt.lcc<>'' & j.1.2<>'CC 0000' then
   exit ccnonzero
exit ccok

job:
   arg jn ji .
   sz=sdsfmin
   m.1='PREFIX *'
   m.2='OWNER' userid()
   m.3='ST'
   m.4='FILTER JOBID =' ji
   m.5= 'PRINT FILE SDSFDD'
   m.6= 'F' jn
   m.7='++XC'
   m.0=7
   if bpxwdyn('alloc fi(sdsfdd) new space(5,5) cyl',
              'msg(2)')<>0 then
      do
      call sayerr 'Temp data set allocation failed'
      address syscall 'sleep 6'
      return
      end
   call dosdsf
   address mvs 'execio * diskr sdsfdd (fini stem say.'
   call bpxwdyn 'free fi(sdsfdd)'
   sx=say.0
   if filesz>sx then
      call sayerr 'Warning: file truncated'
   do vi=1 to say.0
      say strip(say.vi,'T')
   end

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
   prm='++' || sdsflns',300'
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

sayerr: procedure expose esc_n
   parse arg msg
   msg=msg||esc_n
   address syscall 'write 2 msg'
   return

/**********************************************************************/
/*  Function: GETOPTS                                                 */
/*  Example:                                                          */
/*    parse value 'a   b   c   d' with,                               */
/*                 lca lcb lcc lcd .                                  */
/*    argx=getopts('ab','cd')                                         */
/*    if argx=0 then exit 1                                           */
/*    if opt.0=0 then                                                 */
/*       say 'No options were specified'                              */
/*     else                                                           */
/*       do                                                           */
/*       if opt.lca<>'' then say 'Option a was specified'             */
/*       if opt.lcb<>'' then say 'Option b was specified'             */
/*       if opt.lcc<>'' then say 'Option c was specified as' opt.lcc  */
/*       if opt.lcd<>'' then say 'Option d was specified as' opt.lcd  */
/*       end                                                          */
/*    if __argv.0>=argx then                                          */
/*       say 'Files were specified:'                                  */
/*     else                                                           */
/*       say 'Files were not specified'                               */
/*    do i=argx to __argv.0                                           */
/*       say __argv.i                                                 */
/*    end                                                             */
/**********************************************************************/
getopts: procedure expose opt. __argv. errmsg
   parse arg arg0,arg1
   argc=__argv.0
   opt.=''
   opt.0=0
   optn=0
   do i=2 to argc
      if substr(__argv.i,1,1)<>'-' then leave
      if __argv.i='-' then leave
         opt=substr(__argv.i,2)
      do j=1 to length(opt)
         op=substr(opt,j,1)
         if pos(op,arg0)>0 then
            do
            opt.op=1
            optn=optn+1
            end
         else
         if pos(op,arg1)>0 then
            do
            if substr(opt,j+1)<>'' then
               do
               opt.op=substr(opt,j+1)
               j=length(opt)
               end
             else
               do
               i=i+1
               if i>argc then
                  do
                  errmsg='Option' op 'requires an argument'
                  return 0
                  end
               opt.op=__argv.i
               end
            optn=optn+1
            end
         else
            do
            errmsg='Invalid option =' op
            return 0
            end
      end
   end
   opt.0=optn
   return i
