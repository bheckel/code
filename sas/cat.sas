options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: cat.sas
  *
  *  Summary: Demo of concatenating vars. V9+.
  *
  *  Adapted: Mon 30 Mar 2009 12:20:26 (Bob Heckel -- SUGI 010-2009)
  * Modified: Wed 08 Apr 2015 09:17:16 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data catted;
  c1 = 'foo bar';
  c2 = ' baz ';
  c3 = 'other';

  /* Concatenate: leading and trailing blanks are included */
  *cat1 = c1 || c2 || c3;  /* V8 */
  cat1_cat = cat(c1, c2, c3);  /* V9 */

  /* Concatenate: trailing blanks are trimmed removed */
  *cat2 = trim(c1) || trim(c2) || trim(c2);  /* V8 */
  cat2_catt = catt(c1, c2, c3);  /* V9 */

  /* Concatenate: leading and trailing blanks are removed */
  *cat3 = trim(left(c1)) || trim(left(c2)) || trim(left(c3));  /* V8 */
  cat3_cats = cats(c1, c2, c3);  /* V9 */

  /* Concatenate: use a delimiter - CATX is different in that it skips missing
   * values.  Old version would do e.g. foo,,bar
   */
  *cat4 = trim(left(c1)) || ',' || trim(left(c2)) || ',' || trim(left(c3));
  cat4_catx = catx(',', c1, c2, c3);  /* V9 */
run;
proc print data=_LAST_(obs=max) width=minimum; run;


endsas;
data pieces;
  input (c1-c10) (:$4.);
  cards;
0000 1111 2222 3333 4444 5555 6666 7777 8888 9999
a b c d e f g h i j
zz yy xx ww vv uu tt ss rr qq
*** /// ### !!! ??? $$$ *** +++ \\\ ***
 ;
run;
/***proc print data=_LAST_(obs=max) width=minimum; run;***/

 /* Faster substitute for v9's CAT() */
data _null_;
  set pieces;
  length whole $40;  /* PEEK's max is 32767 i.e. for nums it's 4095 vars */
  /* No need to list c1-c10 as in cat(of c1-c10) */
  whole = peekc(addr(c1), 40);
  put 40 * '-' / whole;
run;


data _null_;
   result1=CATQ(' ',
                'noblanks',
                'one blank',
                12345,
                '  lots of blanks    ');
   result2=CATQ('CS',
                'Period (.)                 ',
                'Ampersand (&)              ',
                'Comma (,)                  ',
                'Double quotation marks (") ',
                '   Leading Blanks');
   result3=CATQ('BCQT',
                'Period (.)                 ',
                'Ampersand (&)              ',
                'Comma (,)                  ',
                'Double quotation marks (") ',
                '   Leading Blanks');
   result4=CATQ('ADT',
                '#=#',
                'Period (.)                 ',
                'Ampersand (&)              ',
                'Comma (,)                  ',
                'Double quotation marks (") ',
                '   Leading Blanks');
   result5=CATQ('N',
                'ABC_123   ',
                '123    ',
                'ABC 123');
   result6=CATQ('1AC',
                8123,
                0123,  /* FAIL! */
                923);
   put (result1-result6) (=/);
run;
