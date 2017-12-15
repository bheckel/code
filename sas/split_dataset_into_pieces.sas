options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: code/sas/split_dataset_into_pieces.sas
  *
  *  Summary: Good for breaking up huge dataset into piece before doing FTP, etc.
  *
  *  Adapted: Thu 23 Jul 2009 10:20:59 (Bob Heckel -- http://support.sas.com/kb/35/884.html) 
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%macro splitds(dsn, obs);                                                                                                                   
  %let dsid=%sysfunc(open(&dsn));                                                                                                        
  %let num=%sysfunc(attrn(&dsid,nobs));                                                                                                  
  %let rc=%sysfunc(close(&dsid));                                                                                                        
  %let end=%sysevalf(&num/&obs,integer);                                                                                                 
                                                                                                                                        
  %local newobs;                                                                                                                         
  %do i = 1 %to &end;                                                                                                                    
    %if &i = 1 %then %do;                                                                                                                 
      data x&i;                                                                                                                            
        set &dsn(firstobs=&i obs=&obs);                                                                                                     
      run;                                                                                                                                 
    %end;                                                                                                                                 
    %else %do;                                                                                                                            
      %if &i ne &end %then %do;                                                                                                            
        %let newobs=&newobs+&obs;                                                                                                           
        data x&i;                                                                                                                           
          set &dsn(firstobs=%eval(&newobs+1) obs=%eval(&obs*&i));                                                                            
        run;                                                                                                                                
      %end;                                                                                                                                
      %else %do;                                                                                                                           
        %let newobs=&newobs+&obs;                                                                                                           
        data x&i;                                                                                                                           
          set &dsn(firstobs=%eval(&newobs+1));                                                                                               
        run;                                                                                                                                
      %end;                                                                                                                                
    %end;                                                                                                                                  
  %end;                                                                                                                                  
%mend splitds;                                                                                                                             
%splitds(sashelp.shoes, 3)

proc print data=sashelp.shoes(obs=10) width=minimum; run;
proc contents data=work._all_; run;
proc print data=x1(obs=max) width=minimum; run;
proc print data=x2(obs=max) width=minimum; run;
proc print data=x3(obs=max) width=minimum; run;
