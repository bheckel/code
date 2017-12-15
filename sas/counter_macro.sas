options nosource;
 /*---------------------------------------------------------------------------
  *     Name: counter_macro.sas
  *
  *  Summary: Count using macro like i++
  *
  *  Adapted: Thu 06 Mar 2003 15:34:43 (Bob Heckel --
  *                            file:///C:/bookshelf_sas/macro/z0208971.htm)
  *---------------------------------------------------------------------------
  */
options source;

%macro Count(finish);
  %let i=1;
  %do %while (&i<&finish);
    %put !!! the value of i is &i;
    %let i=%eval(&i+1);
  %end;
  %put !!! the total count of i is &i;
%mend Count;
%Count(5)


 /* Better */
%macro Count2(finish);
  %do j=1 %to &finish;
    %put !!!2 the value of j is &j;
    %let j=%eval(&j+1);
  %end;
  %put !!!2 the total count of j is &j;
%mend Count2;
%Count2(3)
