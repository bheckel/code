proc javainfo; run;

data _null_;
  length s_out $200;

  declare JavaObj j1 ('java/lang/String', 'ABCDE');
  declare JavaObj j2 ('java/lang/String', 'FGHIJ');
  
  j1.callStringMethod('concat', j2, s_out);

  put s_out=;
  j1.delete();
  j2.delete();
run;
