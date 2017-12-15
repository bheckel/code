options ls=180;
/*
2009-02-18
I think this is what you're looking for.  I made the assumption that an -01 suffix would be applied when I concatenated batch and gsk id (to create the key).
 */
libname l '.';

 /* Manually copy paste colunns C-I */
filename PAR 'dis.csv';
data dis(drop=dummy:);
  infile PAR delimiter='09'x MISSOVER LRECL=32767 DSD;
  /*      C            D            E           F          G           H            I            */
  input batgsk :$40. dummy1 :$40. dummy2 :$40. tbl :$40. tstdt :$40. dummy3 :$40. stage :$40.;
  if tbl eq: 'Stage';
  ;
run;
proc sql;CREATE INDEX batgsk ON dis (batgsk);quit;
proc print data=_LAST_(obs=5) width=minimum; run;

 /* Manually copy paste colunns B-L after reformatting 1E+13 to Number in Excel */
filename CSV 'puc.csv';
data puc(drop=dummy:);
  length batgsk $40;
  infile CSV delimiter='09'x MISSOVER LRECL=32767 DSD;
  /*     B          C           D         E         F          G            H            I           J           K           L           */
  input matl :$40. prod :$40. batch :$40. po :$40. gsk :$40. dummy1 :$40. dummy2 :$40. dummy3 :$40. vend :$40. dummy4 :$40. gran :$40.;

  /* 40000594928 */
  if length(gsk) eq 11 then
    gsk = '0'||left(trim(gsk));

  /* build key */
  if batch ne '' and gsk ne '' then
    batgsk = left(trim(upcase(batch)))||'-'||left(trim(gsk))||'-01';
run;
proc sql;CREATE INDEX batgsk ON puc (batgsk);quit;
proc print data=_LAST_(obs=5) width=minimum; run;

data adhoc;
  merge dis puc;
  by batgsk;
  /* elim blank rows in input files */
  if batgsk ne '';
run;
proc print data=_LAST_(obs=50) width=minimum; run;

proc freq;run;

proc export data=adhoc OUTFILE= "adhoc_stageeval_query.csv" DBMS=CSV replace; run;

