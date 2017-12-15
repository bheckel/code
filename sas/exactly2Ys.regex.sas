 /* See also count_occurrence_of_char.sas */
options NOcenter;

data work.tmp;
  ***infile 'BF19.CAX0402.NATMER';
  ***infile 'BQH0.CAX0402.NATMER';
  ***infile 'BF19.CAX0324.NATMER';
  infile 'BF19.WIX0311.MORMER';
  ***input cert $ 3-8 mr $ 277-291;
  input cert $ 3-8 mr $ 166-180;
run;
proc print; run;

data tmp2 (drop= prx);
  set tmp;
  retain prx;

  /* TODO this is only good for 2 *or more* instances of Y in a string */
  if _N_ eq 1 then 
    do;
      prx = prxparse("/.*Y.*Y.*/");
      /* Only work if they're adjacent. */
      ***prx = prxparse("/Y{2}/");
      ***prx = prxparse("/.*Y.*Y.*Y.*/");
    end;

  if prxmatch(prx, mr) then
    do;
      cnt+1;
      putlog "!!! 2 Ys " cert mr cnt;
    end;
run;
