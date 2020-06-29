/* rexx */
/**********************************************************************/
/* Submit JCL                                                         */
/*                                                                    */
/* PROPERTY OF IBM                                                    */
/* COPYRIGHT IBM CORP. 1994, 1998                                     */
/*                                                                    */
/* Bill Schoen (SCHOEN at KGNVMC, schoen@vnet.ibm.com) 7/94, 12/98    */
/*   2004-07-07 Bob Heckel sub 'bqh0.pgm.lib(include)' && sysout -v   */
/**********************************************************************/
parse arg path
if path='?' then
   do
   say 'Usage: submit pathname'
   say "       submit 'data_set_name'"
   say "       submit 'data_set_name(member_name)'"
   return 2
   end
term=0
if path='' then
   do
   path='/dev/fd0'
   address syscall 'isatty 0'
   term = retval=1
   if term then
      say 'Enter JCL, /// ends input'
   end
address syscall 'open (path)' o_rdonly 000
if retval>=0 then
   dd=retval
 else
   if bpxwdyn("alloc fi(subrd) da("path") shr")<>0 then
      do
      say 'Cannot locate' path
      say 'as pathname or data set name'
      return 2
      end
    else
      dd='subrd'
s.0=0
if term then
   do i=1 by 1
      address mvs "execio 1 diskr" dd
      if rc<>0 then leave
      parse pull s.i
      if term & substr(s.i,1,3)='///' then leave
      s.0=i
   end
 else
   address mvs "execio * diskr" dd "(fini stem s."
if dd='subrd' then
   call bpxwdyn 'free dd(subrd)'
call bpxwdyn 'alloc dd(sub) sysout writer(intrdr) recfm(f)',
            'lrecl(80) msg(2)'
address mvs 'execio' s.0 'diskw sub (fini stem s.'
call bpxwdyn 'free dd(sub) msg(2)'
return 0

