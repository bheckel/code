
data _null_;
  call symput('MV1','Smith&Jones');
  call symput('MV2','%macro abc;');
run;

 /* Won't work */
***%let TESTMV1=&MV1;
***%let TESTMV2=&MV2;

 /* Note: no leading '&' required! */
%let TESTMV1=%superq(MV1);
%let TESTMV2=%superq(MV2);

%put Macro variable TESTMV1 is &TESTMV1;
%put Macro variable TESTMV2 is &TESTMV2;
