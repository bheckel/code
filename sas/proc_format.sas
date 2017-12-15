options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_format.sas
  *
  *  Summary: Custom formats.  Good for coded raw data or hash-like
  *           datastructures.
  *
  *           Put this in the code that later uses your precompiled
  *           permanent formats:
  *           options FMTSEARCH=(MYFLIB WORK LIBRARY);
  *
  *           Cannot use a digit as the final char in a format name!
  *
  *           Use FMTLIB to view an existing format.
  *
  *           old name(s) = new name
  *
  *           Warning: the libref LIBRARY is a keyword that says 'search for
  *           formats here'
  *
  *  Adapted: Thu 11 Apr 2002 14:41:23 (Bob Heckel -- Little SAS Book sect 2.4)
  * Modified: Fri 04 Jun 2010 15:00:50 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data tmp;
  /*** infile 'c:\MyRawData\Cars.dat'; ***/
  input Age  Sex  Income  Color $  Cash $  Small  MorF $;
  cards;
19 1 14000 Y -01 0.5 1
45 1 65000 G 02 2.5 1
72 2 35000 B 23 1.0 1
31 1 44000 Y 04 0.8 2
20.5 1 44000 Y 05 0.8 2
58 9 83000 W 0 0 1
;
run;
title 'raw';
proc print; run;


proc format;
  /* No periods after format names, only when you use them!  And can't end with
   * a number.
   */
  
  /* A non 1 or 2 will display as is since there is no 'OTHER'.  Numeric.  */
  value f_gender 1 = 'Male'
                 2 = 'Female'
                 ;

  /* Character.  Can accept digits at end to specify display length the same
   * way the $CHAR66. does.  TODO use NOTSORTED in an example.
   * Max value e.g. $f_gen2d is 8, beyond that is ok but ignored.
   */
  value $f_gen2d (NOTSORTED) 
                 '2' = 'Male'
                 '1' = 'Female'
                 ;

  /* Format alias.  Using f_alias. is now the same as using f_gender.  Have to
   * use {..} instead of [...] on the MF.  Numeric.
   */
  value f_alias OTHER = [f_gender.];

  value f_mutant  LOW - '31dec79'D = 'not eligible'
                 '01jan80'D - HIGH = [WORDDATE20.]
                 ;

  /* Demo of a gap without an OTHER=.  E.g. the value 20.5 is displayed
   * literally instead of error, missing or teen, adult, senior.  Numeric.
   * The '-<' works identically as '<-'
   */
  value f_agegrp 13 -< 20  = 'Teen'
                 21 -< 65  = 'Adult'
                 65 - HIGH = 'Senior'
                 ;

  /* Need the '$' b/c W, B, ... are characters.  256 char max. */
  value $f_col  'W' = 'Moon White'
                'B' = 'Sky Blue'
                'Y' = 'Sunburst Yellow'
                'G' = 'Rain Cloud Gray'
                ;

  /* Between BUT NOT INCLUDING zero and one. */
  value f_decim  0 <-< 1 = 'acceptable decimal >0 and <1'
                 OTHER   = 'not between 0 and 1'
                 ;

  /* 2.1 is B */
  value f_close (fuzz=.2)  1 = 'A'
                           2 = 'B'
                           3 = 'C'
                           ;

  /* Character ranges, even broken ranges, surprisingly work.  But the
   * format must be character ($...)! 
   */
  value $f_crange       LOW-'02' = 'way low'
                  '03','05'-'06' = 'three to six'
                            '04' = 'FOUR!!'
                       '08'-'10' = 'eight to ten'
                      '11'- HIGH = 'eleven or more'
                      ;

  /* Placeholder. */
  value $f_donothing ;

  value $f_color 'B' = 'Bfmtd'
                 OTHER = ''  /* the only way to handle missing */
                 ;

  value f_longnam 1  = 'Male'
                  2 = 'Female'
                  ;
  value f_longnamA 1  = 'wont work Male'
                   2 = 'wont work Female'
                   ;

  /* Only works on numerics. */
  picture f_pict LOW - HIGH = '0000_000' (mult=1.5 prefix='X' fill='~');

  picture ssnum  LOW-HIGH = '999-99-9999';

  /* Disallow zeros.  _SAME_ only works for informats (irrelevant for VALUE formats) */
  invalue f_notz (upcase just) 0 = _ERROR_
                           OTHER = _SAME_
                           ;

  invalue f_trut (upcase just) 'FALSE','NO','F' = 0
                               'TRUE','YES','T' = 1
                               ;

  /* Extended ASCII symbols like stars, etc. */
  value sexunic 1 = '^{Unicode 2642} Male'
                2 = '^{Unicode 2640} Female'
                .M = 'Unk'
                ;
run;

title 'fmt applied (also works for proc freq etc)';
ods rtf file='~/bob/t.rtf';
ods escapechar='^';
proc print; 
  ***format cash $f_crange.;
  /* You can add a width to your formats: */
  ***format cash $f_crange11.;
  ***format color $f_color.;
  ***format cash $f_donothing.;
  format sex sexunic.;

  ***var cash;
  ***var color;
  ***format MorF $f_gen2d.;
  ***var MorF;
  var sex;
run;
ods rtf close;

 /* DEBUG */
/***proc format library=work; select sexunic; run;***/
proc format library=WORK FMTLIB; run;

proc format library=work cntlout=fmtds; run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;

libname myfmt '~/bob/';
proc format library=myfmt cntlin=fmtds; run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;
endsas;


 /******* Can simplify code using formats: */
data tmpx;
  format region $1.;
  do i=1 to 5;
    region=i; 
    output;
  end;
run;

data tmp2;
  set tmpx;
  length groop $ 12;
  
  if region eq '1' then 
    groop = 'group 1';
  else if region in('2', '3') then 
    groop = 'group 2 or 3';
  else if region eq '4' then 
    groop = 'group 4';
  else 
    groop = 'err';
run;
proc print data=_LAST_; run;

 /* Compare with: */

proc format;
  value $f_rgn
      '1' = 'group 1'
  '2'-'3' = 'group 2 or 3'
      '4' = 'group 4'
    OTHER = 'err'
    ;
run;

data tmp2;
  set tmpx;
  length groop $ 12;

  groop = put(region, $f_rgn.);
run;
proc print data=_LAST_; run;

title 'make sure long format names work (they do in v9)';
proc print data=tmp; 
  format sex f_longnamA.;
  var sex;
run;

 /* View */
proc format library=work; select f_longnamA; run;
proc format library=work FMTLIB; run;

 /****************************************/


 /* Simplest possible use of format (must use putc or putn with %sysfunc): */
%put %sysfunc(putc(W, $f_col.));



 /********** Permanent format **********/
options source fmtsearch=(FLIB);  /* required to use, not to build, the fmt */

***libname FLIB 'BQH0.INTRNET.FORMAT.LIB';      
***libname FLIB 'BQH0.FMTS.SASLIB';      
***libname FLIB '.';      
 /* SAS recommends lib[rary]=LIBRARY for formats so this is better: */
libname LIBRARY '.';
***proc format library=LIBRARY;  /* defaults to formats.sas7bcat */

  /* Save this format catalog "permanently" to FLIB catalog ("directory").  It
   * gets the default name formats.sas7bcat if you only say:
   * ... library=FLIB; ...
   */
/***  proc format library=FLIB.myformats;***/
/***proc format library=LIBRARY;***/
proc format lib=LIBRARY;
  value f_sex 1 = 'Male (1)'
              2 = 'Female (2)'
              9 = 'Not Classifiable (9)'
              ;
run;                                         


data t(keep= region stores);
  set SASHELP.shoes; 
  format stores f_sex. ;  /* note no W.D width specification for user-defined formats */
  if stores > 1 and stores < 11;
run;
proc print data=_LAST_(obs=10); run;
endsas;  /* must use Connect for this section */
 
libname L 'DWJ2.MOR03.FORMAT.LIBRARY' disp=shr wait=10;
 /* View display formats */
***proc format library=work FMTLIB;
proc format library=L FMTLIB;
  ***select $f_rgn;
run;
