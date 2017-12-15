
data ci_ind;
  length test $14;
  format test_date DATE9.;
  set tmp_ci_ind_&strength(drop=ACQDATETIME_);

  /* Handle this format:  June 05 2008 9:03:06 PM - convert to SAS date */

  /* Month array character */
  array mon(12) $9 _TEMPORARY_ ('JANUARY' 'FEBRUARY' 'MARCH' 'APRIL' 'MAY' 'JUNE' 'JULY' 'AUGUST' 'SEPTEMBER' 'OCTOBER' 'NOVEMBER' 'DECEMBER');
  /* Month array numeric */
  array num(12) _TEMPORARY_ (1 2 3 4 5 6 7 8 9 10 11 12);
  do i=1 to dim(mon);
    if scan(upcase(ACQDATETIME_),1) eq mon(i) then do;
      numericmo = num(i);
    end;
  end;
  test_date = mdy(numericmo, scan(ACQDATETIME_,2), scan(ACQDATETIME_,3));
  put numericmo= test_date=;
run;
