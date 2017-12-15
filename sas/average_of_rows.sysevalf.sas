options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: average_of_rows.sysevalf.sas
  *
  *  Summary: Calculate average of several rows of obs without proc means.
  *
  *  Created: Thu 01 Oct 2009 09:43:13 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

/*
                                                D
                                                T
                                                S
                                                P
                                                L
                                                T                 S                    S                         S
                                                A                 I                    P                         B
         N   R    R      R  R      R            K                 T                    R                         A
         I   V    V      V  V      V            E                 E                    O                         T
         T   A    A      A  A      A            N                 M                    D                         C
         E   L    L      L  L      L            T                 N                    N                         H
    O    M   U    U      U  U      U            I                 A                    A                         N
    b    I   E    E      E  E      E            M                 M                    M                         B
    s    D   5    4      3  2      1            E                 E                    E                         R

      1 625 29.5 32.4 27.7 28.9 30.4 2009-05-27 13:37:24.103 Hardness-10 Valtrex 500mg Caplet(Lod DFD) 10000000008557-9zm4996
      2 625 26.5 24.2 25.6 25.6 26.2 2009-05-27 13:37:24.103 Hardness-10 Valtrex 500mg Caplet(Lod DFD) 10000000008557-9zm4996
      3 625 28.8 28.7   27 26.8   29 2009-05-27 14:20:29.873 Hardness-10 Valtrex 500mg Caplet(Lod DFD) 10000000008557-9zm4996
      4 625 24.6 28.3 27.2 30.6 29.7 2009-05-27 14:20:29.873 Hardness-10 Valtrex 500mg Caplet(Lod DFD) 10000000008557-9zm4996
      5 625 30.7 28.3 28.7 29.3 28.9 2009-05-27 14:58:51.263 Hardness-10 Valtrex 500mg Caplet(Lod DFD) 10000000008557-9zm4996
      ...
      18
 */
proc sql NOprint;
  select sum(rvalue1), sum(rvalue2), sum(rvalue3), sum(rvalue4), sum(rvalue5), count(*) into :s1, :s2, :s3, :s4, :s5, :cnt
  from tmp1.freeweigh_debugon
  group by sbatchnbr, sitemname
  having sbatchnbr eq '2000820703/9zm8365' and sitemname like 'Hardne%'
  ;
quit;

%macro m;
  /*                                              18     */
  %put average: %sysevalf((&s1+&s2+&s3+&s4+&s5)/(&cnt*5));
%mend; %m
