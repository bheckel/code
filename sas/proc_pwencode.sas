
filename pwdfile '/mnt/nfs/home/bheckel/pwencode.txt';

proc pwencode in='mypw' out=pwdfile; run;

data _null_;
  infile pwdfile obs=1;
  input @1 password $40.;
  call symput('password', password);
  put password=;
run;

%put !!!&password;

proc sql;
  connect to odbc as myconn(user=bheckel password="&password" dsn=db);
  create table foo as select * from connection to myconn(
        select name from myschema.mytbl
  );
   disconnect from myconn;
quit;

