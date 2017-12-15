
data &OUTPUTFILE;
  retain cname instance cnameXsb1 instanceXsb1 cnameXsb2 instanceXsb2;
  set subbatches;
  dpsource = "&DESCRIPTION";
run;

data &OUTPUTFILE(drop=cnamehold cnameXsb1hold);
  retain cnamehold cnameXsb1hold;
  set &OUTPUTFILE;
  if cname ne '' then cnamehold = cname;
  else cname = cnamehold;

  if cnameXsb1 ne '' then cnameXsb1hold = cnameXsb1;
  else cnameXsb1 = cnameXsb1hold;
run;

endsas;
       Batch_     Subbatch_                                       Characteristic1_                    Value1_    is
Obs    ORDINAL     ORDINAL            cname           instance        ORDINAL         name            ORDINAL    UTC    value

 1        1           1        Solvent Granulation       1               1            END TIME           1       -1     2007-07-16T23:01:33
 2        1           1        Solvent Granulation       1               2            START TIME         2       -1     2007-07-16T19:52:09
 3        1           1        Solvent Granulation       1               3            Process Cell       3        .     RM 4391            
v1                                                                                                                                                 10:10 Tuesday, August 3, 2010   4

       Subbatch_    Subbatch1_                       instance    Characteristic2_                               Value2_    is
Obs     ORDINAL      ORDINAL         cnameXsb1         Xsb1          ORDINAL         name           instance    ORDINAL    UTC    value

 1         1            1         FBD Granulation       1               1            END TIME          1           1       -1     2007-07-16T23:01:33
 2         1            1         FBD Granulation       1               2            START TIME        1           2       -1     2007-07-16T19:52:09
 3         1            1         FBD Granulation       1               3            Recipe Name       1           3        .     VALTREX CAPLETS    
 4         1            1         FBD Granulation       1               4            Unit              1           4        .     NIROMP8            
v2                                                                                                                                                 10:10 Tuesday, August 3, 2010   5

       Subbatch1_    Subbatch2_                    instance    Characteristic3_                              Value3_    is
Obs     ORDINAL       ORDINAL      cnameXsb2         Xsb2          ORDINAL            name       instance    ORDINAL    UTC           value

  1        1             1         Precondition       1                1           END TIME         1           1       -1     2007-07-16T20:22:09
  2        1             1         Precondition       1                2           START TIME       1           2       -1     2007-07-16T19:52:09
  3        1             2         Warmup             1                3           END TIME         1           3       -1     2007-07-16T20:39:38
  4        1             2         Warmup             1                4           START TIME       1           4       -1     2007-07-16T20:22:09
  5        1             3         Dry                1                5           END TIME         1           5       -1     2007-07-16T20:44:35
  6        1             3         Dry                1                6           START TIME       1           6       -1     2007-07-16T20:39:38
  7        1             4         Dry                2                7           END TIME         1           7       -1     2007-07-16T20:49:33
  8        1             4         Dry                2                8           START TIME       1           8       -1     2007-07-16T20:44:36
  9        1             5         Dry                3                9           END TIME         1           9       -1     2007-07-16T22:42:01
 10        1             5         Dry                3               10           START TIME       1          10       -1     2007-07-16T20:49:33
 11        1             6         Dry                4               11           END TIME         1          11       -1     2007-07-16T23:01:33
 12        1             6         Dry                4               12           START TIME       1          12       -1     2007-07-16T22:42:01
