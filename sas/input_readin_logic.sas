options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: input_readin_logic.sas
  *
  *  Summary: Hold the line for multiple INPUTting. V9+
  *
  *  Adapted: Wed 20 Nov 2013 14:46:34 (Bob Heckel--??)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

 /* The comma delimited data is read up through the third variable and the
  * trailing @ holds the input record. The ANYDIGIT function is used to view
  * the contents of the COUNT variable and if any numeric digit (0-9) is found
  * the function returns the position found. If the result is greater than 0
  * a number is found. Next, a DO loop is used to iterate the number of
  * times equal to the COUNT value to read in the remaining number of parts on
  * the record. The OUTPUT statement is used within the DO loop to create a new
  * observation for each part.  If the ANYDIGIT function returns a 0 a
  * number was not found. The PART variable is set to the COUNT value and the
  * single observation is output.
  */
data parts;
  infile datalines DSD truncover;
  input dept color : $10. count $ @;
  if anydigit(count) > 0 then do;
    /* It's possible to get multiple obs from one line of input, differing only
     * by part code
     */
    do i=1 to input(count, 8.);  /* char2num */
      input part $ @;
      output;
    end;
  end;
  else do;  /* count is not a counter when it's missing (it's A,B,C,D,E or F) */
    put _ALL_;  /* DEBUG */
    part=count;
    output;
  end;
  drop i count;
  datalines;
101,Green,3,A,B,C
102,Blue,A
103,Purple,F
104,Red,4,A,C,D,F
105,Orange,2,A,B
106,Yellow,E
  ;
run;

proc print; run;
 /*
Obs    dept    color     part

  1     101    Green      A
  2     101    Green      B
  3     101    Green      C
  4     102    Blue       A
  5     103    Purple     F
  6     104    Red        A
  7     104    Red        C
  8     104    Red        D
  9     104    Red        F
 10     105    Orange     A
 11     105    Orange     B
 12     106    Yellow     E
  */



endsas;
 /* Using logic to determine specific lines to read in */
data RawClaims_MT;
  infile 'colon_input.dat' delimiter = ';' MISSOVER DSD lrecl=234;

  input Record_ID :$3. @;
  if Record_ID = 'CLM' then do;
      input Claim_ID :$17.
            ActionCode :$1.
            NDC :$11.
            Date :YYMMDD8.
            Days_Supply :$6.
            Qty :$10.
            Amt_Paid :$11.
            ID_Number :$9.
            ;
      output;
  end;
run;


endsas;
colon_input.dat:
CLM;60999420010217598;0;60432009998;20051011;00030 ;00300.000 ;0000011.27 ;00057412E;0000099916;0000210800;0319503             ; ;00057999E;20000323;xxxEK          ;A           ;MULLINS                  ;M;00000000000000000;BM9999993 
PRV;0000099916;COxxxEN M MxxxON MD            ;BM4451073   ;7770        ;810141660 ;GREAT FALLS CLINIC          ;1400 xxxH ST SOUTH          ;GRxxxxxxxLS       ;MT;59405-0000;4064542171;810149990   ;37;                                
CLM;60529999990160751;0;00093415573;20051025;00010 ;00200.000 ;0000010.32 ;00058771E;0000431587;0000214081;0499971             ; ;00099971E;20001002;COLTON         ;J           ;BYRD                     ;M;00000000000000000;MC0099977 
PRV;0000999997;JACQxxxINE M xxxMENS ARNP      ;MC0046777   ;RN016567    ;810373301 ;                            ;P O BOX 1xxx                ;COLUMBIA FALLS    ;MT;59912-0000;4068923208;810999301   ;92;                                
CLM;99999720010286008;0;61314062810;20050914;00030 ;00010.000 ;0000017.06 ;00069820E;0000047668;0000211837;6656008             ; ;00069820E;20000624;NOAH           ;            ;ZxxxxRBERG               ;M;00000000000000000;BS9996931 
PRV;0000047668;SANDRxxxxxxxMONS MD            ;BS4846931   ;10051       ;810247705 ;                            ;2827 FT MISSOULA RD         ;xxxSOULA          ;Mx;59804-0000;4065420391;899947705   ;37;                                
