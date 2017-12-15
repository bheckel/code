options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: scan.sas (s/b symlinked as splitstring.sas)
  *
  *  Summary: Split a string into pieces or pick off the first word or words.
  *
  *           Delimiters are allowed to vary within the string!
  *
  *           scan(string, chunknum, [delimiter])
  *
  *             1    2       3
  *            ___  ____  _________
  *           (345)/5672/ trailerfoo  leading
  *               --    --            and contiguous delims skipped
  *
  *           Must know roughly how many pieces will exist, countc() might
  *           help if V9.  Limitation: consecutive delimiters are skipped.
  *
  *  Created: Tue 11 Mar 2003 13:28:43 (Bob Heckel)
  * Modified: Thu 22 Jul 2010 15:40:54 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* Take 2nd, 3rd, etc items to end, skipping 1st */
data _NULL_;
  s='abc def ghi';
  pos=index(s, ' ');
  put pos=;
  t=substr(s, pos);
  put t=;
run;


/***%let sp=%str( ) ; %let pos=%index(%bquote(&SYSPARM), &sp); %let pxall=%substr(%bquote(&SYSPARM),&pos);***/
%macro m;
  %let sysparm=u:\projects\prototypes\DPv2 Queries;
  %let x=o;
  %let pos=%index(%bquote(&SYSPARM), &x );
  %let pxall=%substr(%bquote(&SYSPARM),&pos);
  %put _all_;
%mend;%m;



endsas;
data _NULL_;
  ***s='BQH0.PGM.LIB(FOO)';
  s='BQH0.PGM.LIB.FOO';
  /* If you omit delimiters, SAS uses  blank . < ( + & ! $ * ) ; ^ - / , % |
   * (on ASCII systems).
   */
  s2=scan(s, 4);  /* FOO */
  put '!!! tail is ' s2; 

  s3=scan(s, -4);  /* BQH0 */
  put '!!! top level root is ' s3; 

  /* Calc number of delimiters */
  l1=length(s);
  d=compress(s, '.');
  l2=length(d);
  n=l1-l2;

  s4=scan(s, n+1);
  put '!!! if do not know how many delims tail is ' s4;

  put _all_;
run;


data _NULL_;
  /* SAS' scan() default is 200, this shuts up Log spew */
  length a b c d e f g $ 20;

  s=" 00 01 02 03    04";

  /* The ' ' is unecessary, SAS uses blanks then '.' then others */
  a=scan(s, 1, ' '); 
  b=scan(s, 2, ' '); 
  c=scan(s, 3, ' '); 
  d=scan(s, 4, ' '); 
  e=scan(s, 5, ' '); 
  f=scan(s, 6, ' '); 
  /* Get the last word element from the list. */
  /* v8+ only */
  g=scan(s, -1); 

  put "!!! a " a;
  put "!!! b " b;
  put "!!! d " d;
  put "!!! f " f;
  put "!!! g " g;
run;


 /* Same as non-macro version. */
%macro Foo;
  %let s= 00 01 02 03  04;  /* consecutive delimiters count as ONE! */

  %let a=%scan(&s, 1, ' ');
  %let b=%scan(&s, 2, ' ');
  %let c=%scan(&s, 3);  /* ' ' is the default delim */
  %let d=%scan(&s, 4, ' ');
  %let e=%scan(&s, 5, ' ');
  %let f=%scan(&s, 6, ' ');  /* empty */

  %put !!! &a;
  %put !!! &b;
  %put !!! &c;
  %put !!! &d;
  %put !!! &e;
  %put !!! &f;

  %let bar=BOB$V090.;
  %put %scan(&bar, 1, '$');
  %put $%scan(&bar, 2, '$');  /* have to put back the delimiter */
%mend Foo;
%Foo


data _NULL_;
  length a b c $ 20;
  t='a [weird] bracket example';
  a=scan(t, 1, '[]');
  b=scan(t, 2, '[]');
  c=scan(t, 3, '[]');
  put a / b / c;
run;
