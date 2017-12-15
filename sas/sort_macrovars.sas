%macro numsort(a, b);
  %if &a ge &b %then %put &b &a;
  %else %put &a &b;
%mend;

%let x=20; %let y=1;
%numsort(&x, &y);
/***%numsort(20,1);***/
/***%numsort(10,1);***/
/***%numsort(5,10);***/
/***numsort(10,5);***/


endsas;
%macro numsort(a,b);
  %global x;
  %if &a ge &b %then %let x=1;
  %else %let x=0;
%mend;
%numsort(20,1);

%macro m;
  %if &x eq 1 %then %put ok;
%mend;
%m;
