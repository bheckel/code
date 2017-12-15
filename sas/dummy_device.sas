 /* Black hole device */
***filename outlog DUMMY; 
filename outlog 'junklog'; 
  
/* Redirect the log to the DUMMY device so that it is discarded */ 
proc printto log=outlog; 
run; 
 
/* A data step that writes to the log. */ 
data _null_; 
  put 'I will disappear!'; 
run; 
 
/* Reset the log */ 
proc printto; 
run; 
 
