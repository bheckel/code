options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_ds2.sas
  *
  *  Summary: Demo of DS2 language
  *
  *           INIT and TERM run once (at the beginning and the end of the DATA
  *           step, as their names imply), and RUN is executed once for each
  *           input row, just as a conventional DATA step does
  *
  *           proc ds2;
  *             data foo / overwrite=yes;
  *               dcl int x;
  *
  *               method INIT();
  *               end;
  *
  *               method RUN();
  *               end;
  *
  *               method TERM();
  *               end;
  *
  *             enddata;
  *           run; quit;
  *
  *  Adapted: Wed 17 Aug 2016 10:33:12 (Bob Heckel--http://support.sas.com/resources/papers/proceedings15/2523-2015.pdf 
  *                                                 http://blogs.sas.com/content/sastraining/2016/07/20/jedi-sas-tricks-explicit-sql-pass-through-in-ds2/)
  *                                                 https://www.sas.com/storefront/aux/en/spprocds2methods/68945_excerpt.pdf and others)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err ds2scond=error;

 /* ds2 can't access SASHELP */
proc copy inlib=sashelp outlib=work;
  select prdsale;
run;

data prdsale; set prdsale(obs=10); run;

proc ds2;
  data high(overwrite=yes) low(overwrite=yes);
    drop count;
    method run();

      /* TODO where monotonic() < 5 replacement?? */
      set {select  country
                  ,year
                  ,quarter
                  ,sum(actual) as actual
                  ,sum(predict) as predict
             from work.prdsale
             group by country,year,quarter};

      if actual lt 500 then output low;
      else output high;
    end;
  enddata;
  run;
quit;
title "prdsale";proc print data=prdsale width=minimum heading=H;run;title;
title "high";proc print data=high width=minimum heading=H;run;title;



proc ds2;
  data _null_;
    method init();
    end;

    method run();
      dcl varchar(16) str;
      dcl varchar(10) hos;
      dcl date mydt;
      str = 'Hello World!';
      /* fails, ds2 assumes it is a varname */
/***      hos = "i am on &SYSHOSTNAME";***/
      hos = %tslit(i am on &SYSHOSTNAME);
      mydt = date'2016-08-24';  /* date constant must be YYYY-MM-DD */

      put str hos mydt=;
    end;

    method term();
    end;
  enddata;
run; quit;


 /* Create a dataset */
proc ds2;
  data work.greetings /overwrite=yes;
    dcl char(100) message;
    dcl tinyint i;
    dcl date ds2ANSIdate;

    method init();
      message = 'Hello World!'; output;
      message = 'What''s new?'; output;
      /* fails, assumes it a var */
/***      message = "Good-bye World!"; output;***/
      message = 'Good-bye World!'; output;
      i = 1; output;
      ds2ANSIdate = to_date(1); output;  /* SAS epoch number */
    end;
  enddata;
run; quit;
title "&SYSDSN";proc print data=greetings(obs=10) width=minimum heading=H;run;title;



 /* Using embedded FedSQL.  Any ORDER BY should be outside the braces e.g. set {select * from sql13a}; by "X" "Y"; */
data one; set sashelp.shoes; run;
proc ds2;
  data t;
    dcl double s;
    method run();
      set {select * from one where region like 'A%'};
      s+1;
    end;
  enddata;
run; quit;
proc print data=t(obs=10) width=minimum heading=H;run;title;



 /* Can't read and write to the same dataset as in data step */
data one; set sashelp.class; s=1; run;
proc ds2;
  data temp_one;
     method run();
       set one;
       s = s*2;
     end;
  enddata;
run; quit;

proc fedsql;
  drop table one;
  alter table temp_one rename to one;
run; quit;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;



proc ds2;
/***  data _null_;***/
/***  data wtf(overwrite=yes);***/
  /* same (for DATA statement only)*/
  data wtf / overwrite=yes;
    declare int x;  /* global x in global scope */
    declare int y;  /* global y in global scope */
    declare decimal(10,2) z having label 'Test me' format comma6.2;

    method init();
      dcl int x;  /* local x in local scope */
      x = 5;      /* local x assigned 5 */
      y = 6;      /* global y assigned 6 */
      z = 12.349;
      put '0. in init() ' x= y=;
    end;

    method run();
      put '1. in run() ' x= y=;
      x = 1;  /* make local change to x */
      put '2. in run() ' x= y= z=;
    end;

    /* not mandatory */
    method term();
      put '3. done';
    end;

  enddata;
run; quit;
/*
0. in init()  x=5 y=6
1. in run()  x= y=6
2. in run()  x=1 y=6
*/
proc contents data=wtf; run;



data cars;set sashelp.cars;run;

 /* Fails - must pre-sort */
 /*
data new;
  set cars;
  by descending cylinders make model;
  if _n_=10 then stop;
run;
 */

 /* Succeeds without pre-sorting */
proc ds2;
  data;
    method run();
      set cars;
      by descending cylinders make model;
      if _n_=10 then stop;
    end;
  enddata;
run; quit;
 /* Need this if specify e.g. data t otherwise default prints to Log */
/***title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;***/



 /* Using packages */
%let NObs = 1000;
%let min = -40;
%let max = 40; 
proc DS2 scond=error;
  package range /overwrite=YES; 
    method getRange(integer min, integer max, double u) returns integer;
      return(min + floor((1+Max-Min)*u));
    end;
  endpackage;
run; quit;

proc DS2 scond=error; 
  data ds2DegC_4(keep=(degC) overwrite=YES) ds2AvgC_4(keep=(avgC) overwrite=YES);
    declare integer degC having label 'Temp in Celsius' format F3.;
    declare double avgC having label 'Average Temp in Celsius' format F5.2;
    declare integer min max nobs;
    declare double sum;
    declare package range r(); 

    retain sum nobs;

    method init();
      streaminit(12345);
      min = &min; max = &max;
      nobs = &NObs;
      sum = 0;
    end;

    method run();
     declare double u;
     declare int obs;
     do obs = 1 to nobs;
       u = rand('UNIFORM');
       degC = r.getRange(min, max, u); 
       output ds2DegC_4;
       sum = sum + degC;
     end;
    end;

    method term();
      avgC = sum / nobs;
      output ds2AvgC_4;
    end;
  enddata;
run; quit; 
title "ds2DegC_4";proc print data=ds2DegC_4(obs=10) width=minimum heading=H;run;title;
title "ds2AvgC_4";proc print data=ds2AvgC_4(obs=10) width=minimum heading=H;run;title;



 /* Using threads to read existing ds */
proc ds2;
  thread thr / overwrite=yes;
    method run();
      set ds2DegC_4;
    end;
  endthread;
run; quit;

proc DS2 scond=error; 
  data ds2DegF_6 (keep=(degC) overwrite=YES);
    declare double degF having label 'Temp in Fahrenheit' format F6.1;
    declare double sum u;
    declare integer cnt;
    declare package range range(); 
    declare thread thr thr_instance;

    retain sum cnt;

    method init();
      sum = 0;
      cnt = 0;
    end;

    method run();
      set from thr_instance threads=4;  /* 4 threads read the data */
      degF = range.getRange(1, 10, u); 
      sum = sum + degF;
      cnt = cnt + 1;
      output ds2DegF_6; 
    end;

  enddata;
run; quit; 
proc print data=ds2DegF_6(obs=9) width=minimum heading=H;run;title;



 /* Using methods */
proc ds2;
  data _null_;
    dcl int root1 result1;
    dcl decimal(6,2) root2;
    dcl decimal(8,4) result2;

    /* Declare function prior to use or use  FORWARD squareIt; */

    /* overloaded user-defined function */
    method squareIt(int value) returns int;
      return value**2;
    end;

    /* overloaded user-defined function */
    method squareIt(decimal(6,2) value) returns decimal(8,4);
      return value**2;
    end;

    /* overloaded user-defined function with IN_OUT parameter */
    method squareIt(int value, IN_OUT int square);
      square = value**2;
    end;

    /* system method */
    method INIT(); 
      root1 = 3.01;
      root2 = 3.01;
    end;

    /* system method */
    method RUN();
      result1 = squareIt(root1);
      put 'The square of INTEGER ' root1 ' is ' result1;

      result2 = squareIt(root2);
      put 'The square of DECIMAL ' root2 ' is ' result2;

      root1 = 4.99;
      squareIt(root1, result1);
      put 'The square of INTEGER ' root1 ' is ' result1;
    end;

    /* system method */
    method TERM();

      put _all_; /* final values of global variables */
    end;
  enddata;
run; quit;



options fullstimer;
libname l '/Drugs/TMMEligibility/Delhaize/Imports/20160725/Data';


/************ Base SAS method ****************/
proc sql;
  create table rxfilldata0 as
  select  a.*, coalesce(b.gpi,a.productid) as gpi, b.drugname
  from l.rxfilldata as a left join l.medispan as b on a.ndc=b.ndc_upc_hri;
quit;

/************** ds2 method *************/
proc ds2;
  thread thr / overwrite=yes;
    method run();
      set {
            select  a.*, coalesce(b.gpi,a.productid) as gx, b.drugname as dx
            from l.rxfilldata as a left join l.medispan as b on a.ndc=b.ndc_upc_hri
      };
    end;
  endthread;
run; quit;

proc ds2 scond=error;
  data rxfilldata0;
    declare thread thr thr_instance;

    method init();
    end;

    method run();
      set from thr_instance threads=4;
    end;
  enddata;
run; quit;

/********** comparison ***************/

/*                      DS2                                                                           proc sql

           real time           6:10.24                                      |           real time           24:56.85
           user cpu time       9:17.58                                      |           user cpu time       9:56.17
           system cpu time     4:05.26                                      |           system cpu time     17:53.78
           memory              974840.17k                                   |           memory              4199548.31k
           OS Memory           982496.00k                                   |           OS Memory           4201644.00k
           Timestamp           08/25/2016 08:11:18 AM                       |           Timestamp           08/25/2016 08:37:42 AM
           Step Count                        6  Switch Count  844           |           Step Count                        5  Switch Count  676
           Page Faults                       6                              |           Page Faults                       149
           Page Reclaims                     434840                         |           Page Reclaims                     1565064
           Page Swaps                        0                              |           Page Swaps                        0
           Voluntary Context Switches        5542096                        |           Voluntary Context Switches        14434218
           Involuntary Context Switches      521                            |           Involuntary Context Switches      6503
           Block Input Operations            8354208                        |           Block Input Operations            1331705440
           Block Output Operations           666950656                      |           Block Output Operations           2018776904
*/

