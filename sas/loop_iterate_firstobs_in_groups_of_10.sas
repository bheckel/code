%macro m;
  /* Break a dataset into groups of 10 obs each */

 /*
DEBUG: I=1 ITER=10 START=1 END=10
DEBUG: I=2 ITER=20 START=11 END=20
DEBUG: I=3 ITER=30 START=21 END=22
 */

  proc sql;
    select count(*) into :nfnl
    from t
    ;
  quit;

  %let ngroups=%eval((&nfnl/10)+1);

  %do i=1 %to &ngroups;
    %let iter=%eval(&i*10);
    %let start=%eval(&iter-9);
    %let end=&iter;
    %if &end gt &nfnl %then %do;
      %let end=&nfnl;
    %end;
    %put DEBUG: &=i &=iter &=start &=end;

    data t_&i;
      set t(firstobs=&start obs=&end);
    run; 
  %end;
%mend;

  data t;
    input x;
    cards;
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
  ;
  run;

%m;

title "&SYSDSN";proc print data=t_2(obs=max) width=minimum heading=H;run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;
