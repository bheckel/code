%macro IsDSempty;
  %let RunAMAPS=1;  
 /***   data _NULL_;set lelimsgist_MatlList; call symput('RunAMAPS',0); run; ***/
/***  data _NULL_;set SASHELP.shoes; call symput('RunAMAPS',0); run;***/
  data _NULL_;set shoes; call symput('RunAMAPS',0); run;
  %if &RunAMAPS = 1 %then 
    %do; 
      %put empty; 
    %end;
  %else
    %do; 
      %put not empty; 
    %end;
%mend;
%IsDSempty
