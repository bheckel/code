options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sum_multiple_obs_by.sas
  *
  *  Summary: Compress multiple rows down to one and calculate min max average.
  *
  *  Created: Fri 08 May 2009 12:36:52 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

proc sort data=tmp; by sprodname sbatchnbr sitemname;run;

data tmp(drop= rvaluex nItemID DTSPLTAKENTIME i RVALUE:);
  retain mini maxi;
  set tmp;
  by sbatchnbr sitemname;

  if first.sitemname then do;
    i=0;
    rvaluex=0;
  end;

  i+1;

  mini = min(mini, rvalue1);
  maxi = max(maxi, rvalue1);
  mini = min(mini, rvalue2);
  maxi = max(maxi, rvalue2);
  mini = min(mini, rvalue3);
  maxi = max(maxi, rvalue3);
  mini = min(mini, rvalue4);
  maxi = max(maxi, rvalue4);
  mini = min(mini, rvalue5);
  maxi = max(maxi, rvalue5);

  rvaluex+rvalue1;
  rvaluex+rvalue2;
  rvaluex+rvalue3;
  rvaluex+rvalue4;
  rvaluex+rvalue5;

  if last.sitemname then do;
    rvAvg = rvaluex/(i*5);
    output;
    mini = .;
    maxi = .;
  end;
  put _all_;
run;

endsas;
input data looks something like this:

Obs    NITEMID    RVALUE5    RVALUE4    RVALUE3    RVALUE2    RVALUE1             DTSPLTAKENTIME               SITEMNAME             SPRODNAME                SBATCHNBR

  1      575         8.8        8.6        8.4        8.3          8     2009-05-05T13:41:15.0000000-04:00    Hardness-10     Avandaryl 4mg/1mg ROW/US    Avandaryl all_Test
  2      575        10.5         10        9.5          9        8.9     2009-05-05T13:41:15.0000000-04:00    Hardness-10     Avandaryl 4mg/1mg ROW/US    Avandaryl all_Test
  3      574        3.89       3.88       3.65       3.69       3.66     2009-05-05T13:41:15.0000000-04:00    Thickness-10    Avandaryl 4mg/1mg ROW/US    Avandaryl all_Test
  4      574           4        4.5        3.6       3.53        3.4     2009-05-05T13:41:15.0000000-04:00    Thickness-10    Avandaryl 4mg/1mg ROW/US    Avandaryl all_Test
  5      573       200.6      200.5      200.3      200.1        200     2009-05-05T13:41:15.0000000-04:00    Weight-10       Avandaryl 4mg/1mg ROW/US    Avandaryl all_Test
  6      573       204.3      203.9      203.6        203      201.3     2009-05-05T13:41:15.0000000-04:00    Weight-10       Avandaryl 4mg/1mg ROW/US    Avandaryl all_Test
  7      573       200.5      200.4      200.3      200.2      200.1     2009-05-05T13:50:41.0000000-04:00    Weight-10       Avandaryl 4mg/1mg ROW/US    Avandaryl all_Test
  8      573         200      200.9      200.8      200.7      200.6     2009-05-05T13:50:41.0000000-04:00    Weight-10       Avandaryl 4mg/1mg ROW/US    Avandaryl all_Test
  9      574        3.85       3.84       3.83       3.82       3.81     2009-05-05T13:50:41.0000000-04:00    Thickness-10    Avandaryl 4mg/1mg ROW/US    Avandaryl all_Test
 10      574         3.9       3.89       3.88       3.87       3.86     2009-05-05T13:50:41.0000000-04:00    Thickness-10    Avandaryl 4mg/1mg ROW/US    Avandaryl all_Test
 11      575          10        9.5          9        8.5          8     2009-05-05T13:50:41.0000000-04:00    Hardness-10     Avandaryl 4mg/1mg ROW/US    Avandaryl all_Test
 12      575         7.5         12       11.5         11       10.5     2009-05-05T13:50:41.0000000-04:00    Hardness-10     Avandaryl 4mg/1mg ROW/US    Avandaryl all_Test
 13      575         7.5        7.6        7.7        7.8        7.9     2009-05-05T13:58:49.0000000-04:00    Hardness-10     Avandaryl 4mg/1mg ROW/US    Avandaryl all_Test
 14      575           7        7.1        7.2        7.3        7.4     2009-05-05T13:58:49.0000000-04:00    Hardness-10     Avandaryl 4mg/1mg ROW/US    Avandaryl all_Test
 15      574        3.75       3.74       3.73       3.72       3.71     2009-05-05T13:58:49.0000000-04:00    Thickness-10    Avandaryl 4mg/1mg ROW/US    Avandaryl all_Test
 16      574        3.79       3.78       3.77       3.76       3.75     2009-05-05T13:58:49.0000000-04:00    Thickness-10    Avandaryl 4mg/1mg ROW/US    Avandaryl all_Test
 17      573       199.5      199.4      199.3      199.2      199.1     2009-05-05T13:58:49.0000000-04:00    Weight-10       Avandaryl 4mg/1mg ROW/US    Avandaryl all_Test
 18      573         200      199.9      199.8      199.7      199.6     2009-05-05T13:58:49.0000000-04:00    Weight-10       Avandaryl 4mg/1mg ROW/US    Avandaryl all_Test
 19      575           4         12         11        8.1          8     2009-05-04T16:32:02.0000000-04:00    Hardness-10     Avandaryl 4mg/1mg ROW/US    Avandaryl_Test    
 20      575           8          8          8          5        4.6     2009-05-04T16:32:02.0000000-04:00    Hardness-10     Avandaryl 4mg/1mg ROW/US    Avandaryl_Test    
 21      573         199        203        202        201        200     2009-05-04T16:32:02.0000000-04:00    Weight-10       Avandaryl 4mg/1mg ROW/US    Avandaryl_Test    
 22      573         206        204        205        197        198     2009-05-04T16:32:02.0000000-04:00    Weight-10       Avandaryl 4mg/1mg ROW/US    Avandaryl_Test    
 23      574           4        3.5          4        3.9        3.8     2009-05-04T16:32:02.0000000-04:00    Thickness-10    Avandaryl 4mg/1mg ROW/US    Avandaryl_Test    
 24      574           4          4        4.2        4.3        4.1     2009-05-04T16:32:02.0000000-04:00    Thickness-10    Avandaryl 4mg/1mg ROW/US    Avandaryl_Test    
 25      574        3.75       3.81       3.89       3.87        3.8     2009-05-05T06:54:00.0000000-04:00    Thickness-10    Avandaryl 4mg/1mg ROW/US    Avandaryl_Test    
 26      574         3.8       3.65        3.9       4.81       3.78     2009-05-05T06:54:00.0000000-04:00    Thickness-10    Avandaryl 4mg/1mg ROW/US    Avandaryl_Test    
 27      573       199.8      199.3        199        201        200     2009-05-05T06:54:00.0000000-04:00    Weight-10       Avandaryl 4mg/1mg ROW/US    Avandaryl_Test    
 28      573       207.6      205.9      204.8      203.1      201.3     2009-05-05T06:54:00.0000000-04:00    Weight-10       Avandaryl 4mg/1mg ROW/US    Avandaryl_Test    
 29      575         8.1        8.3        8.5        9.3       10.1     2009-05-05T06:54:00.0000000-04:00    Hardness-10     Avandaryl 4mg/1mg ROW/US    Avandaryl_Test    
 30      575         8.6        8.3        8.3        7.4        7.9     2009-05-05T06:54:00.0000000-04:00    Hardness-10     Avandaryl 4mg/1mg ROW/US    Avandaryl_Test    
 31      575         8.2        8.5        8.7        8.8        8.9     2009-05-05T07:07:00.0000000-04:00    Hardness-10     Avandaryl 4mg/1mg ROW/US    Avandaryl_Test    
 32      575         7.3        7.4        7.8        7.4        7.9     2009-05-05T07:07:00.0000000-04:00    Hardness-10     Avandaryl 4mg/1mg ROW/US    Avandaryl_Test    
 33      573       200.5      200.4      200.3      200.2      200.1     2009-05-05T07:07:00.0000000-04:00    Weight-10       Avandaryl 4mg/1mg ROW/US    Avandaryl_Test    
 34      573         199      198.3      199.5      200.9      200.6     2009-05-05T07:07:00.0000000-04:00    Weight-10       Avandaryl 4mg/1mg ROW/US    Avandaryl_Test    
 35      574        3.85       3.82       3.81        3.8       3.79     2009-05-05T07:07:00.0000000-04:00    Thickness-10    Avandaryl 4mg/1mg ROW/US    Avandaryl_Test    
 36      574        4.09       4.11       4.22        4.1       3.89     2009-05-05T07:07:00.0000000-04:00    Thickness-10    Avandaryl 4mg/1mg ROW/US    Avandaryl_Test    

