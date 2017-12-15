options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: list_sampids.sas
  *
  *  Summary: Get a few sample ids for debugging, etc.
  *
  *  Created: Mon 10 Apr 2006 10:38:10 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

libname ORA oracle user=pks password=pks path=usdev100;

%global S;

%macro KnowMethod(meth);
  proc sql print;
    select distinct samp_id into :S separated by ','
    from ORA.tst_rslt_summary
    where meth_spec_nm like %upcase("&meth%") and
          monotonic()<25
    ;
  quit;
%mend;
***%KnowMethod(appear);  /* EDIT */


%macro KnowProdname(prod);
  proc sql print;
    select distinct samp_id into :S separated by ','
    from ORA.samp
    where upcase(prod_nm) like %upcase("&prod%") /*and monotonic()<25*/
    ;
  quit;
%mend;
%KnowProdname(bupr);  /* EDIT */


%macro KnowBoth(meth, prod);
  proc sql print;
    select distinct s.samp_id into :S separated by ','
    from ORA.samp s JOIN ORA.tst_rslt_summary t ON s.samp_id=t.samp_id
    where upcase(t.meth_spec_nm) like %upcase("&meth%") and 
          upcase(s.prod_nm) like %upcase("&prod%") and monotonic()<25
    ;
  quit;
%mend;
***%KnowBoth(appear, lamic);  /* EDIT */


data _null_;
  file PRINT;
  put "&s";
run;
