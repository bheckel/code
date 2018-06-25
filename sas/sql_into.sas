proc sql NOprint;
  connect to postgres as myconn(user=&user password=&password dsn="db6" readbuff=7000);

    select
      clientid
      into
        :clids separated by ','
    from connection to myconn(
      select distinct clientid
      from analytics.vtmmclient
      where locationstatusid=1
      ;
    );

  disconnect from myconn;
quit;
