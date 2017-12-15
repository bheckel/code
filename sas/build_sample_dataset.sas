
data codes;
  infile cards;
  input id $ name $;
  cards;
A01 SUE
A02 TOM
A05 KAY
A10 JIM
  ;
run;
proc print data=_LAST_(obs=max); run;

data patients;
  infile cards;
  input id $ age $ sex $;
  cards;
A01 58 F
A02 20 M
A02 20 M
A04 47 F
A10 11 M
  ;
run;
proc print data=_LAST_(obs=max); run;
