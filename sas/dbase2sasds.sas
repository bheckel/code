libname currdir "tmp";
proc import out=currdir.dbftemp 
  datafile="NCHSFT01.DBF" 
  DBMS=DBF REPLACE;
  getdeleted=NO;
run;
