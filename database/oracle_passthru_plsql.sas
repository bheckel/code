
%mkcgen;
options mprint nomlogic nosource nosource2 notes mprintnest sgen ls=max NOlabel NOcenter;
%let server=mkcr62c.na.as.com;
signon server.8111 noscript;
rsubmit;
  
  proc sql;
    connect to Oracle (user='SETARS' password="XXXXX" path='RNDBDRW01');
     execute (
        declare
           v_count NUMBER;
        begin
           select count(*) into v_count from user_tables where table_name = 'T2';

           if v_count > 0 then
              execute immediate 'drop table T2';
           end if;
        end;
     ) by oracle;
     disconnect from Oracle;
  quit;

endrsubmit;
signoff noscript;
