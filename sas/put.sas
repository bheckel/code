options nosource;
 /*----------------------------------------------------------------------------
  *     Name: put.sas
  *
  *  Summary: Demo of the put STATEMENT (not function).
  *
  *  PUT statement 
  *    writes selected lines (including text strings and DATA step variable
  *    values) to the SAS log. This behavior of the PUT statement requires that
  *    your program does not execute a FILE statement before the PUT statement
  *    in the current iteration of a DATA step, and that it does not execute a
  *    FILE LOG; statement. 
  *
  *    WARNING: vars get autovivified when you PUT a var that doesn't exist:
  *     data t;
  *       set sashelp.shoes;
  *       put region wtf;
  *     run;
  *     proc contents;run;
  *
  *  %PUT statement 
  *    enables you to write a text string or macro variable value to the SAS
  *    log. %PUT is a SAS macro program statement that is independent of the
  *    DATA step and can be used anywhere.
  *
  *    e.g. call symput('NRECS', trim(left(put(cnt, COMMA8.))));
  *
  *           Also see file.sas, sysfunc.macro.sas
  *
  *  Created: Tue, 09 Nov 1999 08:58:30 (Bob Heckel)
  * Modified: Mon 15 Aug 2016 13:23:43 (Bob Heckel)
  *----------------------------------------------------------------------------
  */
data t;
  set sashelp.shoes(obs=20);
  num=sales;
  char=''||left(trim(sales));
run;
proc sql;
  select put(num,z9.) as clientstoreid from t;
  select put(input(char,8.),z9.) as clientstoreid from t;
quit;



data _null_;
  /* http://unicode-table.com/en/#control-character */
  put 'AE'x;  /* ® */

  put 'yen is' + 5 'A5'x;  /* ¥ */
run;



data t;
  infile cards /*MISSOVER*/;
  input a $ b $ c DATE9. d e;
  cards;
evans   donny 01JAN1960 996 63
fvans   eonny 02JAN1960
997 64
gvans   gonny 03JAN1960 998 65
  ;
run;

data _null_;
  set t;
  file 't.out' DLM=',';
  /* Distributive */
  put a b c YYMMDD10.;
run;



%let COMMAFYME=1234567;

data _NULL_;
  length bar $8  tmp 8;

  /* Number of days since the epoch Jan 1, 1960 */
  epoch=0; 
  bar='baz';

  /* Formatted output */
  put epoch YYMMDD10.;  /* if get asterisks, may need to use DATETIME19. ... */
  put "same: " epoch:YYMMDD10.;
  put epoch YYMMDD.;
  put epoch DATE9.;
  put epoch= DATE9.;  /* epoch=01JAN1960 */
  put epoch WORDDATE.;
  put 'zeros ' epoch Z6.;
  put bar $QUOTE.;

  mvar=put(&COMMAFYME, COMMA10.);
  put 'commafy ' mvar;
  put 'START>' mvar+(-1) '<END';  /* START>1,234,567<END */

  mytime=time();
  put mytime= TIME.;  /* confusing, this is NOT assignment */
run;



data _NULL_;
  /* Use Standard Print File keyword PRINT to redirect away from LOG into the
   * LIST for the duration of this step. 
   */
  file PRINT;
  /* Note: no concatenation operator required to fuse the string and
   * variable.  And the slash forces a newline.
   */
  put 'Here are automatic variables: ' _ALL_;
  /* Use keyword _PAGE_ to print a control character signifying the start of a
   * new page. 
   */
  ***put _PAGE_;
  put _PAGE_ '----top of pg after pgbreak----';
  /* Multiline put - make 2nd line with backslash */
  put 'Here are automatic variables: ' / _ALL_;
  put 'Here is a demo proving that there is no need for line continuation '
      'characters while using put statements';
  /* SAS's idea of printing a carriagereturn newline on Windows. */
  put ' ';  /* put; should also work */
  /* SAS's idea of printing a newline on Windows or OS/390. */
  put '0D'x;
  put 'before BLANKPAGE';
  put _BLANKPAGE_;
  put 'after BLANKPAGE';
  put 'the' +10 'end';
run;

  %put And here is how a looooooooooooooooooooooooooooooooooooong macro string
would work w.r.t. line continuation (line 2 must start at column 1);

data work.bf19s;
  infile cards;
  /* Intentional input overkill: */
  length latest $25;
  /* Intentionally too short. */
  informat latest $char19.;
  format latest $char19.;
  input latest $char17.;
cards;
BF19.NCX0133.MORMER1
BF19.NJX0163.MORMER
BF19.AKX0160.MORMER
;
run;


data _NULL_;
  set work.bf19s;
  put '!!! Using put statment you ';   /* this will carriage return */
  put "!!! don't ever need concatenation operators " latest= ' see 4 yourself';
run;


data _NULL_;
  set work.bf19s;
  put latest=; 
  /* Actual. */
  len=length(latest);
  /* Demo of line control '+5' */
  put len= +5 'is length of latest';
  /* Capacity. */
  vlen=vlength(latest);
  ***put len= vlen=;
  put (_ALL_) (=/);
run;


 /* Linehold demo pt. 1*/
 /* Demo of wring to a position based on another field and holding the line
  * while doing so. 
  */
data work.sample;
  input fname $1-10  lname $15-25  @30 storeno 3.;
  put _ALL_;
  put _ALL_  @15 '--INSERTED INTO _ALL_ OUTPUT LINE--';
  ***put fname=;  * DEBUG;
  datalines;
mario         lemieux        100
charlton      heston         300
richard       feynman        300
  ;
run;

 /* Demo of distributive '(=)' */
data tmp;
  set sample;
  put (fname storeno) (=);
run;

 /* Linehold demo pt. 2*/
data _NULL_;
  set work.sample;
  file 'junksasout';
  if ( storeno > 100 and storeno < 300 ) then
    do;
      put @15 storeno @@;
    end;
  put @3 fname  @30 lname;
run;


 /* Another linehold to build a single line */
data _null_;
  file X21;
  put 'SELECT NAME, IP_TREND_TIME, IP_TREND_VALUE FROM "23034794.Vessel.Pres.PV" WHERE IP_TREND_TIME BETWEEN ' @; *** '02-APR-10 00:00:00' AND '21-APR-10 15:00:00';
  put "&IP21START and &IP21END";
run;

 
 /* Repetition factor (like Perl's 'x' repetition operator), print
  * something 5 times.  A.k.a. iteration factor.
  */
data _NULL_;
  put 5* '00'x;
  put 5* 'ABBA';
  /* Fill array with ones as default intialization. */
  array arr[10] x1-x10 (10* 1);
  put;
  put arr[5]=;
  put arr[9]=;
  put arr[*];
run;


data _NULL_;
  set work.sample;
  filename FN 'junk';
  file FN;
  put @3 fname;
run;

 
 /* Subversively print over stuff already printed. */
data _NULL_;
  file PRINT;
  do line=5 to 1 by -1;
    set sample;
    /* Specify line AND column positions. */
    put #line @line fname;
  end;
run;


 /* Use a header line: */
data _NULL_;
  set sample;
  file 'junk' header=top print;
  put @2 lname $10.  @30 storeno 3.;
  return;
top:
  put @1 'name'  @25 'num ber' / @1 20*'-' @25 30*'-';
  return;
run;


data _NULL_;
  set sample;
  put 'Fill exact columns';
  put lname 3-5;
run;


%put 'Hold the line open until end of ds iteration';
data _NULL_;
  set sample;
  put fname @;
  if lname ne 'heston' then
    put lname storeno;
run;
 /* @ and @@ are the same in this case */
data _NULL_;
  set sample;
  put fname lname storeno @@;
run;


data _NULL_;
  array arr{*} $3 d1-d5 ('Mon' 'Tue' 'Wed' 'Thu' 'Fri');
  put arr{*};
  put arr{*}=;
run;


%macro Poottest;
  /* TODO how can this be made to work? */
  %put this line is way too long to fit, it needs a 
       line break;
%mend;
%Poottest


options NOdate NOnumber;
data _NULL_;
  put @10 'bobh';
  put @10 'BOBH';
  /* Print to .lst.  Don't use 'file LIST' */
  file PRINT;
  put @10 'bobh2';
  put @10 'BOBH2';
run;
 /* Reset page number to keep the 'put' headers from taking pg 1 */
options date number pageno=1;
proc report data=sample;run;


data _NULL_;
  %let FOO=bar;
  /* Doesn't work: */
  ***put 'here is ' &FOO ' now';
  /* Does */
  ***put "here is &FOO now";
  /* So use this approach: */
  %let OTHER=%upcase(baz);
  put "upcased: &OTHER";
run;


 /* Comma delimited with no spaces inbetween: */
data _NULL_;
  set tmp;
  put fname +(-1) "," lname +(-1) "," storeno;
run;



data _null_;
  curdt = datetime();
  put '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
  put "++   " +1 curdt DATETIME19. +1 "                          ++ begin";
  put '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
run;
data _null_;
  curdt = datetime();
  put '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
  put "++   " curdt DATETIME18. "                          ++ begin";
  put '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
run;


data equals;
  set SASHELP.shoes (obs=5);
  /* Distributive equal sign to avoid having to add an '=' to each var.
   * Both parens are mandatory.
   */
  put (region sales subsidiary)(=);
run;


%macro PutMacro;
  %let foo=bar;
  %put foo is !!!&foo;
  %put _all_;
%mend;
%PutMacro



 /* Complicated quoting requires breaks across lines:
  * E.g. <a onmouseover="doit('men1','visible')" onMouseOut="doit('men1','hidden')" href="javascript:void(0)">
  */
data _null_;
  put '<a onmouseover="doit('
      "'men1','visible'"
      ')" onMouseOut="doit('
      "'men1','hidden'"
      ')" href="javascript:void(0)">';
      ;
  /* Alternatively, one can use two single quotes in a row to represent a single
   * quote within the literal: 
   */
  put '<a onmouseover="doit(''men1'',''visible'')" onMouseOut="doit(''men1'',''hidden'')" href="javascript:void(0)">';
run;
