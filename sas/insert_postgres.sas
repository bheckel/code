
options sasautos=(SASAUTOS '/Drugs/Macros') ls=140 ps=max mprint mprintnest NOcenter validvarname=any; %dbpassword;

data t;
  infile cards dlm=',';
  input clid @@;
  cards;
17,22,55,56,123,137,142,186,187,188,189,190,192,193,201,209,314,329,424,434,445,449,589,605,606,615,623,636,648,650,651,654,656,657
662,663,668,683,684,686,689,690,691,699,702,704,754,755,756,757,758,760,761,762,764,768,769,797,805,825,829,833,834,841,847,857,879
880,882,884,895,902,909,924,931,935,939,941,950,952,953,958,963,964,965,968,969,970,1008,1010,1011,1012,1013,1015,1020,1021,1027,1033
1039,1041,1043,1048,1050,1056,1059,1060,1065,1068,1218,2,7
  ;
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;

libname jasper ODBC dsn='db6dev' schema='public' user=&user. password=&jasperpassword.;

proc sql;
  insert into jasper.dashboardclients ( clientid )
  select * from t;
quit;



libname jasper ODBC dsn='jaspertwa' schema='perfaudit' user=&user. password=&jasperpassword.;

proc sql;
  insert into jasper.walgreensreport1
    (  campaigncode,
      audience_id,
      patient_id,
      treatmentcode,
      planned_contact_date,
      rx_nbr,
      str_nbr,
      fill_sold_date,
      filldisp_nbr,
      filler_1,
      filler_2,
      filler_3,
      filler_4)
  select * from data.contactfile;
quit;
