//BQH0FL JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=5,CLASS=V,                        
//  REGION=0M                                                                   
//*ROUTE    PRINT R201                                                          
//*                                                                             
//*     NAME: MORFLX                                                            
//*  SUMMARY: CREATE ONE NCHS FORMATTED DEMOGRAPHIC AND                         
//*           ONE NCHS FORMATTED MEDICAL FILE FOR FLORIDA                       
//*           CONTAINING ALL DECEDENTS CODED WITH A STATE                       
//*           OF RESIDENCE = FL BUT DYING OUTSIDE OF FLORIDA.                   
//*  CREATED: MAY 16, 2002 (KJK4/BQH0)                                          
//* MODIFIED: MAY 20, 2002 (BQH0 - NEW FILENAMES)                               
//*                                                                             
//*** OUTPUT LIST OF BF19 FILE NAMES TO DATASET:                                
//*LIST    EXEC PGM=IDCAMS                                                      
//*SYSPRINT DD DSN=BQH0.BF19.DATASET,DISP=OLD                                   
//*SYSIN DD *                                                                   
//* LISTC LEVEL(BF19)                                                           
//*** END OUTPUT                                                                
//*                                                                             
//ANNUAL    EXEC SAS,OPTIONS='MSGCASE,MEMSIZE=0'                                
//WORK DD SPACE=(CYL,(450,450),,,ROUND)                                         
//IN   DD DSN=BQH0.BF19.DATASET,DISP=SHR                                        
//SYSIN     DD *                                                                
OPTIONS LS=133 CAPS NOTES SOURCE MPRINT SYMBOLGEN;                              
                                                                                
%GLOBAL BYR TOTCUR TR;                                                          
                                                                                
%LET XSTATE=FL;    /* ENTER ABBREVIATION FOR STATE TO EXCLUDE */                
%LET XSTATEC=10;   /* ENTER CODE FOR STATE TO EXCLUDE */                        
%LET BYR=2001;     /* FILE YEAR */                                              
                                                                                
* READS IN FILE NAMES FROM LISTING OF ALL BF19 FILES;                           
DATA RAWDATA;                                                                   
  LENGTH FN $ 25;                                                               
  INFILE IN TRUNCOVER;                                                          
  INPUT FN $ 18-42;                                                             
RUN;                                                                            
                                                                                
DATA _NULL_;                                                                    
  SR = SUBSTR("&BYR",3,2);                                                      
  CALL SYMPUT('TR',SR);                                                         
RUN;                                                                            
                                                                                
DATA ALLFILE;                                                                   
  SET RAWDATA;                                                                  
  LENGTH BF19 $ 4 ST $ 2 YR $ 2 INDX $ 2 TYPE $ 7;                              
                                                                                
  * 041801 SCAN THE VALUE OF FN TO DETERMINE THE VALUES BETWEEN;                
  * PERIODS;                                                                    
  WORD1 = SCAN(FN,1,'.');                                                       
  WORD2 = SCAN(FN,2,'.');                                                       
  WORD3 = SCAN(FN,3,'.');                                                       
                                                                                
  ST=SUBSTR(FN,6,2);                                                            
  YR=SUBSTR(FN,9,2);                                                            
                                                                                
  IF ST="&XSTATE" THEN DELETE;                                                  
                                                                                
  * 041801 DETERMINE YRN BY CHECKING TO SEE IF 2 OR 3 DIGIT SHIPMENT;           
  * NUMBER WAS USED;                                                            
  IF LENGTH(WORD2) GE 8 THEN                                                    
    DO;                                                                         
      YRN=SUBSTR(FN,9,5);                                                       
      INDX=SUBSTR(FN,21,2);                                                     
    END;                                                                        
  ELSE                                                                          
     DO;                                                                        
       YRN=SUBSTR(FN,9,4);                                                      
       INDX=SUBSTR(FN,20,2);                                                    
     END;                                                                       
  * 041801 TYPE IS NOW THE VALUE OF WORD3 (NATMER FOR EXAMPLE);                 
  TYPE=SUBSTR(WORD3,1,6);                                                       
  BF19=SUBSTR(FN,1,4);                                                          
  LBR=SUBSTR(FN,6,2) || SUBSTR("&BYR",1,4);                                     
  FN=TRIM(FN);                                                                  
  IF BF19 NE 'BF19' THEN DELETE;                                                
  IF TYPE NE 'MORMER' THEN DELETE;                                              
  IF YR NE &TR THEN DELETE;                                                     
                                                                                
  * DELETES MERGED FILES THAT END WITH AN ALPHA EXTENSION;                      
  * BUT ON 12102001 DAVID ASKED US TO USE THE 2000 MORTALITY;                   
  * DATASET NAMES THAT END IN THE LETTER M;                                     
  * PREV WE WERE TOLD TO RETAIN THESE FILES BUT USE THE FINAL;                  
  * FILES AS LISTED IN THE EXCEL SPREADSHEET WITHOUT THE LETTER M;              
  * THE FOLLOWING IF STATEMENT AND THE ELSE ARE THE LATEST EDITIONS;            
  IF TYPE EQ 'MORMER' AND YR EQ '00' THEN                                       
    DO;                                                                         
      IF SUBSTR(INDX,1,1) GE 'A' AND SUBSTR(INDX,1,1) LE 'Z' THEN               
        DO;                                                                     
          IF SUBSTR(INDX,1,1) NE 'M' THEN DELETE;                               
        END;                                                                    
      IF SUBSTR(INDX,2,1) GE 'A' AND SUBSTR(INDX,2,1) LE 'Z' THEN               
        DO;                                                                     
          IF SUBSTR(INDX,2,1) NE 'M' THEN DELETE;                               
        END;                                                                    
    END;                                                                        
  ELSE                                                                          
    DO;                                                                         
      IF 'A' LE SUBSTR(INDX,1,1) LE 'Z' THEN DELETE;                            
      * 100901 ADDED THIS LINE;                                                 
      IF 'A' LE SUBSTR(INDX,2,1) LE 'Z' THEN DELETE;                            
    END;                                                                        
RUN;                                                                            
                                                                                
* CONVERT THE YR AND SHIPMENT NUMBER (YRN) TO NUMERIC BEFORE SORTING;           
* SO THE 3 DIGIT SHIP NOS ARE AT BOTTOM;                                        
DATA ALLFILE;                                                                   
  SET ALLFILE;                                                                  
  YRNUM = INPUT(YRN,5.);                                                        
RUN;                                                                            
                                                                                
PROC SORT DATA=ALLFILE;                                                         
  BY ST YRNUM INDX;                                                             
RUN;                                                                            
                                                                                
* CORRECT THE PROBLEM WITH THE EXTENSIONS OF THE BF19 MEDMER FILES;             
DATA ALLFILE;                                                                   
  SET ALLFILE;                                                                  
  EXT = SUBSTR(FN,23,3);                                                        
  IF EXT NE '' THEN DELETE;                                                     
RUN;                                                                            
                                                                                
* CHOOSE THE LATEST BF19 FROM THE DATASET;                                      
DATA ALLFILE;                                                                   
  SET ALLFILE;                                                                  
  BY ST YRNUM INDX;                                                             
  IF LAST.ST;                                                                   
  KEEP FN LBR YR;                                                               
RUN;                                                                            
                                                                                
DATA CURRENT;                                                                   
  SET ALLFILE;                                                                  
  KEEP LBR;                                                                     
RUN;                                                                            
                                                                                
DATA _NULL_;                                                                    
   SET CURRENT END=LAST;                                                        
   N = _N_;                                                                     
   IF LAST THEN CALL SYMPUT('TOTCUR',N);                                        
RUN;                                                                            
                                                                                
DATA CURRENT;                                                                   
  SET CURRENT;                                                                  
  LENGTH ST $ 2;                                                                
  ST= SUBSTR(LBR,1,2);                                                          
  KEEP ST;                                                                      
RUN;                                                                            
                                                                                
* GENERATE FILENAME STATEMENTS FROM DATASET OF LATEST BF19 FILES;               
OPTIONS NONOTES NOSOURCE PAGESIZE=2000;                                         
                                                                                
FILENAME FNAME '&NAME' DISP=NEW UNIT=FILE LRECL=80 BLKSIZE=1920                 
               RECFM=FB;                                                        
                                                                                
PROC PRINTTO LOG=FNAME NEW;                                                     
RUN;                                                                            
                                                                                
DATA _NULL_;                                                                    
  SET ALLFILE;                                                                  
  PUT 'FILENAME ' LBR "'" FN  "' " 'DISP=SHR;';                                 
RUN;                                                                            
                                                                                
DATA _NULL_;                                                                    
  SET CURRENT;                                                                  
  N = _N_;                                                                      
  PUT '%LET CUR' N "=" ST ";";                                                  
RUN;                                                                            
                                                                                
PROC PRINTTO;                                                                   
RUN;                                                                            
                                                                                
OPTIONS LS=133 CAPS NOTES SOURCE SOURCE2 MPRINT SYMBOLGEN;                      
                                                                                
%INCLUDE FNAME '&NAME';                                                         
%MACRO READIN;                                                                  
  %DO J = 1 %TO &TOTCUR;                                                        
    %DO K = &BYR %TO &BYR;                                                      
      %LET S = &&CUR&J;                                                         
      DATA IN&J&K;                                                              
      INFILE &S&K;                                                              
      INPUT @89 STRES $CHAR2. @;                                                
      IF STRES = "&XSTATEC";                                                    
        INPUT @5 CERTNO  $CHAR6. @47 ALIAS $CHAR1.                              
              @48 BLOCKA $CHAR5. @64 BLOCKB $CHAR7.                             
              @74 BLOCKC $CHAR3. @77 STOD $CHAR2.                               
              @79 BLOCKD $CHAR10.                                               
              @91 BLOCKE $CHAR7. @117 BLOCKF $CHAR1.                            
              @135 BLOCKG $CHAR8.;                                              
                                                                                
      IF ALIAS = '1' THEN DELETE;                                               
                                                                                
      RUN;                                                                      
    %END;                                                                       
  %END;                                                                         
%MEND READIN;                                                                   
                                                                                
%READIN                                                                         
                                                                                
%MACRO CURFILES;                                                                
  %DO K=1 %TO &TOTCUR;                                                          
    IN&K&BYR                                                                    
  %END;                                                                         
%MEND CURFILES;                                                                 
                                                                                
DATA RPT;                                                                       
  SET %CURFILES;                                                                
RUN;                                                                            
                                                                                
PROC SORT DATA=RPT;                                                             
  BY STOD CERTNO;                                                               
RUN;                                                                            
                                                                                
DATA FLFILE;                                                                    
  SET RPT;                                                                      
  * INITIALIZE PSEUDO CERTIFICATE NUMBER;                                       
  CERTINIT = 0;                                                                 
  CERTINIT + _N_;                                                               
  NEWCERT=PUT(CERTINIT,Z6.);                                                    
RUN;                                                                            
                                                                                
FILENAME FL "DWJ2.FLMOR01.USRES" DISP=NEW UNIT=NCHS LRECL=142                   
            BLKSIZE=14200 RECFM=FB;                                             
                                                                                
DATA _NULL_;                                                                    
  SET FLFILE;                                                                   
  FILE FL;                                                                      
  PUT @5 NEWCERT @48 BLOCKA @64 BLOCKB @74 BLOCKC @77 STOD @79 BLOCKD           
      @89 '10' @91 BLOCKE @117 BLOCKF @135 BLOCKG;                              
RUN;                                                                            
                                                                                
FILENAME MED "DWJ2.FLMOR01.USMED" DISP=NEW UNIT=NCHS LRECL=16                   
              BLKSIZE=8000 RECFM=FB;                                            
                                                                                
DATA _NULL_;                                                                    
  SET FLFILE;                                                                   
  FILE MED;                                                                     
  PUT @1 STOD @4 CERTNO @11 NEWCERT;                                            
RUN;                                                                            
                                                                                
/*                                                                              
//                                                                              
