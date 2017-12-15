
ods xml body='junk.xml';
/* To eliminate the "The Proc Contents Procedure" title from the html. */
ods NOptitle;
  proc print data=l.ven200_analytical_individuals(obs=100);
    var mfg_batch result;
  run;
ods xml close;
