//BQH0SORT JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=2,CLASS=D,REGION=0M
//* IEFBR14 IS AN MVS PROGRAM THAT LETS YOU TEST JCL.              
//***STEP1    EXEC PGM=IEFBR14
//STEP1    EXEC PGM=SORT                                           
//SYSIN DD *                                                       
  SORT FIELDS=(1,75,CH,A)                                          
/*                                                                 
//SYSOUT DD SYSOUT=*                                               
//SORTIN DD *                                                      
NEPTUNE                                                            
PLUTO                                                              
EARTH                                                              
VENUS                                                              
MARS                                                               
/*                                                                 
//SORTOUT DD SYSOUT=*                                              
/*                                                                 

Log output follows:
1                    J E S 2  J O B  L O G  --  S Y S T E M  I P O 1  --  N O D E  C D C J E S 2
0 
 16.43.40 JOB14752 ---- FRIDAY,    24 MAY 2002 ----
 16.43.40 JOB14752  $HASP373 BQH0SORT STARTED - INIT 3    - CLASS D - SYS IPO1
 16.43.40 JOB14752  TSS7000I BQH0 Last-Used 24 May 02 16:43 System=IPO1 Facility=BATCH
 16.43.40 JOB14752  TSS7001I Count=01372 Mode=Fail Locktime=None Name=HECKEL BOB
 16.43.40 JOB14752  IEF403I BQH0SORT - STARTED - TIME=16.43.40
 16.43.41 JOB14752  ST# 001  BQH0SORT STEP1    MAY-24-02------   000 <COMP>
 16.43.41 JOB14752  IEF404I BQH0SORT - ENDED - TIME=16.43.41
 16.43.41 JOB14752  $HASP395 BQH0SORT ENDED
0------ JES2 JOB STATISTICS ------                                     
-  24 MAY 2002 JOB EXECUTION DATE                                      
-           17 CARDS READ                                              
-           92 SYSOUT PRINT RECORDS                                    
-            0 SYSOUT PUNCH RECORDS                                    
-            5 SYSOUT SPOOL KBYTES                                     
-         0.00 MINUTES EXECUTION TIME                                  
         1 //BQH0SORT JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=2,CLASS=D,REGION=0M,    JOB14752
           // USER=BQH0,PASSWORD=
           //* IEFBR14 IS AN MVS PROGRAM THAT LETS YOU TEST JCL.
         2 //STEP1    EXEC PGM=SORT
         3 //SYSIN DD *
         4 //SYSOUT DD SYSOUT=*
         5 //SORTIN DD *
         6 //SORTOUT DD SYSOUT=*
           /*
 IEF236I ALLOC. FOR BQH0SORT STEP1
 IEF237I JES2 ALLOCATED TO SYSIN
 IEF237I JES2 ALLOCATED TO SYSOUT
 IEF237I JES2 ALLOCATED TO SORTIN
 IEF237I JES2 ALLOCATED TO SORTOUT
 IEF142I BQH0SORT STEP1 - STEP WAS EXECUTED - COND CODE 0000
 IEF285I   BQH0.BQH0SORT.JOB14752.D0000101.?            SYSIN
 IEF285I   BQH0.BQH0SORT.JOB14752.D0000103.?            SYSOUT
 IEF285I   BQH0.BQH0SORT.JOB14752.D0000102.?            SYSIN
 IEF285I   BQH0.BQH0SORT.JOB14752.D0000104.?            SYSOUT
 IEF373I STEP/STEP1   /START 2002144.1643
 IEF374I STEP/STEP1   /STOP  2002144.1643 CPU    0MIN 00.02SEC SRB    0MIN 00.00SEC VIRT  2096K SYS   248K EXT    4100K SYS    9968K
  
 *------------------------------------------------------------------------------*
 *  STEP SEQ.   001          PAGE-INS             0       TAPE I/OS         0   *
 *  STEP NAME   STEP1        PAGE-OUTS            0       DISK I/OS         0   *
 *  PGM NAME    SORT         DATA CARDS READ      6       TOTAL I/OS        0   *
 *  STEP START  16:43:40     STEP CPU           .00       RUN TIME        .00   *
 *  STEP STOP   16:43:41     JOB CPU            .00       COMPL CODE     0000   *
 *------------------------------------------------------------------------------*
  
 IEF375I  JOB/BQH0SORT/START 2002144.1643
 IEF376I  JOB/BQH0SORT/STOP  2002144.1643 CPU    0MIN 00.02SEC SRB    0MIN 00.00SEC
  
 *------------------------------------------------------------------------------*
 *              CENTERS FOR DISEASE CONTROL, ATLANTA, GEORGIA                   *
 *                                                                              *
 *                 INFORMATION RESOURCES MANAGEMENT OFFICE                      *
 *------------------------------------------------------------------------------*
 * PROGRAMMER BQH0                 DATE IN       MAY-24-02  START RUN  16:43:40 *
 * ACCOUNT #  BF00                 TIME IN        16:43:40  END RUN    16:43:41 *
 * JOBNAME    BQH0SORT             ELAPSED TIME        .00  RUN TIME        .00 *
 * SYS/MODEL  9672-RC6             INPUT JOB CLASS       D  JOB CPU         .00 *
 *------------------------------------------------------------------------------*
  
1ICE143I 0 BLOCKSET     SORT  TECHNIQUE SELECTED
 ICE000I 1 - CONTROL STATEMENTS FOR 5740-SM1, DFSORT REL 14.0 - 16:43 ON FRI MAY 24, 2002 -
0            SORT FIELDS=(1,75,CH,A)
 ICE201I 0 RECORD TYPE IS F - DATA STARTS IN POSITION 1
 ICE193I 0 ICEAM1 ENVIRONMENT IN EFFECT - ICEAM1 INSTALLATION MODULE SELECTED
 ICE088I 1 BQH0SORT.STEP1   .        , INPUT LRECL = 80, BLKSIZE = 80, TYPE = FB
 ICE093I 0 MAIN STORAGE = (MAX,4194304,4181086)
 ICE156I 0 MAIN STORAGE ABOVE 16MB = (4120560,4120560)
 ICE127I 0 OPTIONS: OVFLO=RC0 ,PAD=RC0 ,TRUNC=RC0 ,SPANINC=RC16,VLSCMP=N,SZERO=Y,RESET=Y,VSAMEMT=Y
 ICE128I 0 OPTIONS: SIZE=4194304,MAXLIM=2097152,MINLIM=450560,EQUALS=Y,LIST=Y,ERET=RC16 ,MSGDDN=SYSOUT
 ICE129I 0 OPTIONS: VIO=N,RESDNT=ALL ,SMF=SHORT,WRKSEC=Y,OUTSEC=Y,VERIFY=N,CHALT=N,DYNALOC=N             ,ABCODE=MSG
 ICE130I 0 OPTIONS: RESALL=4096,RESINV=0,SVC=109 ,CHECK=Y,WRKREL=Y,OUTREL=Y,CKPT=N,STIMER=Y,COBEXIT=COB1
 ICE131I 0 OPTIONS: TMAXLIM=4194304,ARESALL=0,ARESINV=0,OVERRGN=65536,CINV=Y,CFW=Y,DSA=0
 ICE132I 0 OPTIONS: VLSHRT=N,ZDPRINT=N,IEXIT=N,TEXIT=N,LISTX=N,EFS=NONE    ,EXITCK=S,PARMDDN=DFSPARM ,FSZEST=N
 ICE133I 0 OPTIONS: HIPRMAX=OPTIMAL,DSPSIZE=MAX ,ODMAXBF=0,SOLRF=Y,VLLONG=N,VSAMIO=N
 ICE084I 0 BSAM ACCESS METHOD USED FOR SORTOUT
 ICE084I 0 BSAM ACCESS METHOD USED FOR SORTIN
 ICE090I 0 OUTPUT LRECL = 80, BLKSIZE = 80, TYPE = FB
 ICE080I 0 IN MAIN STORAGE SORT
 ICE055I 0 INSERT 0, DELETE 0
 ICE054I 0 RECORDS - IN: 5, OUT: 5
 ICE134I 0 NUMBER OF BYTES SORTED: 400
 ICE180I 0 HIPERSPACE STORAGE USED = 0K BYTES
 ICE188I 0 DATA SPACE STORAGE USED = 0K BYTES
 ICE026I 1 SMF RECORD NOT WRITTEN TO THE SMF DATA SET(RC=20)
 ICE052I 0 END OF DFSORT
 EARTH
 MARS
 NEPTUNE
 PLUTO
 VENUS
