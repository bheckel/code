options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: YCOUT2.sas
  *
  *  Summary: Determine all YC residents who died out of state.  Include vars
  *           based on dwj2 request.
  *
  *           This code differs from YCOUTST.sas in that it uses BF19, not
  *           MVDS.  Created after dwj2 reviewed the run produced by
  *           YCOUTST.sas
  *
  *
  *  Created: Fri 08 Apr 2005 13:58:04 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter NOreplace mlogic mprint sgen;

%include 'BQH0.PGM.LIB(TABDELIM)';

 /* Part I, gather latest BF19 filenames from Register. */
%macro ForEachYr(startyr, span);
  %local j;

  %let j=&startyr;

  %do %while ( &j lt %eval(&startyr+&span)  );
    libname L "/u/dwj2/register/MOR/200&j" DISP=SHR WAIT=10;

     /* Part I, build the dataset of filenames: */
    data tmp&j (keep= mergefile rename= mergefile=fn);
      set L.register;
      /* DEBUG toggle */
      ***if mergefile =: 'BF19.A';
      /* Luckily there are no FIPS states with dead YC residents so only have
       * to run this job once, using the old stres, etc. positions.
       */
      if revising_status not in ('N','F');
    run;

    libname L clear;

    proc append base=allfnames data=tmp&j; run;

    %let j=%eval(&j+1);
  %end;
%mend ForEachYr;
 /* E.g. 3 for 2003, 1 for single year loop: %ForEachYr(3, 1); */
%ForEachYr(3, 1);


 /* Part II, use the filenames dataset to read each filename's data into
  * a single dataset: 
  */
data alldata;
  set allfnames;
  length currinfile $50;

  infile TMPIN FILEVAR=fn FILENAME=currinfile TRUNCOVER END=e; 

  do while ( not e );
    input @47 alias $CHAR1.  @64 ageunit $CHAR1.  @65 age $CHAR2.
          @48 sex $CHAR1.  @95 race $CHAR1.  @166 raceboxes $CHAR15.
          @94 hisp $CHAR1.  @421 hispboxes $CHAR4.  @139 yob $CHAR4.
          @67 mob $CHAR2.  @69 dob $CHAR2.  @135 yod $CHAR4.
          @49 mod $CHAR2.  @51 dod $CHAR2.  @475 racebridge $CHAR2.
          @89 stres $CHAR2.  @91 cntyres $CHAR3.
 /***           @5 certno $CHAR6. ***/
          ;
    output;
  end;
run;

data tmp (keep= ageunit age sex race raceboxes hisp yob mob dob yod mod
                dod racebridge certno);
  set alldata;
  if alias eq '1' then 
    delete;

  if stres eq '33' and cntyres in ('010','011','053','077','087');

  label ageunit='Age Unit'
        age='Age' format=Z2.
        sex='Sex'
        race='Race'
        raceboxes='Multirace Boxes'
        hisp='Hispanic'
        yob='Year of Birth'
        mob='Month of Birth' format=Z2.
        dob='Day of Birth' format=Z2.
        yod='Year of Death'
        mod='Month of Death' format=Z2.
        dod='Day of Death' format=Z2.
        racebridge='Race Bridge' format=Z2.
        ;
run;
proc print data=tmp(obs=10000) label; run;


%Tabdelim(work.tmp, 'BQH0.TMPTRAN2');



  /* vim: foldmethod=marker: */ 
