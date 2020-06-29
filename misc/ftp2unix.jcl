//BQH0FTP  JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M   
//STEP1    EXEC PGM=FTP,REGION=4096K                                  
//* FTP from mainframe to Unix box daeb                               
//* Adapted: Thu Oct 24 12:59:59 2002 (Bob Heckel -- Brenda Boswell)
//SYSIN    DD *                                                       
158.111.250.128                                                       
bqh0                                                                  
mypasswd                                                              
ascii                                                                 
put 'BQH0.PGM.TRASH.JUNKTXT' /home/bqh0/tmp/transn92.out              
quit                                                                  
