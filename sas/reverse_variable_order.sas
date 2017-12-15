options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: reverse_variable_order.sas
  *
  *  Summary: Reverse the display order of vars in a dataset.
  *
  *  Created: Thu 16 Dec 2010 13:43:18 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* STEP 3 */
data l.ods_0001e_advair_reversed;
  retain
PRODUCT                         
MATERIAL_BATCH_NUMBER           
MFG_DATE                        
TEST_METHOD_DESCRIPTION         
RECORDED_TEXT                   
NUMERIC_RESULT_UNIT             
REPLICATE_ID                    
IMPACTOR_NUMBER                 
CHARACTER_RESULT                
METHOD_ID                       
TEST_STATUS                     
TEST_EXECUTION_DATE             
ANALYST_ID                      
BLEND_NUMBER                    
BLEND_MFG_DATE                  
BLEND_MATL_DESCRIPTION          
FILL_BATCH                      
FILL_MFG_DATE                   
FILL_MATL_DESCRIPTION           
AP_BATCH                        
AP_MFG_DATE                     
AP_MATL_DESCRIPTION             
;
  set l.ods_0001e_advair;
run;
proc print data=_LAST_(obs=10) width=minimum; run;

proc export data=_LAST_ OUTFILE="ods_0001e_advair_reversed.csv" DBMS=CSV replace; run;

endsas;

 /* STEP 1 */
proc sql;
  select name 
  from dictionary.columns
  where libname eq 'L' and memname like 'ODS%'
  ;
quit;

 /* STEP 2 */
vim !tac to get retain list above
