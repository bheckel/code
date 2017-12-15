//BQH0FTP  JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M
//STEP1    EXEC PGM=FTP,REGION=4096K                               
//* Must preallocate JUNKREV.
//SYSIN    DD *                                                    
                                                                   
158.111.250.31                                                     
bqh0                                                               
Langway3                                                           
ASCII                                                              
GET /home/bhb6/data/data1/ny03.dem.merge +
    'BQH0.JUNKREV' (REPLACE   
QUIT                                                               
