 /*---------------------------------------------------------------------------
  *     Name: retain.sas (s/b symlinked as runningtotal.sas)
  *
  *           See also pdv.sas
  *
  *  Summary: A variable normally has missing values if it is not assigned 
  *           a value in the datastep.  With retain, a variable is assigned
  *           its value from the PREVIOUS iteration of the datastep.
  *
  *           May be confusing because 'retain' really means 'initialize once
  *           at compile-time'.
  *
  *           We will likely have to reset the var manually at some point
  *           since we've overridden the automatic reinitialization.
  *
  *           The RETAIN statement merely 'retains' the previous value until a
  *           'new value' is established - e.g. by a SET or INPUT statement.
  *           Even if that 'new value' is 'missing', it will still overwrite
  *           the value RETAINed from the previous iteration of the DATA step.
  *
  *           To 'carry forward' a value, it must be coded specifically, by
  *           doing the RETAINing on a variable which is NOT updated by a set
  *           or input, etc. statement.
  *
  *           Automatic SAS variables are not subject to this 'set to missing'
  *           behavior.
  *
  *           Can also be used to force ordering of vars in an output ds
  *           (could use FORMAT instead).
  *
  *  Adapted: Thu 11 Apr 2002 14:41:23 (Bob Heckel -- Little SAS Book sect 3.9)
  * Modified: Fri 13 Jul 2012 15:19:37 (Bob Heckel)
  *---------------------------------------------------------------------------
  */

data t;
  retain foo;  /* does not appear in t because it's not assigned a value */
  retain bar .;  /* does appear */
  retain baz; 
  set sashelp.shoes;

  if _N_ eq 3 then baz=42;  /* also 42 for 4, 5, 6... */
run;
proc print data=_LAST_(obs=9) width=minimum; run;


 /* Compare SUM statement with SUM function */
data t2;
  retain sumfunc;  /* this approach is useless unless you initialize with non-0 */
  set sashelp.shoes;

  sumfunc = sum(sumfunc, sales);
  /* better, same result */
  sumstmt+sales;
run;
proc print data=_LAST_(obs=9) width=minimum; run;

endsas;
data work.gamestats (drop= month day hits);
  ***infile 'c:\myrawdata\games.dat';
  infile cards;
  input month 1 day 3-4 team $ 6-25 hits 27-28 runs 30-31;
  /* We create the underscore variables, infile creates the others. */
  retain _maxruns;  /* only way to keep a running tot of the max */
  ***retain _maxruns 8;  /* could use this if you want the start to be 8 */
  /* Distributive (it's legal to use multiple retain statements) */
  retain _notused _notused2 66 _thisdoesntshowatall;
  _maxruns = max(_maxruns, runs);
  _runstodate + runs;  /* implied retain on _runstodate */
  cards;
6-19 columbia peaches      8  3  
6-20 columbia peaches     10  5  
6-23 plains peanuts        3  4  
6-24 plains peanuts        7  2  
6-25 plains peanuts       12  8  
6-30 gilroy garlics        4  4  
7-1  gilroy garlics        9  4  
7-4  sacramento tomatoes  15  9  
7-4  sacramento tomatoes  10 10  
7-5  sacramento tomatoes   2  3 
  ;
run;


data work.retire;
  input amount 1-5;
  /* _numyrs is optional here - it's auto-retained as a result of the SAS
   * idiom  _numyrs+1, but it would be mandatory if we used _numyrs=_numyrs+1 
   */
  retain _year 1986  _numyrs;
  ***year = year + 1;
  /* same */
  _year+1;
  _numyrs+1;
  runningtotal+amount;
  put (_all_)(=);
  cards;
500
165
.
1000
50
  ;
run;


data work.consecutive_losses;
  infile cards;
  input earnings yr @@;
  put 'debug: ' yr;

  /* Unnecessary - only diff is that the vars are ordered _cumearn _consec
   * instead of the default.
   */
  retain _cumearn _consec;

  if earnings < 0 then
    _consec + 1;
  else
    _consec = 0;

  ***_cumearn = _cumearn + earnings;
  /* Same */
  _cumearn + earnings;

  if _consec > 1 then
    output;
  else if _consec = 0 then
    _cumearn = 0;

  cards;
13 60 -5 61 -15 62 -2  63 16 64 18 65 0 66 -1 67 21 68 22 69
  ;
run;
proc print data=_LAST_(obs=max); run;
