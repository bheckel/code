%macro get_clients;
  %global clids;

  proc sql noprint;
    connect to postgres as myconn(user=&user password=&password dsn="db6" readbuff=7000);

      select clientid into :clids separated by ' ' from connection to myconn(
        select distinct clientid from dshbrd.dashboardclients;
      );
    disconnect from myconn;
  quit;
%put &=clids;
%mend;
%get_clients;


%macro loop;
  %local i;
  %let i=1;
  %let clid=%scan(&clids, &i, ' ');
  %do %while ( &clid ne   );
    %let i=%eval(&i+1);
    %put !!!&=clid;
    %let clid=%scan(&clids, &i, ' ');
  %end;
%mend;
%loop;
