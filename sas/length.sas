options nosource;
 /*---------------------------------------------------------------------------
  *     Name: length.sas
  *
  *  Summary: Demo of both the length statement and function.
  *
  *           The DATA step assigns a length to variables based ON THE FIRST
  *           MENTION of the variable (e.g. at an IF-THEN stmt.).  Must place
  *           the statement (e.g.  length gender $ 6;)  *before* the IF-THEN.
  *           E.g. this will assign gender width of 6 regardless of the data:
  *           ...if foo eq 1 then gender='abcdef' else gender='abcdefg'...
  *           assuming no gender LENGTH statement appears before the IF.
  *
  *           LENGTH statement is also responsible for the order in which the
  *           variables are stored in the dataset.
  *
  *           If length is larger, can adjust vars by saying  length foo $10;
  *           I.e. you can change the lengths of of variables in existing
  *           datasets by using a LENGTH statement between a DATA statement
  *           and a SET, MERGE or UPDATE statement.
  *
  *           Can, but shouldn't, say  length thisworksbut $42.;
  *
  *           The *functions* LENGTH() or %LENGTH() are used to count num of
  *           characters in its argument.
  *
  *
  *           Storage Defaults:
  *           -----------------
  *           If we're using list input, both char and numeric variables 
  *           have a default storage requirement of 8 bytes.  To save space
  *           (e.g. Variable is Y or N) we can use  length yesno $1;
  *
  *           If we're using column input, the LENGTH is equal to the number of
  *           columns we're reading.
  *
  *           If we're using formatted input, the LENGTH is equal to the width
  *           of the FORMAT.
  *
  *           See input_list_formatted_column.sas
  *
  *
  *  Created: Fri 04 Oct 2002 11:41:48 (Bob Heckel)
  * Modified: Mon 06 Apr 2015 15:23:06 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%macro bobh0604150534; /* {{{ */
 /* STATEMENT version of length: */
data work.sample;
  infile cards MISSOVER;
  list;
  /* LENGTH statement must come *before* the INPUT stmt.
   * Then we can usually just say '$' for chars input stmt.
   *
   * Save space when using the qtr1-qtr4 variables but allow extra space for
   * the large Taggart idnum.  Keyword DEFAULT only works for numerics.
   */

  /* The length number (e.g. $10) is distributive (like the format stmt)! */
  ***length DEFAULT=3  idnum 5  name  other $10;
  /* More explicit */
  length idnum 5  name $10  oth $10  DEFAULT=3;
  input  idnum    name $    oth $    qtr1-qtr4;  /* don't even need '$'s here! */
  cards;
1251 ReardenXY other 10 12 14 20
1600000 Tag other . . 10 10
161 Taggart other . . 10 17
482 Galt other 22 14 6 25
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
proc contents; run;


 /* length statement is distributive */
data _allado;
  length foo recorded_text $40;  /* both get $40 */
  input foo $ recorded_text $;
  cards;
9 5
9 10
9 1.5
9 0.5
9 .5
;
run;
proc contents; run;
%mend bobh0604150534; /* }}} */



 /* FUNCTION version of length: */
 /* Trailing spaces are NOT counted! */
data _NULL_;
  length name $11;  /* set at compile time so x gets 11 instead of the 10 if it were below name='...' */
  name = 'foo string';
  /* Only works on strings */
  x = lengthn(name);  /* actual length */
  y = lengthc(name);  /* storage length */
  z = ':' || name || ':';
  put x= /
      y= /
      z=
      ;
run;
