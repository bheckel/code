/* Modified: 01-Jun-2021 (Bob Heckel) */

/* Encrypt passwords e.g. {SAS002}ED6FAA563258C85D4A133510 */

filename pwdfile 'c:/temp/pwencode.txt';

proc pwencode in='mypassword_to_be_encrypted' out=pwdfile; run;

data _null_;
  infile pwdfile obs=1;
  input @1 password $40.;
  call symput('password', password);
  put password=;
run;

%put !!!&password;

endsas;
proc sql;
  connect to odbc as myconn(user=bheckel password="&password" dsn=db);
  create table foo as select * from connection to myconn(
        select name from myschema.mytbl
  );
   disconnect from myconn;
quit;

