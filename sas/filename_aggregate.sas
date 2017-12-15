
 /* Mostly useless */
filename tdir 'c:\temp';
data t;
  infile tdir('_WSB21production.con.txt');
  /* Not possible: */
  /***  infile tdir(junk1 junk2);***/
  input a $;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


 /* Useful, concatenated */
filename tdir2 (
  'c:/temp/_WSB21production.con.txt'
  'c:/temp/_WSB21production.qry.txt'
  'c:/temp/_WSIP21production.*'
);

data t;
  infile tdir2;
  input a $;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
