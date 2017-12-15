options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: dow_loop.sas
  *
  *  Summary: Do Whitlock loops.  A form of by-group processing w/o BY
  *
  *  Adapted: Mon 29 Jul 2013 13:47:25 (Bob Heckel--Dorfman BB13)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

 /* This group of obs has a boundary expressed by missings (or EOF) */
data t;
  do x = 9, 2, .A, 5, 7, .Z, 2;
    output;
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* Control-break processing */
data t2;
/***  put 'DEBUG before DoW ' _n_=;***/
  do _n_ = 1 by 1 until (nmiss(x) | e);
    set t end=e;
    xsum = sum(xsum, x);
  end;
  xmean = xsum/(_n_-1+e);
/***  put 'DEBUG after DoW ' _n_=;***/
  put (xsum xmean)(=4.2);
run;
