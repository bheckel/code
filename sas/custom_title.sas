options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: custom_title.sas
  *
  *  Summary: Build a series of title statements with custom centering.
  *
  *  Created: Wed 22 Oct 2003 11:18:34 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data;
  input x;
  cards;
1 2
  ;
run;

%let STATNAME=foo;
%let FNAME=bar;

 /* Build the 3 line centered titles. */
%global T1 T2 T3;
DATA _NULL_;
  /* Starting col and tot line size */
  length l1 $ 49  l2 $ 135
         l3 $ 62  l4 $ 135
         l5 $ 58  l6 $ 135
         ;

  do i=1 to 49;
    l1= 'x' || l1;
  end;
  do i=1 to 62;
    l3= 'y' || l3;
  end;
  do i=1 to 58;
    l5= 'z' || l5;
  end;

  l2 = l1 || "&STATNAME CYR EVENT TIME";
  l4 = l3 || "(USING ANNUAL PERCENTAGES)";
  l6 = l5 || "DATASET NAME:  &FNAME";
  call symput('T1', l2);
  call symput('T2', l4);
  call symput('T3', l6);
RUN;

title "&T1";
title2 "&T2";
title3 "&T3";
proc print; run;
