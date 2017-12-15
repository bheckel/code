
 /* BETWEEN will not work here */
data psycho;
  set psycho;
  if (date_filled >= '01jun2005:00:00:00'dt) and (date_filled < '30jun2005:00:00:00'dt);
run;
