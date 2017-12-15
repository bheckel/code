 /**********************************************************************        
 * Name: LATESHRT                                 (BQH0)   2003-04-16           
 *                                                                              
 * A shorter version of LATEBF19 that is meant to be %INCLUDE'd                 
 * rather than being copy and pasted into code.                                 
 *                                                                              
 * Assumptions:                                                                 
 *   1.  The caller declares these globals above the '%include LATESHRT'        
 *       statment:                                                              
 *       %global BYR EYR MERGETYPE RPT;                                         
 *                                                                              
 *   2.  The caller defines macrovariables BYR (begin yr YYYY), EYR             
 *       (end yr YYYY), MERGETYPE (NATMER, MORMER, FETMER, MEDMER or            
 *       MICMER) and RPT (print if 1, no print if 0).                           
 *                                                                              
 *   The caller then has access to FILENAME statement tags for each             
 *   state (e.g. AK2003) plus a SAS dataset (work.allyears) containing          
 *   the state filenames (e.g. BF19.AKX0365.MORMER).                            
 *                                                                              
 * This code should be synchronized with LATEBF19.                              
 *                                                                              
 * Update Log:                                                                  
 * 2003-05-28 (BQH0) Added WAIT=30 statment, ConvertMergeType macro.            
 * 2003-07-17 (BQH0) Allow caller to pass a macrovariable, &WANTFULLREVS,       
 *             to indicate 'capture full reviser "Z" suffixes'.                 
 **********************************************************************/        
                                                                                
%put !!!DEBUG  included code LATESHRT beginning...  DEBUG!!!;                   
                                                                                
 /* Points to a recently generated LISTC of the BF19 PDS. */                    
filename IN 'BQH0.BF19.DATASET' DISP=SHR WAIT=250;                              
                                                                                
data _NULL_;                                                                    
  if "&MERGETYPE" not in('FETMER', 'MEDMER', 'MORMER', 'NATMER', 'MICMER') then 
    do;                                                                         
      put "ERROR LATESHRT: Unknown mergetype: &MERGETYPE..  Exiting.";          
      abort abend;                                                              
    end;                                                                        
  if "&RPT" not in (0, 1) then                                                  
    do;                                                                         
      put "ERROR LATESHRT: Unknown print indicator: &RPT..  Exiting.";          
      abort abend;                                                              
    end;                                                                        
run;                                                                            
                                                                                
 /* For historical reasons, MERGETYPE is numeric. */                            
%macro ConvertMergeType;                                                        
  %if &MERGETYPE eq FETMER %then                                                
    %let MERGETYPE = 1;                                                         
  %else %if &MERGETYPE eq MEDMER %then                                          
    %let MERGETYPE = 2;                                                         
  %else %if &MERGETYPE eq MORMER %then                                          
    %let MERGETYPE = 3;                                                         
  %else %if &MERGETYPE eq NATMER %then                                          
    %let MERGETYPE = 4;                                                         
  %else %if &MERGETYPE eq MICMER %then                                          
    %let MERGETYPE = 5;                                                         
%mend ConvertMergeType;                                                         
%ConvertMergeType                                                               
                                                                                
                                                                                
 /*********************************************************************/        
 /* The following code was pasted in unmodified from LATEBF19.  Change          
  * LATEBF19 if any of this code is edited.  TODO see temporary                 
  * exception below (&wantfullrevs).                                            
  */                                                                            
                                                                                
DATA _NULL_;                                                                    
  IF &EYR LT &BYR THEN                                                          
    DO;                                                                         
      PUT '!!! BEGINNING YEAR (BYR) MUST BE LESS THAN OR '                      
          'EQUAL TO ENDING YEAR (EYR) !!!';                                     
      ABORT ABEND;                                                              
    END;                                                                        
  /* GET CURRENT YEAR */                                                        
  CALL SYMPUT("CYR", SUBSTR(PUT("&SYSDATE9"D,MMDDYY10.),7,4));                  
RUN;                                                                            
                                                                                
                                                                                
* SET VARIABLES FOR PROCESSING OF DATA BASED ON BYR, EYR AND CYR VALS;          
* CURPR: FLAG TO PROCESS CURRENT YEAR;                                          
* PRVPR: FLAG TO PROCESS PREVIOUS YEAR(S);                                      
%MACRO SETVARS;                                                                 
  %IF &BYR=&EYR AND &EYR=&CYR %THEN                                             
    %DO;                                                                        
      %LET CURPR=1;                                                             
      %LET PRVPR=0;                                                             
    %END;                                                                       
  %ELSE %IF &BYR=&EYR AND &EYR NE &CYR %THEN                                    
    %DO;                                                                        
      %LET CURPR=0;                                                             
      %LET PRVPR=1;                                                             
    %END;                                                                       
  %ELSE %IF &EYR=&CYR %THEN                                                     
    %DO;                                                                        
      %LET CURPR=1;                                                             
      %LET PRVPR=1;                                                             
    %END;                                                                       
  %ELSE                                                                         
    %DO;                                                                        
      %LET CURPR=0;                                                             
      %LET PRVPR=1;                                                             
    %END;                                                                       
%MEND SETVARS;                                                                  
%SETVARS                                                                        
                                                                                
                                                                                
* READ IN FILE NAMES FROM THE LISTC LISTING OF ALL BF19 FILES;                  
DATA RAWDATA;                                                                   
  LENGTH FN $ 25;                                                               
  INFILE IN TRUNCOVER;                                                          
  * E.G. BF19.AKX0120.MORMER1  ;                                                
  INPUT FN $ 18-42;                                                             
RUN;                                                                            
                                                                                
                                                                                
* DETERMINE WHICH BF19 FILENAMES TO USE FOR A GIVEN YEAR;                       
%MACRO GENYEAR(LYR=);                                                           
  * TWO DIGIT YEAR REPRESENTATION OF THE GIVEN YEAR;                            
  DATA _NULL_;                                                                  
    CALL SYMPUT('TYR', SUBSTR("&LYR",3,2));                                     
  RUN;                                                                          
                                                                                
  * FILTER ONLY DATA SPECIFIED BY MERGETYPE;                                    
  %MACRO GENTYPE;                                                               
    %IF &MERGETYPE = 1 %THEN                                                    
      %DO;                                                                      
        DATA ALLF&LYR;                                                          
          SET ALLF&LYR;                                                         
          IF TYPE NE 'FETMER' THEN DELETE;                                      
          IF YR NE &TYR THEN DELETE;                                            
        RUN;                                                                    
      %END;                                                                     
    %ELSE %IF &MERGETYPE = 2 %THEN                                              
      %DO;                                                                      
        DATA ALLF&LYR;                                                          
          SET ALLF&LYR;                                                         
          IF TYPE NE 'MEDMER' THEN DELETE;                                      
          IF YR NE &TYR THEN DELETE;                                            
        RUN;                                                                    
      %END;                                                                     
    %ELSE %IF &MERGETYPE = 3 %THEN                                              
      %DO;                                                                      
        DATA ALLF&LYR;                                                          
          SET ALLF&LYR;                                                         
          IF TYPE NE 'MORMER' THEN DELETE;                                      
          IF YR NE &TYR THEN DELETE;                                            
        RUN;                                                                    
      %END;                                                                     
    %ELSE %IF &MERGETYPE = 4 %THEN                                              
      %DO;                                                                      
        DATA ALLF&LYR;                                                          
          SET ALLF&LYR;                                                         
          IF TYPE NE 'NATMER' THEN DELETE;                                      
          IF YR NE &TYR THEN DELETE;                                            
        RUN;                                                                    
      %END;                                                                     
    %ELSE %IF &MERGETYPE = 5 %THEN                                              
      %DO;                                                                      
        DATA ALLF&LYR;                                                          
          SET ALLF&LYR;                                                         
          IF TYPE NE 'MICMER' THEN DELETE;                                      
          IF YR NE &TYR THEN DELETE;                                            
        RUN;                                                                    
      %END;                                                                     
  %MEND GENTYPE;                                                                
                                                                                
  DATA ALLF&LYR;                                                                
    SET RAWDATA;                                                                
    LENGTH ST $ 2  YR $ 2  INDX $ 2  TYPE $ 6  FULLTYPE $ 8;                    
                                                                                
    * PARSE THE NAME OF THE FILE ON THE MAINFRAME;                              
    * E.G. BF19.AKX0199.MORMER10  ;                                             
    FN=TRIM(FN);                                                                
    * E.G. BF19;                                                                
    WORD1=SCAN(FN,1,'.');                                                       
    * E.G. AKX0199;                                                             
    WORD2=SCAN(FN,2,'.');                                                       
    * E.G. MORMER1;                                                             
    WORD3=SCAN(FN,3,'.');                                                       
    * E.G. AK;                                                                  
    ST=SUBSTR(FN,6,2);                                                          
    * E.G. 01;                                                                  
    YR=SUBSTR(FN,9,2);                                                          
    * SHIPMENTS RANGE FROM 001-999;                                             
    * E.G. 99 (REMOVES TRAILING PERIOD, IF ANY);                                
    SHIP=TRANSLATE(SUBSTR(FN,11,3),'','.');                                     
    * E.G. 0199 (2 DIGIT YEAR PLUS 2 OR 3 DIGIT SHIPMENT NUM);                  
    YRN=TRANSLATE(SUBSTR(FN,9,5),'','.');                                       
    * E.G. MORMER;                                                              
    TYPE=SUBSTR(WORD3,1,6);                                                     
    * E.G. MORMER10;                                                            
    FULLTYPE=SUBSTR(WORD3,1,8);                                                 
    * E.G. 10;                                                                  
    INDX=SUBSTR(FULLTYPE,7,2);                                                  
    * E.G. AK2002 (LIBNAME TAG);                                                
    TAG = ST || SUBSTR("&LYR",1,4);                                             
                                                                                
    IF WORD1 NE 'BF19' THEN DELETE;                                             
                                                                                
    * 2003-01-09 (BQH0) MEDICAL IS USING ALPHA EXTENSIONS;                      
    * EXTENDED THE IF-THEN LOOP TO CAPTURE FILES LIKE 'MEDMERX';                
    * FILENAMES CAN LOOK LIKE BF19.AKX0199.MEDMER (NORMAL) OR;                  
    *                         BF19.AKX0199.MEDMER1 (1999,2000) OR;              
    *                         BF19.AKX0199.MEDMER10 (1999,2000) OR;             
    *                         BF19.AKX0199.MEDMERR (2001) OR;                   
    *                         BF19.AKX0199.MEDMERX (2001) OR;                   
    IF TYPE EQ 'NATMER' THEN                                                    
      DO;                                                                       
        IF SUBSTR(INDX,1,1) GE 'A' AND SUBSTR(INDX,1,1) LE 'Z' THEN             
          DO;                                                                   
            /* 2003-07-17 Requested to show 'Z' extensions in the IntrNet app.  
             * TODO put this code (in lowercase) in LATEBF19 master!!           
             */                                                                 
            /* The IntrNet project needs full revisers, using e.g.              
             * NATMERZ, if this flag is set so don't skip them.                 
             */                                                                 
            if "&WANTFULLREVS" ne '1' then                                      
              IF SUBSTR(INDX,1,1) NE 'M' THEN DELETE;                           
          END;                                                                  
        IF SUBSTR(INDX,2,1) GE 'A' AND SUBSTR(INDX,2,1) LE 'Z' THEN             
          DO;                                                                   
            IF SUBSTR(INDX,2,1) NE 'M' THEN DELETE;                             
          END;                                                                  
      END;                                                                      
    ELSE IF TYPE EQ 'MORMER' THEN                                               
      DO;                                                                       
        IF SUBSTR(INDX,1,1) GE 'A' AND SUBSTR(INDX,1,1) LE 'Z' THEN             
          DO;                                                                   
            /* 2003-07-17 Requested to show 'Z' extensions in the IntrNet app.  
             * TODO put this code (in lowercase) in LATEBF19 master!!           
             */                                                                 
            /* The IntrNet project needs full revisers, using e.g.              
             * MORMERZ, if this flag is set so don't skip them.                 
             */                                                                 
            if "&WANTFULLREVS" ne '1' then                                      
              IF SUBSTR(INDX,1,1) NE 'M' THEN DELETE;                           
          END;                                                                  
        IF SUBSTR(INDX,2,1) GE 'A' AND SUBSTR(INDX,2,1) LE 'Z' THEN             
          DO;                                                                   
            IF SUBSTR(INDX,2,1) NE 'M' THEN DELETE;                             
          END;                                                                  
      END;                                                                      
    ELSE IF TYPE EQ 'MEDMER' THEN                                               
      DO;                                                                       
        * ELIMINATE MEDMER GARBAGE LIKE BF19.XOX0216.MEDMER;                    
        IF ST IN ('AK','AL','AR','AS','AZ','CA','CO','CT','DC','DE',            
                  'FL','GA','GU','HI','IA','ID','IL','IN','KS','KY',            
                  'LA','MA','MD','ME','MI','MN','MO','MP','MS','MT',            
                  'NC','ND','NE','NH','NJ','NM','NV','NY','OH','OK',            
                  'OR','PA','PR','RI','SC','SD','TN','TX','UT','VA',            
                  'VI','VT','WA','WI','WV','WY','YC');                          
        * MEDICAL HAS BIZARRE ENTRIES LIKE 'MEX01AA';                           
        IF SHIP GE 'A' AND SHIP LE 'Z' THEN DELETE;                             
        * NEED TO EVENTUALLY DO A NUMERIC (NOT ASCII) SORT;                     
        IF INDX GE '0' AND INDX LE '9' THEN                                     
          DO;                                                                   
            IF INDX NE . THEN                                                   
              INDX=INPUT(INDX, F3.);                                            
          END;                                                                  
      END;                                                                      
    ELSE IF TYPE EQ 'MICMER' THEN                                               
      DO;                                                                       
        * WANT TO SKIP FILES WITH THE TRAILING WORD 'BACKUP';                   
        FROMEND = LENGTH(FN) - 5;                                               
        IF SUBSTR(FN, FROMEND, 6) EQ 'BACKUP' THEN DELETE;                      
      END;                                                                      
    ELSE                                                                        
      DO;                                                                       
        IF 'A' LE SUBSTR(INDX,1,1) LE 'Z' THEN DELETE;                          
        IF 'A' LE SUBSTR(INDX,2,1) LE 'Z' THEN DELETE;                          
      END;                                                                      
  RUN;                                                                          
                                                                                
  * RUN NESTED MACRO TO FILTER DATA SET FOR SPECIFIED TYPE (MORMER, ;           
  * MEDMER, ETC.);                                                              
  %GENTYPE                                                                      
                                                                                
  * 041801 CONVERT THE YRN VALUE WHICH IS THE YR AND SHIPMENT NUMBER;           
  * TO NUMERIC BEFORE SORTING SO THE 3 DIGIT SHIP NOS ARE AT BOTTOM;            
  * 091301 I CHANGED THE CONVERSION FROM CHAR TO NUM BECAUSE IT WAS;            
  * NOT WORKING FOR MICMER 1998 NOW THAT IT IS USING THE INPUT;                 
  * FUNCTION IT APPEARS TO BE FINE;                                             
  * 091201 CHANGED THE INPUT STATEMENT TO 5 FROM 4 BECAUSE IT NO;               
  * LONGER CAPTURED THE 3 DIGIT SHIPMENT NUMBERS;                               
  DATA ALLF&LYR;                                                                
    SET ALLF&LYR;                                                               
    YRNUM = INPUT(YRN,5.);                                                      
  RUN;                                                                          
                                                                                
  PROC SORT DATA=ALLF&LYR;                                                      
    BY ST YRNUM INDX;                                                           
  RUN;                                                                          
                                                                                
  * CORRECT THE PROBLEM OF 4TH LEVEL EXTENSIONS OF;                             
  * THE BF19 MEDMER FILES (E.G. 'BF19.NJX0110.MEDMER.PENDINGS');                
  DATA ALLF&LYR;                                                                
    SET ALLF&LYR;                                                               
    EXT = SUBSTR(FN,23,3);                                                      
    IF EXT NE '' THEN DELETE;                                                   
  RUN;                                                                          
                                                                                
  * CHOOSE THE LATEST BF19 FROM THE DATASET;                                    
  DATA ALLF&LYR;                                                                
    SET ALLF&LYR;                                                               
    BY ST YRNUM INDX;                                                           
    IF LAST.ST;                                                                 
    KEEP FN TAG YR;                                                             
  RUN;                                                                          
%MEND GENYEAR;                                                                  
                                                                                
                                                                                
* HANDLE POTENTIAL MULTI-YEAR REQUESTS BY ITERATING AND COMBINING;              
%MACRO ALLYEARS;                                                                
  %DO I=&BYR %TO &EYR;                                                          
    %GENYEAR(LYR=&I)                                                            
  %END;                                                                         
                                                                                
  %MACRO COMBINE;                                                               
    %DO I=&BYR %TO &EYR;                                                        
      ALLF&I                                                                    
    %END;                                                                       
  %MEND COMBINE;                                                                
                                                                                
  * ALLYEARS HOLDS THE (57 X NUM YEARS REQUESTED) MOST RECENT BF19 FILES;       
  DATA ALLYEARS;                                                                
    SET %COMBINE;                                                               
  RUN;                                                                          
                                                                                
  %IF &RPT=1 %THEN %DO;                                                         
    PROC PRINT;                                                                 
    RUN;                                                                        
  %END;                                                                         
                                                                                
  * USED BY %READIN BELOW;                                                      
  DATA CURRENT;                                                                 
    SET ALLYEARS;                                                               
    MYR = SUBSTR("&CYR",3,2);                                                   
    IF YR=MYR;                                                                  
    KEEP TAG;                                                                   
  RUN;                                                                          
                                                                                
  * USED BY %READIN BELOW;                                                      
  DATA _NULL_;                                                                  
    SET CURRENT END=LAST;                                                       
    N = _N_;                                                                    
    IF LAST THEN CALL SYMPUT('TOTCUR',N);                                       
  RUN;                                                                          
%MEND ALLYEARS;                                                                 
%ALLYEARS                                                                       
                                                                                
                                                                                
* GENERATE FILENAME STATEMENTS FROM DATASET ALLYEARS WHICH CONTAINS ;           
* THE LATEST BF19 FILENAMES;                                                    
FILENAME FLEXCODE CATALOG 'WORK.FLEX.SOURCE';                                   
                                                                                
DATA _NULL_;                                                                    
  SET ALLYEARS;                                                                 
  FILE FLEXCODE;                                                                
  PUT 'FILENAME ' TAG "'" FN "' DISP=SHR WAIT=30;";                             
RUN;                                                                            
                                                                                
%INCLUDE FLEXCODE / SOURCE2;                                                    
                                                                                
 /* End of pasted in LATEBF19 logic */                                          
 /*********************************************************************/        
                                                                                
%put !!!DEBUG  ...included code LATESHRT ending  DEBUG!!!;                      
