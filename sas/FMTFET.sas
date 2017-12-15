//BQH0FMTF JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M             
//STEP1    EXEC SAS90,TIME=100,OPTIONS='MEMSIZE=0'                              
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)                                     
//SYSIN    DD *                                                                 
                                                                                
OPTIONS NOSOURCE;                                                               
 /********************************************************************          
  * PROGRAM NAME: FMTFET                                                        
  *               (FORMERLY NAMED TSFAAOX)                                      
  *                                                                             
  *  DESCRIPTION: FORMATS USED BY FETAL DEATH NON-REVISER TSA REPORTS.          
  *               LEADING DIGITS ARE FOR SORTING PURPOSES ONLY.                 
  *                                                                             
  *     CALLS TO:                                                               
  *    CALLED BY:                                                               
  *                                                                             
  *   PROGRAMMER: BQH0                                                          
  * DATE WRITTEN: 2003-08-25                                                    
  *                                                                             
  *   UPDATE LOG:                                                               
  * 2004-01-13 (BQH0) FIXED MOTHERS RACE TYPO                                   
  * 2004-01-14 (BQH0) FIXED EDUCATION TYPO                                      
  * 2004-01-14 (BQH0) FIX AGE OF MOTHER ERROR                                   
  * 2004-01-30 (KJK4) FIXED PROBLEMS WITH BIRTHWEIGHT RANGES                    
  * 2004-02-09 (KJK4) ADDED CODE TO CREATE ODS VERSIONS OF FORMATS              
  * 2004-03-30 (BQH0) LOOP ONCE FOR PRINTER, ONCE FOR ODS                       
  *******************************************************************/          
OPTIONS MLOGIC MPRINT SYMBOLGEN;                                                
                                                                                
%MACRO LOOP;                                                                    
  %LOCAL I C;                                                                   
                                                                                
  %DO I=1 %TO 2;                                                                
    %IF &I EQ 1 %THEN                                                           
      %DO;                                                                      
        * USE THIS LIBNAME & '!' BREAK MARK FOR MAINFRAME PRINTING;             
        LIBNAME FLIB 'DWJ2.FET1989.FORMAT.LIB' DISP=OLD WAIT=30;                
        %LET C=!;                                                               
      %END;                                                                     
    %ELSE                                                                       
      %DO;                                                                      
        * USE THIS LIBNAME & CARAT-LITTLE N BREAK MARK FOR ODS PRINTING;        
        LIBNAME FLIB 'DWJ2.FET1989.FORMAT.ODSLIB' DISP=OLD WAIT=30;             
        %LET C=%STR(µn);                                                        
      %END;                                                                     
                                                                                
    PROC FORMAT LIBRARY=FLIB;                                                   
      /* LABELS USED AS A HEADER FOR EACH GROUP. */                             
      VALUE LABEL (NOTSORTED)                                                   
          1='MO OF BIRTH'                                                       
          2='DAY OF BIRTH'                                                      
          3='SEX'                                                               
          4='PLACE OF DELIVERY'                                                 
          5='ATTENDANT'                                                         
          6='MOTHER MON OF BIRTH'                                               
          7='MOTHER DAY OF BIRTH'                                               
          8='MOTHER YEAR OF BIRTH'                                              
          9='FATHER MONTH OF BIRTH'                                             
         10='FATHER DAY OF BIRTH'                                               
         11='FATHER YEAR OF BIRTH'                                              
         12='MARITAL STATUS'                                                    
         13='HISPANIC ORIGIN-MOTHER'                                            
         14='HISPANIC ORIGIN-FATHER'                                            
         15='RACE OF MOTHER'                                                    
         16='RACE OF FATHER'                                                    
         17='EDUCATION OF MOTHER'                                               
         18='EDUCATION OF FATHER'                                               
         19='AGE OF MOTHER'                                                     
         20='COMP AGE OF MOTHER'                                                
         21='AGE OF FATHER'                                                     
         22='COMP AGE OF FATHER'                                                
         23='CHILDREN NOW LIVING'                                               
         24='CHILDREN NOW DEAD'                                                 
         25='OTHER TERMINATIONS'                                                
         26='MONTH LAST LIVE BIRTH'                                             
         27='YEAR LAST LIVE BIRTH'                                              
         28='MONTH LAST NORM MENSES'                                            
         29='DAY LAST NORM MENSES'                                              
         30='YEAR LAST NORM MENSES'                                             
         36='COMPUTED GESTATION'                                                
         37='ESTIMATED GESTATION'                                               
         38='MO PRENATAL CARE BEG'                                              
         39='N MO PRENATAL CARE BEG'                                            
         40='TOT PRENATAL VISITS'                                               
         41='PLURALITY'                                                         
         42='BIRTH WEIGHT'                                                      
         43='TOBACCO USE'                                                       
         44='TOB USE & CIGAR/DAY'                                               
         45='ALCOHOL USE'                                                       
         46='ALC USE & DRINKS/WK'                                               
         47='WEIGHT GAINED'                                                     
         /* SYNTHETIC */                                                        
         66='LOW BIRTH WEIGHT'                                                  
         /* SYNTHETIC */                                                        
         67='VERY LOW BIRTH WEIGHT'                                             
        ;                                                                       
      /* VARIABLE NAMES FROM LIBRARY */                                         
      VALUE VNAME (NOTSORTED)                                                   
          1='MONTH'                                                             
          2='DAY'                                                               
          3='SEX'                                                               
          4='BIRTHPLC'                                                          
          5='ATTEND'                                                            
          6='MOTHMO'                                                            
          7='MOTHDAY'                                                           
          8='MOTHYR'                                                            
          9='FATHMO'                                                            
         10='FATHDAY'                                                           
         11='FATHYR'                                                            
         12='MARSTAT'                                                           
         13='MOTHHISP'                                                          
         14='FATHHISP'                                                          
         15='MOTHRACE'                                                          
         16='FATHRACE'                                                          
         17='MOTHEDUC'                                                          
         18='FATHEDUC'                                                          
         19='MOTHAGE'                                                           
         20='COMPMYR'                                                           
         21='FATHAGE'                                                           
         22='COMPFYR'                                                           
         23='NOWLIVE'                                                           
         24='NOWDEAD'                                                           
         25='OTHTERM'                                                           
         26='LBIRTHMO'                                                          
         27='LBIRTHYR'                                                          
         28='MENSEMO'                                                           
         29='MENSEDY'                                                           
         30='MENSEYR'                                                           
         36='COMPGEST'                                                          
         37='GEST_WKS'                                                          
         38='CBEGMO'                                                            
         39='NBEGMO'                                                            
         40='TOTVISTS'                                                          
         41='PLURAL'                                                            
         42='WGT_UNIT'                                                          
         43='TOB_USE'                                                           
         44='TOB_DAY'                                                           
         45='ALC_USE'                                                           
         46='ALC_DAY'                                                           
         47='WGT_GAIN'                                                          
         /* SYNTHETIC, ACTUALLY LOW BIRTH WEIGHT. */                            
         66='WGT_UNIT'                                                          
         /* SYNTHETIC, ACTUALLY VERY LOW BIRTH WEIGHT. */                       
         67='WGT_UNIT'                                                          
        ;                                                                       
                                                                                
                                                                                
      /* MONTH OF BIRTH */                                                      
      VALUE $V1F (NOTSORTED)                                                    
         '01' = '01JANUARY(01)'                                                 
         '02' = '02FEBRUARY(02)'                                                
         '03' = '03MARCH(03)'                                                   
         '04' = '04APRIL(04)'                                                   
         '05' = '05MAY(05)'                                                     
         '06' = '06JUNE(06)'                                                    
         '07' = '07JULY(07)'                                                    
         '08' = '08AUGUST(08)'                                                  
         '09' = '09SEPTEMBER(09)'                                               
         '10' = '10OCTOBER(10)'                                                 
         '11' = '11NOVEMBER(11)'                                                
         '12' = '12DECEMBER(12)'                                                
         '99' = '13NOTCLASS(99)'                                                
        OTHER = '14OTHER'                                                       
        ;                                                                       
      /* DAY OF BIRTH */                                                        
      VALUE $V2F (NOTSORTED)                                                    
                  '01','02','03','04','05','06' = '0101-06'                     
                                           '07' = '0207'                        
             '08','09','10','11','12','13','14' = '0308-14'                     
                                           '15' = '0415'                        
        '16','17','18','19','20','21','22','23' = '0516-23'                     
                                           '24' = '0624'                        
                  '25','26','27','28','29','30' = '0725-30'                     
                                           '31' = '0831'                        
                                           '99' = '09NOTCLASS(99)'              
                                          OTHER = '10OTHER'                     
                                          ;                                     
      /* SEX */                                                                 
      VALUE $V3F (NOTSORTED)                                                    
          '1' = '01MALE(1)'                                                     
          '2' = '02FEMALE(2)'                                                   
          '9' = '03NOTCLASS(9)'                                                 
        OTHER = '04OTHER'                                                       
        ;                                                                       
      /* PLACE OF DELIVERY */                                                   
      VALUE $V4F (NOTSORTED)                                                    
          '1' = '01HOSPITAL(1)'                                                 
          '2' = '02NAMED PLACE(2)'                                              
          '3' = '03DOA(3)'                                                      
          '9' = '06NOTCLASS(9)'                                                 
        OTHER = '07OTHER'                                                       
        ;                                                                       
      /* ATTENDANT */                                                           
      VALUE $V5F (NOTSORTED)                                                    
          '1' = '01M.D.(1)'                                                     
          '2' = '02D.O.(2)'                                                     
          '3' = '03C.N.M(3)'                                                    
          '4' = '04OTHER MIDWIFE(4)'                                            
          '5' = '05OTHER(5)'                                                    
          '9' = '06NOTCLASS(9)'                                                 
        OTHER = '07OTHER'                                                       
        ;                                                                       
      /* MOTHER MONTH OF BIRTH */                                               
      VALUE $V6F (NOTSORTED)                                                    
         '01' = '01JANUARY(01)'                                                 
         '02' = '02FEBRUARY(02)'                                                
         '03' = '03MARCH(03)'                                                   
         '04' = '04APRIL(04)'                                                   
         '05' = '05MAY(05)'                                                     
         '06' = '06JUNE(06)'                                                    
         '07' = '07JULY(07)'                                                    
         '08' = '08AUGUST(08)'                                                  
         '09' = '09SEPTEMBER(09)'                                               
         '10' = '10OCTOBER(10)'                                                 
         '11' = '11NOVEMBER(11)'                                                
         '12' = '12DECEMBER(12)'                                                
         '99' = '13NOTCLASS(99)'                                                
        OTHER = '14OTHER'                                                       
        ;                                                                       
      /* MOTHER DAY OF BIRTH */                                                 
      VALUE $V7F (NOTSORTED)                                                    
                  '01','02','03','04','05','06' = '0101-06'                     
                                           '07' = '0207'                        
             '08','09','10','11','12','13','14' = '0308-14'                     
                                           '15' = '0415'                        
        '16','17','18','19','20','21','22','23' = '0516-23'                     
                                           '24' = '0624'                        
                  '25','26','27','28','29','30' = '0725-30'                     
                                           '31' = '0831'                        
                                           '99' = '09NOTCLASS(99)'              
                                          OTHER = '10OTHER'                     
                                          ;                                     
      /* MOTHER YEAR OF BIRTH */                                                
      VALUE $V8F (NOTSORTED)                                                    
        'AA' = '01NOTCLASS(9999)'                                               
         ;                                                                      
      /* FATHER MONTH OF BIRTH */                                               
      VALUE $V9F (NOTSORTED)                                                    
         '01' = '01JANUARY(01)'                                                 
         '02' = '02FEBRUARY(02)'                                                
         '03' = '03MARCH(03)'                                                   
         '04' = '04APRIL(04)'                                                   
         '05' = '05MAY(05)'                                                     
         '06' = '06JUNE(06)'                                                    
         '07' = '07JULY(07)'                                                    
         '08' = '08AUGUST(08)'                                                  
         '09' = '09SEPTEMBER(09)'                                               
         '10' = '10OCTOBER(10)'                                                 
         '11' = '11NOVEMBER(11)'                                                
         '12' = '12DECEMBER(12)'                                                
         '99' = '13NOTCLASS(99)'                                                
        OTHER = '14OTHER'                                                       
        ;                                                                       
      /* FATHER DAY OF BIRTH */                                                 
      VALUE $V10F (NOTSORTED)                                                   
                  '01','02','03','04','05','06' = '0101-06'                     
                                           '07' = '0207'                        
             '08','09','10','11','12','13','14' = '0308-14'                     
                                           '15' = '0415'                        
        '16','17','18','19','20','21','22','23' = '0516-23'                     
                                           '24' = '0624'                        
                  '25','26','27','28','29','30' = '0725-30'                     
                                           '31' = '0831'                        
                                           '99' = '09NOTCLASS(99)'              
                                          OTHER = '10OTHER'                     
                                          ;                                     
      /* FATHER YEAR OF BIRTH */                                                
      VALUE $V11F (NOTSORTED)                                                   
        'AA' = '01NOTCLASS(9999)'                                               
         ;                                                                      
      /* MARITAL STATUS */                                                      
      VALUE $V12F (NOTSORTED)                                                   
          '1' = '01MARRIED(1)'                                                  
          '2' = '02UNMARRIED(2)'                                                
          '3' = '03SPECIAL (P.R.)(3)'                                           
          '9' = '04NOTCLASS(9)'                                                 
        OTHER = '05OTHER'                                                       
        ;                                                                       
      /* HISPANIC ORIGIN-MOTHER */                                              
      VALUE $V13F (NOTSORTED)                                                   
          '0' = '01NON-HISPANIC(0)'                                             
          '1' = '02MEXICAN(1)'                                                  
          '2' = '03PUERTO RICAN(2)'                                             
          '3' = '04CUBAN(3)'                                                    
          '4' = '05C. OR S. AMERICAN(4)'                                        
          '5' = '06OTH AND UNK HISP(5)'                                         
          '9' = '07NOTCLASS(9)'                                                 
        OTHER = '08OTHER'                                                       
        ;                                                                       
      /* HISPANIC ORIGIN-FATHER */                                              
      VALUE $V14F (NOTSORTED)                                                   
          '0' = '01NON-HISPANIC(0)'                                             
          '1' = '02MEXICAN(1)'                                                  
          '2' = '03PUERTO RICAN(2)'                                             
          '3' = '04CUBAN(3)'                                                    
          '4' = '05C. OR S. AMERICAN(4)'                                        
          '5' = '06OTH AND UNK HISP(5)'                                         
          '9' = '07NOTCLASS(9)'                                                 
        OTHER = '08OTHER'                                                       
        ;                                                                       
      /* RACE OF MOTHER */                                                      
      VALUE $V15F (NOTSORTED)                                                   
        '10' = '01ASIAN INDIAN(A)'                                              
        '11' = '02KOREAN(B)'                                                    
        '12' = '03SAMOAN(C)'                                                    
        '13' = '04VIETNAMESE(D)'                                                
        '14' = '05GUAMANIAN(E)'                                                 
        '15' = '06MULTI-RACIAL(F)'                                              
         '0' = '07OTHERS(O)'                                                    
         '1' = '08WHITE(1)'                                                     
         '2' = '09BLACK(2)'                                                     
         '3' = '10INDIAN(3)'                                                    
         '4' = '11CHINESE(4)'                                                   
         '5' = '12JAPANESE(5)'                                                  
         '6' = '13HAWAIIAN(6)'                                                  
         '7' = '14FILIPINO(7)'                                                  
         '8' = '15OTH ASIAN OR PAC ISL(8)'                                      
         '9' = '16NOT CLASS(9)'                                                 
       OTHER = '17OTHER'                                                        
       ;                                                                        
      /* RACE OF FATHER */                                                      
      VALUE $V16F (NOTSORTED)                                                   
        '10' = '01ASIAN INDIAN(A)'                                              
        '11' = '02KOREAN(B)'                                                    
        '12' = '03SAMOAN(C)'                                                    
        '13' = '04VIETNAMESE(D)'                                                
        '14' = '05GUAMANIAN(E)'                                                 
        '15' = '06MULTI-RACIAL(F)'                                              
         '0' = '07OTHERS(O)'                                                    
         '1' = '08WHITE(1)'                                                     
         '2' = '09BLACK(2)'                                                     
         '3' = '10INDIAN(3)'                                                    
         '4' = '11CHINESE(4)'                                                   
         '5' = '12JAPANESE(5)'                                                  
         '6' = '13HAWAIIAN(6)'                                                  
         '7' = '14FILIPINO(7)'                                                  
         '8' = '15OTH ASIAN OR PAC ISL(8)'                                      
         '9' = '16NOT CLASS(9)'                                                 
       OTHER = '17OTHER'                                                        
       ;                                                                        
      /* EDUCATION OF MOTHER */                                                 
      VALUE $V17F (NOTSORTED)                                                   
         '00' = '010 YEARS'                                                     
         '01' = '021 YEAR'                                                      
         '02' = '032 YEARS'                                                     
         '03' = '043 YEARS'                                                     
         '04' = '054 YEARS'                                                     
         '05' = '065 YEARS'                                                     
         '06' = '076 YEARS'                                                     
         '07' = '087 YEARS'                                                     
         '08' = '098 YEARS'                                                     
         '09' = '109 YEARS'                                                     
         '10' = '1110 YEARS'                                                    
         '11' = '1211 YEARS'                                                    
         '12' = '1312 YEARS'                                                    
         '13' = '1413 YEARS'                                                    
         '14' = '1514 YEARS'                                                    
         '15' = '1615 YEARS'                                                    
         '16' = '1716 YEARS'                                                    
         '17' = '1817 YEARS'                                                    
         '99' = '19UNKNOWN(99)'                                                 
        OTHER = '20OTHER'                                                       
         'AA' = '21CONS. EDIT:AGE/EDUC'                                         
        ;                                                                       
      /* EDUCATION OF FATHER */                                                 
      VALUE $V18F (NOTSORTED)                                                   
         '00' = '010 YEARS'                                                     
         '01' = '021 YEAR'                                                      
         '02' = '032 YEARS'                                                     
         '03' = '043 YEARS'                                                     
         '04' = '054 YEARS'                                                     
         '05' = '065 YEARS'                                                     
         '06' = '076 YEARS'                                                     
         '07' = '087 YEARS'                                                     
         '08' = '098 YEARS'                                                     
         '09' = '109 YEARS'                                                     
         '10' = '1110 YEARS'                                                    
         '11' = '1211 YEARS'                                                    
         '12' = '1312 YEARS'                                                    
         '13' = '1413 YEARS'                                                    
         '14' = '1514 YEARS'                                                    
         '15' = '1615 YEARS'                                                    
         '16' = '1716 YEARS'                                                    
         '17' = '1817 YEARS'                                                    
         '99' = '19UNKNOWN(99)'                                                 
        OTHER = '20OTHER'                                                       
         'AA' = '21CONS. EDIT:AGE/EDUC'                                         
        ;                                                                       
      /* AGE OF MOTHER */                                                       
      VALUE $V19F (NOTSORTED)                                                   
         LOW-' 9' = '01<10 (ABS EDIT)'                                          
        '10'-'14' = '0210-14'                                                   
        '15'-'19' = '0315-19'                                                   
        '20'-'24' = '0420-24'                                                   
        '25'-'29' = '0525-29'                                                   
        '30'-'34' = '0630-34'                                                   
        '35'-'39' = '0735-39'                                                   
        '40'-'44' = '0840-44'                                                   
        '45'-'49' = '0945-49'                                                   
        '50'-'54' = '1050-54'                                                   
        '55'-'59' = '1155-59 (ABS EDIT)'                                        
        '60'-'98' = '12>59 (ABS EDIT)'                                          
             '99' = '13NOTCLASS(99)'                                            
            OTHER = '14OTHER'                                                   
            ;                                                                   
      /* COMP AGE OF MOTHER */                                                  
      VALUE $V20F (NOTSORTED)                                                   
        '000'-'009' = '01<10 (ABS EDIT)'                                        
        '010'-'014' = '0210-14'                                                 
        '015'-'019' = '0315-19'                                                 
        '020'-'024' = '0420-24'                                                 
        '025'-'029' = '0525-29'                                                 
        '030'-'034' = '0630-34'                                                 
        '035'-'039' = '0735-39'                                                 
        '040'-'044' = '0840-44'                                                 
        '045'-'049' = '0945-49'                                                 
        '050'-'054' = '1050-54'                                                 
        '055'-'059' = '1155-59 (ABS EDIT)'                                      
        '060'-'098' = '12>59 (ABS EDIT)'                                        
            OTHER = '13CANNOT COMPUTE'                                          
            ;                                                                   
      /* AGE OF FATHER */                                                       
      VALUE $V21F (NOTSORTED)                                                   
         LOW-' 9' = '01<10 (ABS EDIT)'                                          
        '10'-'14' = '0210-14'                                                   
        '15'-'19' = '0315-19'                                                   
        '20'-'24' = '0420-24'                                                   
        '25'-'29' = '0525-29'                                                   
        '30'-'34' = '0630-34'                                                   
        '35'-'39' = '0735-39'                                                   
        '40'-'44' = '0840-44'                                                   
        '45'-'49' = '0945-49'                                                   
        '50'-'54' = '1050-54'                                                   
        '55'-'59' = '1155-59'                                                   
        '60'-'64' = '1260-64'                                                   
        '65'-'98' = '13>64 (COND. EDIT)'                                        
             '99' = '14NOTCLASS(99)'                                            
            OTHER = '15OTHER'                                                   
            ;                                                                   
      /* COMP AGE OF FATHER */                                                  
      VALUE $V22F (NOTSORTED)                                                   
        '000'-'009' = '01<10 (ABS EDIT)'                                        
        '010'-'014' = '0210-14'                                                 
        '015'-'019' = '0315-19'                                                 
        '020'-'024' = '0420-24'                                                 
        '025'-'029' = '0525-29'                                                 
        '030'-'034' = '0630-34'                                                 
        '035'-'039' = '0735-39'                                                 
        '040'-'044' = '0840-44'                                                 
        '045'-'049' = '0945-49'                                                 
        '050'-'054' = '1050-54'                                                 
        '055'-'059' = '1155-59'                                                 
        '060'-'064' = '1260-64'                                                 
        '065'-'098' = '13>64 (COND. EDIT)'                                      
             OTHER = '14CANNOT COMPUTE'                                         
             ;                                                                  
      /* CHILDREN NOW LIVING */                                                 
      VALUE $V23F (NOTSORTED)                                                   
                       '00' = '01NONE(00)'                                      
                  '01'-'05' = '0201-05'                                         
                  '06'-'10' = '0306-10'                                         
                  '11'-'20' = '0411-20'                                         
        '21'-'76','78'-'98' = '0521-98'                                         
                       '77' = '06BLANK(77)'                                     
                       '99' = '07NOTCLASS(99)'                                  
                      OTHER = '08OTHER'                                         
                       'AA' = '09CONS. EDIT:AGE/CHILDREN'                       
                      ;                                                         
      /* CHILDREN NOW DEAD */                                                   
      VALUE $V24F (NOTSORTED)                                                   
                       '00' = '01NONE(00)'                                      
                  '01'-'05' = '0201-05'                                         
                  '06'-'10' = '0306-10'                                         
                  '11'-'20' = '0411-20'                                         
        '21'-'76','78'-'98' = '0521-98'                                         
                       '77' = '06BLANK(77)'                                     
                       '99' = '07NOTCLASS(99)'                                  
                      OTHER = '08OTHER'                                         
                       'AA' = '09CONS. EDIT:AGE/CHILDREN'                       
                      ;                                                         
      /* OTHER TERMINATIONS */                                                  
      VALUE $V25F (NOTSORTED)                                                   
                       '00' = '01NONE(00)'                                      
                  '01'-'05' = '0201-05'                                         
                  '06'-'10' = '0306-10'                                         
                  '11'-'20' = '0411-20'                                         
        '21'-'76','78'-'98' = '0521-98'                                         
                       '77' = '06BLANK(77)'                                     
                       '99' = '07NOTCLASS(99)'                                  
                      OTHER = '08OTHER'                                         
                      ;                                                         
      VALUE $V26F (NOTSORTED)                                                   
         '01' = '01JANUARY(01)'                                                 
         '02' = '02FEBRUARY(02)'                                                
         '03' = '03MARCH(03)'                                                   
         '04' = '04APRIL(04)'                                                   
         '05' = '05MAY(05)'                                                     
         '06' = '06JUNE(06)'                                                    
         '07' = '07JULY(07)'                                                    
         '08' = '08AUGUST(08)'                                                  
         '09' = '09SEPTEMBER(09)'                                               
         '10' = '10OCTOBER(10)'                                                 
         '11' = '11NOVEMBER(11)'                                                
         '12' = '12DECEMBER(12)'                                                
         '99' = '13NOTCLASS(99)'                                                
        OTHER = '14OTHER'                                                       
                      ;                                                         
      /* YEAR LAST LIVE BIRTH */                                                
      VALUE $V27F (NOTSORTED)                                                   
              '000' = '01THIS YEAR'                                             
              '001' = '021 YEAR AGO'                                            
              '002' = '032 YEARS AGO'                                           
              '003' = '043 YEARS AGO'                                           
              '004' = '054 YEARS AGO'                                           
              '005' = '065 YEARS AGO'                                           
              '006' = '076 YEARS AGO'                                           
              '007' = '087 YEARS AGO'                                           
              '008' = '098 YEARS AGO'                                           
              '009' = '109 YEARS AGO'                                           
        '010'-'098' = '1110 YEARS AGO OR MORE'                                  
              '099' = '12NOTCLASS(9999)'                                        
              OTHER = '13OTHER'                                                 
              ;                                                                 
      /* MON LAST NORM MENSES */                                                
      VALUE $V28F (NOTSORTED)                                                   
         '01' = '01JANUARY(01)'                                                 
         '02' = '02FEBRUARY(02)'                                                
         '03' = '03MARCH(03)'                                                   
         '04' = '04APRIL(04)'                                                   
         '05' = '05MAY(05)'                                                     
         '06' = '06JUNE(06)'                                                    
         '07' = '07JULY(07)'                                                    
         '08' = '08AUGUST(08)'                                                  
         '09' = '09SEPTEMBER(09)'                                               
         '10' = '10OCTOBER(10)'                                                 
         '11' = '11NOVEMBER(11)'                                                
         '12' = '12DECEMBER(12)'                                                
         '99' = '13NOTCLASS(99)'                                                
        OTHER = '14OTHER'                                                       
        ;                                                                       
      /* DAY LAST NORM MENSES */                                                
      VALUE $V29F (NOTSORTED)                                                   
             '01' = '0101'                                                      
        '02'-'06' = '0202-06'                                                   
             '07' = '0307'                                                      
        '08'-'14' = '0408-14'                                                   
             '15' = '0515'                                                      
        '16'-'23' = '0616-23'                                                   
             '24' = '0724'                                                      
        '25'-'30' = '0825-30'                                                   
             '31' = '0931'                                                      
             '99' = '10NOTCLASS(99)'                                            
            OTHER = '11OTHER'                                                   
            ;                                                                   
      /* YR LAST NORM MENSES */                                                 
      VALUE $V30F (NOTSORTED)                                                   
          '1' = '01CURRENT YEAR'                                                
          '2' = '02PRIOR YEAR'                                                  
          '3' = '03NOTCLASS(9999)'                                              
        OTHER = '04OTHER (COND. EDIT)'                                          
        ;                                                                       
      /* COMPUTED GESTATION */                                                  
      VALUE $V36F (NOTSORTED)                                                   
        '-12','-11','-10','-09','-9','-08','-8','-07','-7','-06','-6','-05','-5'
        '-04','-4','-03','-3','-02','-2','-01','-1',                            
        '000','00','0' = '01<= 0 (CON EDT)'                                     
        '003','03','3','002','02','2','001','01','1' = '02< 4 MONTHS (CON EDT)' 
                    '004','04','4' = '034 MONTHS'                               
                    '005','05','5' = '045 MONTHS'                               
                    '006','06','6' = '056 MONTHS'                               
                    '007','07','7' = '067 MONTHS'                               
                    '008','08','8' = '078 MONTHS'                               
                    '009','09','9' = '089 MONTHS'                               
                    '010','10' = '0910 MONTHS'                                  
                    '011','11' = '1011 MONTHS'                                  
                    '012','12' = '11> 11 MONTHS (CON EDT)'                      
                    OTHER = '12CANNOT COMPUTE'                                  
                    '999' = '13CON EDT:BWGT/GEST'                               
                    ;                                                           
      /* ESTIMATED GESTATION */                                                 
      VALUE $V37F (NOTSORTED)                                                   
             '00' = '0100 (CON EDT)'                                            
        '01'-'15' = '02< 4 MONTHS (CON EDT)'                                    
        '16'-'19' = '034 MONTHS'                                                
        '20'-'23' = '045 MONTHS'                                                
        '24'-'28' = '056 MONTHS'                                                
        '29'-'32' = '067 MONTHS'                                                
        '33'-'36' = '078 MONTHS'                                                
        '37'-'41' = '089 MONTHS'                                                
        '42'-'45' = '0910 MONTHS'                                               
        '46'-'49' = '1011 MONTHS'                                               
        '51'-'98' = '11> 11 MONTHS (CON EDT)'                                   
             '99' = '12UNKNOWN(99)'                                             
            OTHER = '13OTHER'                                                   
            'AA' = '14CON EDT:BWGT/GEST'                                        
            ;                                                                   
      /*  MO PRENATAL CARE BEG */                                               
      VALUE $V38F (NOTSORTED)                                                   
         '11' = '01MONTH NAMED'                                                 
          '0' = '02NONE(0)'                                                     
          '1' = '03FIRST MONTH(1)'                                              
          '2' = '04SECOND MONTH(2)'                                             
          '3' = '05THIRD MONTH(3)'                                              
          '4' = '06FOURTH MONTH(4)'                                             
          '5' = '07FIFTH MONTH(5)'                                              
          '6' = '08SIXTH MONTH(6)'                                              
          '7' = '09SEVENTH MONTH(7)'                                            
          '8' = '10EIGHTH MONTH(8)'                                             
          '9' = '11NINTH MONTH(9)'                                              
         '10' = '12NOT STATED(-)'                                               
        OTHER = '13OTHER'                                                       
         'AA' = '14CON EDT:DLNM/MPCB'                                           
         ;                                                                      
      /* N MO PRENAT CARE BEG */                                                
      VALUE $V39F (NOTSORTED)                                                   
         '00' = '01BLANK'                                                       
         '01' = '02JANUARY(01)'                                                 
         '02' = '03FEBRUARY(02)'                                                
         '03' = '04MARCH(03)'                                                   
         '04' = '05APRIL(04)'                                                   
         '05' = '06MAY(05)'                                                     
         '06' = '07JUNE(06)'                                                    
         '07' = '08JULY(07)'                                                    
         '08' = '09AUGUST(08)'                                                  
         '09' = '10SEPTEMBER(09)'                                               
         '10' = '11OCTOBER(10)'                                                 
         '11' = '12NOVEMBER(11)'                                                
         '12' = '13DECEMBER(12)'                                                
        OTHER = '14OTHER'                                                       
        ;                                                                       
      /* TOT PRENATAL VISITS */                                                 
      VALUE $V40F (NOTSORTED)                                                   
             '00' = '0100'                                                      
        '01'-'05' = '0201-05'                                                   
        '06'-'10' = '0306-10'                                                   
        '11'-'15' = '0411-15'                                                   
        '16'-'20' = '0516-20'                                                   
        '21'-'48' = '0621-48'                                                   
        '49'-'98' = '0749+'                                                     
             '99' = '08NOTCLASS(99)'                                            
            OTHER = '09OTHER'                                                   
             'AA' = '10CON EDT:TPV=0,PC REP'                                    
             'BB' = '11CON EDT:TPV REP,MPCB=0'                                  
             ;                                                                  
      /* PLURALITY */                                                           
      VALUE $V41F (NOTSORTED)                                                   
          '1' = '01SINGLE(1)'                                                   
          '2' = '02TWIN(2)'                                                     
          '3' = '03TRIPLET(3)'                                                  
          '4' = '04QUADRUPLET(4)'                                               
          '5' = '05QUINT AND HIGHER(5)'                                         
          '9' = '06NOTCLASS(9)'                                                 
        OTHER = '07OTHER'                                                       
        ;                                                                       
      /* BIRTH WEIGHT */                                                        
      VALUE $V42F (NOTSORTED)                                                   
      '10000'-'10499','20000'-'20016','20099','20100'-'20102','20199'           
       = "010-499 G / 0 LB 0 OZ-&C   1 LB 2 OZ (CON EDT)"                       
      '10500'-'10999','20103'-'20116','20200'-'20203','20299'                   
      = "02500-999 G /&C   1 LB 3 OZ-2 LB 3 OZ"                                 
      '11000'-'11499','20204'-'20216','20300'-'20305','20399'                   
      = "031000-1499 G /&C   2 LB 4 OZ-3 LB 5 OZ"                               
      '11500'-'11999','20306'-'20316','20400'-'20407','20499'                   
      = "041500-1999 G /&C   3 LB 6 OZ-4 LB 7 OZ"                               
      '12000'-'12499','20408'-'20416','20500'-'20508','20599'                   
      = "052000-2499 G /&C   4 LB 8 OZ-5 LB 8 OZ"                               
      '12500'-'12999','20509'-'20516','20600'-'20610','20699'                   
      = "062500-2999 G /&C   5 LB 9 OZ-6 LB 10 OZ"                              
      '13000'-'13499','20611'-'20616','20700'-'20711','20799'                   
      = "073000-3499 G /&C   6 LB 11 OZ-7 LB 11 OZ"                             
      '13500'-'13999','20712'-'20716','20800'-'20813','20899'                   
      = "083500-3999 G /&C   7 LB 12 OZ-8 LB 13 OZ"                             
      '14000'-'14499','20814'-'20816','20900'-'20916','20999'                   
      = "094000-4499 G /&C   8 LB 14 OZ-9 LB 15 OZ"                             
      '14500'-'14999','21000'-'21016','21099','21100','21199'                   
      = "104500-4999 G /&C   10 LB 0 OZ-11 LB 0 OZ"                             
      '15000'-'18165','21101'-'21116','21199'-'21216','21299'-'21316',          
      '21399'-'21416','21499'-'21516','21599'-'21616','21699'-'21716',          
      '21799'-'21800'                                                           
      = "115000-8165 G /&C   11 LB 1 OZ-18 LB 0 OZ"                             
      '18166'-'19998','21801'-'29998'                                           
      = "12> 8165 G /&C   > 18 LB 0 OZ (CON EDT)"                               
                              '19999' = '13UNKNOWN (G)'                         
                              '29999' = '14UNKNOWN (LB/OZ)'                     
                              '99999' = '15UNKNOWN'                             
                                OTHER = '16OTHER'                               
                                ;                                               
      /* LOW BIRTH WEIGHT */                                                    
      VALUE $V66F (NOTSORTED)                                                   
      '10000'-'10499','20000'-'20016','20099','20100'-'20102','20199',          
      '10500'-'10999','20103'-'20116','20200'-'20203','20299',                  
      '11000'-'11499','20204'-'20216','20300'-'20305','20399',                  
      '11500'-'11999','20306'-'20316','20400'-'20407','20499',                  
      '12000'-'12499','20408'-'20416','20500'-'20508','20599'                   
      = '01< 2500 G / < 5 LB 8 OZ'                                              
                                  ;                                             
      /* VERY LOW BIRTH WEIGHT */                                               
      VALUE $V67F (NOTSORTED)                                                   
      '10000'-'10499','20000'-'20016','20099','20100'-'20102','20199',          
      '10500'-'10999','20103'-'20116','20200'-'20203','20299',                  
      '11000'-'11499','20204'-'20216','20300'-'20305','20399'                   
      = '01< 1500 G / < 3 LB 5 OZ'                                              
                                  ;                                             
      /* TOBACCO USE */                                                         
      VALUE $V43F (NOTSORTED)                                                   
          '1' = '01YES(1)'                                                      
          '2' = '02NO(2)'                                                       
          '9' = '03NOTCLASS(9)'                                                 
        OTHER = '04OTHER'                                                       
        ;                                                                       
      /* TOB USE & CIGAR/DAY */                                                 
      VALUE $V44F (NOTSORTED)                                                   
        '100'       = '01YES, 00'                                               
        '199'       = '02YES, 99'                                               
        '101'-'197' = '03YES, NUMBER'                                           
        '200'       = '04NO, 00'                                                
        '299'       = '05NO, 99'                                                
        '201'-'297' = '06NO, NUMBER'                                            
        '900'       = '07UNK, 00'                                               
        '999'       = '08UNK, 99'                                               
        '901'-'997' = '09UNK, NUMBER'                                           
              OTHER = '10OTHER'                                                 
              ;                                                                 
      /* ALCOHOL USE */                                                         
      VALUE $V45F (NOTSORTED)                                                   
          '1' = '01YES(1)'                                                      
          '2' = '02NO(2)'                                                       
          '9' = '03NOTCLASS(9)'                                                 
        OTHER = '04OTHER'                                                       
         'AA' = '05CON EDT:F.A.S./USE=NO'                                       
        ;                                                                       
      /* ALC USE & DRINKS/WK */                                                 
      VALUE $V46F (NOTSORTED)                                                   
        '100'       = '01YES, 00'                                               
        '199'       = '02YES, 99'                                               
        '101'-'197' = '03YES, NUMBER'                                           
        '200'       = '04NO, 00'                                                
        '299'       = '05NO, 99'                                                
        '201'-'297' = '06NO, NUMBER'                                            
        '900'       = '07UNK, 00'                                               
        '999'       = '08UNK, 99'                                               
        '901'-'997' = '09UNK, NUMBER'                                           
              OTHER = '10OTHER'                                                 
              ;                                                                 
      /* WEIGHT GAINED */                                                       
      VALUE $V47F (NOTSORTED)                                                   
             '00' = '0100 LBS'                                                  
        '01'-'25' = '0201-25 LBS'                                               
        '26'-'69' = '0326-69 LBS'                                               
        '70'-'98' = '0470-98 LBS'                                               
             '99' = '05NOTCLASS(99)'                                            
            OTHER = '06OTHER'                                                   
            ;                                                                   
                                                                                
                                                                                
                                                                                
      /* BEGIN RISK FACTORS. */                                                 
      /* LABELS USED AS A HEADER FOR EACH GROUP. */                             
      VALUE RFLABEL (NOTSORTED)                                                 
        1='MEDICAL RISK FACTORS'                                                
        2='OBSTETRIC PROCEDURES'                                                
        3='COMPLICATIONS OF LABOR AND DELIVERY'                                 
        4='METHOD OF DELIVERY'                                                  
        5='CONGENITAL ANOMALIES'                                                
        ;                                                                       
      /* THE 6 CATEGORIES OF MED RISK. */                                       
      VALUE RFVNAME (NOTSORTED)                                                 
        1='RSK'                                                                 
        2='OBS'                                                                 
        3='LAB'                                                                 
        4='DEL'                                                                 
        5='CON'                                                                 
        ;                                                                       
                                                                                
      VALUE $RFV1F (NOTSORTED)                                                  
        '53A' = '01NONE'                                                        
        '53B' = '02NOT CLASSIFIABLE'                                            
        '54'  = '03ANEMIA(HCT<30/HGB<10)'                                       
        '55'  = '04CARDIAC DISEASE'                                             
        '56'  = "05ACUTE OR CHRONIC LUNG&C   DISEASE"                           
        '57'  = '06DIABETES'                                                    
        '58'  = '07GENITAL HERPES'                                              
        '59'  = "08HYDRAMNIOS/OLIGO-&C   HYDRAMNIOS"                            
        '60'  = '09HEMOGLOBINOPATHY'                                            
        '61'  = '10HYPERTENSION,CHRONIC'                                        
        '62'  = "11HYPERTENSION,PREGNANCY-&C   ASSOC"                           
        '63'  = '12ECLAMPSIA'                                                   
        '64'  = '13INCOMPETENT CERVIX'                                          
        '65'  = '14PREV INFANT 4000+ GR'                                        
        '66'  = "15PREV PRETERM OR SMALL FOR&C   GEST AGE INFANT"               
        '67'  = '16RENAL DISEASE'                                               
        '68'  = '17RH SENSITIZATION'                                            
        '69'  = '18UTERINE BLEEDING'                                            
        '70'  = '19OTHER'                                                       
        ;                                                                       
      VALUE $RFV2F (NOTSORTED)                                                  
        '71A' = '01NONE'                                                        
        '71B' = '02NOT CLASSIFIABLE'                                            
        '72'  = '03AMNIOCENTESIS'                                               
        '73'  = '04ELEC FET MONITORING'                                         
        '74'  = '05INDUCTION OF LABOR'                                          
        '75'  = '06STIMULATION OF LABOR'                                        
        '76'  = '07TOCOLYSIS'                                                   
        '77'  = '08ULTRASOUND'                                                  
        '78'  = '09OTHER'                                                       
        ;                                                                       
      VALUE $RFV3F (NOTSORTED)                                                  
        '79A' = '01NONE'                                                        
        '79B' = '02NOT CLASSIFIABLE'                                            
        '80'  = '03FEBRILE (>100 F OR 38 C)'                                    
        '81'  = '04MECONIUM, MOD/HEAVY'                                         
        '82'  = "05PREMATURE RUPTURE OF&C   MEMBRANE (> 12 HRS)"                
        '83'  = '06ABRUPTIO PLACENTA'                                           
        '84'  = '07PLACENTA PREVIA'                                             
        '85'  = '08OTH EXCESS BLEEDING'                                         
        '86'  = '09SEIZURES DURING LABOR'                                       
        '87'  = '10PRECIPITOUS LAB <3 HR'                                       
        '88'  = '11PROLONGED LAB >20 HR'                                        
        '89'  = '12DYSFUNCTIONAL LABOR'                                         
        '90'  = '13BREECH/MALPRESENTATION'                                      
        '91'  = "14CEPHALOPELVIC&C   DISPROPORTION"                             
        '92'  = '15CORD PROLAPSE'                                               
        '93'  = '16ANESTHETIC COMPLICATIONS'                                    
        '94'  = '17FETAL DISTRESS'                                              
        '95'  = '18OTHER'                                                       
        ;                                                                       
      VALUE $RFV4F (NOTSORTED)                                                  
        '96'  = '01NOT CLASSIFIABLE'                                            
        '97'  = '02VAGINAL'                                                     
        '98'  = '03VAG AFTER PREV C-SECT'                                       
        '99'  = '04PRIMARY C-SECTION'                                           
        '100' = '05REPEAT C-SECTION'                                            
        '101' = '06FORCEPS'                                                     
        '102' = '07VACUUM'                                                      
        '103' = '08HYSTEROTOMY/HYSTERECTOMY'                                    
        ;                                                                       
      VALUE $RFV5F (NOTSORTED)                                                  
        '104A' = '01NONE'                                                       
        '104B' = '02NOT CLASSIFIABLE'                                           
        '105'  = '03ANECEPHALUS'                                                
        '106'  = '04SPIN BIF/MENINGOCELE'                                       
        '107'  = '05HYDROCEPHALUS'                                              
        '108'  = '06MICROCEPHALUS'                                              
        '109'  = '07OTH CEN NERV SYS ANOM'                                      
        '110'  = '08HEART MALFORMATIONS'                                        
        '111'  = '09OTHER CIRC/RESP ANOM'                                       
        '112'  = '10RECTAL ATRESIA/STENOSIS'                                    
        '113'  = "11TRACHEO-ESOPHAGEAL&C   FISTULA/ESOPHAGEAL ATR"              
        '114'  = "12OMPHALAOCELE/&C   GASTROSCHISIS"                            
        '115'  = '13OTH GASTROINTESTINAL ANOM'                                  
        '116'  = '14MALFORMED GENITALIA'                                        
        '117'  = '15RENAL AGENESIS'                                             
        '118'  = '16OTH UROGENITAL ANOM'                                        
        '119'  = '17CLEFT LIP/PALATE'                                           
        '120'  = '18POLY./SYN./ADACTYLY'                                        
        '121'  = '19CLUB FOOT'                                                  
        '122'  = '20DIAPHRAGMATIC HERNIA'                                       
        '123'  = '21OTH MUSC/INTEG ANOM'                                        
        '124'  = '22DOWNS SYNDROME'                                             
        '125'  = '23OTH CHROMOSOMAL'                                            
        '126'  = '24OTHER'                                                      
        ;                                                                       
    RUN;                                                                        
  %END;                                                                         
%MEND LOOP;                                                                     
%LOOP                                                                           
