 /* see also pdv.sas and ~/code/sas/locf.sas */

data _null_;
  put "PDV1 before: " _all_;  /* printout PDV */
  input x;
  put "PDV1 after:  " _all_;
  cards;
1
2
3
  ;
run;


data _null_;
  retain x;
  put "PDV2 before: " _all_;
  input x;
  put "PDV2 after:  " _all_;
  cards;
1
2
3
  ;
run;


 /* Implied auto retain */
data _null_;
  put "PDV3 before: " _all_;
  input x;
  x+10;
  put "PDV3 after:  " _all_;
  cards;
1
2
3
  ;
run;


data _null_;
  /* retain _all_; */  /* doesn't matter */
  put "PDV4 before: " _all_;  /* printout PDV */
  set sashelp.class(obs=2);
  put "PDV4 after:  " _all_;
  ;
run;
