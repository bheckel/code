 /* See also count_num_obs.sas */

 /* Count number of occurences of something in a dataset without iterating
  * through a datastep.
  */

%let c1=%sysfunc(attrn(%sysfunc(open(sashelp.shoes)), NLOBSF));
%let c2=%sysfunc(attrn(%sysfunc(open(sashelp.shoes(where=(Region=:"Af")))), NLOBSF));

data emptyds;
run;
 /* count is 1 */
%let emptycount=%sysfunc(attrn(%sysfunc(open(WORK.emptyds)), NLOBSF));

 /* Safer */
%let dsid=%sysfunc(open(work.emptyds)); %let cntobs=%sysfunc(attrn(&dsid, NLOBS)); %let dsid=%sysfunc(close(&dsid));

%put _user_;

endsas;
%let SampFull=0;
data _null_;
  set emptyds;
  Numb=1;
  call symput('SampFull',Numb);
run;
%let c3=%sysfunc(attrn(%sysfunc(open(WORK.countmex)), NLOBSF));
