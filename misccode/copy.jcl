//BQH0CPY  JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M
//STEP1    EXEC PGM=IDCAMS                                         
//SYSPRINT DD SYSOUT=*                                             
//INDD     DD DISP=SHR,DSN=BQH0.ICETEST                            
//OUTDD    DD DISP=(NEW,CATLG,DELETE),UNIT=NCHS,                   
//            DSN=BQH0.ICETESTX,                                   
//            DCB=(LRECL=80,RECFM=FB)                              
//SYSIN    DD *                                                    
 REPRO INFILE(INDD) OUTFILE(OUTDD)                                 
/*                                                                 
