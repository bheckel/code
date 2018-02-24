 
data header(drop=diag) diagnoses;
  infile cards;
  input record_id @;

  if record_id eq 1 then do;
    retain claim_id person_id claim_from_date;
    input @3 claim_id @5 person_id $5. @11 claim_from_date YYMMDD8.;
    output header;
  end;
  else if record_id eq 2 then do;
    /* retain claim_id record_id diag; */
    input @3 claim_id @5 diag $5.;
    output diagnoses;
  end;
  cards;
1 8 ABCDE 20180113 
2 8 DIABE
2 8 STATI
1 9 ABCDX 20180114 
2 9 DIABE
2 9 STATI
  ;
run;
title "header";proc print data=header width=minimum heading=H;run;title;
title "diagnoses";proc print data=diagnoses width=minimum heading=H;run;title;
/*
                                                               header                           14:48 Thursday, February 1, 2018   1

                                                                                   claim_
                                                 record_                person_     from_
                                          Obs       id      claim_id      id        date

                                           1        1           8        ABCDE      21197
                                           2        1           9        ABCDX      21198
                                                             diagnoses                          14:48 Thursday, February 1, 2018   2

                                                                               claim_
                                             record_                person_     from_
                                      Obs       id      claim_id      id        date     diag

                                       1        2           8        ABCDE      21197    DIABE
                                       2        2           8        ABCDE      21197    STATI
                                       3        2           9        ABCDX      21198    DIABE
                                       4        2           9        ABCDX      21198    STATI
*/
