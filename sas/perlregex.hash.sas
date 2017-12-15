options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: perlregex.hash.sas
  *
  *  Summary: Use a regex to find unstructured data while iterating a hash.
  *
  *           In this example we want to search doctor's notes and eliminate
  *           cases where pre-eclampsia has been "ruled out" or some other
  *           negating term has been used in the freeform text field.
  *
  *  Adapted: Thu 14 Nov 2013 10:27:07 (Bob Heckel--SUGI 091-2013)
  * Modified: Mon 04 Aug 2014 08:46:59 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data negation_concepts;
  length key $4 regex $200;
  infile cards TRUNCOVER;
  input @01 key $4.  @05 negterms $100.;

  /*     /no evidence of (PRE(\s|\-)?ECLAMPSIA)/i            */
  regex='/'||strip(negterms)||' '||"(PRE(\s|\-)?ECLAMPSIA)/i";

  cards;
aaaano evidence of
bbbbdenied
ccccrule out
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


data clinical_notes;
  infile cards;
  input @1 phrase $28. @30 line $1. patient_id $;
  cards;
pregnant                     5 a
not pregnant                 5 b
eclampsia possible           7 c
rule out PRE-ECLAMPSIA       8 d
pre-eclampsia possible       7 c
no evidence of PRE eclampsia 0 e
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


data cond_possible rule_out;
  length key $4 regex $200;
  set clinical_notes;

  if _N_ eq 1 then do;
    declare hash myhash(dataset:"WORK.negation_concepts", ordered:'YES');
    rc=myhash.DEFINEKEY('key');  /* var from negation_concepts ds */
    rc=myhash.DEFINEDATA('key', 'regex');  /* vars from negation_concepts ds */
    rc=myhash.DEFINEDONE();
    call missing(key, regex);
    /*      SAS keyword          */
    /*      _____                */
    declare hiter myiter('myhash');
  end;

  /* Copies the contents of the first item from myhash into the data variable
   * 'regex'. While there are items to be read (rc=0), each item of the hash
   * table is accessed one by one in the DO loop.
   */
  rc=myiter.first();
  /* The hash object searches for regex matches against the free text var
   * 'phrase' in the clinical_notes data set.  This loop looks for matches but
   * that's not what the task is, so the cond_possible ds is the answer to our
   * question.
   */
  do while (rc eq 0);
    rx=prxparse(strip(regex));
    if prxmatch(rx, phrase)>0 then do;
      put 'match: ' (_all_)(=);  /* DEBUG */
      /* All variables from clinical_note plus data variables from DEFINEDATA
       * are outputted into rule_out dataset
       */
      output rule_out;
      call prxfree(rx);
      goto NEXT_OBS;
    end;
    else
      put 'no match: ' (_all_)(=);  /* DEBUG */

    call prxfree(rx);
    rc=myiter.next();
  end;

  output cond_possible;

  NEXT_OBS:;
  put;  /* DEBUG cosmetic, add a blank line between groups */
run;
proc print data=cond_possible(obs=max) width=minimum; run;
proc print data=rule_out(obs=max) width=minimum; run;
