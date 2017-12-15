options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_tabulate_class_and_overall.sas
  *
  *  Summary: Demo of adding a total to proc tabulate
  *
  *  Created: Tue 10 Jul 2012 14:17:02 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data t;                                            
  input grouping biton;                                   
  datalines;                                            
201   0                                               
201   0                                               
201   1                                               
201   1                                               
 42   0                                               
 42   0                                               
 42   0                                               
603   0                                               
603   1                                               
;                                                     
run;                                                  
proc print data=_LAST_(obs=max) width=minimum; run;
                                                      
data t2;                                           
  set t;                                          
  tot=1;                                             
run;                                                  
                                                                                                           
proc tabulate data=t2 format=8.;                   
  class grouping;                                       
  var biton tot;                                       
  tables grouping, (biton='Bit Is On' tot='Total')*sum='N';         
run;                                                  
     
