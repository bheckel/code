
data _null_;
  infile '!SASCFG\sasv8.cfg';
/***  infile '!SASROOT\sasnews.txt';***/
  input;
  put _infile_;
run;
