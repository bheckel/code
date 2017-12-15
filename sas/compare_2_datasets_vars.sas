
options mprint mautosource sasautos=('/Drugs/Macros', sasautos) ps=max ls=max nocenter sgen /*NOlabel*/;

%macro db6;
  libname l '.';

  %dbpassword;
    proc sql;
      connect to odbc as myconn (user=&user. password=&jasperpassword. dsn='db6' readbuff=7000);

      create table l.t as select * from connection to myconn (

        select distinct genericproductidentifier as gpi, outcomecode, roleoftherapycode, 'Y' as chronic
        from medispan.indgind
        where trim(leading '0' from roleoftherapycode) in ('1','3') 
              and trim(leading '0' from outcomecode) not in ('1')
        order by genericproductidentifier, outcomecode, roleoftherapycode
        ;

      );

      disconnect from myconn;
    quit;
    %put !!!&SQLRC &SQLOBS;
%mend;
/***%db6;***/


%macro compare;
  libname l '.';
  libname l2 '/Drugs/TMMEligibility/Delhaize/Imports/20160725/Data';

  title 'before';
  proc sql;
    select * 
    from l2.medispanchronic
    where gpi = '25150035101820'
    ;
  quit;

  title 'after';
  proc sql;
    select * 
    from l.t
    where gpi = '25150035101820'
    ;
  quit;


  proc sql;
    create table notonsas as
    select gpi, outcomecode, roleoftherapycode from l.t
    EXCEPT
    select gpi, outcomecode, roleoftherapycode from l2.medispanchronic
    ;
  quit;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;  

  proc sql;
    create table notondb as
    select gpi, outcomecode, roleoftherapycode from l2.medispanchronic
    EXCEPT
    select gpi, outcomecode, roleoftherapycode from l.t
    ;
  quit;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;  


  proc sql;
    create table ondbonly as
    select b.gpi as gpiold, b.outcomecode as outcomecodeold, b.roleoftherapycode as roleoftherapycodeold, a.gpi as gpinew, a.outcomecode as outcomecodenew, a.roleoftherapycode as roleoftherapycodenew
    from notonsas a left join notondb b on a.gpi=b.gpi
    ;
  quit;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;  

  proc sql;
    create table onsasonly as
    select b.gpi as gpiold, b.outcomecode as outcomecodeold, b.roleoftherapycode as roleoftherapycodeold, a.gpi as gpinew, a.outcomecode as outcomecodenew, a.roleoftherapycode as roleoftherapycodenew
    from notonsas a right join notondb b on a.gpi=b.gpi
    ;
  quit;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;  
  

  title 'final';
  data l2.compare_medispan_20160908;
    set ondbonly onsasonly;
  run;
  proc sort nodupkey;
    by gpinew gpiold outcomecodenew outcomecodeold roleoftherapycodenew roleoftherapycodeold ;
  run;
proc print data=_LAST_ width=minimum heading=H;run;title;  

%mend;
%compare;
