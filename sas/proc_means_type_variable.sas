 /*----------------------------------------------------------------------------
  *     Name: proc_means_type_variable.sas
  *
  *  Summary: Sample of proc summary and proc means _TYPE_ automatic variable.
  *
  *  Adapted: Thu, 04 Nov 1999 14:27:13 (Bob Heckel-- Semicolon June 1999)
  * Modified: Tue 05 Aug 2014 10:37:04 (Bob Heckel)
  *----------------------------------------------------------------------------
  */

data work.demo;
  infile cards missover;
  input dept $  store $  city $  region $  sales;
  cards;
D161 A Raleigh North 10
D161 B Capebreton North 20
D162 C Richardson East 30
D163 D Atlanta East 40
;
run;

  /* NWAY only shows max _TYPE_, 15 here */
proc summary data=work.demo /*NWAY*/;
  var sales;  /* sum data we care about */
  class dept store city region;  /* summed up by these */
  output out=work.demo2 sum(sales)=totsales;
run;
proc print; run;
/*
All permutations of dept store city region:
Obs    dept    store      city      region    _TYPE_    _FREQ_    totsales
  1                                              0         4         100  
  2                                 East         1         2          70  
  3                                 North        1         2          30  
  4                     Atlanta                  2         1          40  
  5                     Capebret                 2         1          20  
  6                     Raleigh                  2         1          10  
  7                     Richards                 2         1          30  
  8                     Atlanta     East         3         1          40  
  9                     Capebret    North        3         1          20  
 10                     Raleigh     North        3         1          10  
 11                     Richards    East         3         1          30  
 12              A                               4         1          10  
 13              B                               4         1          20  
 14              C                               4         1          30  
 15              D                               4         1          40  
 16              A                  North        5         1          10  
 17              B                  North        5         1          20  
 18              C                  East         5         1          30  
 19              D                  East         5         1          40  
 20              A      Raleigh                  6         1          10  
 21              B      Capebret                 6         1          20  
 22              C      Richards                 6         1          30  
 23              D      Atlanta                  6         1          40  
 24              A      Raleigh     North        7         1          10  
 25              B      Capebret    North        7         1          20  
 26              C      Richards    East         7         1          30  
 27              D      Atlanta     East         7         1          40  
 28    D161                                      8         2          30  
 29    D162                                      8         1          30  
 30    D163                                      8         1          40  
 31    D161                         North        9         2          30  
 32    D162                         East         9         1          30  
 33    D163                         East         9         1          40  
 34    D161             Capebret                10         1          20  
 35    D161             Raleigh                 10         1          10  
 36    D162             Richards                10         1          30  
 37    D163             Atlanta                 10         1          40  
 38    D161             Capebret    North       11         1          20  
 39    D161             Raleigh     North       11         1          10  
 40    D162             Richards    East        11         1          30  
 41    D163             Atlanta     East        11         1          40  
 42    D161      A                              12         1          10  
 43    D161      B                              12         1          20  
 44    D162      C                              12         1          30  
 45    D163      D                              12         1          40  
 46    D161      A                  North       13         1          10  
 47    D161      B                  North       13         1          20  
 48    D162      C                  East        13         1          30  
 49    D163      D                  East        13         1          40  
 50    D161      A      Raleigh                 14         1          10  
 51    D161      B      Capebret                14         1          20  
 52    D162      C      Richards                14         1          30  
 53    D163      D      Atlanta                 14         1          40  
 54    D161      A      Raleigh     North       15         1          10  
 55    D161      B      Capebret    North       15         1          20  
 56    D162      C      Richards    East        15         1          30  
 57    D163      D      Atlanta     East        15         1          40  
*/


/* dept  store  city  region
 *  8      4      2      1       Binary base (Grandtotal is always 0).
 *
 * Therefore:
 *  8  +   4 = 12 on the Output is DEPT plus STORE
 *  8  +   4  +   2 = 14 on the Output is DEPT plus STORE plus CITY.
 */
title 'Where _TYPE_ equal 12 i.e. dept+store';
proc print;
  where _TYPE_ = 12;
run;

title 'Roll up the numbers at the region level and for depts within city';
proc print;
  where _TYPE_ in(1, 10);
run;


title 'Alternative to manually using _TYPE_s';
proc summary data=work.demo;
  types dept dept*store;
  var sales;
  class dept store city region;
  output out=work.demo2 sum(sales)=totsales;
run;
proc print; run;
/*
Obs    dept    store    city    region    _TYPE_    _FREQ_    totsales

 1     D161                                  8         2         30   
 2     D162                                  8         1         30   
 3     D163                                  8         1         40   
 4     D161      A                          12         1         10   
 5     D161      B                          12         1         20   
 6     D162      C                          12         1         30   
 7     D163      D                          12         1         40   
*/
