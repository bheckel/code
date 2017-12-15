%macro ip21_0001;
  %put !!!in ip21_0001;
  %put !!!received &DESCRIPTION and other xml elements;
%mend;

%macro m;
  libname xlib XML 'DataLinkSQLPlusWSAdapterCon.xml';
  data t;
    set xlib.DataLinkSQLPlusWSAdapterCon; 
    file LOG;
    put "!!!========"; put (_ALL_)(=); put;
  run;

  proc contents data=t out=tout; run;
  proc sql NOprint;
    select name into :vnms separated by ' '
    from tout
    ;
  quit;
  %put !!!&vnms;

  data _NULL_;
    set t;
    %let i=1;
    %do %until (%qscan(&vnms, &i)=  );
      %let f=%qscan(&vnms, &i);
      call symput("&f",&f);
      %let i=%eval(&i+1);
    %end;
    s1='%'||connectionID;
    call execute(s1);
  run;
%mend;
%m;



endsas;
<?xml version="1.0" encoding="UTF-8"?>
<Configuration>
  <DataLinkSQLPlusWSAdapterCon>
    <ConnectionID>ip21_0001</ConnectionID>
    <Description>IP21 via websvc RTPSAMOC004</Description>
    <ConnectionString>
      <![CDATA[
      http://RTPSAMOC004/SQLPlusWebService/sqlpluswebservice.asmx
      ]]>
    </ConnectionString>
    <useNTLM>0</useNTLM>
    <Domain>us1_auth</Domain>
    <Username>rsh86800</Username>
    <Password>ntbassb8</Password>
    <Opt1></Opt1>
    <Opt2></Opt2>
    <Opt3></Opt3>
    <Opt4></Opt4>
    <Opt5></Opt5>
    <Enabled>1</Enabled>
  </DataLinkSQLPlusWSAdapterCon>
</Configuration>
