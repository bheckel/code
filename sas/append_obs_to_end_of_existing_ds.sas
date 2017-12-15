
/* proc print data=sashelp.shoes width=minimum heading=H;run;title; */
data t;
  set sashelp.shoes end=e;
  output;
  if e then do;
    Region='Africa'; Product='Sandals'; Returns=0;
    output;
  end;
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;
