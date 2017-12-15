options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: input_linehold_trailing_atsign.sas
  *
  *  Summary: Make multiple obs from a single raw record
  *
  *   @@ holds a record across multiple iterations of the DATA Step to allow
  *   reading multiple obs from a single line of raw data.  A single INPUT
  *   statement exists in data step.  Releases when the end of the raw RECORD
  *   is reached or an @[@]-less INPUT statement is encountered.
  *
  *   @  holds record in input buffer so that logic can be used to figure out
  *   which (following, but in same data step) INPUT statement to use.  More
  *   than one INPUT statement always exists in data step.  Releases when
  *   control returns to top of data step.
  *
  *  Created: Tue 31 Mar 2008 14:01:31 (Bob Heckel)
  * Modified: Thu 30 Nov 2017 10:41:16 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;


data t;
  input clid @@;
  cards;
17 22 55 56 123 137 142 186 187 188 189 190 192 193 201 209 314 329 424 434 445 449 589 605 606 615 623 636 648 650 651 654 656 657 
662 663 668 683 684 686 689 690 691 699 702 704 754 755 756 757 758 760 761 762 764 768 769 797 805 825 829 833 834 841 847 857 879  
880 882 884 895 902 909 924 931 935 939 941 950 952 953 958 963 964 965 968 969 970 1008 1010 1011 1012 1013 1015 1020 1021 1027 1033  
1039 1041 1043 1048 1050 1056 1059 1060 1065 1068 1218 2 7
  ;
run;

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



 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
 /* Canonical @@ - read repeating blocks of raw data */
data doubletrailingAT;
  infile CARDS;  /* do not use MISSOVER for @@, only for @ ! */
  input mydt :DATE. hitemp  @@;
  cards;
01APR90 67 03APR90 70 31DEC09 01
05APR90 88 09APR90 89 29DEC09 02
01JUN10 90 09APR90 99 30DEC09 03
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*
Obs     mydt    hitemp

 1     11048      67  
 2     11050      70  
 3     18262       1  
 4     11052      88  
 5     11056      89  
 6     18260       2  
 7     18414      90  
 8     11056      99  
 9     18261       3  
 */



data only1var;
  input Size $  @@;  /* multiple executions of this INPUT statement per raw record */
  datalines;  /* @@ releases only when input pointer moves past end of record */
medium    LARGE1
large     LARGE2
large     MEDIUM3
medium    SMALL4
small     MEDIUM5
;
run;  /* <---end of data step does NOT mean we're done with that raw record (as it does with "@") */
proc print data=_LAST_(obs=max); run;
/*
Obs     Size

  1    medium 
  2    LARGE1 
  3    large  
  4    LARGE2 
  5    large  
  6    MEDIUM3
  7    medium 
  8    SMALL4 
  9    small  
 10    MEDIUM5
 */
 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/



 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
 /* Canonical @ read repeating blocks of data with an ID (store in this case) */

data singletrailingAT;
  input idnum @;
  do i=1 to 5;
     input part @;
     output;
     end;
  drop i;
  datalines;
22 287 265 248 263 271
23 267 253 285 251 271
24 249 252 277 269 241
41 243 241 245 263 248
  ;
run;
/*
Obs    idnum      part

  1      22        287  
  2      22        265  
  3      22        248  
  4      22        263  
  5      22        271  
  6      23        267  
  7      23        253  
  8      23        285  
  9      23        251  
 10      23        271  
 11      24        249  
 12      24        252  
 ...
*/



data t;
  infile CARDS MISSOVER;  /* MISSOVER is important here even when no missings! */
  input store $  sales :COMMA.  @;
  mo=0;
  put 'PDV viewer:';
  put '!!!1. ' _all_;
  do while (sales ne .);
    mo+1;
    output;
    input sales :COMMA. @;
    put '   2. ' _all_;
  end;
  put '3. ' _all_;  /* sales is always '.' here */
  cards;
1001 77,163,19 76,804.75 74,384.27
1002 76,612,93 81,456.34 82,063.97
1003 82,185.16 79,422.33 12,345.67
 ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*
Obs    store       sales      mo

 1     1001     7716319.00     1
 2     1001       76804.75     2
 3     1001       74384.27     3
 4     1002     7661293.00     1
 5     1002       81456.34     2
 6     1002       82063.97     3
 7     1003       82185.16     1
 8     1003       79422.33     2
 9     1003       12345.67     3
*/



 /***** ID followed by same # of repeating fields (3 in this case) *****/
 /* Read in horizontal data (usually with an id), store vertically */
data singletrailingAT; 
  infile CARDS MISSOVER;  /* MISSOVER is important here even when no missings! */
  input type $ @; 
  do period=1 to 3; 
    input stemleng  bucks :COMMA.  @; 
    output; 
  end;  /* <---control returns to top of DO, NOT top of data step, so hold line */
  cards; 
 clarion  32.7 1,234 32.3 2,234 31.5 9,876
 clinton  32.1 3,234 29.7 $4,234 29.1 8,876
 webster  32.5 5,234.99 31.1 6,234
 ; 
run;  /* <---control returns to top of data step for @, so release line, reset all vars to missing */
proc print data=_LAST_(obs=max); run;
/*
Obs     type     period    stemleng     bucks

 1     clarion     1         32.7       1234.00
 2     clarion     2         32.3       2234.00
 3     clarion     3         31.5       9876.00
 4     clinton     1         32.1       3234.00
 5     clinton     2         29.7       4234.00
 6     clinton     3         29.1       8876.00
 7     webster     1         32.5       5234.99
 8     webster     2         31.1       6234.00
 9     webster     3         29.7       7876.00
*/


 /***** ID(s) followed by varying # of repeating fields *****/
 /* If data is jagged, not just containing a few missings, and you don't know period will be 1 to 3, need a DO WHILE (...) */
data singletrailingAT; 
  infile CARDS MISSOVER;  /* MISSOVER is important here even when no missings! */
  input type $  stemleng  bucks :COMMA.  @; 
  period=0;
  do while (stemleng ne . and bucks ne .);
    period+1;
    output; 
    input stemleng  bucks :COMMA.  @; 
  end;  /* <--control returns to top of DO, not top of data step, so hold line */
  cards; 
 clarion  32.7 1,234 32.3 2234 31.5 9,876
 clinton  32.1 3,234 29.7 $4,234 29.1 8,876 55.5 1,9876 66.6 2,9876
 webster  32.5 5,234.99 31.1 6,234
 ; 
run;  /* <--control returns to top of data step for @, so release line, reset all vars to missing */
proc print data=_LAST_(obs=max); run;
/*
Obs     type      stemleng      bucks     period

  1    clarion      32.7       1234.00       1  
  2    clarion      32.3       2234.00       2  
  3    clarion      31.5       9876.00       3  
  4    clinton      32.1       3234.00       1  
  5    clinton      29.7       4234.00       2  
  6    clinton      29.1       8876.00       3  
  7    clinton      55.5      19876.00       4  
  8    clinton      66.6      29876.00       5  
  9    webster      32.5       5234.99       1  
 10    webster      31.1       6234.00       2  
*/

 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
