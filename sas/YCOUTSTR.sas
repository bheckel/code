options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: YCOUTSTR.sas
  *
  *  Summary: Determine all YC residents who died out of state.  Include vars
  *           based on dwj2 request.
  *
  *           Obsoleted by 2nd request 2005-04-13
  *
  *  Created: Mon 11 Apr 2005 10:53:00 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter NOreplace mlogic mprint sgen;

libname L '/u/dwj2/mvds/MOR/2003/';

%include 'BQH0.PGM.LIB(TABDELIM)';

data tmp (keep= decedent_age sex race1-race23
                dethnic1-dethnic5 dob_mo dob_dy dod_mo dod_dy 
                fstatres fcntyres fstatocc);
  set L.CANEW L.IDNEW L.MTNEW L.NYNEW L.YCNEW end=e;

  if (alias eq '1') or (void eq '1') then 
    delete;

  /* The 5 boroughs of NYC */
  if fcntyres in ('USNY005','USNY047','USNY061','USNY081','USNY085');

  if e then
    put '!!! ' _N_;
run;

proc print data=_LAST_(obs=max); run;

%Tabdelim(work.tmp, 'BQH0.TMPTRAN2');
