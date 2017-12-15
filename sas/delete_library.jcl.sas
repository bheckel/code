//BQH0DEL  JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M             
//STEP1    EXEC SAS,TIME=100,OPTIONS='MSGCASE,MEMSIZE=0'                        
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)                                     
//SYSIN    DD *                                                                 
LIBNAME MOR "DWJ2.MOR2000.LIBRARY" DISP=OLD WAIT=30;                            
PROC DATASETS LIBRARY=MOR; DELETE MA2000; RUN;                                  
