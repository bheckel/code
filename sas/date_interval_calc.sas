
data _null_;
  dateofbirth='20oct1965'd;
  roundedage = int((intck('YEAR', today(), dateofbirth)))*-1;
  put roundedage=;

  fractionalage = yrdif(dateofbirth, today());
  put fractionalage=;

  daycnt = datdif('01oct16'd,'04oct16'd, '30/360');
  put daycnt=;
run;
