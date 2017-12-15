 /* see also is_num.sas */

data one;
  x_num=12345;
  y_char='12345';
run;

proc sql;
  select type into : vartype
  from dictionary.columns
  where libname='WORK' and
        memname='ONE' and
        name='y_char';
quit;

data char2num;
   set one;
   if "&vartype"="char" then numval=input(y_char,5.);
run;

proc print data=char2num;
  title 'CHAR2NUM';
run;

proc contents; run;
