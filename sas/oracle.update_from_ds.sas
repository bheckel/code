/* Not sure how efficient this is... */

DATA _NULL_;SET lelimsgist05b2;
  /* Protect Oracle from strings containing single quotes */          
  ARRAY chars _CHARACTER_;
  DO OVER chars;
    chars=TRANWRD(chars, "'", "''");
  END;
  TotNum+1;
  CALL SYMPUT('TVarA'||COMPRESS(PUT(_N_,5.)),TRIM(LEFT(COMPRESS(Samp_Id))));
  CALL SYMPUT('TVarB'||COMPRESS(PUT(_N_,5.)),TRIM(LEFT(COMPRESS(Matl_Nbr))));
  CALL SYMPUT('TVarC'||COMPRESS(PUT(_N_,5.)),TRIM(LEFT(COMPRESS(Batch_Nbr))));
  CALL SYMPUT('TVarD'||COMPRESS(PUT(_N_,5.)),TRIM(LEFT(Prod_Grp)));
  CALL SYMPUT('TVarE'||COMPRESS(PUT(_N_,5.)),TRIM(LEFT(Prod_Nm)));
  CALL SYMPUT('TVarF'||COMPRESS(PUT(_N_,5.)),TRIM(LEFT(Prod_Level)));
  CALL SYMPUT('TVarG'||COMPRESS(PUT(_N_,5.)),TRIM(LEFT(Mfg_Tst_Grp)));
  CALL SYMPUT('TVarH'||COMPRESS(PUT(_N_,5.)),TRIM(LEFT(Sub_Batch)));
  CALL SYMPUT('TVarI'||COMPRESS(PUT(_N_,5.)),TRIM(LEFT(Samp_Comm_Txt)));
  CALL SYMPUT('TVarJ'||COMPRESS(PUT(_N_,5.)),TRIM(LEFT(Samp_Status)));
  CALL SYMPUT('TVarK'||COMPRESS(PUT(_N_,5.)),TRIM(LEFT(Stability_Study_Nbr_Cd)));
  CALL SYMPUT('TVarL'||COMPRESS(PUT(_N_,5.)),TRIM(LEFT(Stability_Samp_Stor_Cond)));
  CALL SYMPUT('TVarM'||COMPRESS(PUT(_N_,5.)),TRIM(LEFT(Stability_Samp_Time_Point)));
  CALL SYMPUT('TVarN'||COMPRESS(PUT(_N_,5.)),TRIM(LEFT(Stability_Study_Grp_Cd)));
  CALL SYMPUT('TVarO'||COMPRESS(PUT(_N_,5.)),TRIM(LEFT(Stability_Study_Purpose_Txt)));
  CALL SYMPUT('TVarP'||COMPRESS(PUT(_N_,5.)),TRIM(LEFT(Stability_Study_Max_TP)));

  IF Storage_Dt ^= . THEN DO;
          Stor_Dt=DATEPART(Storage_Dt);Stor_Month=UPCASE(PUT(Stor_Dt,monname3.));Stor_Day=PUT(DAY(Stor_Dt),Z2.);Stor_Year=YEAR(Stor_Dt);
          New_Storage_Dt="'"||TRIM(LEFT(Stor_Day))||'-'||TRIM(LEFT(Stor_Month))||'-'||TRIM(LEFT(Stor_Year))||"'";
          CALL SYMPUT('TVarQ'||COMPRESS(PUT(_N_,5.)),TRIM(LEFT(COMPRESS(New_Storage_Dt))));
  END;
  ELSE DO;
          CALL SYMPUT('TVarQ'||COMPRESS(PUT(_N_,5.)),"'01-JAN-1960'");
  END;

  CALL SYMPUT('TVarR'||COMPRESS(PUT(_N_,5.)),trim(LEFT(COMPRESS(Approved_By_User_Id))));

  IF Approved_Dt ^= . THEN DO;
          App_Dt=DATEPART(Approved_Dt);App_Month=UPCASE(PUT(App_Dt,monname3.));App_Day=PUT(DAY(App_Dt),Z2.);App_Year=YEAR(App_Dt);
          New_Approved_Dt="'"||TRIM(LEFT(App_Day))||'-'||TRIM(LEFT(App_Month))||'-'||TRIM(LEFT(App_Year))||"'";
          CALL SYMPUT('TVarS'||COMPRESS(PUT(_N_,5.)),TRIM(LEFT(COMPRESS(New_Approved_Dt))));
  END;
  ELSE DO;
          CALL SYMPUT('TVarS'||COMPRESS(PUT(_N_,5.)),"'01-JAN-1960'");
  END;

  CALL SYMPUT('TotNum',TotNum);
RUN;

/* Must wrap VARCHAR2s in single quotes for Oracle's UPDATE */
%LET sq=%STR(%');
%IF %SUPERQ(TotNum)^= %THEN %DO;
  PROC SQL;
    CONNECT TO ORACLE(USER=&oraid ORAPW=&orapsw BUFFSIZE=5000 PATH="&orapath");
    %DO I=1 %TO &TotNum;
            /****************************************************************************/
            /*****  V15 - When sample is commercial, protect stability vars by making ***/
            /*****        sure that ' ' is not used in the SET below.  Instead force  ***/
            /*****        a '' to tell Oracle that the value is NULL.                 ***/
            /****************************************************************************/
            %IF %LENGTH(&&TVarK&i) < 2  %THEN %DO;
                    %LET TVarK&i=;
                    %LET TVarL&i=;
                    %LET TVarM&i=;
                    %LET TVarN&i=;
                    %LET TVarO&i=;
                    %LET TVarP&i=;
            %END;
            EXECUTE (
            UPDATE SAMP
            SET Prod_Grp                 =&sq.&&TVarD&i.&sq, 
            Prod_Nm                      =&sq.&&TVarE&i.&sq, 
            Prod_Level                   =&sq.&&TVarF&i.&sq, 
            Mfg_Tst_Grp                  =&sq.&&TVarG&i.&sq, 
            Sub_Batch                    =&sq.&&TVarH&i.&sq, 
            Samp_Comm_Txt                =&sq.&&TVarI&i.&sq, 
            Samp_Status                  =&sq.&&TVarJ&i.&sq,
            Stability_Study_Nbr_Cd       =&sq.&&TVarK&i.&sq,
            Stability_Samp_Stor_Cond     =&sq.&&TVarL&i.&sq,
            Stability_Samp_Time_Point    =&sq.&&TVarM&i.&sq,
            Stability_Study_Grp_Cd       =&sq.&&TVarN&i.&sq,
            Stability_Study_Purpose_Txt  =&sq.&&TVarO&i.&sq,
            Stability_Study_Max_TP       =&sq.&&TVarP&i.&sq,
            Storage_Dt                   =&&TVarQ&i,
            Approved_By_User_Id          =&sq.&&TVarR&i.&sq,
            Approved_Dt                  =&&TVarS&i
            WHERE Samp_Id  = &&TVarA&i AND MATL_NBR = &sq.&&TVarB&i.&sq AND BATCH_NBR = &sq.&&TVarC&i.&sq
            %IF &HSQLXRC = 0 %THEN %DO;
                    %IF &HSQLXMSG = '' OR &HSQLXMSG = ' ' OR &HSQLXMSG = 
                            %THEN %LET CondCode = 0;
                            %ELSE %LET CondCode = 4;
            %END;
            %ELSE %LET CondCode = 12;
            ) BY ORACLE;
    %END;
    DISCONNECT FROM ORACLE;
  QUIT;
  RUN;
%END;
