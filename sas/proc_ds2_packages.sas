options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_ds2_packages.sas
  *
  *  Summary: Demo of ds2 packages
  *
  *  Adapted: Thu 24 Aug 2017 15:14:56 (Bob Heckel--http://www.notecolon.info/2013/02/note-ds2-threaded-processing.html)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

proc ds2;
  package pythagorus/overwrite=yes;
    method gethyp(double a, double b)
                 returns double;
      a_sq = a**2;
      b_sq = b**2;
      return sqrt(a_sq + b_sq);
    end;
    method getside(double hyp, double sidea)
                  returns double;
      return sqrt(hyp**2 - sidea**2);
    end;
  endpackage;
  run;


  data demo(overwrite=yes);
    method init();
      short=3; long=4; hyp=.; output;
      short=4; long=5; hyp=.; output;
      short=.; long=4; hyp=5; output;
      short=3; long=.; hyp=5; output;
    end;
  enddata;
  run;


  data results(overwrite=yes);
    dcl package pythagorus pyth();

    method run();
      set demo;
      select;
        when (missing(hyp))
          hyp=pyth.gethyp(short,long);
        when (missing(short))
          short=pyth.getside(hyp,long);
        when (missing(long))
          long=pyth.getside(hyp,short);
      end;
    end;
  enddata;
  run;
quit;
proc print data=demo width=minimum heading=H;run;title;
proc print data=results width=minimum heading=H;run;title;
