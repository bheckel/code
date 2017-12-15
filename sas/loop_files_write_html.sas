options source NOthreads NOcenter;

%let Y=2003;

libname THELIB "DWJ2.MED&Y..MVDS.LIBRARY" DISP=SHR;

data tmp (keep= mergefile rename= mergefile=fn);
  set THELIB.register;
  /* Skip states w/o any mergefiles submitted. */
  if mergefile ne '';
  /* DEBUG */
  ***if mergefile =: 'BF19.A';
run;
proc print; run;

libname THELIB clear;

data tmp;
  set tmp;
  length currinfile $50;
  label autopsy = 'Was Autopsy Performed?'
        findings = 'Were Autopsy Findings Available?'
        tobacco = 'Tobacco Use?'
        pregnancy = 'Pregnancy'
        timeinj = 'Time of Injury'
        timeinjunits = 'Time of Injury Units'
        certifier = 'Certifier'
        deathstate = 'State of Death'
        ;

  infile TMPIN FILEVAR=fn FILENAME=currinfile TRUNCOVER END=done; 

  do while ( not done );
    input @5 deathstate $CHAR2.  @317 autopsy $CHAR1.  @318 findings $CHAR1.  
          @319 tobacco $CHAR1.  @320 pregnancy $CHAR1.  @330 timeinj $CHAR4.  
          @335 certifier $CHAR29.
          ;
    ***f=fn;
    output;
  end;
  put '!!!finished reading ' currinfile=; 
run;

proc format;
  value $f_time '0000'-'2400' = '0000-2400'
                '9999'        = '9999'
                ;
run;
                

ods HTML body="/u/bqh0/public_html/bob/&Y.medmer.html" style=Brick;
title "Frequencies of New Medical Data Elements (&Y mergefiles)";
proc freq;
  format timeinj $f_time.;
  tables autopsy findings tobacco pregnancy timeinj certifier deathstate
                                             / NOCUM NOCOL NOROW NOPERCENT;
run;
ods HTML close;
