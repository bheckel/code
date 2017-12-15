options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: iorc.sas
  *
  *  Summary: Demo of finding a match for every combination.  Many-to-many.
  *
  *           The _IORC_ variable is created when you use the MODIFY statement
  *           or when you use the SET statement with the KEY= option. 
  *
  *           Value of _IORC_ is a numeric return code that indicates the
  *           status of the most recent I/O operation performed on an obs.
  *           Success is 0, EOF error is -1 and all others indicate non-match.
  *
  *           See also merge_fast.sas
  *
  *  Adapted: Sat 14 Jan 2006 19:28:08 (Bob Heckel -- Combining and Modifying)
  * Modified: Wed 31 Jul 2013 11:12:52 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data sales;
  input product salesrep $ ordernum $;
  cards;
310 Polanski  RAL5447
310 Alvarez   CH1443
312 Corrigan  DUR5523
313 Corrigan  DUR5524
313 Polanski  RAL5498
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

data stock(index=(product));
  input product prdtdesc $ 10-29 piece pcdesc $ 45-54;
  cards;
310      oak pedestal table         310.01  tabletop
310      oak pedestal table         310.02  pedestal
310      oak pedestal table         310.03  2 leaves
312      brass floor lamp           312.01  lamp base
312      brass floor lamp           312.02  lamp shade
313      oak bookcase, short        313.01  bookcase
313      oak bookcase, short        313.02  2 shelves
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

data shiplist(drop=dummy);
  set sales;
  by product;
  dummy=0;
  do until(_IORC_=%sysrc(_DSENOM));
     if dummy then product=99999;
     set stock key=product;
     select (_IORC_);
        when (%sysrc(_SOK))  /* _IORC_ is 0 */
          output;
        when (%sysrc(_DSENOM))
          do;
            _error_=0;
            if not last.product and not dummy then
              do;
                dummy=1;
                _IORC_=0;
               end;
           end;
        otherwise
          do;
            put 'Unexpected ERROR: _IORC_ =  ' _IORC_;
            stop;
          end;
     end;
  end;
run;
 /* 2 sales 310s x 3 stock 310s = 6 in the print output */
title '_IORC_'; proc print data=_LAST_(obs=max); run;


title 'same - standard proc sql inner join';
proc sql;
  select monotonic() as obs, *
  from sales a, stock b
  where a.product=b.product
  ;
quit;


 /* Produces "NOTE: MERGE statement has more than one data set with repeats of BY values." */
data t;
  merge sales stock;
  by product;
run;
title 'standard SAS merge-does not give all combinations'; proc print data=_LAST_(obs=max); run;
