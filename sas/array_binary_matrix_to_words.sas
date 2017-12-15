options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: array_binary_matrix_to_words.sas
  *
  *  Summary: Demo of turning a binary 1/0 matrix into human words
  *
  *  Created: Tue 05 Aug 2014 09:12:26 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data t;
  input subjid saf itt oth;
  cards;
101     1     .     1
103     1     1     1
106     0     1     1
107     1     0     1
   ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


proc format;
  value myfmt
        1="Safety"
        2="Intent-to-Treat"
        3="Other"
        ;
run;

data t2;
  set t;
  by subjid;

  length words $28;  /* the 3 words and 2 slashes */

  /*           arr{1} arr{2} arr{3}    */
  array arr{*} saf    itt    oth;

  do i=1 to dim(arr);
    if words eq "" and arr{i} eq 1 then
      words=put(i, myfmt.);
    else if words^="" and arr{i} eq 1 then
      words = trim(words)||"/"||put(i, myfmt.);
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
