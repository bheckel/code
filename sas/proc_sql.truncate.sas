
proc sql;
  connect to odbc (user=&user password=&ajsperpassword dsn='ajsper');

  execute (truncate myschem.atpapients) by odbc;
  disconnect from odbc;
quit;
