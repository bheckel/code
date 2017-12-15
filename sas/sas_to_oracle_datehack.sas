 /* SAS to Oracle date hack */
%let daysback = 14;
data _null_;
  x=put(date()-&daysback,date.);
  y="'"||substr(x,1,2)||'-'||substr(x,3,3)||'-'||substr(x,6,2)||' 00:00:00'||"'";
  put y=;
  call symput('STARTDT', y);
run; 

PROC SQL feedback;
  CONNECT TO ORACLE(USER=pks ORAPW=dev123dba PATH=usdev388);
    CREATE TABLE foo AS SELECT * FROM CONNECTION TO ORACLE (
      SELECT activity_dt, patron_id
      FROM activity_log
      WHERE activity_dt > to_date(&STARTDT, 'DD-MON-YY HH24:MI:SS')
    );
  DISCONNECT FROM ORACLE;
QUIT;

%put &SQLXMSG;
%put &SQLXRC;
%let HSQLXRC = &SQLXRC;
%let HSQLXMSG = &SQLXMSG;
proc print data=_LAST_(obs=max); run;
