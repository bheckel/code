
proc sql noprint;
  connect to postgres as myconn(user=&user password=&password dsn="db6dev" readbuff=7000);

    select etllog_done into :_return from connection to myconn(
      select 1 as etllog_done from analytics.tmmstore limit 1;
    );
  disconnect from myconn;
quit;


proc sql NOprint;
  connect to postgres as myconn(user=&user password=&password dsn="db6dev" readbuff=7000);

    create table build as select * from connection to myconn(
      select *
      from analytics.build
      where clientid = &clid
      ;
    );
  disconnect from myconn;
quit;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;


proc sql NOprint;
  connect to postgres as myconn(user=&user password=&password dsn="db6dev" readbuff=7000);

    select
      put(datepart(lastbuild), DATE.),
      datamonthsback,
      mindrugs,
      ifc(usecap eq '0', 'N', 'Y'),
      numcap,
      importdelay,
      removeinvalidpatients,
      minage
      into
        :lastbuild_date TRIMMED,
        :months TRIMMED,
        :mindrugs TRIMMED,
        :cap TRIMMED,
        :numcap TRIMMED,
        :import_delay_days TRIMMED,
        :rm_enrolled TRIMMED,
        :minage TRIMMED,
        :el_file TRIMMED
    from connection to myconn(
      select lastbuild, datamonthsback, mindrugs, usecap, numcap, importdelay, removeinvalidpatients, minage
      from analytics.buildconfig
      where clientid = &clid
      ;
    );

  disconnect from myconn;
quit;
%put !!!wtf; %put _user_;
