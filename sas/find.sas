 /* find() family improves index() family because they allow you to specify a starting position and use modifiers like i for ignore case */
data t;
  input s $10.;

  /* Find 1st position of substring xyz or XYZ */
  pos_first = find(s, 'xyz', 'i');
  /* Find 1st position of character x or X or y or Y or z or Z */
  pos_first_c = findc(s, 'xyz', 'i');

  pos_1stNA = notalpha(strip(s));
  pos_1stND = notdigit(strip(s));
  pos_1stNALN = notalnum(strip(s));

  countofsubstring = count(s, 'xyz', 'i');
  countofchars = countc(s, 'xyz', 'i');

  cards;
abczya1
123456
XYZ123
the.end
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
