
 /* Messy */
data _null_;
  /* Convert current SAS datetime to Oracle datetime format */
  x=put(datetime(), datetime.);
  call symput('ORANOW', "'"||substr(x,1,2)||'-'||substr(x,3,3)||'-'||substr(x,6,2)||" "||substr(x,9,8)||"'");
run;


proc format;
  picture oradtt other='%0d-%b-%0y %0H:%0M:%0S' (datatype=datetime);
run;

 /* Cleaner */
data _null_;
  x=put(datetime(), oradtt.);
  call symput('ORANOW2', x);
run;

 /* Other */
data _null_;
  call symput('IP21START', "'"||trim(left(put(datetime(), oradtt.)))||"'");
run;

 /* Best */
data _null_;
  call symput('ORANOW3', put(datetime(), oradtt.));
run;

data _null_;
  call symput('YESTERDAY', put(datetime()-(24*60*60), oradtt.));
run;
%put _all_;



endsas;

PROC SQL feedback;
  CONNECT TO ORACLE(USER=&oraid ORAPW=&orapw PATH=&orapath);
    EXECUTE (
      update retain.fnsh_prod 
      set prod_sel = 'Y', prod_sel_dt = TO_DATE(&ORANOW, 'DDMONYY:HH24:MI:SS')
      where fnsh_prod_id_nbr = '56768'
  ) BY ORACLE;
  DISCONNECT FROM ORACLE;
QUIT;
 /* File will hold a single '0' on success */
data _null_;
  file ORARC;
  put "&SQLXRC";                                           
  put "&SQLXMSG";                                           
run;                                                    


endsas;
%let daysback = 14;
data _null_;
  x=put(datetime()-&daysback,datetime.);
  /* 05JUN07:09:42:49 */
  y="'"||substr(x,1,2)||'-'||substr(x,3,3)||'-'||substr(x,6,2)||" "||substr(x,9,8)||"'";
  put y=;
  call symput('STARTDT', y);
run; 
%put _all_;

data _null_;
  x=put(date()-&daysback,date.);
  y="'"||substr(x,1,2)||'-'||substr(x,3,3)||'-'||substr(x,6,2)||' 00:00:00'||"'";
  put y=;
  call symput('STARTDT', y);
run; 
