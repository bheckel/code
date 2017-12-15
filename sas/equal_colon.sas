options nosource;
 /*---------------------------------------------------------------------
  *     Name: equal_colon.sas
  *
  *  Summary: Use colon equals operator =: to detect the first few 
  *           characters of a string.  Starts with.  Mildly regex-like
  *           and SQL LIKE-like.
  *
  *           To find something not starting with these chars use this:
  *           NOT =: 
  *
  *           Also see index.sas verify.sas
  *
  *  Created: Wed Oct 23 10:35:32 2002 (Bob Heckel)
  * Modified: Mon 10 Nov 2008 10:11:48 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source;

data _NULL_;
  code='00123';
  ***codex='UNKNOWN a';
  codex='UNKNOWN 42';

  if code =: '00' then
    put 'found 00 prefix';
  else
    put 'did not find 00 prefix';

  if code =: '12' then
    put 'found 12 prefix';
  else
    put 'did not find 12 prefix';

  /* This doesn't require a trailing digit or digits in order to get a match */ 
  if codex eq: 'UNKNOWN ' then
    put 'found word followed by number or char';

  /* This does (v8 - where's Perl when you need it?) */
  if (scan(codex,1) eq 'UNKNOWN') and indexc((scan(codex,2)),'0123456789') then
    put '!!!found word followed by number';

  if code in:('00','12') then 
    put 'wow even this works';
run;


data movies;
  infile cards DSD;
  input mtitle $  rating $;
  ***if rating eq: 'P';
  if rating ne: 'P';
  cards;
Brave Heart,R
Jaws,PG
Rocky,PG
Titanic,PG-13
  ;
run;
proc print; run;


 /* Doesn't work for macro so use something like this: */
%macro EqualColonLike(endyr);
  %if not %index(&endyr, 20) %then
    %put ERROR: does not start with 20;
%mend;
%EqualColonLike(2004);
