options nosource;
 /*---------------------------------------------------------------------
  *     Name: helloworld_macro.sas
  *
  *  Summary: Macro demos.
  *
  *           Macro must be defined before being called (like C funcs).
  *
  *           In non-macro SAS, words have meaning so we must
  *           distinguish character values with quotes.
  *           In macro, everything is a text value so the instructions
  *           must be distinguished with special symbols (e.g. '%', '&')
  *
  *           PC SAS specific!
  *
  *           Also see if_then_macro.sas
  *
  *           http://support.sas.com/techsup/faq/macro.html
  *
  *           Avoid using the strings AF, DMS, or SYS as the beginning
  *           characters of macro names and macro variable names.
  *
  *           Do not use trailing empty parentheses:
  *           %macro foo();
  *             %put ok;
  *           %mend;
  *           %foo();  <---error
  *
  *           See also autocall.sas
  *
  *  Created: Tue 24 Sep 2002 09:18:00 (Bob Heckel)
  * Modified: Fri 10 Oct 2008 11:37:08 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options linesize=78 pagesize=32767 NOcenter NOdate nonumber NOreplace
        source NOsource2 notes obs=max errors=5 datastmtchk=allkeywords 
        symbolgen mprint mlogic merror serror msymtabmax=1
        ;
title; footnote;

%put %sysfunc(date()) days since 1/1/60;
%put %sysfunc(time()) seconds since midnight;
%put %sysfunc(datetime()) seconds since 1/1/60;
%let fn="myfile.txt.%sysfunc(today(),yymmddn8.)";
%put &fn;  /* prints with quotes! */

%let y=MORMER;
%let x=my%substr(&y,1,3);  /* myMOR */

 /* Mainframe only */
***libname LFMT "DWJ2.%substr(&the_type,1,3)03.FORMAT.LIBRARY" DISP=SHR WAIT=30;

 /* Not required, it's global by default outside of any %macro...%mend */
 /* No comma!! */
%global LOOSE_CANNON LOOSE_CANNON42;
 /* Intentional left pad with 4 spaces.  %let is always valid in open
  * code.
  */
%let LOOSE_CANNON=%str(    &SYSUSERID is abusing global variables);
 /* Visual distinction on the leading spaces. */
%put [&LOOSE_CANNON];


%macro EmptyTest;
  %let NONEXISTENT_CANNON='';
  /* Macro IF statements are executed during the GENERATION OF SAS CODE.
   * Typically it is a decision about what code to generate, not the normal
   * SAS case of deciding whether to execute a block of compiled code for a
   * given data situation.
   */
  /* Can't say  %if &LOOSE_CANNON %then  ... */
  %if &LOOSE_CANNON ne  %then
    %do;
      %put cannon is not empty;
      %put 'no interpolation &LOOSE_CANNON';
      %put "interpolation &LOOSE_CANNON";
    %end;
  %if &NONEXISTENT_CANNON ne '' %then
    %put cannon is not empty;
%mend EmptyTest;
%EmptyTest


%macro SayHello(hi, num);
  %* %local bumpup ...    should go here in production code ;

  %* This is for entertainment only, num is interpreted as a number in ;
  %* the do-loop below (caution: %eval does INTEGER arithmetic only, see ;
  %* %sysevalf for floating point arithmetic) ;
  %let bumpup=%eval(&num + 1);
  %* Not used anywhere but here;
  %let floatingpoint=%sysevalf(&num + 1.2);
  %let mini_str=%substr(&hi, 5, 3);
  %* This is not a good idea, demo use only;
  %let LOOSE_CANNON42=footytoo;
  %let fortytwo=42;
  /* No quotes! */
  %let address=7212 Mill Ridge Rd.;
  /* Assign a null to floatingpoint. */
  %let floatingpoint=;

  %put !!!DEBUG> show local macrovariables;
  %put _LOCAL_;

  %put !!!DEBUG> show global macrovariables;
  %put _GLOBAL_;

  %put !!!DEBUG> show user-created macrovariables (includes _LOCAL_);
  %put _USER_;

  %***%put !!!DEBUG> show automatics;
  %***%put _AUTOMATIC_;

  /* No quotes!! */
  %if &hi=yes sir %then %do;
    %do n=1 %to &bumpup;
      %put;
      %* Print to SAS Log.  No quotes!!;
      %put &SYSDATE9 &n Hello bizarre 'world' of macro, &mini_str;
      %put I said %upcase(Hello bizarre world of twisty SAS passages);
      %put;
    %end;
    %* Disambiguate with a period;
    %put global is loose: &LOOSE_CANNON.12345;
    %put global is loose: &LOOSE_CANNON&BUMPUP;
    %* Resolve desired reference (&LOOSE_CANNON42) on the second scan;
    %put global is loose: &&LOOSE_CANNON&fortytwo;
    /* Usually not necessary. */
    %symdel LOOSE_CANNON;
    %put;
    %put %scan(&address, 1);
    %* Test to prove that this macroname is not changed (default) due to;
    %* the %local statement;
    %let yolk=runny;

    %* Efficiency problem if done this way.  Better to nest only the;
    %* macro call, not the macro definition;
    %macro Nester;
      %* Probably a good idea to always use local to avoid accidental;
      %* stomping of previously declared globals;
      %local egg;
      %let egg=yolk;
      %put nested macro - this is a legal &egg construct;
    %mend Nester;
    %Nester

    %let escaped=%nrstr(so called %local statement);
    %put still the original &yolk because of the &escaped;
  %end;

  %if &SYSDAY=Tuesday %then 
    %do;
      %put it is Tues;
    %end;
  %else
    %do;
      %put it is not Tues;
    %end;  /* WARNING this comment style is ok here but the other kind is not */

  %put;
%mend SayHello;


* If nothing is passed by caller, makeemiknock= keeps SAS from barfing;
%macro OptionalArg(makeemiknock=);
  %local makeemiknock;

  %if &makeemiknock = 1 %then %put maybe again maybe not; 
  %* Extreme global from ~/code/sas/autoexec.sas;
  %put &fooautoexec;
%mend OptionalArg;


 /* No quotes!!  No semicolon!!  The lack of a semicolon allows easier nested
  * macro calls.
  */
%SayHello(yes sir, 2)
%OptionalArg
%OptionalArg(makeemiknock=1)


 /* No quotes !!  It opens and waits to be closed before running the rest of
  * helloworld_macro.sas code.
  */
***%sysexec(notepad);


%macro DayOfWk(otherday);
  %if not %index(monday tuesday %lowcase(&otherday), %lowcase(&SYSDAY)) %then
    %do;
      %put It is not MT nor &otherday;
      %goto mexit;
    %end;
  %else
    %put It *is* M, T or &otherday;
  %mexit:
%mend DayOfWk;
%DayOfWk(Thursday)


 /* How to handle semicolons. */
%let mac=one;
%let roe=two;
%let semicolon=&mac&roe %str(;);
%put &semicolon;


%let multilinevar = this one goes across lines 
                    with no problem;
 /* ...works for my ForEach (foreach.sas) code */
 /* ...but this approach is not working: */
***%put %sysfunc(compress(&multilinevar, '  '));


%macro HandleComments;
  /* These are ignored ok with the ^*** style comment. */
  ***endsas;
  ***%include 'tabdex';
  /* But this isn't so must use slash-star to hide it properly. */
  /***   %put &semicolon; ***/
   /* TODO figure out why ^*** style is resolved */

  %put ignored properly;
%mend HandleComments;
%HandleComments


%macro ADoLoop(filen);
  %put here is &filen;
%mend ADoLoop;

data _NULL_;
  do f='one.txt', 'two.txt';
    put f=;
    /* Doesn't work due to macro resolution. */
    %ADoLoop(f)
  end;
run;


%macro Whoami;
  %put running macro &SYSMACRONAME;
%mend;
%Whoami


 /* Comment out. */
%macro bobh;
 data _NULL_;
 run;
%mend bobh;


 /* v9+ */
%macro check;
  %let checkme=yes;

  %if %symexist(checkme) %then
    %put macrovariable exists;
%mend;
%check


%macro multipleconditionIF;
  %let checkme=yes;
  %let foo=bar;

  %if &checkme eq yes and &foo eq bar %then
    %put macrovariable exists;
%mend;
%multipleconditionIF
