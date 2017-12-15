
data t;
  input race sex;
  cards;
3 1
2 1
3  
. 2
1 2
4 1
1 2
4 2
  ;
run;

data t;
  set t;

  /* b_ oolean: */

  b_white = (race eq 1);
  b_black = (race eq 3);
  /* Obfuscated version works - but don't use it */
  b_asian = race = 4;
  b_raceexists = not missing(race);

  b_female = (sex eq 1);
  b_male = (sex eq 2);
  b_sexexists = not missing(sex);

  /* l_ ogical: */

  l_asianfemale = (b_asian AND b_female);
  l_malenonwhite = (b_male AND (NOT b_white));
run;
proc print data=_LAST_(obs=max) width=minimum; run;


proc freq;
  tables sex * b_female / list missing;
run;
