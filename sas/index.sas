options nosource;
 /*---------------------------------------------------------------------------
  *     Name: index.sas (deprecated, see find() for v9+)
  *
  *  Summary: Demo of INDEX function used for locating substrings, returns 
  *           numeric position of first char of first search string found.
  *
  *           1 (not 0) based counting!
  *
  *           Also see substr() and verify() if need to determine if ANY chars
  *           are in a string.
  *
  *           index(str_2_search, what_2_look_for);  <---returns 0 on failure
  *
  *           indexc() searches for SPECIFIC characters, not a string of 
  *           characters.
  *
  *           Use indexw() to avoid finding partial "words" in the source
  *           string.  Note there is no macro %indexw
  *
  *           Also see indexc.sas, indexw.sas, equal_colon.sas, find.sas (v9)
  *
  *  Created: Tue 22 Oct 2002 13:04:18 (Bob Heckel)
  * Modified: Fri 07 Aug 2015 08:40:15 (Bob Heckel)
  *---------------------------------------------------------------------------
  */

%macro m;
  %let the_name=%str(foo b%'ar baz);
  %put &the_name;

  %if %index(&the_name, %str(%')) %then %put found an apostrophe;
%mend;
%m;


endsas;
%let needle='z0';
***%let needle='X1';
%let haystack='ABCZ0XYZA';

 /* Find position of a string. */
data _NULL_;
  /* Case sensitive. */
  ***mystrpos = index(&haystack, &needle);
  /* Case insensitive. */
  mystrpos = index(upcase(&haystack), upcase(&needle));
  /* Returns zero if no match found. */
  ***if mystrpos ^= 0 then ;
  /* Same */
  if mystrpos then
    put "first &needle found in &haystack at position " mystrpos;
  else
    put 'not found';
run;

title 'berkely';
 /* Find position of one or more SPECIFIC characters using INDEXC() */
data _NULL_;
  /* Case sensitive. */
  mystrpos = indexc('berkely', 'rs');
  if mystrpos then
    put "found r or s at pos: " mystrpos;
  else
    put 'not found';
run;
title;


 /* New demo */
%macro SniffPosition(s, c, pos);
  %if %index(&s, &c) eq &pos %then
    %put !!! found &c in &s at first position;
  %else
    %put !!! searched &s for &c but was not found in expected position &pos;
%mend SniffPosition;
 /* Look in position number 1. */
%SniffPosition(rmormer, r, 1)


%macro Idx;
  /***   %let the_type=rmormer; ***/
  %let the_type=natmer;

   /* Look for mormer or rnatmer strings: */
  %if %index(&the_type, natmer) %then
    %put found a [r]natmer;
%mend;
%Idx



data _null_;
  foo='bar';
  pos1=index(foo, 'b');
  pos2=index(foo, 'ar');
  pos3=index(foo, 'r');
  pos4=index(foo, 'ax');
  pos5=indexC(foo, 'ax');
  put _ALL_;
run;
