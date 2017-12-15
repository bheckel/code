
/* By default, the delimiter to read input data records with list input is a
 * blank space. Both the DSD option and the DELIMITER= option affect how list
 * input handles delimiters. The DELIMITER= option specifies that the INPUT
 * statement use a character other than a blank as a delimiter for data values
 * that are read with list input. When the DSD option is in effect, the INPUT
 * statement uses a comma as the default delimiter.
 *
 * To read a value as missing between two consecutive delimiters, use the DSD
 * option. By default, the INPUT statement treats consecutive delimiters as a
 * unit. When you use DSD, the INPUT statement treats consecutive delimiters
 * separately. Therefore, a value that is missing between consecutive delimiters
 * is read as a missing value. To change the delimiter from a comma to another
 * value, use the DELIMITER= option.
 * 
 * For example, this DATA step program uses list input to read data that are
 * separated with commas. The second data line contains a missing value. Because
 * SAS allows consecutive delimiters with list input, the INPUT statement cannot
 * detect the missing value.
 */

data scores;
  infile datalines DELIMITER=',';
  input test1 test2 test3;
  datalines;
91,87,95
97,,92
,1,1
  ;
run;
title 'wrong';proc print data=_LAST_(obs=max) width=minimum; run;

data scores;
  infile datalines /*DELIMITER=','*/ DSD;
  input test1 test2 test3;
  datalines;
91,87,95
97,,92
,1,1
  ;
run;
title 'right';proc print data=_LAST_(obs=max) width=minimum; run;

data scores;
  infile datalines DLM='|' DSD;
  input test1 test2 test3;
  datalines;
91|87|95
97||92
|1|1
  ;
run;
title 'also right';proc print data=_LAST_(obs=max) width=minimum; run;
