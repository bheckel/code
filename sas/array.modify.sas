options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: array.modify.sas
  *
  *  Summary: Demo of copying an array in a single action without looping.
  *
  *  Adapted: Mon 30 Mar 2009 12:20:26 (Bob Heckel -- SUGI 010-2009)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data _null_;
  array cc [14] $ 1 ('0' '1' '2' '3' '4' '5' '6' '7' '1' '2' '3' '4' '5' '1');
  addr1 = addr(cc[1]);  /* using intermediate variable to hold array image */
  cc_img = put(peekc(addr1, 14), $14.);
  cc_img = tranwrd(cc_img, '1234', 'ABCD');
  cc_img = reverse(cc_img);
  call poke (cc_img, addr1, 14);
  put 41 * '-' / (cc[*]) (+1);
  /* Using single convoluted expression to restore status-quo */
  call poke (reverse(tranwrd(put(peekc(addr(cc[1]), 14), $14.), 'DCBA', '4321')),
  addr(cc[1]), 14);
  put 41 * '-' / (cc[*]) (+1);
run;

 /* Copy */
data _null_;
  /* Doesn't have to be a temp array */
  array tocopy[-5:4] _TEMPORARY_ (0 1 2 3 4 5 6 7 8 9);
  array target[0:9]              (9 8 7 6 5 4 3 2 1 0);
  call poke (put(peekc(addr(tocopy[-5]), 80), $80.), addr(target[0]), 80);
  put 19 * '-' / (target[*]) (~);
run;
