# S/b symlinked to ~/code/sas/

Generation Data Groups:

Create (actually create an entry for the GDG in the system catalog):
//BQH0GDG  JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=2,CLASS=D,REGION=0M
//STEP1    EXEC PGM=IDCAMS                                          
//SYSPRINT DD SYSOUT=0                                            
//SYSIN    DD *                                                  
 DEFINE GDG (NAME(BQH0.TESTGDG) LIMIT(3) SCRATCH)                 
/*                                                                

E.g.
//BQH0GDG  JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=2,CLASS=D,REGION=0M
//STEP1    EXEC PGM=IDCAMS                                          
//SYSPRINT DD SYSOUT=0                                            
//SYSIN    DD *                                                  
 DEFINE GDG (NAME(DWJ2.SC03MOR.GEN) LIMIT(255) SCRATCH)                 
/*                                                                


Now add a new generation.  Assumes code that creates output is run and uses
this OUT card:
...
//OUT  DD DSN=BQH0.TESTGDG(+1),DISP=(NEW,CATLG),    
//        RECFM=FB,LRECL=476,SPACE=(CYL,10)        
...

This now exists:
           GDG convention
BQH0.TESTGDG.G0001V00
             ^    ^
Which is another name for:
BQH0.TESTGDG(0)


Remove:
//BQH0GDEL JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=2,CLASS=D,REGION=0M 
//STEP1    EXEC PGM=IDCAMS                                           
//SYSPRINT DD SYSOUT=0                                             
//SYSIN    DD *                                                   
 DELETE BQH0.TEST2G GDG FORCE                                      
/*                                                                 

E.g.
//BQH0GDEL JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=2,CLASS=D,REGION=0M 
//STEP1    EXEC PGM=IDCAMS                                           
//SYSPRINT DD SYSOUT=0                                             
//SYSIN    DD *                                                   
 DELETE DWJ2.SC03MOR.GEN GDG FORCE                                      
/*                                                                 


List information:
//BQH0GLIS JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=2,CLASS=D,REGION=0M 
//STEP1    EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=0
//SYSIN    DD *
 LISTCAT GDG -
   ENTRIES (BQH0.TESTGDG) ALL
/*


Use.  Each time it runs, a new file is created 
(e.g. BQH0.TESTGDG.G0001V00, BQH0.TESTGDG.G0002V00, ...):
//BQH0GCPY JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M
//STEP1    EXEC PGM=IDCAMS                                         
//SYSPRINT DD SYSOUT=0                                             
//INDD     DD DISP=SHR,DSN=BQH0.ICETEST                            
//OUTDD    DD DISP=(NEW,CATLG,DELETE),UNIT=NCHS,                   
//            DSN=BQH0.TESTGDG(+1),                                
//            DCB=(LRECL=476,RECFM=FB)                              
//SYSIN    DD *                                                    
 REPRO INFILE(INDD) OUTFILE(OUTDD)                                 
/*                                                                 


Then can use the newest like this while running TESTG SAS code:
//BQH0USE JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M
//STEP49  EXEC SAS,WTR1=A,WTR=A,OPTIONS='MSGCASE,MEMSIZE=0'         
//IN      DD DISP=SHR,DSN=BQH0.GDGAZ(0)                                       
//SYSIN   DD DSN=BQH0.PGM.LIB(TESTG),DISP=SHR                        
/*                                                                 
