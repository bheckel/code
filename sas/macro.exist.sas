
 /* Must come before MacroExist() */
%macro Testmcr;
  %put foo;
%mend;

%macro MacroExist(name);                                                                                                                      
  %global bool;                                                                                                                            

  proc catalog cat=work.sasmacr;                                                                                                          
    contents out=ctnts(keep=name);                                                                                                           
  run;                                                                                                                                    
                                                                                                                                          
  data _null_;                                                                                                                           
    set ctnts;                                                                                                                              
     if upcase(name) = "%upcase(&name)" then do;                                                                                          
       call symput('bool','yes');                                                                                                          
       stop;                                                                                                                              
     end;                                                                                                                                 
     else call symput('bool','no');                                                                                                        
  run;                                                                                                                                   
%mend MacroExist;  
                                                                                                                           
/* Check for the existence of the macro Testmcr */                                                                                                                                      

%MacroExist(Testmcr)                                                                                                                             
%put Does Testmcr exist: &bool;
