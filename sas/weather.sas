%let zip=27709;
%let dates=2004/12/24-2005/01/23;

%let url=http://www.wunderground.com/history/zipcode/&zip/
     %substr(&dates,1,10)/CustomHistory.html
     ?dayend=%substr(&dates,20,2)
     %nrstr(%str(&)monthend)=%substr(&dates,17,2)
     %nrstr(%str(&)yearend)=%substr(&dates,12,4));

data Temperatures(keep=Date AvgTemp);
  length AvgTemp 8;
  infile %sysfunc(compress("&url")) url lrecl=6000 termstr=cr;
  input;
  i=index(_infile_,"/DailyHistory.html");
  if i;
  date=mdy(scan(substr(_infile_,1,i-1),-2,'/'),
         scan(substr(_infile_,1,i-1),-1,'/'),
         scan(substr(_infile_,1,i-1),-3,'/'));
  input ////;
  AvgTemp=scan(_infile_,3,'<>');
  if AvgTemp^=.;
run;


options nocenter nodate nonumber;
proc print;
  title Avg Daily Temps for Zip &zip;
  format Date yymmdd10.;
run;
