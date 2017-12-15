options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: round.sas
  *
  *  Summary: Fractional floating point comparisons.
  *
  *  Created: Mon 26 Nov 2012 09:13:17 (Bob Heckel)
  * Modified: Mon 12 Jun 2017 11:28:17 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

 /* This is only vaguely related to the floating point stuff below: */
 /* Forces 1.2346E18 when not specifying informat:  input x 19. */
data t;
  input x;
  cards;
1
123456
1234567890123456789
  ;
run;
title 'no fmt'; proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

 /* SAS can't store 1234567890123456789, too large */
data t;
  input x 19.;
  cards;
1
123456
1234567890123456789
  ;
run;
title '19.'; proc print data=_LAST_(obs=10) width=minimum heading=H; format x 19.; run;title;
title 'COMMA25.'; proc print data=_LAST_(obs=10) width=minimum heading=H; format x COMMA25.; run;title;
title 'BEST32.'; proc print data=_LAST_(obs=10) width=minimum heading=H; format x BEST32.; run;title;
proc contents;run;



endsas;
data _null_; x=1/3; if x eq .3333 then put 'fraction'; run;  /* fail */
data _null_; x=1/3; if round(x, .0001) eq .3333 then put 'fraction'; run;


 /* Force very small numbers into zeros */
data _null_;
  r=round(0.0005, .01);
  if ( r eq 0 ) then
    put r=;
run;


data x ;
  x1 = .3 ;
  x2 = 3 * .1 ;
  xcomp = x1 - x2 ;
  x1hex = put( x1, hex16. ) ;
  x2hex = put( x2, hex16. ) ;
  r1 = round( x1, .00000001 ) ;
  r2 = round( x2, .00000001 ) ;
  rcomp = r1 - r2 ;
run ;
