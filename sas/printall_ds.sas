options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: printall_ds.sas
  *
  *  Summary: proc print all datasets in a library.
  *
  *  Adapted: Fri 29 Aug 2003 13:27:39 (Bob Heckel -- SAS Doc v8 proc print)
  * Modified: Fri 19 Aug 2005 13:53:04 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%macro Printall(libname, worklib=WORK);
  %local num i;
  proc datasets library=&libname memtype=data nodetails;
     contents out=&worklib..temp1 (keep=memname) data=_ALL_ noprint;
  run;

  data _NULL_;
    set &worklib..temp1 end=lastobs;
    by memname notsorted;
    if last.memname;
    n+1;
    call symput('ds'||left(put(n,8.)),trim(memname));

    if lastobs then 
      call symput('num',put(n,8.));
  run;

  %do i=1 %to &num;
    proc print data=&libname..&&ds&i noobs (obs=max);
      title "!!!Data Set &libname..&&ds&i";
    run;
  %end;
%mend Printall;


options nodate pageno=1 linesize=max pagesize=60;
%Printall(WORK)
