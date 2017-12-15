options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: input_linepointercontrol.sas
  *
  *  Summary: Demo of moving around raw data and building one obs from many
  *           rows of data.
  *
  *  Created: Wed 23 Jun 2010 12:12:00 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data t;
  input a $ 1-8 b $;
  input c $ d;
  input e COMMA10.;
  cards;
abramsaa   thomas 1
marketing  2
$25,209.03
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* Absolute, i.e. non-sequential, pointer control using #n */
data t;
  /* These can go #2 #1 #3 or whatever or even repeat a #n (or use both styles
   * #n and / simultaneously)
  */
  input #1 a $ 1-8 b $
        #2 c $ d
        #3 e COMMA10.
        ;
  cards;
abramsaa   thomas 1
marketing  2
$25,209.03
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* Relative, i.e. sequential, pointer control */
 /* same */
data t;
  input a $ 1-8 b $ /
        c $ d /
        e COMMA10.
        ;
  cards;
abramsaa   thomas 1
marketing  2
$25,209.03
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
