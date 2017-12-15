%let CSV='00';

data medmerclosed (keep= fn);
  length fn $25;
  infile 'HDG7.FINAL.BF19.DATASET' TRUNCOVER;
  input c $ 1-8  @;
    if c eq '0NONVSAM';
    input fn $ 18-42  yy $ 26-27;                                                             
    if ( scan(fn, 3, '.') eq: 'MEDMER' ) and ( yy in(&CSV) );
run;
proc print data=_LAST_; run;
