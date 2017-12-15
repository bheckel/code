 /* see also is_char.sas */

options ls=max;

data one;
  x_num=12345;
  y_char='12345';
run;

proc sql;
  select *
  from dictionary.columns
  where libname='WORK'
        ;
quit;
options NOlabel;
proc sql;
  select *
  from dictionary.columns
  where libname='WORK'
        ;
quit;

proc sql NOprint;
  select type into :vartype
  from dictionary.columns
  where libname='WORK' and
        memname='ONE' and
        name='x_num'
        ;
quit;

data num2char;
  set one;
  if "&vartype"="num" then do;
    put '!!!found a numeric.  converting to character.';
    charval=put(x_num,5.);
  end;
run;

proc contents; run;
