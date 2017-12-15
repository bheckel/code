options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: show_record.connect.sas
  *
  *  Summary: Examine a single specific certificate number's line directly 
  *           from a MF merged file.
  *
  *  Created: Wed 23 Apr 2003 09:39:18 (Bob Heckel)
  * Modified: Wed 18 Aug 2004 16:28:53 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source ls=max;

options ls=max;
filename IN1 'BF19.flX0409.NATMER';
***filename IN2 'BF19.OKX0310.NATMER';
***filename OUT 'BQH0.BYTES898';

data tmp (drop=certno);
  infile IN1;
  ***input @7 certno $CHAR6.  @1 block $CHAR400.;
  /* Connect can't handle $CHAR700. */
  input @3 certno $CHAR6.  @1 block $CHAR100.;
  if certno eq '017444';
run;

%macro bobh;
data tmp;
  infile IN1 obs=10;
  input @1 block $CHAR407.;
run;
data tmp2 (drop= certno);
  infile IN2;
  input @3 certno $CHAR6.  @1 block $CHAR898.;
  if certno eq '000868';
run;
 /* Won't work for the 700 byte files... */
***proc print data=tmp (obs= 25); run;
 /* ...so use this: */
data _NULL_;
  set tmp tmp2;
  file OUT;
  put block;
run;
%mend bobh;

proc print data=_LAST_; run;
