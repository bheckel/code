 /*---------------------------------------------------------------------------
  *     Name: select.sas
  *
  *  Summary: Demo of using select.  CASE in other languages.
  *
  *           There is no fallthru feature, first one to match wins.
  * 
  *  Created: Thu 30 May 2002 17:35:41 (Bob Heckel)
  * Modified: Thu 10 Jun 2010 12:50:59 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options linesize=92 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace datastmtchk=allkeywords nocenter
	;

data _null_;
  Matl_Nbr='AGENER';

  select ( substr(Matl_Nbr,1,6) );
    when ('ADVAIR','AGENER') Matl_Nbr = '';
    otherwise;  /* essentially mandatory but won't error unless there is no match */
  end;
  put _all_;
run;



data work.numeric;
  input fname $1-10 lname $15-25 @30 storeno 2.;

  /* Not limited to a constant like C */
  select ( storeno );
    /* OK to break to a new line if the WHEN conditions become numerous */
    when ( 81,83, 12 ) delete;
    when ( 73 )        put 'okthen';
    when ( 10 )        storeno = 99;
    otherwise          put 'unk';
  end;

  datalines;
ann           becker         81
chris         dobson         81
earl          fisher         81
gary          howe           81
jack          keller         12
larry         moore          10
nancy         paul           12
rick          tenny          12
vic           watson         83
arnie         carlson        83
david         gelder         83
betty         johnson        73
karen         adams          73
  ;
run;



data work.character;
  input fname $1-10 lname $15-25 @30 storeno 2.;

  select ( fname );
    * OK to break to a new line if the WHEN conditions become numerous;
    when ( 'ann' ) delete;
    when ( 'chris' ) put 'hamster';
    otherwise put _ALL_;
  end;

  datalines;
ann           becker         81
chris         dobson         81
earl          fisher         81
gary          howe           81
  ;
run;
proc print; run;



data _null_;
  x=1;
  select;  /* "naked" select is less efficient in this example, better is SELECT ( x ) ... WHEN ( 1 ) ... */
    /* Cannot put something like VERIFY(foo, '123') between parens, must be 
     * a separate x=VERIFY(...) then ( x eq 0 ) ... 
     */
    when ( x eq 1 ) do;
      put '!!!1';
      put 'ok';
    end;
    when ( x eq 2 ) do;
      put '!!!2';
      put 'twok';
    end;
    otherwise
      put 'huh?';
  end;
run;



data _null_;
  select;
    when ( test in('AS_CI_0','AS_CI_1','AS_CI_2') ) sum012+result;
    when ( test in('AS_CI_3','AS_CI_4','AS_CI_5') ) sum345+result;
    when ( test in('AS_CI_6','AS_CI_7','AS_CI_F') ) sum67F+result;
    otherwise;
  end;
run;



data valtrex_productionANDanalytical(drop= _: );
  length source $100;
  set valtrex_productionANDanalytical(drop=InspectionLot rename=(source=_aisource));
  /* Assumption is that there will always be analytical source */
  select;
    when ( _aisource ne '' and _paasource ne '' and _fwsource ne '' ) source = left(trim(_aisource)) || ' / ' || left(trim(_paasource)) || ' / ' || left(trim(_fwsource));
    when ( _aisource ne '' and _paasource ne '' and _fwsource eq '' ) source = left(trim(_aisource)) || ' / ' || left(trim(_paasource));
    when ( _aisource ne '' and _paasource eq '' and _fwsource ne '' ) source = left(trim(_aisource)) || ' / ' || left(trim(_fwsource));
    when ( _aisource ne '' and _paasource eq '' and _fwsource eq '' ) source = left(trim(_aisource));
    otherwise source = 'N/A';
  end;
run;
