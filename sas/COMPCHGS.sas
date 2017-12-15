options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: COMPCHGS.sas
  *
  *  Summary: Compare two merged files and identify which records had a change
  *           for any of the mother's or father's information per Jenny J.
  *
  *  Created: Wed 18 Aug 2004 15:27:36 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter mlogic mprint sgen;

filename OLD  'BF19.OKX0309.NATMER';
filename NEW  'BF19.OKX0310.NATMER';
filename DIFS 'DWJ2.OKDIFFS.BYTE898.D19AUG04' LRECL=898 DISP=OLD;

%macro BuildDs(s);
  %local i f;

  %let i=1;
  %let f=%scan(&s, &i, ' '); 

  %do %while ( &f ne  );
    %let i=%eval(&i+1);
    data WORK.&f.raw;
      infile &f;
      /* Items that Jenny wants to check are moth* and fath* */
      input @1 block $CHAR898.  
            @3 certno $CHAR6. 
            @23 mothdobmm $CHAR2.  @25 mothdobdd $CHAR2.
            @228 mothdobyyyy $CHAR4.  @29 mothbplcst $CHAR2.
            @31 mothstres $CHAR2.  @44 mothrace $CHAR1.  
            @42 mothhisp $CHAR1.  @46 motheduc $CHAR2.  
            @60 marstat $CHAR1.  @36 fathdobmm $CHAR2.  
            @38 fathdobdd $CHAR2.  @232 fathdobyyyy $CHAR4.  
            @43 fathhisp $CHAR1.
            ;
    run;
    data WORK.&f;
      set WORK.&f.raw;
      length combined $35;
      /* Want to see if *any* of these items are different. */
      combined = certno||mothdobmm||mothdobdd||mothdobyyyy||mothbplcst||
                 mothstres||mothrace||mothhisp||motheduc||marstat||
                 fathdobmm||fathdobdd||fathdobyyyy||fathhisp
                 ;
    run;
    %let f=%scan(&s, &i, ' '); 
  %end;
%mend BuildDs;
%BuildDs(OLD NEW)


 /* Find the differences. */
data WORK.diffs;
  merge work.old (in=inold) work.new (in=innew);
  by combined;
  if not innew;
run;


data _NULL_;
  set WORK.diffs;
  file DIFS;
  put block;
run;
