options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: preloadfmt_completetypes.sas
  *
  *  Summary: Demo of controlling procs with formats
  *
  *  Adapted: Fri 29 Jul 2016 09:58:34 (Bob Heckel--http://support.sas.com/resources/papers/proceedings15/2220-2015.pdf)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

proc format;
  value $type
    'SUV' = 'SUV'
    'Truck' = 'Truck'
    'Wagon' = 'Wagon'
    'Hybrid' = 'Hybrid'
  ;
run;

/*
The MEANS Procedure

                      Analysis Variable : MPG_City MPG (City)
 
            N
Type      Obs      N            Mean         Std Dev         Minimum         Maximum
------------------------------------------------------------------------------------
Hybrid      0      0               .               .               .               .

SUV        60     60      16.1000000       2.8206262      10.0000000      22.0000000

Truck      24     24      16.5000000       3.2302914      13.0000000      24.0000000

Wagon      30     30      21.1000000       4.2128703      15.0000000      31.0000000
------------------------------------------------------------------------------------
*/
proc means data=sashelp.cars(where=(type ne 'Hybrid')) COMPLETETYPES;
  format type $type.;
  class type / PRELOADFMT EXCLUSIVE;
  var MPG_City;
run;

/* Without EXCLUSIVE:
The MEANS Procedure

                      Analysis Variable : MPG_City MPG (City)
 
            N
Type      Obs      N            Mean         Std Dev         Minimum         Maximum
------------------------------------------------------------------------------------
Hybrid      0      0               .               .               .               .

SUV        60     60      16.1000000       2.8206262      10.0000000      22.0000000

Sedan     262    262      21.0839695       4.2345743      12.0000000      38.0000000

Sports     49     49      18.4081633       2.6686324      12.0000000      26.0000000

Truck      24     24      16.5000000       3.2302914      13.0000000      24.0000000

Wagon      30     30      21.1000000       4.2128703      15.0000000      31.0000000
------------------------------------------------------------------------------------
*/
