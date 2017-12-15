options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: view_speed_comparison.sas
  *
  *  Summary: Compare efficiency
  *
  *           Can improve from 6 seconds to 1.5 seconds
  *
  *  Adapted: Tue 30 Nov 2004 09:43:11 (Bob Heckel -- SASTip113 - Making
  *                                     programs go faster using data step
  *                                     views -- Phil Mason)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%let start=%sysfunc(time()) ;                                           
                                                                        
data a  ;                                                               
***data a / view=a;                                                               
  do i=1 to 100 ;                                                       
    do j=1 to nobs ;                                                    
      set sashelp.prdsale point=j nobs=nobs ;                           
      output ;                                                          
    end ;                                                               
  end ;                                                                 
  stop ;                                                                
run ;                                                                   
        
data b  ;                                                               
***data b / view=b;                                                               
   do i=1 to 100 ;                                                       
     do j=1 to nobs ;                                                    
       set sashelp.prdsale point=j nobs=nobs ;                           
       calc=actual*10 ;                                                  
       output ;                                                          
     end ;                                                               
   end ;                                                                 
   stop ;                                                                
 run ;                                                                   

data c  ;                                                               
***data c / view=c;                                                               
  merge a b ;                                                           
run ;                                                                   
       
data d  ;                                                               
***data d / view=d;                                                               
  set c sashelp.class ;                                                 
run ;                                                                   

data save_here ;                                                        
  set d ;                                                               
run ;  

%put time taken: %sysevalf(%sysfunc(time())-&start) ;
