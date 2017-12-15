//BQH0UST0 JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=20,CLASS=J,REGION=0M                                                                   
//ANNUAL   EXEC SAS,OPTIONS='MSGCASE,MEMSIZE=0'                                
//WORK     DD SPACE=(CYL,(450,450),,,ROUND)                                         
//US2000   DD DSN=DWJ2.CAUS2000.US,
//         DISP=(NEW,CATLG,DELETE),UNIT=NCHS,
//         DCB=(DSORG=PS,RECFM=FS,LRECL=6144,BLKSIZE=6144),
//         SPACE=(TRK,(50,50),RLSE)
//SYSIN    DD *                                                                

OPTIONS NOSOURCE;
 /*-------------------------------------------------------------------
  *     NAME: CAUSUS00
  *
  *  SUMMARY: CREATE THE FINAL 2000 U.S. UNDERLYING CAUSE TOTAL FILE 
  *
  *           The US tot file had not been created during the 2000
  *           close process so I'm doing it now.
  *
  *           Had to use MPX0001.MEDMER and VIX0004.MEDMER b/c the 
  *           'MEDMER1' versions have been deleted somehow.
  *
  *  CREATED: 04 AUG 2004 (BQH0)
  *-------------------------------------------------------------------
  */
OPTIONS SOURCE LS=133 CAPS NOTES MPRINT SYMBOLGEN;                              

 /* CLOSING YEAR. */
%LET K = 2000;
                                                                                
 /* PER HDG7.FINAL.BF19.DATASET */
FILENAME AK2000 'BF19.AKX0009.MEDMER2' DISP=SHR;
FILENAME AL2000 'BF19.ALX0018.MEDMER2' DISP=SHR;
FILENAME AR2000 'BF19.ARX0019.MEDMER3' DISP=SHR;
FILENAME AS2000 'BF19.ASX0001.MEDMER1' DISP=SHR;
FILENAME AZ2000 'BF19.AZX0013.MEDMER9' DISP=SHR;
FILENAME CA2000 'BF19.CAX0016.MEDMER9' DISP=SHR;
FILENAME CO2000 'BF19.COX0012.MEDMER9' DISP=SHR;
FILENAME CT2000 'BF19.CTX0014.MEDMER5' DISP=SHR;
FILENAME DC2000 'BF19.DCX0005.MEDMER6' DISP=SHR;
FILENAME DE2000 'BF19.DEX0016.MEDMER2' DISP=SHR;
FILENAME FL2000 'BF19.FLX0018.MEDMER2' DISP=SHR;
FILENAME GA2000 'BF19.GAX0042.MEDMER3' DISP=SHR;
FILENAME GU2000 'BF19.GUX0004.MEDMER2' DISP=SHR;
FILENAME HI2000 'BF19.HIX0008.MEDMER5' DISP=SHR;
FILENAME IA2000 'BF19.IAX0005.MEDMER3' DISP=SHR;
FILENAME ID2000 'BF19.IDX0016.MEDMER5' DISP=SHR;
FILENAME IL2000 'BF19.ILX0015.MEDMER3' DISP=SHR;
FILENAME IN2000 'BF19.INX0019.MEDMER4' DISP=SHR;
FILENAME KS2000 'BF19.KSX0038.MEDMER3' DISP=SHR;
FILENAME KY2000 'BF19.KYX0010.MEDMER2' DISP=SHR;
FILENAME LA2000 'BF19.LAX0013.MEDMER2' DISP=SHR;
FILENAME MA2000 'BF19.MAX0011.MEDMER7' DISP=SHR;
FILENAME MD2000 'BF19.MDX0014.MEDMER1' DISP=SHR;
FILENAME ME2000 'BF19.MEX0009.MEDMER2' DISP=SHR;
FILENAME MI2000 'BF19.MIX0011.MEDMER9' DISP=SHR;
FILENAME MN2000 'BF19.MNX0009.MEDMER8' DISP=SHR;
FILENAME MO2000 'BF19.MOX0009.MEDMER4' DISP=SHR;
FILENAME MP2000 'BF19.MPX0001.MEDMER' DISP=SHR;
FILENAME MS2000 'BF19.MSX0008.MEDMER3' DISP=SHR;
FILENAME MT2000 'BF19.MTX0009.MEDMER2' DISP=SHR;
FILENAME NE2000 'BF19.NEX0008.MEDMER1' DISP=SHR;
FILENAME NC2000 'BF19.NCX0015.MEDMER3' DISP=SHR;
FILENAME ND2000 'BF19.NDX0005.MEDMER2' DISP=SHR;
FILENAME NH2000 'BF19.NHX0003.MEDMER3' DISP=SHR;
FILENAME NJ2000 'BF19.NJX0017.MEDMER6' DISP=SHR;
FILENAME NM2000 'BF19.NMX0016.MEDMER1' DISP=SHR;
FILENAME NV2000 'BF19.NVX0009.MEDMER5' DISP=SHR;
FILENAME NY2000 'BF19.NYX0003.MEDMER4' DISP=SHR;
FILENAME OH2000 'BF19.OHX0020.MEDMER7' DISP=SHR;
FILENAME OK2000 'BF19.OKX0010.MEDMER9' DISP=SHR;
FILENAME OR2000 'BF19.ORX0019.MEDMER4' DISP=SHR;
FILENAME PA2000 'BF19.PAX0010.MEDMER8' DISP=SHR;
FILENAME PR2000 'BF19.PRX0044.MEDMER1' DISP=SHR;
FILENAME RI2000 'BF19.RIX0019.MEDMER4' DISP=SHR;
FILENAME SC2000 'BF19.SCX0007.MEDMER5' DISP=SHR;
FILENAME SD2000 'BF19.SDX0014.MEDMER4' DISP=SHR;
FILENAME TN2000 'BF19.TNX0029.MEDMER3' DISP=SHR;
FILENAME TX2000 'BF19.TXX0023.MEDMER5' DISP=SHR;
FILENAME UT2000 'BF19.UTX0015.MEDMER4' DISP=SHR;
FILENAME VA2000 'BF19.VAX0011.MEDMER10' DISP=SHR;
FILENAME VI2000 'BF19.VIX0004.MEDMER' DISP=SHR;
FILENAME VT2000 'BF19.VTX0016.MEDMER1' DISP=SHR;
FILENAME WA2000 'BF19.WAX0005.MEDMER6' DISP=SHR;
FILENAME WI2000 'BF19.WIX0009.MEDMER9' DISP=SHR;
FILENAME WV2000 'BF19.WVX0008.MEDMER2' DISP=SHR;
FILENAME WY2000 'BF19.WYX0018.MEDMER4' DISP=SHR;
FILENAME YC2000 'BF19.YCX0027.MEDMER5' DISP=SHR;

%LET ST1  = AL;                                                                  
%LET ST2  = AK;                                                                  
%LET ST3  = AZ;                                                                  
%LET ST4  = AR;                                                                  
%LET ST5  = CA;                                                                  
%LET ST6  = CO;                                                                  
%LET ST7  = CT;                                                                  
%LET ST8  = DE;                                                                  
%LET ST9  = DC;                                                                  
%LET ST10 = FL;                                                                  
%LET ST11 = GA;                                                                  
%LET ST12 = HI;                                                                  
%LET ST13 = ID;                                                                  
%LET ST14 = IL;                                                                  
%LET ST15 = IN;                                                                  
%LET ST16 = IA;                                                                  
%LET ST17 = KS;                                                                  
%LET ST18 = KY;                                                                  
%LET ST19 = LA;                                                                  
%LET ST20 = ME;                                                                  
%LET ST21 = MD;                                                                  
%LET ST22 = MA;                                                                  
%LET ST23 = MI;                                                                  
%LET ST24 = MN;                                                                  
%LET ST25 = MS;                                                                  
%LET ST26 = MO;                                                                  
%LET ST27 = MT;                                                                  
%LET ST28 = NE;                                                                  
%LET ST29 = NV;                                                                  
%LET ST30 = NH;                                                                  
%LET ST31 = NJ;                                                                  
%LET ST32 = NM;                                                                  
%LET ST33 = NY;                                                                  
%LET ST34 = NC;                                                                  
%LET ST35 = ND;                                                                  
%LET ST36 = OH;                                                                  
%LET ST37 = OK;                                                                  
%LET ST38 = OR;                                                                  
%LET ST39 = PA;                                                                  
%LET ST40 = RI;                                                                  
%LET ST41 = SC;                                                                  
%LET ST42 = SD;                                                                  
%LET ST43 = TN;                                                                  
%LET ST44 = TX;                                                                  
%LET ST45 = UT;                                                                  
%LET ST46 = VT;                                                                  
%LET ST47 = VA;                                                                  
%LET ST48 = WA;                                                                  
%LET ST49 = WV;                                                                  
%LET ST50 = WI;                                                                  
%LET ST51 = WY;                                                                  
%LET ST52 = PR;                                                                 
%LET ST53 = VI;                                                                 
%LET ST54 = GU;                                                                 
%LET ST55 = YC;                                                                 
%LET ST56 = AS;                                                                  
%LET ST57 = MP;                                                                  
%LET TOTST =57;                                                                  

                                                                                
%MACRO COMBINE;
  %DO J=1 %TO &TOTST;
    %LET S = &&ST&J;
    DATA IN&J&K;
      INFILE &S&K;
      INPUT CAUSE $ 50-54;
    RUN;
  %END;

  DATA US&K;
    SET IN1&K IN2&K IN3&K IN4&K IN5&K IN6&K IN7&K IN8&K IN9&K IN10&K           
        IN11&K IN12&K IN13&K IN14&K IN15&K IN16&K IN17&K IN18&K 
        IN19&K IN20&K IN21&K IN22&K IN23&K IN24&K IN25&K IN26&K 
        IN27&K IN28&K IN29&K IN30&K IN31&K IN32&K IN33&K IN34&K 
        IN35&K IN36&K IN37&K IN38&K IN39&K IN40&K IN41&K IN42&K 
        IN43&K IN44&K IN45&K IN46&K IN47&K IN48&K IN49&K IN50&K 
        IN51&K IN52&K IN53&K IN54&K IN55&K IN56&K IN57&K;                              
  RUN;                                                                         
%MEND COMBINE;
%COMBINE
                                                                                

PROC SORT DATA=US&K;                                                     
  BY CAUSE;                                                                     
RUN;                                                                            


PROC FREQ DATA=US&K;                                                       
  TABLES CAUSE / MISSING NOPRINT OUT=USDATA;                                     
RUN;                                                                          


DATA US&K..DATA;
  SET USDATA;
RUN;
