
filename CONN "junk";

data ;
  infile CONN DLM='=';
  input @'Initial Catalog=' db $CHAR9.  @'Data Source=' svr $CHAR11.;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

endsas;
Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=usprd1208;Data Source=zebsamoc007
