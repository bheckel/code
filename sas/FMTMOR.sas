OPTIONS NOSOURCE;                                                               
 /********************************************************************          
  * PROGRAM NAME: FMTMOR                                                        
  *               (FORMERLY NAMED TSMAAOX)                                      
  *                                                                             
  *  DESCRIPTION: FORMATS USED BY MORTALITY NON-REVISER TSA REPORTS.            
  *               LEADING DIGITS ARE FOR SORTING PURPOSES ONLY.                 
  *                                                                             
  *     CALLS TO:                                                               
  *    CALLED BY:                                                               
  *                                                                             
  *   PROGRAMMER: BQH0                                                          
  * DATE WRITTEN: 2003-10-01                                                    
  *                                                                             
  *   UPDATE LOG:                                                               
  * 2004-01-09 (BQH0) FIX TYPO IN TYPE PLACE OF DEATH                           
  * 2004-01-12 (BQH0) FIX TYPO IN BIRTHPLACE                                    
  * 2004-01-28 (BQH0) CHANGE EDUC 17+ TO 17 PER BRENDA G.                       
  * 2004-05-10 (BQH0) CHANGE CENTURY <1900 TO 1800-1899 PER DWJ2                
  *******************************************************************/          
OPTIONS SOURCE;                                                                 
                                                                                
LIBNAME FLIB 'DWJ2.MOR1989.FORMAT.LIB';                                         
                                                                                
PROC FORMAT LIBRARY=FLIB;                                                       
  /* LABELS ARE USED AS A HEADER FOR EACH GROUP. */                             
  VALUE LABEL (NOTSORTED)                                                       
              1='SEX'                                                           
              2='MO OF DEATH'                                                   
              3='DAY OF DEATH'                                                  
              5='MO OF BIRTH'                                                   
              6='DAY OF BIRTH'                                                  
              8='CENTURY'                                                       
              9='REPORTED AGE'                                                  
             21='INFANT DEATHS'                                                 
             10='COMP AGE IN YRS'                                               
             11='COMP AGE IN MOS'                                               
             12='COMP AGE IN DYS'                                               
             13='BIRTHPLACE'                                                    
             14='TYPE PLACE OF DEATH'                                           
             15='MARITAL STATUS'                                                
             16='HISPANIC ORIGIN'                                               
             17='RACE'                                                          
             18='EDUCATION'                                                     
             20='INJ AT WORK(ADD-1993)'                                         
             ;                                                                  
  /* VARIABLE NAMES FROM LIBRARY */                                             
  VALUE VNAME (NOTSORTED)                                                       
              1='SEX'                                                           
              2='MONTH'                                                         
              3='DAY'                                                           
              5='BIRTHMO'                                                       
              6='BIRTHDY'                                                       
              8='CENTURY'                                                       
              9='AGE'                                                           
             10='COMPYR'                                                        
             11='COMPMO'                                                        
             12='COMPDY'                                                        
             13='BIRTHPLC'                                                      
             14='TYP_PLAC'                                                      
             15='MARITAL'                                                       
             16='HISPANIC'                                                      
             17='RACE'                                                          
             18='EDUC'                                                          
             20='INJURY'                                                        
             21='UNIT'                                                          
             ;                                                                  
                                                                                
  /* SEX */                                                                     
  VALUE $V1F (NOTSORTED)                                                        
             '1' = '00MALE(1)'                                                  
             '2' = '01FEMALE(2)'                                                
             '9' = '02NOTCLASS(9)'                                              
           OTHER = '03OTHER'                                                    
           ;                                                                    
  /* MONTH OF DEATH */                                                          
  VALUE $V2F (NOTSORTED)                                                        
             '01' = '00JANUARY(01)'                                             
             '02' = '01FEBRUARY(02)'                                            
             '03' = '02MARCH(03)'                                               
             '04' = '03APRIL(04)'                                               
             '05' = '04MAY(05)'                                                 
             '06' = '05JUNE(06)'                                                
             '07' = '06JULY(07)'                                                
             '08' = '07AUGUST(08)'                                              
             '09' = '08SEPTEMBER(09)'                                           
             '10' = '09OCTOBER(10)'                                             
             '11' = '10NOVEMBER(11)'                                            
             '12' = '11DECEMBER(12)'                                            
             '99' = '12NOTCLASS(99)'                                            
            OTHER = '13OTHER'                                                   
            ;                                                                   
  /* DAY OF DEATH */                                                            
  VALUE $V3F (NOTSORTED)                                                        
                       '01','02','03','04','05','06' = '0001-06'                
                                                '07' = '0107'                   
                  '08','09','10','11','12','13','14' = '0208-14'                
                                                '15' = '0315'                   
             '16','17','18','19','20','21','22','23' = '0416-23'                
                                                '24' = '0524'                   
                       '25','26','27','28','29','30' = '0625-30'                
                                                '31' = '0731'                   
                                                '99' = '08NOTCLASS(99)'         
                                               OTHER = '09OTHER'                
                                               ;                                
  /* PLACEHOLDER */                                                             
  VALUE V4F ;                                                                   
  /* MONTH OF BIRTH */                                                          
  VALUE $V5F (NOTSORTED)                                                        
             '01' = '00JANUARY(01)'                                             
             '02' = '01FEBRUARY(02)'                                            
             '03' = '02MARCH(03)'                                               
             '04' = '03APRIL(04)'                                               
             '05' = '04MAY(05)'                                                 
             '06' = '05JUNE(06)'                                                
             '07' = '06JULY(07)'                                                
             '08' = '07AUGUST(08)'                                              
             '09' = '08SEPTEMBER(09)'                                           
             '10' = '09OCTOBER(10)'                                             
             '11' = '10NOVEMBER(11)'                                            
             '12' = '11DECEMBER(12)'                                            
             '99' = '12NOTCLASS(99)'                                            
            OTHER = '13OTHER'                                                   
            ;                                                                   
  /* DAY OF BIRTH */                                                            
  VALUE $V6F (NOTSORTED)                                                        
                       '01','02','03','04','05','06' = '0001-06'                
                                                '07' = '0107'                   
                  '08','09','10','11','12','13','14' = '0208-14'                
                                                '15' = '0315'                   
             '16','17','18','19','20','21','22','23' = '0416-23'                
                                                '24' = '0524'                   
                       '25','26','27','28','29','30' = '0625-30'                
                                                '31' = '0731'                   
                                                '99' = '08NOTCLASS(99)'         
                                               OTHER = '09OTHER'                
                                               ;                                
  /* PLACEHOLDER */                                                             
  VALUE $V7F ;                                                                  
  /* CENTURY */                                                                 
  VALUE $V8F (NOTSORTED)                                                        
             '800' = '001800-1899'                                              
             '900' = '01=1900'                                                  
             '901' = '021901-1999'                                              
             '200' = '03>=2000'                                                 
             '999' = '04NOTCLASS(9999)'                                         
           OTHER = '05OTHER'                                                    
           ;                                                                    
  /* REPORTED AGE */                                                            
  VALUE $V9F (NOTSORTED)                                                        
             '120'-'199' = '01YR 120+(COND. EDIT)'                              
             '110'-'119' = '02YR 110-119'                                       
             '100'-'109' = '03YR 100-109'                                       
             '095'-'099' = '04YR 95-99'                                         
             '090'-'094' = '05YR 90-94'                                         
             '085'-'089' = '06YR 85-89'                                         
             '080'-'084' = '07YR 80-84'                                         
             '075'-'079' = '08YR 75-79'                                         
             '070'-'074' = '09YR 70-74'                                         
             '065'-'069' = '10YR 65-69'                                         
             '060'-'064' = '11YR 60-64'                                         
             '055'-'059' = '12YR 55-59'                                         
             '050'-'054' = '13YR 50-54'                                         
             '045'-'049' = '14YR 45-49'                                         
             '040'-'044' = '15YR 40-44'                                         
             '035'-'039' = '16YR 35-39'                                         
             '030'-'034' = '17YR 30-34'                                         
             '025'-'029' = '18YR 25-29'                                         
             '020'-'024' = '19YR 20-24'                                         
             '015'-'019' = '20YR 15-19'                                         
             '010'-'014' = '21YR 10-14'                                         
             '005'-'009' = '22YR 5-9'                                           
             '001'-'004' = '23YR 1-4'                                           
                    '000' = '24YR 00'                                           
                    '200' = '25MO 00'                                           
             '200'-'211' = '26MO 00-11'                                         
             '212'-'223' = '27MO 12-23'                                         
             '224'-'298' = '28MO 24+(COND. EDIT)'                               
                   '299' = '29MO UNKNOWN'                                       
                   '300' = '30WK 00'                                            
             '301'-'304' = '31WK 01-04'                                         
             '305'-'352' = '32WK 05-52'                                         
             '353'-'398' = '33WK 53+(COND. EDIT)'                               
                   '399' = '34WK UNKNOWN'                                       
                   '400' = '35DY 00'                                            
             '401'-'427' = '36DY 01-27'                                         
             '428'-'460' = '37DY 28-60'                                         
             '461'-'498' = '38DY 61+(COND. EDIT)'                               
                   '499' = '39DY UNKNOWN'                                       
                   '500' = '40HR 00'                                            
             '501'-'523' = '41HR 01-23'                                         
             '524'-'572' = '42HR 24-72'                                         
             '573'-'598' = '43HR 73+(COND. EDIT)'                               
                   '599' = '44HR UNKNOWN'                                       
                   '600' = '45MN 00'                                            
             '600'-'659' = '46MN 00-59'                                         
             '660'-'695' = '47MN 60-95'                                         
             '695'-'698' = '48MN 95+(COND. EDIT)'                               
                   '699' = '49MN UNKNOWN'                                       
                   '999' = '50NOT CLASS'                                        
                   OTHER = '51OTHER'                                            
                   'AAA' = '52ABS EDT:REP/CMP DIF>5'                            
                   'BBB' = '53ABS EDT:INF DOB/AGE'                              
                     ;                                                          
  /* COMP AGE IN YRS.  FORCE A NUMERIC TO A CHAR. */                            
  VALUE $V10F (NOTSORTED)                                                       
              '120'-'998' = '00120+(COND. EDIT)'                                
             '110'-'119' = '01110-119'                                          
             '100'-'109' = '02100-109'                                          
             '095'-'099' = '0395-99'                                            
             '090'-'094' = '0490-94'                                            
             '085'-'089' = '0585-89'                                            
             '080'-'084' = '0680-84'                                            
             '075'-'079' = '0775-79'                                            
             '070'-'074' = '0870-74'                                            
             '065'-'069' = '0965-69'                                            
             '060'-'064' = '1060-64'                                            
             '055'-'059' = '1155-59'                                            
             '050'-'054' = '1250-54'                                            
             '045'-'049' = '1345-49'                                            
             '040'-'044' = '1440-44'                                            
             '035'-'039' = '1535-39'                                            
             '030'-'034' = '1630-34'                                            
             '025'-'029' = '1725-29'                                            
             '020'-'024' = '1820-24'                                            
             '015'-'019' = '1915-19'                                            
             '010'-'014' = '2010-14'                                            
             '005'-'009' = '215-9'                                              
             '001'-'004' = '221-4'                                              
               LOW-'000' = '23LT 1YR'                                           
                   OTHER = '24CAN NOT COMP'                                     
                                ;                                               
  /* COMP AGE IN MONTHS */                                                      
  VALUE $V11F (NOTSORTED)                                                       
              '001'-'011' = '0001-11'                                           
              '012'-'023' = '0112-23'                                           
              '024'-'098' = '0224+(COND. EDIT)'                                 
               OTHER = '03CAN NOT COMP'                                         
               ;                                                                
  /* COMP AGE IN DAYS */                                                        
  VALUE $V12F (NOTSORTED)                                                       
                '000' = '00LESS THAN 1 DAY'                                     
           '001'-'027' = '0101-27'                                              
           '028'-'060' = '0228-60'                                              
           '061'-'098' = '0361+(COND. EDIT)'                                    
               OTHER = '04CAN NOT COMP'                                         
               ;                                                                
  /* BIRTHPLACE */                                                              
  VALUE $V13F (NOTSORTED)                                                       
              '01' = '00AL(01)'                                                 
              '02' = '01AK(02)'                                                 
              '03' = '02AZ(03)'                                                 
              '04' = '03AR(04)'                                                 
              '05' = '04CA(05)'                                                 
              '06' = '05CO(06)'                                                 
              '07' = '06CT(07)'                                                 
              '08' = '07DE(08)'                                                 
              '09' = '08DC(09)'                                                 
              '10' = '09FL(10)'                                                 
              '11' = '10GA(11)'                                                 
              '12' = '11HI(12)'                                                 
              '13' = '12ID(13)'                                                 
              '14' = '13IL(14)'                                                 
              '15' = '14IN(15)'                                                 
              '16' = '15IA(16)'                                                 
              '17' = '16KS(17)'                                                 
              '18' = '17KY(18)'                                                 
              '19' = '18LA(19)'                                                 
              '20' = '19ME(20)'                                                 
              '21' = '20MD(21)'                                                 
              '22' = '21MA(22)'                                                 
              '23' = '22MI(23)'                                                 
              '24' = '23MN(24)'                                                 
              '25' = '24MS(25)'                                                 
              '26' = '25MO(26)'                                                 
              '27' = '26MT(27)'                                                 
              '28' = '27NE(28)'                                                 
              '29' = '28NV(29)'                                                 
              '30' = '29NH(30)'                                                 
              '31' = '30NJ(31)'                                                 
              '32' = '31NM(32)'                                                 
              '33' = '32NY(33)'                                                 
              '34' = '33NC(34)'                                                 
              '35' = '34ND(35)'                                                 
              '36' = '35OH(36)'                                                 
              '37' = '36OK(37)'                                                 
              '38' = '37OR(38)'                                                 
              '39' = '38PA(39)'                                                 
              '40' = '39RI(40)'                                                 
              '41' = '40SC(41)'                                                 
              '42' = '41SD(42)'                                                 
              '43' = '42TN(43)'                                                 
              '44' = '43TX(44)'                                                 
              '45' = '44UT(45)'                                                 
              '46' = '45VT(46)'                                                 
              '47' = '46VA(47)'                                                 
              '48' = '47WA(48)'                                                 
              '49' = '48WV(49)'                                                 
              '50' = '49WI(50)'                                                 
              '51' = '50WY(51)'                                                 
              '52' = '51PR(52)'                                                 
              '53' = '52VI(53)'                                                 
              '54' = '53GU(54)'                                                 
              '55' = '54CN(55)'                                                 
              '56' = '55CB(56)'                                                 
              '57' = '56MX(57)'                                                 
              '59' = '57RW(59)'                                                 
              '61' = '58AS(61)'                                                 
              '62' = '59MP(62)'                                                 
              '99' = '60NOT CLASS(99)'                                          
             OTHER = '61OTHER'                                                  
             ;                                                                  
 /* TYPE OF PLACE OF DEATH */                                                   
  VALUE $V14F (NOTSORTED)                                                       
              '1' = '00HOSP-INPATIENT(1)'                                       
              '2' = '01HOSP-OUTPATIENT OR ER(2)'                                
              '3' = '02HOSP-DOA(3)'                                             
              '4' = '03HOSP-NOT CLASS(4)'                                       
              '5' = '04NURSING HOME(5)'                                         
              '6' = '05RESIDENCE(6)'                                            
              '7' = '06OTH ENTRIES(7)'                                          
              '9' = '07NOT CLASS(9)'                                            
            OTHER = '08OTHER'                                                   
            ;                                                                   
  /* MARITAL STATUS */                                                          
  VALUE $V15F (NOTSORTED)                                                       
              '1' = '00MARRIED(1)'                                              
              '2' = '01NEVER MARRIED(2)'                                        
              '3' = '02WIDOWED(3)'                                              
              '4' = '03DIVORCED(4)'                                             
              '9' = '04NOT CLASS(9)'                                            
            OTHER = '05OTHER'                                                   
              'A' = '06CON EDIT: AGE<12/MS NE2'                                 
            ;                                                                   
  /* HISPANIC ORIGIN */                                                         
  VALUE $V16F (NOTSORTED)                                                       
              '0' = '00NON-HISPANIC(0)'                                         
              '1' = '01MEXICAN(1)'                                              
              '2' = '02PUERTO RICAN(2)'                                         
              '3' = '03CUBAN(3)'                                                
              '4' = '04C. OR S. AMERICAN(4)'                                    
              '5' = '05OTH AND UNK HISP(5)'                                     
              '9' = '06NOT CLASS(9)'                                            
            OTHER = '07OTHER'                                                   
            ;                                                                   
  /* RACE */                                                                    
  VALUE $V17F (NOTSORTED)                                                       
         '10','A' = '00ASIAN INDIAN(A)'                                         
         '11','B' = '01KOREAN(B)'                                               
         '12','C' = '02SAMOAN(C)'                                               
         '13','D' = '03VIETNAMESE(D)'                                           
         '14','E' = '04GUAMANIAN(E)'                                            
         '15','F' = '05MULTI-RACIAL(F)'                                         
          'O','0' = '06OTHERS(O)'                                               
              '1' = '07WHITE(1)'                                                
              '2' = '08BLACK(2)'                                                
              '3' = '09INDIAN(3)'                                               
              '4' = '10CHINESE(4)'                                              
              '5' = '11JAPANESE(5)'                                             
              '6' = '12HAWAIIAN(6)'                                             
              '7' = '13FILIPINO(7)'                                             
              '8' = '14OTH API(8)'                                              
              '9' = '15NOT CLASS(9)'                                            
            OTHER = '16OTHER'                                                   
            ;                                                                   
  /* EDUCATION */                                                               
  VALUE $V18F (NOTSORTED)                                                       
              '00' = '0000 YEARS'                                               
              '01' = '0101 YEAR'                                                
              '02' = '0202 YEARS'                                               
              '03' = '0303 YEARS'                                               
              '04' = '0404 YEARS'                                               
              '05' = '0505 YEARS'                                               
              '06' = '0606 YEARS'                                               
              '07' = '0707 YEARS'                                               
              '08' = '0808 YEARS'                                               
              '09' = '0909 YEARS'                                               
              '10' = '1010 YEARS'                                               
              '11' = '1111 YEARS'                                               
              '12' = '1212 YEARS'                                               
              '13' = '1313 YEARS'                                               
              '14' = '1414 YEARS'                                               
              '15' = '1515 YEARS'                                               
              '16' = '1616 YEARS'                                               
              '17' = '1717 YEARS'                                               
              '99' = '18NOT CLASS(99)'                                          
             OTHER = '19OTHER'                                                  
              'AA' = '20CON EDIT: AGE/EDUC'                                     
              ;                                                                 
  /* PLACEHOLDER */                                                             
  VALUE $V19F ;                                                                 
  /* INJURY AT WORK */                                                          
  VALUE $V20F (NOTSORTED)                                                       
              ' ' = '00BLANK'                                                   
              '1' = '01YES(1)'                                                  
              '2' = '02NO(2)'                                                   
              '9' = '03NOT CLASS(9)'                                            
            OTHER = '04OTHER'                                                   
            ;                                                                   
  /* UNIT (INFANT DEATH) */                                                     
  VALUE $V21F (NOTSORTED)                                                       
            'A','B','R','S','T','U','V','W' = '00< 1 YEAR'                      
            ;                                                                   
RUN;                                                                            
