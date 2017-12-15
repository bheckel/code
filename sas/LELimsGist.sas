****************************************************************************************;
*                     PROGRAM HEADER                                                   *;
*--------------------------------------------------------------------------------------*;
*  PROJECT NUMBER: ZEO-986025-1                                                        *;
*  PROGRAM NAME: LELimsGist.SAS                 SAS VERSION: 8.2                       *;
*  DEVELOPED BY: Michael Hall                   DATE: 10/14/2002                       *;
*  PROJECT REPRESENTATIVE: Carol Hiser                                                 *;
*  PURPOSE: Extract and Translate data from LIMS and GIST databases.                   *;
*  SINGLE USE OR MULTIPLE USE? (SU OR MU) MU                                           *;
*  PROGRAM ASSUMPTIONS OR RESTRICTIONS: The LIMS, GIST, and LINKS databases            *;
*     must be up and accessable for this program to function correctly.                *;
*--------------------------------------------------------------------------------------*;
*  OTHER SAS PROGRAMS, MACROS OR MACRO VARIABLES USED IN THIS                          *;
*  PROGRAM:  GetParm.sas, LeGist.sas, LeLimsSumRes.sas, LeLimsIndRes.sas,              *;
*            UpdActLg.sas, LdrBld.sas, SqlDel.sas, LdrRun.sas, SendMsg.sas,            *;
*            LeLIMSGist.sql                                                            *;
*--------------------------------------------------------------------------------------*;
*  DESCRIPTION OF OUTPUT: Data is loaded into LINKS database                           *;
*--------------------------------------------------------------------------------------*;
*  LOGIC:                                                                              *;
*    SETUP:                                                                            *;
*       GetParm       Call GetParm macro to obtain all variable parameters             *;
*                     uilized in the program, one call per parameter needed.           *;
*       CkRptFlg      Ensure the program is currently not running for more             *;
*                     than an hour, and ensure the program has not abended             *;
*                     in the previous run.                                             *;
*    EXTRACTION:                                                                       *;
*       LELimsSumRes  Extract the LIMS Result data from the Result table.              *;
*       LELimsIndRes  Extract the LIMS Result data from the Element table.             *;
*       LEGist        Extract the GIST data from the Study table.                      *;
*    TRANSLATION:                                                                      *;
*       To_Num        Convert text strings into numbers by removing all                *;
*                     characters (ex: "25 C" converts to "25"). (Called by             *;
*                     TrnLimsS and TrnLimsI).                                          *;
*       DeDup         Sort and remove duplicates from the passed SAS dataset.          *;
*                     (Called by TrnLimsS, TrnLimsI).                                  *;
*       TrnFmts       Read the LINKS PEC table, calling LoadFmt once for each          *;
*                     user defined format.                                             *;
*          LoadFmt    Formulate the desired field into a FORMAT-ready SAS              *;
*                     dataset, sort it and store it using PROC FORMAT.                 *;
*       TrnGist       Translate the GIST data by extract study purpose and             *;
*                     storage date from study desc field from LEGist.                  *;
*       TrnLimsS      Translate the data from LELimsSumRes (vertical format)           *;
*                     into a horizontal format.                                        *;
*          LEXBTCH    Extract Batch Info from the LIMS SampName                        *;
*          LEXSTDY    Extract Study Info from the LIMS SampName                        *;
*          SRLTDesc   Determine correct Lab Test Description data to store.            *;
*       TrnSamp       Extract the needed elements from TrnLimsS for the LINKS          *;
*                     Samp table.                                                      *;
*       TrnTRS        Extract the needed elements from TrnLimsS for the LINKS          *;
*                     Tst_Rslt_Summary table.                                          *;
*       TrnST         Extract the needed elements from TrnLimsS for the LINKS          *;
*                     Tst_Rslt_Summary table and then adding the                       *;
*                     Indvl_Meth_Stage_Nm field.                                       *;
*       TrnLimsI      Translate the data from LELimsIndRes (vertical format)           *;
*                     into a horizontal format.                                        *;
*       TrnITR        Extract the needed elements from TrnLimsI for the LINKS          *;
*                     Indvl_Tst_Rslt table.                                            *;
*       TrnTP         Extract the needed elements from TrnLimsS for the LINKS          *;
*                     Tst_Parm table.                                                  *;
*    LOAD:                                                                             *;
*       VerData       Ensure the data will load into the tables properly,              *;
*                     before the Table Load process starts.                            *;
*       LdData                                                                         *;
*          LdrBld     Call LdrBld external macro, one for each table. This             *;
*                     will build the CTL and DAT files for the LdrRun                  *;
*                     process.                                                         *;
*          (next)     Lock the database from reporting.                                *;
*          SqlDel     Purge the old sample data from the LINKS database.               *;
*          LdrRun     Call LdrRun external macro to load each table, LM,               *;
*                     Samp, TRS, ST, ITR, and TP.                                      *;
*    CLEANUP          If successful, delete all work files. If unsuccessful,           *;
*                     determine cause of error, call UpdActLg external macro,          *;
*                     and send Emails to the System Administrators.                    *;
*       UpdActLg      Log the results in the Activity Log.                             *;
****************************************************************************************;
*                     HISTORY OF CHANGE                                                *;
*-------------+---------+--------------+-----------------------------------------------*;
*     DATE    | VERSION | NAME         | Description                                   *;
*-------------+---------+--------------+-----------------------------------------------*;
*  10/14/2002 |    1.0  | Michael Hall | Original                                      *;
*-------------+---------+--------------+-----------------------------------------------*;
*  10/30/2002 |    2.0  | Michael Hall | * TrnLimsS - Removed SRPKGAPP                 *;
*             |         |              |   macro processing.                           *;
*             |         |              | * TrnLimsI - Modified IR002A macro            *;
*             |         |              |   processing to include the last              *;
*             |         |              |   column before the $ in the                  *;
*             |         |              |   ColName field (INDIVIDUAL vs.               *;
*             |         |              |   INDIVIDUALS) which contains                 *;
*             |         |              |   SHAPEINDIVIDUALS$.                          *;
*-------------+---------+--------------+-----------------------------------------------*;
*  11/01/2002 |    3.0  | Michael Hall | VTR0034                                       *;
*             |         |              | * VerData - Changed Indvl_Tst_Res             *;
*             |         |              |   to Indvl_Tst_Rslt.                          *;
*-------------+---------+--------------+-----------------------------------------------*;
*  02/06/2003 |    4.0  | James Becker | In %MACRO TRNLIMSI :                          *;
*             |         |              | - Added Macro IR003B & IR003C to              *;
*             |         |              |   create Indvl_Tst_Rslt_Nm due to             *;
*             |         |              |   change in LIMS.                             *;
*             |         |              | - Removed Macro IRNVDEV                       *;
*             |         |              |-----------------------------------------------*;
*             |         |              | In %MACRO TRNLIMSS :                          *;
*             |         |              | - Removed Macro SRMETH & SRMETHD              *;
*             |         |              | - Added Lab_Tst_Meth &                        *;
*             |         |              |   Lab_Tst_Meth_SPec_Desc to be                *;
*             |         |              |   pulled from PEC Table.                      *;
*             |         |              | - Added code for missing <0.05 value          *;
*             |         |              |-----------------------------------------------*;
*             |         |              | In %MACRO TRNTP :                             *;
*             |         |              | - Added Code to check Indvl_Tst_              *;
*             |         |              |   Rslt_Device if records don't match          *;
*             |         |              |-----------------------------------------------*;
*             |         |              | - Additional Error Handling in                *;
*             |         |              |     %MACRO VERDATA                            *;
*             |         |              | - Additional Error Files in                   *;
*             |         |              |     %MACRO CLEANUP                            *;
*             |         |              | - Added 1 Daily Email if running OK           *;
*             |         |              |     %MACRO CLEANUP                            *;
*-------------+---------+--------------+-----------------------------------------------*;
*  08/25/2003 |    5.0  | James Becker | Amendment for SAP/MERPS project:              *;
*             |         |              | - Replaced Lot_Nbr With                       *;
*             |         |              |   Matl_Nbr/Batch_Nbr                          *;
*             |         |              |   in the following Macros:                    *;
*             |         |              |     %MACRO LEXBTCH                            *;
*             |         |              |     %MACRO TRNGIST                            *;
*             |         |              |     %MACRO TRNLIMSS                           *;
*             |         |              |     %MACRO TRNPMD                             *;
*             |         |              |     %MACRO VERDATA                            *;
*             |         |              |     %MACRO CLEANUP                            *;
*             |         |              | - Check for Corrupted Database                *;
*             |         |              | - if Material Number is not found in          *;
*             |         |              |   LINKS_Material, populate LINKS_Material &   *;
*             |         |              |   LINKS_Material_Genealogy tables from        *;
*             |         |              |   AMAPS_Matl_History table.                   *;
*-------------+---------+--------------+-----------------------------------------------*;
*  10/02/2003 |    6.0  | James Becker | Cascade Impaction Program Changes             *;
*             |         |              | - Modified the following Macros:              *;
*             |         |              |     %MACRO TRNTRS - CI Steps for PKS Table    *;
*             |         |              |     %MACRO TRNST  - CI Steps for PKS Table    *;
*             |         |              |-----------------------------------------------*;
*             |         |              | In %MACRO TRNLIMSS :                          *;
*             |         |              | - Added Macro IR005A, IRPEAK & IRNVLIM        *;
*             |         |              |-----------------------------------------------*;
*             |         |              | In %MACRO TRNLIMSI :                          *;
*             |         |              | - Added Macro IR005A & IR005B                 *;
*-------------+---------+--------------+-----------------------------------------------*;
*  10/14/2003 |    7.0  | James Becker |VTR0006                                        *;
*             |         |              |     %MACRO LEXBTCH - Replaced INDEX with      *;
*             |         |              |          INDEXC in two places.                *;
*-------------+---------+--------------+-----------------------------------------------*;
*  11/20/2003 |    8.0  | James Becker | Modified %MACRO CLEANUP                       *;
*             |         |              | - Added '^= 12' To Fix Military Time For      *;
*             |         |              |   12:00-12:59pm.                              *;
*-------------+---------+--------------+-----------------------------------------------*;
*  01/29/2004 |    9.0  | James Becker | VCC29954 - Cascade Impaction Program Changes  *;
*             |         |              | - Modified the following Macros:              *;
*             |         |              |     %MACRO TrnLimsS - CI Steps for TRS Table  *;
*             |         |              |     %MACRO TrnLimsI - CI Steps for ITR Table  *;
*-------------+---------+--------------+-----------------------------------------------*;
*  03/31/2004 |   10.0  | James Becker | VCC31135 - Cascade Impaction Program Changes  *;
*             |         |              | - Modified the following Macros:              *;
*             |         |              |     %MACRO TrnITR   - Added Res_ID to delete  *;
*             |         |              |                       Duplicates by.          *;
*-------------+---------+--------------+-----------------------------------------------*;
*  01/13/2005 |   11.0  | James Becker | VCC32356 - Create Genealogy file for          *;
*             |         |              |     multiple LINKS Programs                   *;
*             |         |              |     %MACRO LeGenealogy - Added                *;
*--------------------------------------------------------------------------------------*;
*  02Aug2005  |   12.0  | Tammy Hodges | VCC42394 - Changed ProcStatus > 15 to         *;
*             |         |              |            ProcStatus > 0                     *;
*--------------------------------------------------------------------------------------*;
*  09SEP2005  |   13.0  | James Becker | VCC43014 - Change for dynamic data            *;
*             |         |              |          - Created MulipleSqlDel macro for    *;
*             |         |              |            more than one variable.            *;
*--------------------------------------------------------------------------------------*;
*  21OCT2005  |   14.0  | James Becker | VCC43434 - Create MetaData file for           *;
*             |         |              |     multiple LINKS Programs                   *;
*             |         |              |     %MACRO LeMetaData - Added                 *;
*--------------------------------------------------------------------------------------*;
*  20JAN2006  |   15.0  | James Becker | VCC45936    SiteWide LINKS Phase I            *;
*             |         |              | %TrnFmts  - added 2 new variables             *;
*             |         |              | %TrnGist  - Added INDEX3 check                *;
*             |         |              | %TrnLimsS - added step to standardize         *;
*             |         |              |             product names                     *;
*             |         |              |           - added step to determine strength  *;
*             |         |              |             where 2 or more exist for a prod  *;
*             |         |              |           - modified LinkLvl for multiple     *;
*             |         |              |             strength prods                    *;
*             |         |              |           - added LinkLvl for new prods       *;
*             |         |              |           - added method to indres pull       *;
*             |         |              |           - added datasets 03f2 and 03u       *;
*             |         |              |           - added 03a to merge statement      *;
*             |         |              |           - added block to handle methods     *;
*             |         |              |             shared across products            *;
*             |         |              |           - added exception for GENUSPDISS    *;
*             |         |              |           - modified svc assignment for       *;
*             |         |              |             prods having multiple strengths   *;
*             |         |              |           - added block for ATM02003          *;
*             |         |              |           - added error trap for cases where  *;
*             |         |              |             prods share methods               *;
*             |         |              |           - added prefixes for new methods    *;
*             |         |              |           - added block to standardize        *;
*             |         |              |             the "Conforms" strings            *;
*             |         |              |           - added IRNVLIM macro               *;
*             |         |              |           - added Approved_Dt dataset         *;
*             |         |              |           - widen Approved_By_User_Id to $30  *;
*             |         |              | %TrnLimsI - added methods to lmac assignment  *;
*             |         |              |             and output statements             *;
*             |         |              |           - added device # for drug release   *;
*             |         |              |             and dissolution methods           *;
*             |         |              |           - added IRPREP macro                *;
*             |         |              |           - added suffix for drug release     *;
*             |         |              |           - elemstrval                        *;
*             |         |              |           - added Indvl_Meth_Stage_Nm for     *;
*             |         |              |             drug release and dissolution      *;
*             |         |              |           - added call to %DEDUP for          *;
*             |         |              |             Indvl_Tst_Rslt_Prep               *;
*             |         |              |           - Modified IRPeak for 1st word      *;
*             |         |              |             in string only                    *;
*             |         |              | %TrnSamp  - modify 05b datastep for empty     *;
*             |         |              |             Prod_Nm and Prod_Grp              *;
*             |         |              | %TrnST    - added Indvl_Meth_Stage_Nm and     *;
*             |         |              |             Summary_Meth_Stage_Nm             *;
*             |         |              | %TrnITR   - added CALCWEIGHTS to IF statment  *;
*             |         |              |           - added an Indvl_Meth_Stage_Nm      *;
*             |         |              |             exception for ATM02003            *;
*             |         |              |           - avoid sorting on numeric values   *;
*             |         |              | %LdData   - modified Oracle's UPDATE to use   *;
*             |         |              |             faster pass-thru style SQL        *;
*             |         |              | %TimeCheck- changed year from 2 to 4 digits   *;
*             |         |              | %CleanUp  - changed year from 2 to 4 digits   *;
*             |         |              |           - added email setup for new error   *;
*             |         |              |             trap                              *;
*             |         |              | %MultipleDEDUP - added dual key duplicate     *;
*             |         |              |                  removal macro                *;
*             |         |              |                  removal macro                *;
*             |         |              | %LELimsGist - check CondCode individually     *;
*--------------------------------------------------------------------------------------*;
*  09JUN2006  |   16.0  | Bob Heckel   | VCC45936    SiteWide LINKS Phase I            *;
*             |         |              | %TrnLimsS - modified code that determines     *;
*             |         |              |             strength for Bupropion and        *;
*             |         |              |             Lamictal                          *;
*--------------------------------------------------------------------------------------*;
*  10JUL2006  |   17.0  | James Becker | VCC51274    Missing Water Content/Appearance  *;
*             |         |              | %TrnLimsI - Modified DEVICE code for %IRDEV   *;
*             |         |              |             Modified DEVICE code for BLEND &  *;
*             |         |              |             CASCADE                           *;
*--------------------------------------------------------------------------------------*;
*  11JUL2006  |   18.0  | Bob Heckel   | VCC51556    SiteWide Phase I adjustments      *;
*             |         |              | %TrnLimsS - modified code that blanks         *;
*             |         |              |             Matl_Nbr to include all prods,    *;
*             |         |              |             not just Advair                   *;
*             |         |              |           - Added block to read in list of    *;
*             |         |              |             product from external file        *;
*             |         |              |           - Added 8/2, 8/4 strengths for      *;
*             |         |              |             Avandaryl                         *;
*             |         |              |           - Reordered WHEN statements for     *;
*             |         |              |             Lamictal CD                       *;
*             |         |              |           - Added code to parse ResStrVal     *;
*             |         |              |             for new Valtrex data              *;
*             |         |              |           - Added 24MG strength for Zofran    *;
*             |         |              |           - Added Ondansetron                 *;
*             |         |              |           - Added 'SAL/FP' as alternate       *;
*             |         |              |             Advair HFA product string         *;
*             |         |              |           - Added 'Albuterol' as alternate    *;
*             |         |              |             Ventolin product string           *;
*             |         |              |           - Added ID* methods to list of      *;
*             |         |              |             shared products                   *;
*             |         |              |           - Added code to limit debug data    *;
*             |         |              |             printing to the Log (avoid        *;
*             |         |              |             overflow)                         *;
*             |         |              |           - Removed CALCWEIGHT from 2 blocks  *;
*             |         |              |             shared products                   *;
*             |         |              |           - Added products Ondansetron,       *;
*             |         |              |             Albuterol                         *;
*             |         |              |           - added more shared methods to      *;
*             |         |              |             IF statement list                 *;
*             |         |              |           - modified IF statment to ignore    *;
*             |         |              |             PRODUCTCODE$                      *;
*             |         |              |           - Addded exceptions for method      *;
*             |         |              |             MEANSPRAYPATTERN                  *;
*             |         |              | %TrnITR   - Modify ACTUATOR delete line       *;
*             |         |              |           - Add 'ATM02064CONTENTHPLC' to      *;
*             |         |              |             avoid WT device dups              *;
*--------------------------------------------------------------------------------------*;
*  23JUL2006  |   19.0  | James Becker | VCC51556/VCC51914                             *;
*             |         |              | %SampelRemoval - Added Macro to skip over     *;
*             |         |              |                  bad samples and send out an  *;
*             |         |              |                  email to prevent LINKS from  *;
*             |         |              |                  not running                  *;
*             |         |              | %TrnGist       - Added INDEX4 check           *;
*--------------------------------------------------------------------------------------*;
*  29SEP2006  |   20.0  | James Becker | VCC51556/VCC51914                             *;
*             |         |              | %TrnITR   - Modify Deletions of Cascade       *;
*             |         |              |             with no Num Values                *;
*--------------------------------------------------------------------------------------*;
*  30OCT2006  |   21.0  | James Becker | VCC55175                                      *;
*             |         |              | %TrnITR   - Add AM0952 to list of methods     *;
*             |         |              |             requiring actual RowIx to fix     *;
*             |         |              |             Pct vs. Weight problem            *;
*             |         |              | %TrnLimsS - Change date field pulled from     *;
*             |         |              |             ResEntTs to EntryTs               *;
*             |         |              | %LELimsGist - Changed Date Criteria to look   *;
*             |         |              |               at 3 LIMS dates instead of 1    *;
*--------------------------------------------------------------------------------------*;
*  11DEC2006  |   22.0  | Bob Heckel   | VCC55755                                      *;
*             |         |              | %TrnITR   - Renumber ATM02064 device to       *;
*             |         |              |             avoid deletions due to LIMS       *;
*             |         |              |             non-sequential numbering          *;
*--------------------------------------------------------------------------------------*;
*  14MAR2007  |   23.0  | James Becker | VCC57957                                      *;
*             |         |              | %TrnITR   - Added CASCADE to line to          *;
*             |         |              |             avoid deletions due to LIMS       *;
*             |         |              |             non-sequential numbering          *;
*             |         |              | %TrnLimsI - Added macro IRNUMDEV to create    *;
*             |         |              |             variable to hold # or devices     *;
*--------------------------------------------------------------------------------------*;
*  12APR2007  |   24.0  | Bob Heckel   | Add Relenza VCC57535                          *;
*             |         |              | %TrnLimsS - add Relenza Rotadisk string       *;
*             |         |              |           - removed 03l (spec info is now in  *;
*             |         |              |             a separate table)                 *;
*             |         |              |           - removed %SRLIM macro              *;
*             |         |              |             (and %SRLIM macro calls)          *;
*             |         |              | %TrnLimsI - added macro IR005D                *;
*             |         |              |           - added CI for Relenza -            *;
*             |         |              |             Indvl_Meth_Stage_Nm and           *;
*             |         |              |             Meth_Var_Nm                       *;    
*             |         |              | %TrnST    - added CI stages for Relenza       *;
*             |         |              | %TrnITR   - added CI stages for Relenza       *;
*             |         |              |           - added impurities for Relenza      *;
*--------------------------------------------------------------------------------------*;
*  03APR2007  |   25.0  | James Becker | VCC57958  BOE/EOU For Cascade Methods         *;
*             |         |              | %TrnLimsS - Added pull from SumRes of         *;
*             |         |              |             "INHALERUSE" records to be run    *;
*             |         |              |             thru %TrnLimsI                    *;
*             |         |              | %TrnLimsI - Added macro IRUSE to write        *;
*             |         |              |             BOU/EOU - Indvl_tst_rslt_Location *;
*             |         |              | %TrnITR   - added 04e2 dataset to hold        *;
*             |         |              |             BOU/EOU in Location               *;
*--------------------------------------------------------------------------------------*;
*  02MAY2007  |   26.0  | James Becker | VCC57958  BOE/EOU For Cascade Methods         *;
*             |         |              | %TrnLimsS - Changed Summary_Meth_Stage_Nm     *;
*             |         |              |             from 6F to 6-F and 34 to 3-4      *;
*             |         |              | %TrnST    - Changed Summary_Meth_Stage_Nm     *;
*             |         |              |             from 6F to 6-F and 34 to 3-4      *;
*--------------------------------------------------------------------------------------*;
*  03MAY2007  |   27.0  | James Becker | VCC59356  Missing Diskus Cascade              *;
*             |         |              | %TrnLimsS - Added code which Fixed Diskus     *;
*             |         |              |             Cascade from missing in LINKS     *;
*--------------------------------------------------------------------------------------*;
*  07MAY2007  |   28.0  | James Becker | VCC59495  Missing Diskus Cascade              *;
*             |         |              | %TrnLimsS - Added code which made sure all    *;
*             |         |              |             methods would be loaded in LINKS  *;
*             |         |              | %LdData   - Added check to verify methods     *;
*             |         |              |             being written to LINKS            *;
*--------------------------------------------------------------------------------------*;
*  25MAY2007  |   29.0  | James Becker | VCC60195  BOE/EOU For Cascade Methods         *;
*             |         |              | %TrnITR   - Added code to distinguish between *;
*             |         |              |             BOU and EOU records.              *;
*--------------------------------------------------------------------------------------*;
*  03AUG2007  |   30.0  | Bob Heckel   | VCC62215  Duplicates exist for  CI 6-F Diskus *;
*             |         |              | %TrnITR   - Added code to eliminate dups      *;
*             |         |              |             for 6-F second loops              *;
*-------------+---------+--------------+-----------------------------------------------*;
*  19OCT2007  |   31.0  | Bob Heckel   | VCC63536 Add Ventolin HFA                     *;
*             |         |              | %TrnLimsS                                     *;
*             |         |              |    - Added Ventolin and Albuterol strings     *;
*             |         |              |      to product name parsing section.         *;
*             |         |              |    - Removed Ventolin from multi-strength     *;
*             |         |              |      exception section.                       *;
*             |         |              |    - Modified shared method list.             *;
*             |         |              |    - Added AVERAGEDOSEWEIGHT to exception.    *;
*             |         |              |    - Added 2TO6 summary meth stage.           *;
*             |         |              | %TrnLimsI                                     *;
*             |         |              |    - Removed AM0995 for filling peak.         *;
*             |         |              |    - Added WTOFSUSP to criteria.              *;
*             |         |              |    - Added 2TO6 individual meth stage.        *;
*             |         |              |    - Added PEAKINFOCALCSUMS to existing       *;
*             |         |              |      Diskus, AdvHFA and Relenza meth_var_nm   *;
*             |         |              |      list.                                    *;
*             |         |              | %TrnST                                        *;
*             |         |              |    - Added 2-6 individual stages.             *;
*             |         |              |    - Added Cascade ATM02003.                  *;
*             |         |              | %TrnITR                                       *;
*             |         |              |    - Removed Duplicates - AM02003 CASCADE.    *;
*--------------------------------------------------------------------------------------*;
*  07NOV2007  |   32.0  | Bob Heckel   | VCC63536    Modifications based on regression *;
*             |         |              |             test findings.                    *;
*             |         |              | %TrnLimS  - Modified ProdName determination   *;
*             |         |              |             of Ventolin.                      *;
****************************************************************************************;
*                       MODULE HEADER                                                  *;
*--------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SETUP                                                            *;
*   REQUIREMENT:      N/A                                                              *;
*   INPUT:            None.                                                            *;
*   PROCESSING:       Calls GetParm for every parameter needed from the                *;
*                     LINKS.ini file.                                                  *;
*   OUTPUT:           Extablishes the following global parms:                          *;
*                     OraPath, OraId, OraId, OraPsw, GistPath, GistId,                 *;
*                     GistPsw, LimsPath, LimsId, LimsPsw, SqlPlus, SqlLdr              *;
*                     ErrMsg, CtlDir, FailLog, SysAdmin, EmailPgm,                     *;
*                     ServerName, GistFltr, LimsFltr, IRKey, SQLErr, JobStep,          *;
*                     CondCode, HSqlXMsg, HSqlXRC                                      *;
****************************************************************************************;
%MACRO	SetUp;
	
	OPTIONS NUMBER NODATE NOMLOGIC MPRINT NOSYMBOLGEN SOURCE2 PAGENO=1 ERROR=2
			MERGENOBY=ERROR MAUTOSOURCE LINESIZE=120 NOCENTER PAGENO=1 NOXWAIT
			SPOOL COMPRESS=YES BLKSIZE=2560 MSGLEVEL=I MRECALL FULLSTIMER; 
	%GLOBAL HSqlXMSG HSqlXRC 
			OraPath OraId OraPsw
			SysAdmin SqlPlus SqlLdr ErrMsg CtlDir
			GistPath GistId GistPsw gistfltr
			LimsPath LimsId LimsPsw limsfltr
			IRKey SqlErr FailLog Success datefltr datefltr2 datefltr3 
			JobStep StepRC CondCode LMCheck TimeCheck ServerName EmailPgm
			M_Samp M_TRS M_ST M_ITR M_TP TableFlag NormalRun FullRun DebugRun
			Ld_LMTable LD_LMGTable RunAMAPS SampFull Tst_Parm_Flag AMAPS_Execute
                        SampNum LimitSamps RunDate
			;

	%LET CondCode   	= 0;
	%LET LMCheck 		= 0;
	%LET AMAPS_Execute	= 0;
	%LET ServerName		= ;
	%LET FailLog		= N;
	%LET JobStep		= N; 
	%LET Tst_Parm_Flag 	= N;

			/* Get the parameters from the LINKS.INI file.           */
			/* NOTE: The following parameters MUST come first and in */
			/*       the following sequence: CtlDir, ServerName,     */
			/*       DefaultErrMsg, EmailPgm, and SysAdmin.          */
			/*       DO NOT code GetParm calls above these.          */
	%IF &CondCode = 0 %THEN %DO; %GetParm(SasServer, CtlDir, N);		%LET CtlDir     = &parm;  %END;
	%IF &CondCode = 0 %THEN %DO; %GetParm(SasServer, ServerName, N);	%LET ServerName = &parm;  %END;
	%IF &CondCode = 0 %THEN %DO; %GetParm(SasServer, DefaultErrMsg, N);	%LET ErrMsg     = &parm;  %END;
	%IF &CondCode = 0 %THEN %DO; %GetParm(SasServer, EmailPgm, N);		%LET EmailPgm   = &parm;  %END;
	%IF &CondCode = 0 %THEN %DO; %GetParm(SasServer, SysAdmin, N);		%LET SysAdmin   = &parm;  %END;
			/*       Other parameter calls go here:                  */
	%IF &CondCode = 0 %THEN %DO; %GetParm(SasServer, SqlPlus, N);		%LET SqlPlus    = &parm;  %END;
	%IF &CondCode = 0 %THEN %DO; %GetParm(SasServer, SqlLdr, N);		%LET SqlLdr     = &parm;  %END;
	%IF &CondCode = 0 %THEN %DO; %GetParm(GistServer, ServerName, N);	%LET GistPath   = &parm;  %END;
	%IF &CondCode = 0 %THEN %DO; %GetParm(GistServer, UserId, N);		%LET GistId     = &parm;  %END;
	%IF &CondCode = 0 %THEN %DO; %GetParm(GistServer, UserPsw, Y);		%LET GistPsw    = &parm;  %END;
	%IF &CondCode = 0 %THEN %DO; %GetParm(LimsServer, ServerName, N);	%LET LimsPath   = &parm;  %END;
	%IF &CondCode = 0 %THEN %DO; %GetParm(LimsServer, UserId, N);		%LET LimsId     = &parm;  %END;
	%IF &CondCode = 0 %THEN %DO; %GetParm(LimsServer, UserPsw, Y);		%LET LimsPsw    = &parm;  %END;
	%IF &CondCode = 0 %THEN %DO; %GetParm(DbServer, ServerName, N);		%LET OraPath    = &parm;  %END;
	%IF &CondCode = 0 %THEN %DO; %GetParm(DbServer, SysOperId, N);		%LET OraId      = &parm;  %END;
	%IF &CondCode = 0 %THEN %DO; %GetParm(DbServer, SysOperPsw, Y);		%LET OraPsw     = &parm;  %END;

	%LET limsfltr	=;
	%LET gistfltr	=;
	%LET IRKey		= Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Id
					  Indvl_Tst_Rslt_Row Res_Loop Res_Repeat Res_Replicate;
	%LET SqlErr		= &CtlDir.LELimsGist.err;

%MEND	SetUp;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: LEXBTCH                                                         *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Extract Manufacturing Information                               *;
*   INPUT:            SampName field.                                                 *;
*   PROCESSING:       Extracts Lot_Nbr, Mfg_Tst_Grp, and Sub_Batch from               *;
*                     SampName                                                        *;
*   OUTPUT:           Lot_Nbr, Mfg_Tst_Grp, and Sub_Batch fields.                     *;
***************************************************************************************;
%MACRO	LEXBTCH;
		/************************************************************/
		/*** V5 - Replaced Lot_Nbr with Matl_Nbr & Batch_Nbr      ***/
		/************************************************************/
	 	IF INDEX(SampName, "-") > 0 THEN DO;
			Batch_Nbr  	= SUBSTR(SampName,1,INDEX(SampName, "-")-1); 
			SubSampName 	= SUBSTR(SampName,INDEX(SampName, "-")+1);
			Matl_Nbr 	= SUBSTR(Matl_Nbr,1);
			/************************************************************/
			/*** V7 - Replaced INDEX with INDEXC in two places below  ***/
			/************************************************************/
	 		IF INDEXC(SubSampName, "-/") > 0 THEN DO;
				Mfg_Tst_Grp = SUBSTR(SubSampName,1,INDEXC(SubSampName, "-/")-1);
				Sub_Batch   = SUBSTR(SubSampName,INDEXC(SubSampName, "-/")+1);
			END;
			ELSE DO;
				Mfg_Tst_Grp = '';
				Sub_Batch = '';
			END;
		END;
		ELSE DELETE; 				
		Matl_Nbr  	= UPCASE(Matl_Nbr); 
		Batch_Nbr 	= UPCASE(Batch_Nbr); 
		IF LAST.Samp_ID THEN PUT Samp_Id SampName Batch_Nbr SubSampName Matl_Nbr Sub_Batch Mfg_Tst_Grp;

%MEND	LEXBTCH;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: LEXSTDY                                                         *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Extract Study Information                                       *;
*   INPUT:            SampName field                                                  *;
*   PROCESSING:       Extracts Stability_Study_Nbr_Cd,                                *;
*                     Stability_Samp_Stor_Cond, Stability_Samp_Time_Point             *;
*                      and Sub_Batch from SampName                                    *;
*   OUTPUT:           Lot_Nbr, Mfg_Tst_Grp, and Sub_Batch fields                      *;
***************************************************************************************;
%MACRO	LEXSTDY;
		IF INDEX(SampName, "-") > 0 THEN DO;
			Stability_Study_Nbr_Cd   = SUBSTR(SampName,1,INDEX(SampName, "-")-1);
			SubSampName 		 = SUBSTR(SampName,INDEX(SampName, "-")+1);
			Stability_Samp_Stor_Cond = SUBSTR(SubSampName,1,INDEX(SubSampName, "-")-1);
			Stability_Samp_Stor_Cond = 
				SUBSTR(Stability_Samp_Stor_Cond,1,INDEX(Stability_Samp_Stor_Cond, "/")-1)
				|| "C/" ||
				TRIM(SUBSTR(Stability_Samp_Stor_Cond,INDEX(Stability_Samp_Stor_Cond, "/")+1));
			SubSampName = SUBSTR(SubSampName,INDEX(SubSampName, "-")+1);
			Stability_Samp_Time_Point = INPUT(SUBSTR(SubSampName,1,INDEX(SubSampName, "-")-1),$4.);
			IF Stability_Samp_Time_Point = 'INT' THEN Stability_Samp_Time_Point = '0';
			Sub_Batch = SUBSTR(SubSampName,INDEX(SubSampName, "-")+1);
		END;
		ELSE Stability_Study_Nbr_Cd = SampName;
%MEND	LEXSTDY;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SRLTDesc                                                        *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Extract Lab Test Description                                    *;
*   INPUT:            VarDispName field, svc field, and format $LLTDesc.              *;
*   PROCESSING:       Determines proper Lab_Tst_Desc value                            *;
*   OUTPUT:           Lab_Tst_Desc field                                              *;
***************************************************************************************;
%MACRO	SRLTDesc;
		Lab_Tst_Desc = PUT(svc,$LLTDesc.);
		IF Lab_Tst_Desc = '' THEN Lab_Tst_Desc = VarDispName;
%MEND	SRLTDesc;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SRLIM                                                           *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Extract Specification Limits                                    *;
*   INPUT:            svc field and formats $LSLLim, $LSULim, $LTSLimA,               *;
*                     $LTSLimB, $LTSLimC, $LMLLim, $LMULim, $LTMLimA,                 *;
*                     $LTMLimB,$LTMLimC.                                              *;
*   PROCESSING:       Determines proper values for the Specification Limits           *;
*   OUTPUT:           Low_Limit, Upr_Limit, Txt_Limit_A, Txt_Limit_B,                 *;
*                     Txt_Limit_C                                                     *;
***************************************************************************************;
%MACRO	SRLIM;
	IF SUBSTR(SampName,1,1) = 'S' THEN DO;
		Low_Limit   = PUT(PUT(svc,$LSLLim.),12.);
		Upr_Limit   = PUT(PUT(svc,$LSULim.),12.);
		Txt_Limit_A = PUT(svc,$LTSLimA.);
		Txt_Limit_B = PUT(svc,$LTSLimB.);
		Txt_Limit_C = PUT(svc,$LTSLimC.);
		IF Low_Limit = . AND Upr_Limit = . THEN DO;
			Low_Limit   = PUT(PUT(svc,$LMLLim.),12.);
			Upr_Limit   = PUT(PUT(svc,$LMULim.),12.);
			Txt_Limit_A = PUT(svc,$LTMLimA.);
			Txt_Limit_B = PUT(svc,$LTMLimB.);
			Txt_Limit_C = PUT(svc,$LTMLimC.);
		END;
	END;
	ELSE DO;
		Low_Limit   = PUT(PUT(svc,$LMLLim.),12.);
		Upr_Limit   = PUT(PUT(svc,$LMULim.),12.);
		Txt_Limit_A = PUT(svc,$LTMLimA.);
		Txt_Limit_B = PUT(svc,$LTMLimB.);
		Txt_Limit_C = PUT(svc,$LTMLimC.);
	END;
%MEND	SRLIM;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: LoadFmt                                                         *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Load a User-Defined Format                                      *;
*   INPUT:            lelimsgist01a (input SAS dataset), dataset name to hold         *;
*                     the data, field name containing the resulting value,            *;
*                     length of the resulting formatted value, user-defined           *;
*                     format name.                                                    *;
*   PROCESSING:       Extract the needed parameters from the input dataset,           *;
*                     placing them in the proper field names for PROC FORMAT,         *;
*                     saving the results in the passed dsn parameter dataset.         *;
*                     Next, sort the dataset, removing duplicates. Call PROC          *;
*                     FORMAT to create the user-defined format.                       *;
*   OUTPUT:           Specified user-defined format                                   *;
***************************************************************************************;
%MACRO	LoadFmt(dsn,var,len,fmt);
	DATA &dsn;
		SET lelimsgist01a;
		WHERE &var Not = " " AND &var Not = ".";
		LENGTH	START	$163
			LABEL	$&len
			FMTNAME	$8
			;
		RETAIN FMTNAME;
		FMTNAME = "&fmt";
		IF _N_ = 1 THEN DO;	
			HLO = 'O'; LABEL = ''; START = ' '; OUTPUT; HLO = ' '; 
			END;
		START = UPCASE(COMPRESS(Meth_Spec_Nm||"/"||Meth_Var_Nm||"/"||Column_Nm||"/"||PKS_Level));
		LABEL = &var;
		KEEP START LABEL HLO FMTNAME;
		OUTPUT;
	RUN;

	PROC SORT NODUPKEY DATA=&dsn;
		BY FMTNAME START HLO;
	RUN;

	PROC FORMAT CNTLIN=&dsn;
	RUN;
%MEND	LoadFmt;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: To_Num                                                          *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Convert a text field to a number, removing all                  *;
*                     non-numeric characters beforehand (i.e. "25 C" is               *;
*                     converted to "25").                                             *;
*   INPUT:            String to convert.                                              *;
*   PROCESSING:       Remove all non-numeric characters.                              *;
*   OUTPUT:           A Number.                                                       *;
***************************************************************************************;
%MACRO	To_Num(strval);
	COMPRESS(TRANSLATE(TRANSLATE(UPCASE(&strval)," ",
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#$%^&*()_+[]{}\|:;'<>?/,"),' ','"'))
%MEND	To_Num;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: DEDUP                                                           *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Sort and remove duplicates from specified SAS dataset.          *;
*   INPUT:            SAS dataset name and sort criteria.                             *;
*   PROCESSING:       Sort with NODUP option.                                         *;
*   OUTPUT:           DeDuped SAS dataset.                                            *;
***************************************************************************************;
%MACRO	DEDUP(sasds,key,crit);
	PROC SORT DATA=&sasds NODUP;
		BY &crit 
		%IF	&key ^= Y %THEN %DO;
			DESCENDING ResEntTs
		%END;
		;
	RUN;
	%IF	&key ^= Y %THEN %DO;
		DATA &sasds;
			SET		&sasds;
			BY		&crit;
			IF		FIRST.&key;
			DROP	ResEntTs;
		RUN;
	%END;
%MEND	DEDUP;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: MultipleDEDUP                                                   *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Sort and remove duplicates from specified SAS dataset on 2 keys *;
*   INPUT:            SAS dataset name and sort criteria.                             *;
*   PROCESSING:       Sort with NODUP option.                                         *;
*   OUTPUT:           DeDuped SAS dataset.                                            *;
***************************************************************************************;
%MACRO	MultipleDEDUP(sasds,key,key2,crit);
	PROC SORT DATA=&sasds NODUP;
		BY &crit 
		%IF	&key ^= Y %THEN %DO;
			DESCENDING ResEntTs
		%END;
		;
	RUN;
	%IF	&key ^= Y %THEN %DO;
		DATA &sasds;
			SET		&sasds;
			BY		&crit;
			IF		FIRST.&key2;
			DROP	ResEntTs;
		RUN;
	%END;
%MEND	MultipleDEDUP;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: CkRptFlg                                                        *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          To ensure the current job can run.                              *;
*   INPUT:            &CtlDir                                                         *;
*   PROCESSING:       Ensure neither LELimsGist.txt or CkRptFlg.txt exists in         *;
*                     the Control Directory (specified by &CtlDir).                   *;
*   OUTPUT:           Condition Code is set to 0 if processing can continue,          *;
*                     and to 12 if processing should not continue.                    *;
***************************************************************************************;
%MACRO	CkRptFlg;
	/* LELimsGist is currently running */
	%IF %SYSFUNC(FILEEXIST(&CtlDir.LELimsGist.txt)) %THEN %DO;
		%LET CondCode=2;
	%END;
	/* Database flag not cleared on previous failed run */
	%ELSE %IF %SYSFUNC(FILEEXIST(&CtlDir.CkRptFlg.txt)) %THEN %DO;
		%PUT +++ ERROR: Previous run of LELimsGist failed! Current run cannot run until corrected.;
		%LET jobstep=CkRptFlg (Previous run failed!);
		%LET CondCode=12;
		%LET StepRC=12;
	%END;
	/* Create dummy file as a flag for this run */
	%ELSE %DO;
		%SYSEXEC(echo >&CtlDir.LELimsGist.txt);
		%LET CondCode=0;
	%END;
%MEND	CkRptFlg;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: TrnGist                                                         *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          To extract study information from the GIST data.                *;
*   INPUT:            legist01a (output from LEGist external macro).                  *;
*   PROCESSING:       Extract Stability_Study_Purpose_Txt and Storage_Dt from         *; 
*                     legist01a.StudyDescriptionBegin and                             *;
*                     legist01a.StudyDescriptionEnd, copy the remaining               *;
*                     fields to the output dataset.                                   *;
*   OUTPUT:           Stability_Study_Grp_Cd, Stability_Study_Nbr_Cd                  *;
*                     Storage_Dt, Batch_Nbr, Matl_Nbr and                             *;
*                     Stability_Study_Purpose_Txt.                                    *;
***************************************************************************************;
%MACRO	TrnGist;
	DATA lelimsgist02a;							/* Extract study purpose and		*/
		SET legist01a;							/*    storage date from study desc	*/ 
		FORMAT	Storage_Dt 			DATETIME13.
			Stability_Study_Purpose_Txt 	$200.;
		/* Extract Purpose from last comma before "Manufacture		*/
		/* Date" to first character before "Manufacture Date"		*/
		*******************************************************;
		*** V4 - Extracting Matl_Nbr from Description Field ***;
		*******************************************************;
		*** Creating Matl_Nbr Section                       ***;
		*******************************************************;
		Len=LENGTH(StudyDescriptionEnd);
		INDEX0=INDEX(StudyDescriptionEnd,"AMAPS Code#:");
		INDEX1=INDEX(StudyDescriptionEnd,"AMAPS Code:");
		INDEX2=INDEX(StudyDescriptionEnd,"AMAPS:");
		INDEX3=INDEX(StudyDescriptionEnd,"Code:");
		INDEX4=INDEX(StudyDescriptionEnd,"AMAPS #:");
		INDEX5=INDEX(StudyDescriptionEnd,"Code #:");
		INDEX6=INDEX(StudyDescriptionEnd,"MAPS:");
		INDEX7=INDEX(StudyDescriptionEnd,"APS:");
		INDEX8=INDEX(StudyDescriptionEnd,"PS:");
		IF INDEX0 GT 0 THEN INDEX=INDEX0+12;
		ELSE IF INDEX1 GT 0 THEN INDEX=INDEX1+11;
		ELSE IF INDEX2 GT 0 THEN INDEX=INDEX2+6;
		ELSE IF INDEX3 GT 0 THEN INDEX=INDEX3+5;
		ELSE IF INDEX4 GT 0 THEN INDEX=INDEX4+8;
		ELSE IF INDEX5 GT 0 THEN INDEX=INDEX5+7;
		ELSE IF INDEX6 GT 0 THEN INDEX=INDEX6+5;
		ELSE IF INDEX7 GT 0 THEN INDEX=INDEX7+4;
		ELSE IF INDEX8 GT 0 THEN INDEX=INDEX8+3;
		IF INDEX+12 > Len THEN POS=Len-INDEX;ELSE POS=12;
		SubDescription = SUBSTR(StudyDescriptionEnd,INDEX,12);
		FIND1=INDEXC(SubDescription,",.M");

		IF INDEX GT 0 AND FIND1 GT 0 
				THEN Matl_Nbr = COMPRESS(LEFT(SUBSTR(StudyDescriptionEnd,INDEX,FIND1-1)));
		ELSE IF INDEX GT 0           
				THEN Matl_Nbr = COMPRESS(LEFT(SUBSTR(StudyDescriptionEnd,INDEX,12)));
		        	ELSE Matl_Nbr = ' ';

		*******************************************************;
		*** Creating Stability_Study_Purpose_Txt Section    ***;
		*** V15 - Added INDEX3 check due to change in GIST  ***;
		*******************************************************;
		INDEX1=INDEX(StudyDescriptionBegin,"Manufacture Date");
		INDEX2=INDEX(StudyDescriptionBegin,"Mfg Date");
		INDEX3=INDEX(StudyDescriptionBegin,"Mfg. Date");
		**************************;
		*** V19 - Added INDEX4 ***;
		**************************;
		INDEX4=INDEX(StudyDescriptionBegin,"Manufactured Date");
		IF INDEX1 GT 0 THEN Stability_Study_Purpose_Txt = SUBSTR(StudyDescriptionBegin,1,INDEX1-1);
		IF INDEX2 GT 0 THEN Stability_Study_Purpose_Txt = SUBSTR(StudyDescriptionBegin,1,INDEX2-1);
		IF INDEX3 GT 0 THEN Stability_Study_Purpose_Txt = SUBSTR(StudyDescriptionBegin,1,INDEX3-1);
		IF INDEX4 GT 0 THEN Stability_Study_Purpose_Txt = SUBSTR(StudyDescriptionBegin,1,INDEX4-1);
		IF INDEX(Stability_Study_Purpose_Txt, ",") > 0 
			THEN DO;
				Stability_Study_Purpose_Txt = SUBSTR(Stability_Study_Purpose_Txt,
						INDEX(Stability_Study_Purpose_Txt, ",")+1);
				IF INDEX(Stability_Study_Purpose_Txt, ",")>0 THEN DO;
					Stability_Study_Purpose_Txt = SUBSTR(Stability_Study_Purpose_Txt,
						INDEX(Stability_Study_Purpose_Txt, ",")+1);
				END;
			END;
			ELSE IF INDEX(Stability_Study_Purpose_Txt, ".") > 0
			   THEN Stability_Study_Purpose_Txt = SUBSTR(Stability_Study_Purpose_Txt,
						INDEX(Stability_Study_Purpose_Txt, ".")+1);
		Stability_Study_Purpose_Txt = LEFT(Stability_Study_Purpose_Txt);

		***********************************;
		*** Creating Storage_Dt Section ***;
		***********************************;
		INDEX3=INDEX(StudyDescriptionEnd, "Storage Date");
		IF INDEX3 GT 0 THEN DO;
			StudyDescriptionPart = SUBSTR(StudyDescriptionEnd,INDEX3);
			Start  = INDEX(StudyDescriptionPart, "-")-4;
			IF Start GT 0 THEN DO;
				Storage_Temp = LEFT(COMPRESS(SUBSTR(StudyDescriptionPart,Start+1,13),"-,:. "));
				IF SUBSTR(Storage_Temp,1,1) IN ('0','1','2','3','4','5','6','7','8','9')
				THEN DO;
					IF SUBSTR(Storage_Temp,1,1) IN ('4','5','6','7','8','9') THEN DO;
						Storage_Temp='0'||LEFT(SUBSTR(Storage_Temp,1,1))||LEFT(SUBSTR(Storage_Temp,2,3))||LEFT(SUBSTR(Storage_Temp,5,4));
						tdate=INPUT(Storage_Temp,DATE9.);
					END;
					ELSE IF LENGTH(Storage_Temp)=9 THEN DO;
						tdate=INPUT(Storage_Temp,DATE11.);
					END;
					ELSE DO;
						Storage_Temp=LEFT(SUBSTR(Storage_Temp,1,2))||LEFT(SUBSTR(Storage_Temp,3,3))||LEFT(SUBSTR(Storage_Temp,7,4));
						tdate=INPUT(Storage_Temp,DATE9.);
					END;
				END;
				ELSE DO;
					Storage_Temp=LEFT(SUBSTR(Storage_Temp,4,2))||LEFT(SUBSTR(Storage_Temp,1,3))||LEFT(SUBSTR(Storage_Temp,6,4));
					tdate=INPUT(Storage_Temp,DATE9.);
				END;
			END;
			ELSE DO;
				Storage_Temp = LEFT(COMPRESS(SUBSTR(StudyDescriptionEnd,INDEX3+13,10),"-,:. "));
				tdate=INPUT(Storage_Temp,MONYY7.);
			END;
			Storage_Dt = INPUT(PUT(tdate,date7.) || " 00:00",DATETIME13.);
		END;
		*********************************************************;
		*** Creating Matl_Nbr from Reference # if still empty ***;
		*********************************************************;
		IF Matl_Nbr='' THEN DO;
			INDEX1=INDEX(Reference_Nbr,'Item #');
			IF INDEX1 GT 0 THEN Matl_Nbr=SUBSTR(Reference_Nbr,INDEX1+6);
			               ELSE Matl_Nbr=SUBSTR(Reference_Nbr,1);
		END;

		Matl_Nbr  = UPCASE(TRIM(LEFT(Matl_Nbr))); 
		Batch_Nbr = UPCASE(TRIM(LEFT(Batch_Nbr))); 
		KEEP	Matl_Nbr Batch_Nbr Stability_Study_Grp_Cd Stability_Study_Nbr_Cd Storage_Dt Stability_Study_Purpose_Txt Stability_Study_Max_TP;
	RUN;
	PROC SORT NOEQUALS;
		BY	Stability_Study_Nbr_Cd;
	RUN;
%MEND	TrnGist;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: TrnFmts                                                         *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Build all the user-defined formats for LELimsGist.              *;
*   INPUT:            LINKS PKS_Extraction_Control table.                             *;
*   PROCESSING:       Read PEC table, then call LoadFmt for each format               *;
*                     needed.      Macro variable CondCode                            *;
*                     set depending on PEC table extract success or failure.          *;
*   OUTPUT:           The following user-defined formats: $LSLLim, $LSULim,           *;
*                     $LTSLimA, $LTSLimB, $LTSLimC, $LMLLim, $LMULim,                 *;
*                     $LTMLimA, $LTMLimB, $LTMLimC, $LMac, $LVar, $LPeak,             *;
*                     $LStg, $LLvl, $LLTDesc, $ECNDesc.                               *;
*                     Macro variable CondCode.                                        *;
***************************************************************************************;
%MACRO	TrnFmts;
	PROC SQL;
		*******************************************;
		*****  V15 - Added Prod_Nm, Prod_Grp  *****;
		*******************************************;
		CONNECT TO ORACLE(USER=&OraId ORAPW=&OraPsw BUFFSIZE=5000 PATH="&OraPath");
		CREATE TABLE lelimsgist01a AS SELECT * FROM CONNECTION TO ORACLE (
			SELECT DISTINCT
					Meth_Spec_Nm,
					Meth_Var_Nm,
					Column_Nm,
					Pks_Extraction_Macro,
					Pks_Var_Nm,
					Pks_Stage,
					Pks_Peak,
					Pks_Level,
					Pks_Lab_Tst_Desc,
					Mfg_Lower_Spec_Limit,
					Mfg_Upper_Spec_Limit,
					Stability_Lower_Spec_Limit,
					Stability_Upper_Spec_Limit,
					Prod_Nm,
					Prod_Grp,
					Mfg_Spec_Txt_A,
					Mfg_Spec_Txt_B,
					Mfg_Spec_Txt_C,
					Stability_Spec_Txt_A,
					Stability_Spec_Txt_B,
					Stability_Spec_Txt_C,
					Pks_Extraction_Cntrl_Notes_Txt
			FROM	PKS_Extraction_Control
			);
		DISCONNECT FROM ORACLE;
		QUIT;
		%PUT &SQLXMSG;
		%PUT &SQLXRC;
		%LET HSQLXRC = &SQLXRC;
		%LET HSQLXMSG = &SQLXMSG;
	RUN;

	%IF &HSQLXRC = 0 %THEN %DO;
		%IF &SQLXMSG = '' OR &SQLXMSG = ' ' OR &SQLXMSG = %THEN %DO;
			DATA _NULL_;
				CALL SYMPUT('Condcode',0);
			RUN;
		%END;
		%ELSE %DO;
			DATA _NULL_;
				CALL SYMPUT('JobStep','TrnFmts');
				CALL SYMPUT('StepRc',4);
				CALL SYMPUT('Condcode',4);
			RUN;
		%END;
	%END;
	%ELSE %DO;
		DATA _NULL_;
			CALL SYMPUT('JobStep','TrnFmts');
			CALL SYMPUT('StepRc',12);
			CALL SYMPUT('Condcode',12);
		RUN;
	%END;

	%IF &CondCode = 0 %THEN %DO;
		%LOADFMT(lelimsgist01M,Pks_Extraction_Macro,8,$LMac);
		%LOADFMT(lelimsgist01V,Pks_Var_Nm,40,$LVar);
		%LOADFMT(lelimsgist01P,Pks_Peak,40,$LPeak);
		%LOADFMT(lelimsgist01S,Pks_Stage,40,$LStg);
		%LOADFMT(lelimsgist01L,Pks_Level,40,$LLvl);
		%LOADFMT(lelimsgist01MU,Mfg_Upper_Spec_Limit,12,$LMULim);
		%LOADFMT(lelimsgist01ML,Mfg_Lower_Spec_Limit,12,$LMLLim);
		%LOADFMT(lelimsgist01SU,Stability_Upper_Spec_Limit,12,$LSULim);
		%LOADFMT(lelimsgist01SL,Stability_Lower_Spec_Limit,12,$LSLLim);
		%LOADFMT(lelimsgist01TMA,Mfg_Spec_Txt_A,200,$LTMLimA);
		%LOADFMT(lelimsgist01TMB,Mfg_Spec_Txt_B,200,$LTMLimB);
		%LOADFMT(lelimsgist01TMC,Mfg_Spec_Txt_C,200,$LTMLimC);
		%LOADFMT(lelimsgist01TSA,Stability_Spec_Txt_A,200,$LTSLimA);
		%LOADFMT(lelimsgist01TSB,Stability_Spec_Txt_B,200,$LTSLimB);
		%LOADFMT(lelimsgist01TSC,Stability_Spec_Txt_C,200,$LTSLimC);
		%LOADFMT(lelimsgist01LTD,Pks_Lab_Tst_Desc,40,$LLTDesc);
		%LOADFMT(lelimsgist01ECN,Pks_Extraction_Cntrl_Notes_Txt,100,$ECNDesc);
		%LOADFMT(lelimsgist01PN,Prod_Nm,40,$ProdNm);
		%LOADFMT(lelimsgist01PG,Prod_Grp,40,$ProdGrp);
	%END;
%MEND	TrnFmts;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: TrnTableChk                                                     *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Check that none of the tables are corrupt.                      *;
*   INPUT:            LimsGistTableCount.txt                                          *;
*   PROCESSING:       Check that tables are populated.                                *;
*   OUTPUT:           MACRO TableFlag                                                 *;
***************************************************************************************;
%MACRO	TrnTableChk;
	DATA _NULL_;
		IF FILEEXIST("&CtlDir.LimsGistTableCount.txt") THEN DO;
			CALL SYMPUT ('TableCode',0);
		END;
		ELSE DO;
			CALL SYMPUT('JobStep','TrnTableChk (Missing LimsGistTableCount.txt File)');
			CALL SYMPUT ('CondCode',12);
		END;
	RUN;


	%IF &TableCode = 0 %THEN %DO; 							
		DATA _NULL_;
			INFILE "&CtlDir.LimsGistTableCount.txt"
			LENGTH=flen TRUNCOVER END=eofflg DLM='=';
			INPUT @1  TableNm    $4.
			      @10 Count      8.
			      @25 Run_Date   DATE9.
			      @35 NormalRun  $1.
			      @36 FullRun    $1.
			      @37 DebugRun   $1.
			      @40 SampNum    8.;
			IF TableNm='Samp' THEN CALL SYMPUT('M_Samp',TRIM(LEFT(Count)));
			IF TableNm='TRS ' THEN CALL SYMPUT('M_TRS', TRIM(LEFT(Count)));
			IF TableNm='ST  ' THEN CALL SYMPUT('M_ST',  TRIM(LEFT(Count)));
			IF TableNm='ITR ' THEN CALL SYMPUT('M_ITR', TRIM(LEFT(Count)));
			IF TableNm='TP  ' THEN CALL SYMPUT('M_TP',  TRIM(LEFT(Count)));
			CALL SYMPUT('RunDate',  TRIM(LEFT(Run_Date)));
			CALL SYMPUT('NormalRun',TRIM(LEFT(NormalRun)));
			CALL SYMPUT('FullRun',  TRIM(LEFT(FullRun)));
			CALL SYMPUT('DebugRun', TRIM(LEFT(DebugRun)));
			CALL SYMPUT('SampNum',  TRIM(LEFT(SampNum)));
		RUN;
	%END;
	%ELSE %DO; 							
		%LET M_Samp=0;
		%LET M_TRS=0;
		%LET M_ST=0;
		%LET M_ITR=0;
		%LET M_TP=0;
		%LET RunDate=0;
	%END;

	%IF &DebugRun = N 
		%THEN %LET LimitSamps = ;
		%ELSE %LET LimitSamps = %STR(IF Samp_Id IN(&SampNum););

%MEND	TrnTableChk;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: TrnTableCnt                                                     *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Returns total number of records in the tables.                  *;
*   INPUT:            LINKS Tables                                                    *;
*   PROCESSING:       Read tables and gets table counts                               *;
*   OUTPUT:           MACRO TableFlag                                                 *;
***************************************************************************************;
%MACRO	TrnTableCnt;
	%LET TableFlag=0;

	PROC SQL;
	CONNECT TO ORACLE(USER=&oraid ORAPW=&orapsw BUFFSIZE=5000 PATH="&orapath");
		CREATE TABLE Samp_List AS SELECT * FROM CONNECTION TO ORACLE
		    (SELECT Samp_Id  FROM	Samp) ORDER BY SAMP_ID;
		CREATE TABLE Samp_Count AS SELECT * FROM CONNECTION TO ORACLE
		    (SELECT COUNT(*) FROM	Samp);
		CREATE TABLE TRS_Count AS SELECT * FROM CONNECTION TO ORACLE
		    (SELECT COUNT(*) FROM	Tst_Rslt_Summary);
		CREATE TABLE ST_Count AS SELECT * FROM CONNECTION TO ORACLE
		    (SELECT COUNT(*) FROM	Stage_Translation);
		CREATE TABLE ITR_Count AS SELECT * FROM CONNECTION TO ORACLE
		    (SELECT COUNT(*) FROM	Indvl_Tst_Rslt);
		CREATE TABLE TP_Count AS SELECT * FROM CONNECTION TO ORACLE
		    (SELECT COUNT(*) FROM	Tst_Parm);
		DISCONNECT FROM ORACLE;
		QUIT;
	RUN;

	DATA Samp_Count;SET Samp_Count;TableNm='Samp';RUN;
	DATA TRS_Count ;SET TRS_Count ;TableNm='TRS ';RUN;
	DATA ST_Count  ;SET ST_Count  ;TableNm='ST  ';RUN;
	DATA ITR_Count ;SET ITR_Count ;TableNm='ITR ';RUN;
	DATA TP_Count  ;SET TP_Count  ;TableNm='TP  ';RUN;
	
	DATA TableCnt;SET Samp_Count TRS_Count ST_Count ITR_Count TP_Count;
		IF TableNm='Samp' AND Count___ LT "&M_Samp" THEN CALL SYMPUT('TableFlag',1);
		IF TableNm='TRS ' AND Count___ LT "&M_TRS"  THEN CALL SYMPUT('TableFlag',1);
		IF TableNm='ST  ' AND Count___ LT "&M_ST"   THEN CALL SYMPUT('TableFlag',1);
		IF TableNm='ITR ' AND Count___ LT "&M_ITR"  THEN CALL SYMPUT('TableFlag',1);
		IF TableNm='TP  ' AND Count___ LT "&M_TP"   THEN CALL SYMPUT('TableFlag',1);
		IF "&M_Samp" = 0 OR "&M_TRS" = 0 OR "&M_ST" = 0 OR "&M_ITR" = 0 OR "&M_TP" = 0 
			THEN CALL SYMPUT('TableFlag',1);
		Put TableNm Count___;
	RUN;

%MEND	TrnTableCnt;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: TrnLimsS                                                        *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Translate and group the data into a format that is              *;
*                     one-step away from LINKS ready-to-load for the LM,              *;
*                     Samp, TRS, and ST tables.                                       *;
*   INPUT:            lelimssumres01a (from LELimsSumRes),                            *;
*                     lelimsgist02a (from TrnGist), and                               *;
*                     user-defined formats from TrnFmts.                              *;
*   PROCESSING:       Utilizing the User-Defined formats, process the LIMS            *;
*                     summary Result data and translate the data.                     *;
*   OUTPUT:           Datasets:  lelimsgist03s,                                       *;
*                     lelimsgist03v and                                               *;
*                     lelimsgist03w (combined with lelimsgist03v to create            *;
*                     TRS table data).                                                *;
***************************************************************************************;
%MACRO	TrnLimsS;
	PROC SQL;CREATE INDEX Samp_Id ON lelimssumres01a (Samp_Id);QUIT;
	
	***********************************************************;
	*****  V15 - Added step to standardize product names  *****;
	***********************************************************;
	DATA lelimsgist01b(KEEP=Samp_Id ProductNm);
		SET		lelimssumres01a;
		FORMAT	ProductNm	$40.;
		LENGTH svc $163;
		svc = UPCASE(COMPRESS(SpecName||"/"||VarName||"//"));
		lmac = UPCASE(PUT(svc,$LMac.));
                /* Note: ProductNm must be less than 24 chars wide to avoid
                 * exceeding SAS' dataset naming maximum (during metadata
                 * creation). 
                 */
		IF	(lmac = "SR002A") THEN	DO;
			*****************************************************************************************************;
			*****  V32 - Added "ADVAIR DISKUS" to make sure ProductNm is not empty during the delete below  *****;
			*****************************************************************************************************;
			IF INDEX(UPCASE(COMPRESS(ResStrVal)),"DISKUS") THEN
					ProductNm="ADVAIR DISKUS";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"COMBIVIRTABLETS") THEN
					ProductNm="COMBIVIR TABLETS";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"LANOXIN") THEN
					ProductNm="LANOXIN TABLETS";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"LOTRONEXTABLETS") THEN
					ProductNm="LOTRONEX TABLETS";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"ZOVIRAXCAPSULES") THEN
					ProductNm="ZOVIRAX CAPSULES";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"ZOVIRAXTABLETS") THEN
					ProductNm="ZOVIRAX TABLETS";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"RETROVIRCAPSULES") THEN
					ProductNm="RETROVIR CAPSULES";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"RETROVIRTABLETS") THEN
					ProductNm="RETROVIR TABLETS";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"TRIZIVIRTABLETS") THEN
					ProductNm="TRIZIVIR TABLETS";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"ZOFRANTABLETS") THEN
					ProductNm="ZOFRAN TABLETS";
			*************************;
			*****  V18 - Added  *****;
			*************************;
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"ONDANSETRONTABLETS") THEN
					ProductNm="ONDANSETRON TABLETS";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"IMITREXTABLETS") THEN
					ProductNm="IMITREX TABLETS";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"IMITREXFDTTABLETS") OR INDEX(UPCASE(COMPRESS(ResStrVal)),"IMITREXFASTDISSOLVING") THEN
					ProductNm="IMITREX FDT TABLETS";
			/* Order matters */
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"LAMICTALCDTABLETS") THEN
					ProductNm="LAMICTAL CD TABLETS";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"LAMICTALXRTABLETS") THEN
					ProductNm="LAMICTAL XR TABLETS";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"LAMICTAL") THEN
					ProductNm="LAMICTAL TABLETS";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"ZIAGENTABLETS") THEN
					ProductNm="ZIAGEN TABLETS";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"EPIVIRTABLETS") THEN
					ProductNm="EPIVIR TABLETS";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"VALTREXCAPLETS") THEN
					ProductNm="VALTREX CAPLETS";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"ZANTACTABLETS") THEN
					ProductNm="ZANTAC TABLETS";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"WELLBUTRIN") THEN
					ProductNm="WELLBUTRIN SR TABLETS";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"ZYBAN") THEN
					ProductNm="ZYBAN SR TABLETS";
                        /* Special case where Bupro data is in Watson file */
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"(DEPRESSION)") THEN
					ProductNm="BUPROPION HCL SR TABLETS";
			/* Watson must precede Bupropion in this block */
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"WATSON") THEN
					ProductNm="WATSON HCL SR TABLETS";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"BUPROPION") THEN
					ProductNm="BUPROPION HCL SR TABLETS";
			**********************************************************************;
			*****  V18 - Added Albuterol                                     *****;
			*****  V31 - Added (Ventolin HFA is stab, Albuterol is release)  *****;
			*****  V32 - More specific identification of what is 'Ventolin'. *****;
			*****        Eliminate non-US versions.                          *****;
			**********************************************************************;
                        /* Per Ruth D. "Basically, you would need to look for 'Ventolin' or 'albuterol' plus 'HFA' or '134a'" */
			ELSE IF UPCASE(COMPRESS(ResStrVal))="ALBUTEROL134AINHALERS200ACT" OR 
                        	UPCASE(COMPRESS(ResStrVal))="VENTOLINHFA(ALBUTEROL134A)INHALERS,200ACT" THEN
					ProductNm="VENTOLIN HFA";
			******************************************************************************;
			*****  V18 - Stability uses 'ADVAIR HFA...', Release uses 'SAL/FP...'    *****;
			******************************************************************************;
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"ADVAIRHFA") OR INDEX(UPCASE(COMPRESS(ResStrVal)),"SAL/FP") THEN
					ProductNm="ADVAIR HFA";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"AGENERASECAPSULES") THEN
					ProductNm="AGENERASE CAPSULES";
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"AMERGETABLETS") THEN
					ProductNm="AMERGE TABLETS";
			*******************************;
			*** V24 - new product added ***;
			*******************************;
			ELSE IF INDEX(UPCASE(COMPRESS(ResStrVal)),"RELENZA") OR INDEX(UPCASE(COMPRESS(ResStrVal)),"ZANAMIVIR") THEN
					ProductNm="RELENZA ROTADISK";
		END;
		IF ProductNm ^= '' THEN DO;OUTPUT;END;
	RUN;
	PROC SORT NODUP;BY Samp_Id ;RUN;
	DATA lelimsgist01b(KEEP=Samp_Id ProductNm);SET lelimsgist01b;
		BY		Samp_Id ;
		IF		LAST.Samp_Id;
IF SAMP_ID IN (&sampnum) THEN PUT SAMP_ID ProductNm;
	RUN;
	*********************************************************************************************************;
	*****  V15 - Get more specific product info. Important in cases where there are multiple strengths  *****;
	*********************************************************************************************************;
	DATA lelimsgist01c(KEEP=Samp_Id ItemCdDesc);
		SET		lelimssumres01a;
		FORMAT	ItemCdDesc	$40.;
		LENGTH svc $163;
		svc = UPCASE(COMPRESS(SpecName||"/"||VarName||"//"));
		lmac = UPCASE(PUT(svc,$LMac.));
		IF	(lmac = "SR002A" AND VarName='ITEMCODEDESC$') THEN DO;
			ItemCdDesc = ResStrVal;
			END;
			IF ItemCdDesc ^= '' THEN DO;OUTPUT;END;
	RUN;
	PROC SORT NODUP;BY Samp_Id;RUN;
	DATA lelimsgist01c(Keep=Samp_Id ItemCdDesc);SET lelimsgist01c;
		BY		Samp_Id ;
		IF		LAST.Samp_Id;
IF SAMP_ID IN (&sampnum) THEN PUT SAMP_ID ItemCdDesc;
	RUN;
        DATA lelimssumres01a;
		MERGE	lelimssumres01a
			lelimsgist01b
			lelimsgist01c;
		BY	Samp_Id;
	**************************************************************************************;
	*****  V32 - Eliminate the merging of samples (like Ventolin AUS, UK, etc.) that *****;
	*****        were filtered out earlier in 01b                                    *****;
	**************************************************************************************;
        	if ProductNm = '' then delete;
	RUN;

	**************************************************************************************;
	*****  V15 - Build LinkLvl for products where ItemCdDesc has multiple strengths  *****;
	**************************************************************************************;
	DATA lelimsgist03a(KEEP=Samp_Id LinkLvl flg);
		SET		lelimssumres01a;
		FORMAT	LinkLvl	$10.;
		LENGTH svc $163;
		svc = UPCASE(COMPRESS(SpecName||"/"||VarName||"//"));
		lmac = UPCASE(PUT(svc,$LMac.));
		LinkLvl = '';
		flg =  '';
		/* Note: more specific product strings must precede less specific ones in this block */
		***********************************************************;
		*****  V19 - Modify condition to ignore PRODUCTCODE$  *****;
		***********************************************************;
		IF	(lmac = "SR002A" AND VarName='PRODCODEDESC$') THEN	DO;
			/* Advair HFA must precede Advair Diskus */
			IF INDEX(UPCASE(ProductNm),"ADVAIR HFA") THEN DO;
					SELECT;
						WHEN (INDEX(UPCASE(ResStrVal),'115'))	LinkLvl = '115-21';
						WHEN (INDEX(UPCASE(ResStrVal),'230'))	LinkLvl = '230-21';
						WHEN (INDEX(UPCASE(ResStrVal),'45'))	LinkLvl = '45-21';
						OTHERWISE DO;
						END;
					END;
				END;
			ELSE IF INDEX(UPCASE(ResStrVal),"ADVAIR") OR 
			   ( INDEX(UPCASE(SPECNAME),"CASCADE") AND (INDEX(UPCASE(ResStrVal),"RELEASE") OR INDEX(UPCASE(ResStrVal),"STABILI") )) THEN DO;
				SELECT;
					WHEN (INDEX(UPCASE(ResStrVal),"100"))	LinkLvl = '100/50';
					WHEN (INDEX(UPCASE(ResStrVal),"250"))	LinkLvl = '250/50';
					WHEN (INDEX(UPCASE(ResStrVal),"500"))	LinkLvl = '500/50';
					OTHERWISE DO;
							LinkLvl = '100/50';
							flg =  'Y';
					END;
				END;
			END;
			ELSE IF INDEX(UPCASE(ProductNm),"LANOXIN TABLETS") THEN DO;
					SELECT;
						/* Lanoxin's RESSTRVAL for specname ITEMCODE / varname PRODUCTCODE$ occasionally 
						 * lists *both* .125 and .25 so look in another field to determine level. 
						 */
						WHEN (INDEX(UPCASE(ResStrVal),".125") AND INDEX(UPCASE(ResStrVal),".25")) DO;	
								SELECT;
									WHEN (INDEX(UPCASE(ItemCdDesc),'.125')) LinkLvl = '0.125';
									WHEN (INDEX(UPCASE(ItemCdDesc),'.25'))  LinkLvl = '0.250';
									OTHERWISE DO;
									END;
								END;
						END;
						WHEN (INDEX(UPCASE(ResStrVal),".125"))	LinkLvl = '0.125';
						WHEN (INDEX(UPCASE(ResStrVal),".25"))	LinkLvl = '0.250';
						OTHERWISE DO;
						END;
					END;
			END;
			ELSE IF INDEX(UPCASE(ProductNm),"ZOVIRAX") THEN DO;
					SELECT;
						/* Zovirax Capsules are 200mg, Tablets are 400 or 800 */
						WHEN (INDEX(UPCASE(ResStrVal),"400") AND INDEX(UPCASE(ResStrVal),"800")) DO;	
								SELECT;
									WHEN (INDEX(UPCASE(ItemCdDesc),'400'))	LinkLvl = '400';
									WHEN (INDEX(UPCASE(ItemCdDesc),'800'))	LinkLvl = '800';
									OTHERWISE DO;
									END;
								END;
						END;
						WHEN (INDEX(UPCASE(ResStrVal),'400'))	LinkLvl = '400';
						WHEN (INDEX(UPCASE(ResStrVal),'800'))	LinkLvl = '800';
						WHEN (INDEX(UPCASE(ResStrVal),'200'))	LinkLvl = '200';
						OTHERWISE DO;
						END;
					END;
				END;
			ELSE IF INDEX(UPCASE(ProductNm),"RETROVIR") THEN DO;
					SELECT;
						/* Retrovir Capsules are 100mg, Tablets are 300 */
						WHEN (INDEX(UPCASE(ResStrVal),'100'))	LinkLvl = '100';
						WHEN (INDEX(UPCASE(ResStrVal),'300'))	LinkLvl = '300';
						OTHERWISE DO;
						END;
					END;
				END;
			ELSE IF INDEX(UPCASE(ProductNm),"ZOFRAN TABLETS") THEN DO;
					SELECT;
						WHEN (INDEX(UPCASE(ResStrVal),"4") AND INDEX(UPCASE(ResStrVal),"8")) DO;	
								SELECT;
									WHEN (INDEX(UPCASE(ItemCdDesc),'4'))	LinkLvl = '4';
									WHEN (INDEX(UPCASE(ItemCdDesc),'8'))	LinkLvl = '8';
									OTHERWISE DO;
									END;
								END;
						END;
						***************************************;
						*****  V18 - Added new strength   *****;
						***************************************;
						WHEN (INDEX(UPCASE(ResStrVal),'24'))	LinkLvl = '24';
						WHEN (INDEX(UPCASE(ResStrVal),'4'))	LinkLvl = '4';
						WHEN (INDEX(UPCASE(ResStrVal),'8'))	LinkLvl = '8';
						OTHERWISE DO;
						END;
					END;
				END;
			/* This block must follow Zofran's */
			ELSE IF INDEX(UPCASE(ProductNm),"ONDANSETRON") THEN DO;
					SELECT;
						WHEN (INDEX(UPCASE(ResStrVal),"4") AND INDEX(UPCASE(ResStrVal),"8")) DO;	
								SELECT;
									WHEN (INDEX(UPCASE(ItemCdDesc),'4'))	LinkLvl = '4';
									WHEN (INDEX(UPCASE(ItemCdDesc),'8'))	LinkLvl = '8';
									OTHERWISE DO;
									END;
								END;
						END;
						WHEN (INDEX(UPCASE(ResStrVal),'24'))	LinkLvl = '24';
						WHEN (INDEX(UPCASE(ResStrVal),'4'))	LinkLvl = '4';
						WHEN (INDEX(UPCASE(ResStrVal),'8'))	LinkLvl = '8';
						OTHERWISE DO;
						END;
					END;
				END;
			ELSE IF INDEX(UPCASE(ProductNm),"IMITREX") THEN DO;
					SELECT;
						WHEN (INDEX(UPCASE(ResStrVal),"25") AND INDEX(UPCASE(ResStrVal),"50")) DO;	
							SELECT;
								WHEN (INDEX(UPCASE(ItemCdDesc),'25'))	LinkLvl = '25';
								WHEN (INDEX(UPCASE(ItemCdDesc),'50'))	LinkLvl = '50';
								OTHERWISE DO;
								END;
							END;
						END;
						WHEN (INDEX(UPCASE(ResStrVal),"50") AND INDEX(UPCASE(ResStrVal),"100")) DO;	
							SELECT;
								WHEN (INDEX(UPCASE(ItemCdDesc),'50'))	LinkLvl = '50';
								WHEN (INDEX(UPCASE(ItemCdDesc),'100'))	LinkLvl = '100';
								OTHERWISE DO;
								END;
							END;
						END;
						WHEN (INDEX(UPCASE(ResStrVal),'25'))	LinkLvl = '25';
						WHEN (INDEX(UPCASE(ResStrVal),'50'))	LinkLvl = '50';
						WHEN (INDEX(UPCASE(ResStrVal),'100'))	LinkLvl = '100';
						OTHERWISE DO;
							SELECT;
								/* Rare case where ITEMCODE$ does not hold any strength, must use MISCELLANEOUSLOGIN$ */
								WHEN (INDEX(UPCASE(ItemCdDesc),'25'))	LinkLvl = '25';
								WHEN (INDEX(UPCASE(ItemCdDesc),'50'))	LinkLvl = '50';
								WHEN (INDEX(UPCASE(ItemCdDesc),'100'))	LinkLvl = '100';
								OTHERWISE DO;
								END;
							END;
						END;
					END;
				END;
			ELSE IF INDEX(UPCASE(ProductNm),"LAMICTAL TABLETS") THEN DO;
					SELECT;
						WHEN (INDEX(UPCASE(ResStrVal),"25") AND INDEX(UPCASE(ResStrVal),"100") AND
						      INDEX(UPCASE(ResStrVal),"150") AND INDEX(UPCASE(ResStrVal),"200")) DO;	
							SELECT;
								WHEN (INDEX(UPCASE(ItemCdDesc),'100'))	LinkLvl = '100';
								WHEN (INDEX(UPCASE(ItemCdDesc),'150'))	LinkLvl = '150';
								WHEN (INDEX(UPCASE(ItemCdDesc),'200'))	LinkLvl = '200';
								WHEN (INDEX(UPCASE(ItemCdDesc),'25'))	LinkLvl = '25';
								OTHERWISE DO;
								END;
							END;
						END;
						WHEN (INDEX(UPCASE(ResStrVal),"100"))	LinkLvl = '100';
						WHEN (INDEX(UPCASE(ResStrVal),"150"))	LinkLvl = '150';
						WHEN (INDEX(UPCASE(ResStrVal),"200"))	LinkLvl = '200';
						WHEN (INDEX(UPCASE(ResStrVal),"25"))	LinkLvl = '25';
						OTHERWISE DO;
						END;
					END;
				END;
			ELSE IF INDEX(UPCASE(ProductNm),"LAMICTAL XR") THEN DO;
					SELECT;
						WHEN (INDEX(UPCASE(ResStrVal),"25") AND INDEX(UPCASE(ResStrVal),"50")) DO;
								SELECT;
									WHEN (INDEX(UPCASE(ItemCdDesc),'25'))	LinkLvl = '25';
									WHEN (INDEX(UPCASE(ItemCdDesc),'50'))	LinkLvl = '50';
									OTHERWISE DO;
									END;
								END;
						END;
						WHEN (INDEX(UPCASE(ResStrVal),"100") AND INDEX(UPCASE(ResStrVal),"200")) DO;
								SELECT;
									WHEN (INDEX(UPCASE(ItemCdDesc),'100'))	LinkLvl = '100';
									WHEN (INDEX(UPCASE(ItemCdDesc),'200'))	LinkLvl = '200';
									OTHERWISE DO;
									END;
								END;
						END;
						WHEN (INDEX(UPCASE(ResStrVal),'100'))	LinkLvl = '100';
						WHEN (INDEX(UPCASE(ResStrVal),'200'))	LinkLvl = '200';
						WHEN (INDEX(UPCASE(ResStrVal),'25'))	LinkLvl = '25';
						WHEN (INDEX(UPCASE(ResStrVal),'50'))	LinkLvl = '50';
						OTHERWISE DO;
						END;
					END;
				END;
			ELSE IF INDEX(UPCASE(ProductNm),"LAMICTAL CD") THEN DO;
					SELECT;
						WHEN (INDEX(UPCASE(ResStrVal),"5") AND INDEX(UPCASE(ResStrVal),"25") AND INDEX(UPCASE(ResStrVal),"100")) DO;	
							SELECT;
								WHEN (INDEX(UPCASE(ItemCdDesc),'100'))	LinkLvl = '100';
								*************************************************************************;
								*****  V18 - Longer strings must come 1st - reorder WHEN statements  ****;
								*************************************************************************;
								WHEN (INDEX(UPCASE(ItemCdDesc),'25'))	LinkLvl = '25';
								WHEN (INDEX(UPCASE(ItemCdDesc),'5'))	LinkLvl = '5';
								OTHERWISE DO;
								END;
							END;
						END;
						WHEN (INDEX(UPCASE(ResStrVal),"100"))	LinkLvl = '100';
						WHEN (INDEX(UPCASE(ResStrVal),"25"))	LinkLvl = '25';
						WHEN (INDEX(UPCASE(ResStrVal),"5"))	LinkLvl = '5';
						WHEN (INDEX(UPCASE(ResStrVal),"2") AND INDEX(UPCASE(ResStrVal),"ROW")) 	LinkLvl = '2row';
						WHEN (INDEX(UPCASE(ResStrVal),"2"))	LinkLvl = '2';
						OTHERWISE DO;
						END;
					END;
				END;
			ELSE IF INDEX(UPCASE(ProductNm),"EPIVIR TABLETS") THEN DO;
					SELECT;
						WHEN (INDEX(UPCASE(ResStrVal),'100'))	LinkLvl = '100';
						WHEN (INDEX(UPCASE(ResStrVal),'150'))	LinkLvl = '150';
						WHEN (INDEX(UPCASE(ResStrVal),'300'))	LinkLvl = '300';
						OTHERWISE DO;
						END;
					END;
				END;
			ELSE IF INDEX(UPCASE(ProductNm),"VALTREX") THEN DO;
					SELECT;
						***********************************************************************************;
						*****  V18 - Valtrex now has combined strength ResStrVal which must be parsed  ****;
						***********************************************************************************;
						WHEN (INDEX(UPCASE(ResStrVal),"500") AND INDEX(UPCASE(ResStrVal),"1000")) DO;	
							SELECT;
								WHEN (INDEX(UPCASE(ItemCdDesc),'1000'))	LinkLvl = '1000';
								WHEN (INDEX(UPCASE(ItemCdDesc),'500'))	LinkLvl = '500';
								OTHERWISE DO;
								END;
							END;
						END;
						WHEN (INDEX(UPCASE(ResStrVal),'1000'))	LinkLvl = '1000';
						WHEN (INDEX(UPCASE(ResStrVal),'500'))	LinkLvl = '500';
						OTHERWISE DO;
						END;
					  END;
				END;
			ELSE IF INDEX(UPCASE(ProductNm),"ZANTAC TABLETS") THEN DO;
					SELECT;
						WHEN (INDEX(UPCASE(ResStrVal),"150") AND INDEX(UPCASE(ResStrVal),"300")) DO;	
							SELECT;
								WHEN (INDEX(UPCASE(ItemCdDesc),'150'))	LinkLvl = '150';
								WHEN (INDEX(UPCASE(ItemCdDesc),'300'))	LinkLvl = '300';
								OTHERWISE DO;
								END;
							END;
						END;
						WHEN (INDEX(UPCASE(ResStrVal),"150"))	LinkLvl = '150';
						WHEN (INDEX(UPCASE(ResStrVal),"300"))	LinkLvl = '300';
						OTHERWISE DO;
						END;
					END;
				END;
			ELSE IF INDEX(UPCASE(ProductNm),"WELLBUTRIN") THEN DO;
					SELECT;
						WHEN (INDEX(UPCASE(ResStrVal),'100'))	LinkLvl = '100';
						WHEN (INDEX(UPCASE(ResStrVal),'150'))	LinkLvl = '150';
						WHEN (INDEX(UPCASE(ResStrVal),'200'))	LinkLvl = '200';
						OTHERWISE DO;
						END;
					END;
				END;
			/* Watson must precede Bupro */
			ELSE IF INDEX(UPCASE(ProductNm),"WATSON HCL") THEN DO;
					SELECT;
						WHEN (INDEX(UPCASE(ResStrVal),'100'))		LinkLvl = '100';
						WHEN (INDEX(UPCASE(ResStrVal),'150'))	        LinkLvl = '150';
						WHEN (INDEX(UPCASE(ResStrVal),'SMOKING'))	LinkLvl = '150smoking';
						WHEN (INDEX(UPCASE(ResStrVal),'200'))		LinkLvl = '200';
						OTHERWISE DO;
						END;
					END;
				END;
			ELSE IF INDEX(UPCASE(ProductNm),"BUPROPION HCL") THEN DO;
					SELECT;
						WHEN (INDEX(UPCASE(ResStrVal),'100'))		LinkLvl = '100';
						WHEN (INDEX(UPCASE(ResStrVal),'WHITE'))		LinkLvl = '150white';
						WHEN (INDEX(UPCASE(ResStrVal),'PURPLE'))	LinkLvl = '150purple';
						WHEN (INDEX(UPCASE(ResStrVal),'SMOKING'))	LinkLvl = '150smoking';
						WHEN (INDEX(UPCASE(ResStrVal),'200'))		LinkLvl = '200';
						WHEN (INDEX(UPCASE(ResStrVal),'150'))		LinkLvl = '150';
						OTHERWISE DO;
						END;
					END;
				END;
			***************************************************************************************;
			*****  V31 - Removed Ventolin strength condition since it is single strength now  *****;
			***************************************************************************************;
			ELSE IF INDEX(UPCASE(ProductNm),"AVANDARYL TABLETS") THEN DO;
					SELECT;
						******************************************;
						*****  V18 - Added ROW for Avandaryl  ****;
						******************************************;
						WHEN (INDEX(UPCASE(ResStrVal),"1MG") AND INDEX(UPCASE(ResStrVal),"2MG") AND INDEX(UPCASE(ResStrVal),"4MG") AND INDEX(UPCASE(ResStrVal),"ROW")) DO;
							SELECT;
								WHEN (INDEX(UPCASE(ItemCdDesc),'4MG/1MG'))	LinkLvl = '4/1row';
								WHEN (INDEX(UPCASE(ItemCdDesc),'4MG/2MG'))	LinkLvl = '4/2row';
								WHEN (INDEX(UPCASE(ItemCdDesc),'4MG/4MG'))	LinkLvl = '4/4row';
								OTHERWISE DO;
								END;
							END;
						END;
						/* 'US' or blank for non-ROW */
						WHEN (INDEX(UPCASE(ResStrVal),"1MG") AND INDEX(UPCASE(ResStrVal),"2MG") AND INDEX(UPCASE(ResStrVal),"4MG")) DO;	
							SELECT;
								WHEN (INDEX(UPCASE(ItemCdDesc),'4MG/1MG'))	LinkLvl = '4/1';
								WHEN (INDEX(UPCASE(ItemCdDesc),'4MG/2MG'))	LinkLvl = '4/2';
								WHEN (INDEX(UPCASE(ItemCdDesc),'4MG/4MG'))	LinkLvl = '4/4';
								OTHERWISE DO;
								END;
							END;
						END;
						*********************************************************;
						*****  V18 - Added strengths 8/2, 8/4 for Avandaryl  ****;
						*********************************************************;
						/* E.g. ITEMCODE/PRODCODEDESC$ is "Avandaryl Tablets 8mg/2mg, 8mg/4mg for ROW" */
						WHEN (INDEX(UPCASE(ResStrVal),"2MG") AND INDEX(UPCASE(ResStrVal),"4MG") AND INDEX(UPCASE(ResStrVal),"8MG") AND INDEX(UPCASE(ResStrVal),"ROW")) DO;
							SELECT;
								WHEN (INDEX(UPCASE(ItemCdDesc),'8MG/1MG'))	LinkLvl = '8/1row';
								/* E.g. MISCELLANEOUSLOGIN/ITEMCODEDESC$ is "8MG/2MG (6ZM5201) US" */
								WHEN (INDEX(UPCASE(ItemCdDesc),'8MG/2MG'))	LinkLvl = '8/2row';
								WHEN (INDEX(UPCASE(ItemCdDesc),'8MG/4MG'))	LinkLvl = '8/4row';
								OTHERWISE DO;
								END;
							END;
						END;
						/* E.g. ITEMCODE/PRODCODEDESC$ is "Avandaryl Tablets 8mg/2mg, 8mg/4mg for US" */
						WHEN (INDEX(UPCASE(ResStrVal),"2MG") AND INDEX(UPCASE(ResStrVal),"4MG") AND INDEX(UPCASE(ResStrVal),"8MG")) DO;	
							SELECT;
								WHEN (INDEX(UPCASE(ItemCdDesc),'8MG/1MG'))	LinkLvl = '8/1';
								/* E.g. MISCELLANEOUSLOGIN/ITEMCODEDESC$ is "8MG/2MG (6ZM5201) US" */
								WHEN (INDEX(UPCASE(ItemCdDesc),'8MG/2MG'))	LinkLvl = '8/2';
								WHEN (INDEX(UPCASE(ItemCdDesc),'8MG/4MG'))	LinkLvl = '8/4';
								OTHERWISE DO;
								END;
							END;
						END;
						WHEN (INDEX(UPCASE(ResStrVal),"4MG/1MG") AND INDEX(UPCASE(ResStrVal),"ROW"))	LinkLvl = '4/1row';
						/* E.g. ITEMCODE/PRODCODEDESC$ is "Avandaryl Tablets 4mg/1mg" */
						WHEN (INDEX(UPCASE(ResStrVal),"4MG/1MG"))	LinkLvl = '4/1';
						WHEN (INDEX(UPCASE(ResStrVal),"4MG/2MG") AND INDEX(UPCASE(ResStrVal),"ROW"))	LinkLvl = '4/2row';
						WHEN (INDEX(UPCASE(ResStrVal),"4MG/2MG"))	LinkLvl = '4/2';
						WHEN (INDEX(UPCASE(ResStrVal),"4MG/4MG") AND INDEX(UPCASE(ResStrVal),"ROW"))	LinkLvl = '4/4row';
						WHEN (INDEX(UPCASE(ResStrVal),"4MG/4MG"))	LinkLvl = '4/4';
						WHEN (INDEX(UPCASE(ResStrVal),"8MG/1MG") AND INDEX(UPCASE(ResStrVal),"ROW"))	LinkLvl = '8/1row';
						WHEN (INDEX(UPCASE(ResStrVal),"8MG/1MG"))	LinkLvl = '8/1';
						WHEN (INDEX(UPCASE(ResStrVal),"8MG/2MG") AND INDEX(UPCASE(ResStrVal),"ROW"))	LinkLvl = '8/2row';
						WHEN (INDEX(UPCASE(ResStrVal),"8MG/2MG"))	LinkLvl = '8/2';
						WHEN (INDEX(UPCASE(ResStrVal),"8MG/4MG") AND INDEX(UPCASE(ResStrVal),"ROW"))	LinkLvl = '8/4row';
						WHEN (INDEX(UPCASE(ResStrVal),"8MG/4MG"))	LinkLvl = '8/4';
						OTHERWISE DO;
						END;
					END;
				END;
			ELSE IF INDEX(UPCASE(ProductNm),"LOTRONEX TABLETS") THEN DO;
					SELECT;
						WHEN (INDEX(UPCASE(ResStrVal),'0.5'))	LinkLvl = '0.5';
						WHEN (INDEX(UPCASE(ResStrVal),'1'))	LinkLvl = '1';
						OTHERWISE DO;
						END;
					END;
				END;
			ELSE IF INDEX(UPCASE(ProductNm),"AGENERASE CAPSULES") THEN DO;
					SELECT;
						WHEN (INDEX(UPCASE(ResStrVal),"50") AND INDEX(UPCASE(ResStrVal),"150")) DO;	
								SELECT;
									WHEN (INDEX(UPCASE(ItemCdDesc),'150'))	LinkLvl = '150';
									WHEN (INDEX(UPCASE(ItemCdDesc),'50'))	LinkLvl = '50';
									OTHERWISE DO;
									END;
								END;
						END;
						/* Order matters */
						WHEN (INDEX(UPCASE(ResStrVal),'150'))	LinkLvl = '150';
						WHEN (INDEX(UPCASE(ResStrVal),'50'))	LinkLvl = '50';
						OTHERWISE DO;
						END;
					END;
				END;
			ELSE IF INDEX(UPCASE(ProductNm),"AMERGE TABLETS") THEN DO;
					SELECT;
						WHEN (INDEX(UPCASE(ResStrVal),"1.0") AND INDEX(UPCASE(ResStrVal),"2.5")) DO;	
								SELECT;
									WHEN (INDEX(UPCASE(ItemCdDesc),'1.0'))	LinkLvl = '1.0';
									WHEN (INDEX(UPCASE(ItemCdDesc),'2.5'))	LinkLvl = '2.5';
									OTHERWISE DO;
									END;
								END;
						END;
						WHEN (INDEX(UPCASE(ResStrVal),'1.0'))	LinkLvl = '1.0';
						WHEN (INDEX(UPCASE(ResStrVal),'2.5'))	LinkLvl = '2.5';
						OTHERWISE DO;
						END;
					END;
				END;

		IF LinkLvl ^= '' THEN DO;OUTPUT;END;
		END;
	RUN;
	PROC SORT NODUP;
		BY	Samp_Id flg;
	RUN;
	DATA lelimsgist03a;
		SET		lelimsgist03a;
		BY		Samp_Id;
		IF		LAST.Samp_Id;
		KEEP	Samp_Id LinkLvl;
IF SAMP_ID IN (&sampnum) THEN PUT SAMP_ID LINKLVL;
	RUN;

	************************************************************************************************************************;
	*****  V15 - Need certain indres records on the sumres side (e.g. GENUSPDISS uses Criteria / Accept$ for Conforms) *****;
	*****  V25 - Added "INDEX(VarName,'INHALER')>0" to pull BOU/EOU data over from SumRes to run thru %TrnLimsI        *****;
	*****      - Added "INDEX(VarName,'NUMCANS')>0" to fix duplicate THROAT stages in ITR Dataset                      *****;
	************************************************************************************************************************;
	DATA lelimsindres01a; SET lelimsindres01a lelimssumres01a(WHERE=((INDEX(VarName,'INHALERUSE$')>0) OR INDEX(VarName,'NUMCANS')>0 ));RUN;  

	DATA lelimssumres01a; SET lelimsindres01a(WHERE=((INDEX(SpecName,'CASCADE')>0) OR (INDEX(ColName,'ACCEPT$')>0) )) lelimssumres01a;RUN;

	PROC SQL;CREATE INDEX SORTB ON lelimssumres01a (Samp_Id, SpecName);QUIT;

	*******************************************************************************;
	*****  V18 - Added to capture all product names for Matl_Nbr check below  *****;
	*******************************************************************************;
	DATA _NULL_;
		INFILE "&CtlDir.QueryProductList.txt" TRUNCOVER LRECL=400;
		INPUT @1 csvlst $CHAR400.;
		IF csvlst = "" THEN DO;
			CALL SYMPUT('JobStep','TrnLimsS (Missing Product File)');
			CALL SYMPUT('CondCode',12);
		END;
		ELSE DO;
			CALL SYMPUT('Prod_List',csvlst);
		END;
	RUN;

	************************************************************************;
	*****  V15 - Added lelimsgist03f2, lelimsgist03u to DATA statement *****;
	*****  V28 - Added 03L dataset back into the code                  *****;
	************************************************************************;
	DATA lelimsgist03b(KEEP=Samp_Id Samp_Comm_Txt ResEntTs)
		lelimsgist03c(KEEP=Samp_Id Meth_Spec_Nm Lab_Tst_Meth Lab_Tst_Meth_Spec_Desc ResEntTs)
		lelimsgist03d(KEEP=Samp_Id RowIX ColumnIX Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc Meth_Rslt_Char ResEntTs Lab_Tst_Meth_Spec_Desc)
		lelimsgist03e(KEEP=Samp_Id RowIX ColumnIX Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc Meth_Rslt_Numeric ResEntTs Lab_Tst_Meth_Spec_Desc)
		lelimsgist03f(KEEP=Samp_Id Approved_By_User_Id ResEntTs)
		lelimsgist03f2(KEEP=Samp_Id Approved_Dt ResEntTs)
		lelimsgist03g(KEEP=Samp_Id Meth_Spec_Nm Proc_Stat ResEntTs)
		lelimsgist03h(KEEP=Samp_Id Samp_Status ResEntTs)
		lelimsgist03i(KEEP=Samp_Id Meth_Spec_Nm Checked_Dt ResEntTs)
		lelimsgist03j(KEEP=Samp_Id Meth_Spec_Nm Checked_By_User_Id ResEntTs)
		lelimsgist03k(KEEP=Samp_Id Meth_Spec_Nm Samp_Tst_Dt ResEntTs)
		lelimsgist03l(KEEP=Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc Lab_Tst_Meth_Spec_Desc
						Upr_Limit Low_Limit Txt_Limit_A Txt_Limit_B Txt_Limit_C ResEntTs)
		lelimsgist03m(KEEP=Samp_Id Matl_Nbr Batch_Nbr Mfg_Tst_Grp Sub_Batch) 
		lelimsgist03n(KEEP=Stability_Study_Nbr_Cd Samp_Id Stability_Samp_Stor_Cond
						Stability_Samp_Time_Point Sub_Batch)
		lelimsgist03o(KEEP=Samp_Id Stability_Study_Nbr_Cd RowIX ColumnIX Meth_Spec_Nm Meth_Var_Nm Summary_Meth_Stage_Nm)
		lelimsgist03p(KEEP=Samp_Id Stability_Study_Nbr_Cd RowIX ColumnIX Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm)
		lelimsgist03u(KEEP=Samp_Id Prod_Nm Prod_Grp Prod_Level) 
		lelimsgist03X
                errorProduct
		;
		**********************************************************;
		*****  V15 - Added lelimsgist03a to MERGE statement  *****;
		**********************************************************;
		MERGE	lelimssumres01a
				lelimsgist03a
				lelimsgist01b;
		BY		Samp_Id;
		FORMAT	Approved_By_User_Id				$30.
				Approved_Dt				DATETIME13.
				Checked_By_User_Id			$30.
				Checked_Dt				DATETIME13.
				Lab_Tst_Desc				$40.
				Lab_Tst_Meth				$15.
				Lab_Tst_Meth_Spec_Desc			$40.
				LinkLvl					$10.
				Low_Limit				8.
				Meth_Peak_Nm				$40.
				Meth_Rslt_Char				$40.
				Meth_Rslt_Numeric			8.
				Meth_Spec_Nm				$40.
				Meth_Var_Nm				$40.
				Mfg_Tst_Grp				$8.
				Matl_Nbr				$18.
				Batch_Nbr				$10.
				Proc_Stat				8.
				Samp_Comm_Txt				$120.
				Samp_Id					10.
				Samp_Status				8.
				Samp_Tst_Dt				DATETIME13.
				Stability_Samp_Stor_Cond		$15.
				Stability_Samp_Time_Point		$4.
				Stability_Study_Nbr_Cd			$15.
				Sub_Batch				$4.
				Prod_Nm					$40.
				Prod_Grp				$40.
				Txt_Limit_A				$200.
				Txt_Limit_B				$200.
				Txt_Limit_C				$200.
				Upr_Limit				8.
				;
		LENGTH svc $163 ;
		SampName = UPCASE(SampName);
		IF SUBSTR(TRIM(LEFT(SampName)),1,1) = 'T' THEN DELETE;
		IF SUBSTR(TRIM(LEFT(SampName)),1,1) = 'S' THEN	DO; %LEXSTDY; END;
				ELSE	DO; %LEXBTCH; END;
		*****************************************************************************************;
		*****  V18 - Added more-these meth_spec_nm are shared across two or more products   *****;
                *****  V31 - Ventolin: removed ATM02047, ATM02003, AM0839. Added MEANSPRAYPATTERN   *****;
		*****************************************************************************************;
      		IF (SpecName IN ('APPEARDESCRIP','GENUSPDISS','GENCUBYTPW', 'AM0861ASSAYHPLC','AM0751LOD',
				'AM0899ASSAYHPLC','AM0888DRUGRELEASEUV','MDIWATERCONTENT','AM0952LEAKMAN',
				'AM0880PARTICULATEMATTER','ODOR','HARDNESS','FRIABILITY','DISINTEGRATION',
				'PKGAPPEAR','IDIR','UNIFORMITYOFDISPERSION','UNIFORMITYOFMASS',
				'AM0840DRUGRELEASEUV','AM0900DRUGRELEASEUV','AM0888DRUGRELEASEUV',
				'IDHPLC','IDUV','IDTLC','CHLORIDEID','AM0428ASSAYHPLC','AM0430CUHPLC',
				'GENMANCUBYUV','MEANSPRAYPATTERN') OR
		    INDEX(SpecName,'DRUGRELEASEUV')>0 ) AND UPCASE(ColName)^='ACCEPT$' THEN DO;
			ColName = ProductNm;
		END;

		********************************************************************************************;
		*****  V15 - Added - avoid problems with the merge of 03d and 03ll below (GENUSPDISS)  *****;
		********************************************************************************************;
		IF UPCASE(ColName)='ACCEPT$' THEN RowIX=.;

		IF ColName='' THEN DO;
			/* Method is not shared */
			svc = UPCASE(COMPRESS(SpecName||"/"||VarName||"//"||LinkLvl));
			lmac = UPCASE(PUT(svc,$LMac.));
			IF lmac = '' THEN DO;
				svc = UPCASE(COMPRESS(SpecName||"/"||VarName||"//"));
				lmac = UPCASE(PUT(svc,$LMac.));
			END;
		END;
		ELSE DO;
			*************************************************************************************************************;
			*****  V15 - Added - Two or more levels exist for a single peak and method is shared e.g. APPEARDESCRIP *****;
			*****  V31 - Removed Ventolin                                                                           *****;
			*************************************************************************************************************;
			IF INDEX(ProductNm,'WELLBUTRIN') OR INDEX(ProductNm,'BUPROPION') OR INDEX(ProductNm,'WATSON') OR INDEX(ProductNm,'ADVAIR HFA') OR
				INDEX(ProductNm,'RETROVIR') OR INDEX(ProductNm,'LANOXIN') OR INDEX(ProductNm,'ZOVIRAX') OR INDEX(ProductNm,'ZOFRAN TABLETS') OR 
				INDEX(ProductNm,'IMITREX') OR INDEX(ProductNm,'LAMICTAL') OR INDEX(ProductNm,'EPIVIR') OR INDEX(ProductNm,'ZANTAC TABLETS') OR 
				INDEX(ProductNm,'AVANDARYL') OR INDEX(ProductNm,'ADVAIR HFA') OR INDEX(ProductNm,'VALTREX') OR 
				INDEX(ProductNm,'AGENERASE') OR INDEX(ProductNm,'AMERGE') OR INDEX(ProductNm,'ONDANSETRON') THEN
			        svc = UPCASE(COMPRESS(SpecName||"/"||VarName||"/"||ColName||"/"||LinkLvl));
			ELSE
				svc = UPCASE(COMPRESS(SpecName||"/"||VarName||"/"||ColName||"/"));

			lmac = UPCASE(PUT(svc,$LMac.));
		END;

		Meth_Spec_Nm = UPCASE(SpecName);
		Meth_Var_Nm = UPCASE(PUT(svc,$LVar.));
		IF COMPRESS(Meth_Var_Nm) = "" THEN Meth_Var_Nm = UPCASE(VarName);
		Meth_Peak_Nm = UPCASE(PUT(svc,$LPeak.));
		Summary_Meth_Stage_Nm = UPCASE(PUT(svc,$LStg.));

		**********************************************************************************************************;
		***** V31 - Added - Ventolin has sumres value AVERAGEDOSEWEIGHT buried in with normal Cascade data,  *****;
                *****       it is added here to keep it from being deleted later when normal CI processing occurs.   *****;
		**********************************************************************************************************;
	      	IF INDEX(Meth_Spec_Nm,'CASCADE')=0 OR (INDEX(Meth_Spec_Nm,'ATM02003') AND VarName = 'AVERAGEDOSEWEIGHT') THEN DO;     
			IF Meth_Peak_Nm = "" THEN Meth_Peak_Nm = "NONE";
			IF Summary_Meth_Stage_Nm = "" THEN Summary_Meth_Stage_Nm = "NONE";
		END;

		************************************;
		*****  V15 - Added error trap  *****;
		************************************;
		IF (UPCASE(ProductNm) ^= UPCASE(PUT(svc,$ProdNm.))) AND ((PUT(svc,$ProdNm.) NOT IN (' ','','N/A')) AND (ProductNm NOT IN (' ',''))) THEN DO;
                	errorProd_Nm = PUT(svc,$ProdNm.);
			CALL SYMPUT('CondCode',12);
			CALL SYMPUT('StepRc',12);
			CALL SYMPUT('JobStep','TrnLimsS');
			CALL SYMPUT('ErrMsg',"Error indicates that a product has begun sharing another product's method.");
			CALL SYMPUT('FailLog','LELimsGistProduct.log');
                	OUTPUT errorProduct;
		END;

		*******************************************************************;
		*** Added V4 - To Create Lab_Tst_Meth & Lab_Tst_Meth_Spec_Desc  ***;
		*** Added V18 - Added more method prefixes                      ***;
		*** Added V24 - Relenza method prefix                           ***;
		*******************************************************************;
		TempSpecDispName = PUT(svc,$ECNDesc.);
		IF SUBSTR(Meth_Spec_Nm,1,2) IN ('AP','AD','AM','CH','DI','MD','GE','AT','FR','HA','ID','ME','OD','PK','RE','UN','WE') AND TempSpecDispName NE '' THEN DO;
			Lab_Tst_Meth           =  UPCASE(SUBSTR(TempSpecDispName,1,INDEX(TempSpecDispName,"-")-1));
			Lab_Tst_Meth_Spec_Desc =  LEFT(SUBSTR(TempSpecDispName,INDEX(TempSpecDispName,"-")+1));
			Prod_Nm                =  PUT(svc,$ProdNm.);
			Prod_Grp               =  PUT(svc,$ProdGrp.);
			Prod_Level	       =  LinkLvl;
		END;
		Proc_Stat = ProcStat;

		*IF lmac = "" THEN OUTPUT lelimsgist03X;
		SELECT;
			WHEN (lmac = "")  DELETE;
			WHEN (lmac = "SRCOMT") DO;
				IF ColName='' THEN Samp_Comm_Txt = ResStrVal;
				              ELSE Samp_Comm_Txt = ElemStrVal;
				Proc_Stat = 0;
			END;
			WHEN (lmac = "SRCVLIM")	DO; 
				%SRLIM;
				Meth_Rslt_Char = ResStrVal;
				***************************************************************;
				*****  V15 - Added to standardize for reporting purposes  *****;
				***************************************************************;
				IF INDEX(UPCASE(Meth_Rslt_Char), 'NOT CONFORM')>0 THEN
					Meth_Rslt_Char='Does Not Conform';
				ELSE IF INDEX(UPCASE(Meth_Rslt_Char), 'CONFORM')>0 THEN
					Meth_Rslt_Char='Conforms';
				%SRLTDesc;
			END;
			WHEN (lmac = "SRLIM")	DO; 
				%SRLIM;
				%SRLTDesc;
			END;
			WHEN (lmac = "SRNVAL") DO;
				Meth_Rslt_Numeric = ResNumVal;
				IF Meth_Rslt_Numeric = . THEN Meth_Rslt_Numeric = PUT(ResStrVal,8.);
				%SRLTDesc;
			END;
			WHEN (lmac = "SRNVLIM")	DO; 
				%SRLIM;
				Meth_Rslt_Numeric = ResNumVal;
				IF Meth_Rslt_Numeric = . THEN Meth_Rslt_Numeric = PUT(ResStrVal,8.);
				%SRLTDesc;
			END;
			WHEN (lmac = "SRSAPRV")	DO; 
				Approved_By_User_Id = ResEntUserid;
				Approved_Dt = EntryTs;   /** Changed from ResEntTs ***/
				Proc_Stat = 0;
			END;
			WHEN (lmac = "SRCHKBY")	Checked_By_User_Id = ResStrVal;
			WHEN (lmac = "SRCHKTS")	Checked_Dt = ResEntTs;
			WHEN (lmac = "SRTS")	Samp_Tst_Dt = INPUT(PUT(INPUT(PUT(
						COMPRESS(ResStrVal,"-"),6.),MMDDYY.),date7.) || " 00:00",DATETIME13.);
			WHEN (lmac = "SR001A")	DO; 
				Checked_By_User_Id = ResEntUserid;
				Checked_Dt = ResEntTs;
				%SRLIM;
				Meth_Rslt_Char = ResStrVal;
				%SRLTDesc;
			END;
			WHEN (lmac = "SR002A")	DELETE; 
			WHEN (lmac = "IR005A")	DO;							*** Advair Cascade Impaction Special Processing ***;
				IF INDEX(ElemStrVal,'SUM-') > 0 THEN DO;
					Summary_Meth_Stage_Nm = SUBSTR(ElemStrVal,INDEX(ElemStrVal,'-')+1,40);
				END;
				ELSE DELETE;
			END;
			WHEN (lmac = "IR005B")	DO;							*** e.g. PeakInfo ***;
				IF SUBSTR(ElemStrVal,1,1)='S' AND INDEX(UPCASE(ElemStrVal),'E') > 0 THEN DO;
					Summary_Meth_Stage_Nm = SUBSTR(ElemStrVal,INDEX(UPCASE(ElemStrVal),'E')+1,40);
				END;
				ELSE 
					Summary_Meth_Stage_Nm = SUBSTR(UPCASE(ElemStrVal),1);
			END;
			WHEN (lmac = "IR005C")	DO;							*** e.g. PeakInfoCalSums ***;
				IF INDEX(ElemStrVal,'SUM-') > 0 THEN DO;
					Summary_Meth_Stage_Nm = SUBSTR(ElemStrVal,INDEX(ElemStrVal,'-')+1,40);
				END;
				ELSE 
					Summary_Meth_Stage_Nm = SUBSTR(UPCASE(ElemStrVal),1);
			END;
			/* Added V24 */
			WHEN (lmac = "IR005D")	DO;							*** Relenza Cascade Impaction Special Processing ***;
				IF SUBSTR(ElemStrVal,1,1)='S' AND INDEX(UPCASE(ElemStrVal),'E') > 0 THEN DO;
					Summary_Meth_Stage_Nm = SUBSTR(ElemStrVal,INDEX(UPCASE(ElemStrVal),'E')+1,40);
				END;
				ELSE 
					Summary_Meth_Stage_Nm = ElemStrVal;
			END;
			WHEN (lmac = "IRPEAK")	DO;
				Meth_Peak_Nm  = UPCASE(ElemStrVal);
			END;
			WHEN (lmac = "IRCVAL")	DO; 
				Meth_Rslt_Char = ElemStrVal;
			END;
			*******************************;
			*****  V15 - Added macro  *****;
			*******************************;
			WHEN (lmac = "IRNVAL")	DO; 
				Meth_Rslt_Numeric = ElemNumVal;
				IF Meth_Rslt_Numeric = . AND ElemStrVal NE 'N/A' 
					THEN Meth_Rslt_Numeric = PUT(TRIM(ElemStrVal),8.);
			END;
			OTHERWISE;
		END;

		***************************************************************;
		*****  V26 - Change Summary_Meth_Stage_Nm to 6-F from 6F  *****;
		*****        Change Summary_Meth_Stage_Nm to 3-4 from 34  *****;
		***************************************************************;
		IF Meth_Peak_Nm = 'FLUTICASONE PROPIONATE' THEN Meth_Peak_Nm = 'FLUTICASONE';
		SELECT;
			WHEN (Summary_Meth_Stage_Nm IN ('1-5', '1thru5', '1THRU5'))
					Summary_Meth_Stage_Nm = '1-5';
			WHEN (Summary_Meth_Stage_Nm IN ('01&2'))
					Summary_Meth_Stage_Nm = '0-2';
			WHEN (Summary_Meth_Stage_Nm IN ('34', '3-4', '3&4'))
					Summary_Meth_Stage_Nm = '3-4';
			WHEN (Summary_Meth_Stage_Nm IN ('34&5'))
					Summary_Meth_Stage_Nm = '3-5';
			WHEN (Summary_Meth_Stage_Nm IN ('6F', '67F', '6&7&F', '6-7&F', '6&7&FILTER', '67&F'))
					Summary_Meth_Stage_Nm = '6-F';
                        /* V24 - Added for Relenza */
			WHEN (Summary_Meth_Stage_Nm IN ('1TO3'))
					Summary_Meth_Stage_Nm = '1-3';
                        /* V24 - Added for Relenza */
			WHEN (Summary_Meth_Stage_Nm IN ('4&5'))
					Summary_Meth_Stage_Nm = '4-5';
                        /* V24 - Added for Relenza */
			WHEN (Summary_Meth_Stage_Nm IN ('FPM&5'))
					Summary_Meth_Stage_Nm = '1-5';
                        /* V24 - Added for Relenza */
			WHEN (Summary_Meth_Stage_Nm IN ('PRESEP&0'))
					Summary_Meth_Stage_Nm = 'PRESEP-0';
                        /* V31- Added for Ventolin */
			WHEN (Summary_Meth_Stage_Nm IN ('2TO6'))
					Summary_Meth_Stage_Nm = '2-6';
			OTHERWISE;
		END;


		************************************************************;
		*****  V18 - Added all products, formerly only Advair  *****;
		*****  V28 - Added 03L dataset back into the code      *****;
		************************************************************;
		SELECT ( SUBSTR(Matl_Nbr,1,6) );
			WHEN ( &Prod_List ) Matl_Nbr = '';
			OTHERWISE;
		END;

		IF Samp_Comm_Txt                        NOT = ''        THEN OUTPUT lelimsgist03b;
		IF Lab_Tst_Meth                         NOT = ''        THEN OUTPUT lelimsgist03c;
		IF Meth_Rslt_Char                       NOT = ''        THEN OUTPUT lelimsgist03d;
		IF Meth_Rslt_Numeric                    NOT = .         THEN OUTPUT lelimsgist03e;
		IF Approved_By_User_Id                  NOT = ''        THEN OUTPUT lelimsgist03f;
		*************************************;
		*****  V15 - Added Approved_Dt  *****;
		*************************************;
		IF Approved_Dt                          NOT = .         THEN OUTPUT lelimsgist03f2;
		IF Proc_Stat                            NOT = .  AND
		   Proc_Stat                            > 0             THEN OUTPUT lelimsgist03g;
		IF Samp_Status                          NOT = .         THEN OUTPUT lelimsgist03h;
		IF Checked_Dt                           NOT = .         THEN OUTPUT lelimsgist03i;
		IF Checked_By_User_Id                   NOT = ''        THEN OUTPUT lelimsgist03j;
		IF Samp_Tst_Dt                          NOT = .         THEN OUTPUT lelimsgist03k;
                /* Specs are now handled by spec table so we expect to find 'x' in PEC's _txt_ sumres fields */
		IF Txt_Limit_A                          NOT = ''        THEN OUTPUT lelimsgist03l;
		IF Matl_Nbr                             NOT = '' AND    
		   Batch_Nbr                       	NOT = ''        THEN OUTPUT lelimsgist03m;
		IF Stability_Study_Nbr_Cd               NOT = ''        THEN OUTPUT lelimsgist03n;
		IF Summary_Meth_Stage_Nm  		NOT = '' AND		
			lmac = "IR005A"					THEN OUTPUT lelimsgist03o;	
		IF Meth_Peak_Nm				NOT = '' AND
			lmac = "IRPEAK"					THEN OUTPUT lelimsgist03p;
		IF Prod_Nm                              NOT IN ('','N/A')
									THEN OUTPUT lelimsgist03u;
	RUN;

	%DEDUP(lelimsgist03o,Y,Samp_Id RowIX ColumnIX Meth_Spec_Nm Meth_Var_Nm Summary_Meth_Stage_Nm);
	%DEDUP(lelimsgist03p,Y,Samp_Id RowIX ColumnIX Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm);

	PROC SORT DATA=lelimsgist03o;BY Samp_Id RowIX Meth_Spec_Nm Meth_Var_Nm;RUN;
	PROC SORT DATA=lelimsgist03p;BY Samp_Id RowIX Meth_Spec_Nm Meth_Var_Nm;RUN;

	DATA 	lelimsgist03os;
	MERGE	lelimsgist03o(IN=IN1)
			lelimsgist03p(IN=IN2);
	BY Samp_Id RowIX Meth_Spec_Nm Meth_Var_Nm;
	IF Summary_Meth_Stage_Nm = '' OR Meth_Peak_Nm = '' THEN DELETE;
	RUN;

	PROC SQL;CREATE INDEX Samp_Id ON lelimsgist03os (Samp_Id);QUIT;

	DATA lelimsgist03oo(KEEP=Samp_Id RowIX ColumnIX Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc
						Upr_Limit Low_Limit Txt_Limit_A Txt_Limit_B Txt_Limit_C);	
	MERGE lelimsgist03os(IN=IN1)
		  lelimsgist03a(IN=IN2);
	BY		Samp_Id;
	IF IN1;
			FORMAT	
				LinkLvl						$10.
				Low_Limit					8.
				Txt_Limit_A					$200.
				Txt_Limit_B					$200.
				Txt_Limit_C					$200.
				Upr_Limit					8.
				;

		SampName=Stability_Study_Nbr_Cd;
      	IF INDEX(Meth_Spec_Nm ,'CASCADE')>0 THEN DO;     
			LENGTH SName $7.;
			SELECT;
				WHEN (Summary_Meth_Stage_Nm IN ('TP0'))	SName = 'TP0';
				WHEN (Summary_Meth_Stage_Nm IN ('1-5'))	SName = '125';
				WHEN (Summary_Meth_Stage_Nm IN ('3-4'))	SName = '34';
				WHEN (Summary_Meth_Stage_Nm IN ('6-F'))	SName = '6FILTER';
				OTHERWISE;
			END;	
		
			svc = UPCASE(COMPRESS(Meth_Spec_Nm||"/"||Meth_Peak_Nm||SName||"INDIVIDUALS//"||LinkLvl));
			Lab_Tst_Desc = PUT(svc,$LLTDesc.);
			Meth_Var_Nm = UPCASE(PUT(svc,$LVar.));			
			%SRLIM;
			OUTPUT lelimsgist03oo;
			svc = UPCASE(COMPRESS(Meth_Spec_Nm||"/"||Meth_Peak_Nm||SName||"INDIVIDUALS25PCT//"||LinkLvl));
			Lab_Tst_Desc = PUT(svc,$LLTDesc.);
			Meth_Var_Nm = UPCASE(PUT(svc,$LVar.));			
			%SRLIM;
			OUTPUT lelimsgist03oo;		
		END;
		ELSE DO;
			OUTPUT lelimsgist03oo;		
		END;
	RUN;

	********************************************************************;
	***** Added V9 - Making sure Meth_Var_Nm is same for TRS & ITR *****;
	********************************************************************;
	DATA lelimsgist03c;SET lelimsgist03c;FORMAT Meth_Var_Nm $40.;
		      	IF INDEX(Meth_Spec_Nm ,'CASCADE')>0 THEN DO;
                                IF Meth_Var_Nm='PEAKINFOCALCRESULTSTBL' THEN Meth_Var_Nm='PEAKINFO';     
				/* V24 - Added Relenza CI */
                                IF Meth_Var_Nm='PEAKINFOCALCSUMS' THEN Meth_Var_Nm='PEAKINFO';     
                        END;RUN;

	*******************************************************************;
	*****  V27 - Added code was reinserted to fix missing Cascade *****;
	*****  V28 - Added 03L dataset back into the code             *****;
	*******************************************************************;
	DATA lelimsgist03ll(KEEP=Samp_Id RowIX ColumnIX Meth_Spec_Nm Meth_Var_Nm Summary_Meth_Stage_Nm Meth_Peak_Nm Lab_Tst_Desc);
	SET lelimsgist03l lelimsgist03oo;FORMAT Meth_Var_Nm $40.;
		      	IF INDEX(Meth_Spec_Nm ,'CASCADE')>0 THEN DO;
                                IF Meth_Var_Nm='PEAKINFOCALCRESULTSTBL' THEN Meth_Var_Nm='PEAKINFO';     
                        END;RUN;
	RUN;

	%DEDUP(lelimsgist03b,Samp_Id,Samp_Id Samp_Comm_Txt);
	PROC SORT DATA=lelimsgist03c OUT=Checkgist03c NODUPKEY;BY Lab_Tst_Meth Lab_Tst_Meth_Spec_Desc;RUN;
	%MultipleDEDUP(lelimsgist03c,Meth_Spec_Nm,Lab_Tst_Meth_Spec_Desc,Samp_Id Meth_Spec_Nm Lab_Tst_Meth Lab_Tst_Meth_Spec_Desc);

	DATA lelimsgist03d1;SET lelimsgist03d;
	FORMAT Meth_Var_Nm $40.;
      	IF INDEX(Meth_Spec_Nm ,'CASCADE')>0 THEN DO;     
      			IF Meth_Var_Nm='PEAKINFOCALCRESULTSTBL' THEN Meth_Var_Nm='PEAKINFO';     
			DROP Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc ;
		END;
	RUN;
	PROC SORT DATA=lelimsgist03d1;BY Samp_Id RowIX Meth_Spec_Nm Meth_Var_Nm;         RUN;
	PROC SORT DATA=lelimsgist03ll;BY Samp_Id RowIX Meth_Spec_Nm Meth_Var_Nm;        RUN;

	DATA lelimsgist03d;	
	MERGE lelimsgist03ll(IN=IN1)
		  lelimsgist03d1(IN=IN2);
	BY	Samp_Id RowIX Meth_Spec_Nm Meth_Var_Nm;
	IF Meth_Rslt_Char^='';
	IF IN1;
	RUN;

	%DEDUP(lelimsgist03d,Lab_Tst_Desc,Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc Meth_Rslt_Char Lab_Tst_Meth_Spec_Desc);
	/****************************************************************/
	/*** Added V27 - Code was reinserted to fix missing Cascade   ***/
	/****************************************************************/
	DATA lelimsgist03e1;SET lelimsgist03e;FORMAT Meth_Var_Nm $40.;
      	IF INDEX(Meth_Spec_Nm ,'CASCADE')>0 THEN DO;     
      			IF Meth_Var_Nm='PEAKINFOCALCRESULTSTBL' THEN Meth_Var_Nm='PEAKINFO';     
			DROP Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc ;
		END;
	RUN;
	PROC SORT DATA=lelimsgist03e1;BY Samp_Id RowIX Meth_Spec_Nm Meth_Var_Nm ;         RUN;
	PROC SORT DATA=lelimsgist03ll;BY Samp_Id RowIX Meth_Spec_Nm Meth_Var_Nm  ;        RUN;

DATA _NULL_;SET lelimsgist03ll;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;
DATA _NULL_;SET lelimsgist03e1;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;

	DATA lelimsgist03e;	
	MERGE lelimsgist03ll(IN=IN1)
		  lelimsgist03e1(IN=IN2);
	BY	Samp_Id RowIX Meth_Spec_Nm Meth_Var_Nm ;
	IF Meth_Rslt_Numeric^=.;
	IF IN1;
	RUN;

	%DEDUP(lelimsgist03e,Lab_Tst_Desc,Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc Meth_Rslt_Numeric Lab_Tst_Meth_Spec_Desc);
	%DEDUP(lelimsgist03f,Samp_Id,Samp_Id Approved_By_User_Id);
	%DEDUP(lelimsgist03f2,Samp_Id,Samp_Id Approved_Dt);
	%DEDUP(lelimsgist03g,Meth_Spec_Nm,Samp_Id Meth_Spec_Nm Proc_Stat);
	%DEDUP(lelimsgist03h,Samp_Id,Samp_Id Samp_Status);
	%DEDUP(lelimsgist03i,Meth_Spec_Nm,Samp_Id Meth_Spec_Nm Checked_Dt);
	%DEDUP(lelimsgist03j,Meth_Spec_Nm,Samp_Id Meth_Spec_Nm Checked_By_User_Id);
	%DEDUP(lelimsgist03k,Meth_Spec_Nm,Samp_Id Meth_Spec_Nm Samp_Tst_Dt);
	%DEDUP(lelimsgist03l,Lab_Tst_Desc,Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc Upr_Limit Low_Limit Txt_Limit_A Txt_Limit_B Txt_Limit_C Lab_Tst_Meth_Spec_Desc);
	%DEDUP(lelimsgist03m,Y,Samp_Id Matl_Nbr Batch_Nbr Mfg_Tst_Grp Sub_Batch); 
	%DEDUP(lelimsgist03n,Y,Stability_Study_Nbr_Cd Samp_Id Stability_Samp_Stor_Cond Stability_Samp_Time_Point Sub_Batch);
	%DEDUP(lelimsgist03u,Y,Samp_Id Prod_Nm Prod_Grp Prod_Level); 

DATA _NULL_;SET lelimsgist03n;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;

	DATA lelimsgist03q;
		MERGE	lelimsgist03n(in=n)	
			lelimsgist02a(in=a);
		BY	Stability_Study_Nbr_Cd;
		IF	n;
		IF Matl_Nbr = ' ' THEN Matl_Nbr='0000000';
	RUN;
	PROC SORT DATA=lelimsgist03q NOEQUALS;
		BY	Samp_Id;
	RUN;

DATA _NULL_;SET lelimsgist03b;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;
DATA _NULL_;SET lelimsgist03f;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;
DATA _NULL_;SET lelimsgist03f2;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;
DATA _NULL_;SET lelimsgist03h;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;
DATA _NULL_;SET lelimsgist03m;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;
DATA _NULL_;SET lelimsgist03u;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;
	DATA lelimsgist03r;
		MERGE	lelimsgist03b(in=b)	
			lelimsgist03f(in=f)
			lelimsgist03f2(in=f2)
			lelimsgist03h(in=h)
			lelimsgist03m(in=m)
			lelimsgist03u(in=u);
		BY	Samp_Id;
	RUN;

DATA _NULL_;SET lelimsgist03r;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;
DATA _NULL_;SET lelimsgist03q;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;

	DATA lelimsgist03s;
		MERGE	lelimsgist03r(in=r)	
			lelimsgist03q(in=q);
		BY	Samp_Id;
	RUN;
DATA _NULL_;SET lelimsgist03s;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;

	DATA lelimsgist03t;SET lelimsgist03k;
		BY	Samp_Id Meth_Spec_Nm;
		IF	FIRST.Meth_Spec_Nm;
	RUN;
DATA _NULL_;SET lelimsgist03t;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;
DATA _NULL_;SET lelimsgist03c;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;
DATA _NULL_;SET lelimsgist03g;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;
DATA _NULL_;SET lelimsgist03i;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;
DATA _NULL_;SET lelimsgist03j;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;

	DATA lelimsgist03v;
		MERGE	lelimsgist03t(in=t)	
			lelimsgist03c(in=c)	
			lelimsgist03g(in=g)	
			lelimsgist03i(in=i)	
			lelimsgist03j(in=j);
		BY	Samp_Id Meth_Spec_Nm;
	RUN;

DATA _NULL_;SET lelimsgist03d;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;
DATA _NULL_;SET lelimsgist03e;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;

	*******************************************************************;
	*****  V28 - Added 03L dataset back into the code             *****;
	*******************************************************************;
	PROC SORT DATA=lelimsgist03d nodupkey;
	BY Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc Lab_Tst_Meth_Spec_Desc;RUN;
	DATA lelimsgist03w;
		MERGE	lelimsgist03d(in=d)	
			lelimsgist03e(in=e)
			lelimsgist03l(in=l)
                        ;
		BY	Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc Lab_Tst_Meth_Spec_Desc;
		DROP RowIX ColumnIX;
	RUN;

	********************************************************************************;
	*** Added V4 - Displays to log Spec/Var Combinations not in PEC Table        ***;
	***            NOTE: SampName written is the Last SampName in that group     ***;
	********************************************************************************;
	DATA lelimsgist01AA;SET lelimsgist01A;
		Meth_Var_Nm=UPCASE(Meth_Var_Nm);
		ColName=UPCASE(Column_Nm);
	RUN;
	PROC SQL;CREATE INDEX SORTED1 ON lelimsgist03X (Meth_Spec_Nm, Meth_Var_Nm, SampName);QUIT;
	PROC SORT DATA=lelimsgist01AA NOEQUALS;BY Meth_Spec_Nm Meth_Var_Nm;         RUN;
	DATA lelimsgist03X;
	MERGE lelimsgist03X(IN=IN1)
	      lelimsgist01aa(IN=IN2);
	BY Meth_Spec_Nm Meth_Var_Nm;
	IF IN1 AND NOT IN2;
	Meth_Count+1;
	IF LAST.Meth_Var_Nm THEN DO;
		PUT @1 '#' Meth_Count @7 SpecName @37 VarName @67 SampName;
		PUT @15  ResStrVal; 
		OUTPUT;
		Meth_Count=0;
	END;
	RUN;
%MEND	TrnLimsS;

***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: TrnLMRead                                                       *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Prepare lelimsgist05a for table insertion into the              *;
*                     LINKS_Material/Genealogy table (if necessary).                  *;
*   INPUT:            LINKS Tables                                                    *;
*   PROCESSING:       Read dataset, create AMAPS file for checking.                   *;
*   OUTPUT:           lelimsgist05a                                                   *;
***************************************************************************************;
%MACRO	TrnLMRead;
	PROC SQL;
		CONNECT TO ORACLE(USER=&OraId ORAPW=&OraPsw BUFFSIZE=20000 READBUFF=20000 PATH="&OraPath" DBINDEX=YES);
		CREATE TABLE lelimsgist05_LM AS SELECT * FROM CONNECTION TO ORACLE (
			SELECT DISTINCT
				Matl_Nbr			,
				Batch_Nbr			,
				Matl_Desc			,
				Matl_Mfg_Dt			,
				Matl_Exp_Dt			
			FROM	LINKS_Material
			) ORDER BY Matl_Nbr, Batch_Nbr;
		CREATE TABLE lelimsgist05_LMG AS SELECT * FROM CONNECTION TO ORACLE (
			SELECT DISTINCT
				Prod_Matl_Nbr			,
				Prod_Batch_Nbr			,
				Comp_Matl_Nbr			,
				Comp_Batch_Nbr
			FROM	LINKS_Material_Genealogy	LMG
			) ORDER BY Prod_Matl_Nbr, Prod_Batch_Nbr, Comp_Matl_Nbr, Comp_Batch_Nbr;
		DISCONNECT FROM ORACLE;
		QUIT;
		%PUT &SQLXMSG;
		%PUT &SQLXRC;
		%LET HSQLXRC = &SQLXRC;
		%LET HSQLXMSG = &SQLXMSG;
	RUN;
	DATA lelimsgist05a;SET lelimsgist05_LM; RUN;

%MEND	TrnLMRead;

***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: TrnLimsI                                                        *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Translate and group the data into a format that is              *;
*                     one-step away from LINKS ready-to-load for the ITR and          *;
*                     TP tables.                                                      *;
*   INPUT:            lelimsindres01a (from LELimsIndRes) and user-defined            *;
*                     formats from TrnFmts.                                           *;
*   PROCESSING:       Utilizing the User-Defined formats, process the LIMS            *;
*                     Element Results data and translate the data.                    *;
*   OUTPUT:           lelimsgist04a,                                                  *;
*		      lelimsgist04b, lelimsgist04c, lelimsgist04d,                    *;
*                     lelimsgist04e, lelimsgist04f, lelimsgist04g,                    *;
*                     lelimsgist04h, lelimsgist04i, lelimsgist04j,                    *;
*                     lelimsgist04k, lelimsgist04l. These will be grouped             *;
*                     again in later steps (TrnITR and TrnTP).                        *;
***************************************************************************************;
%MACRO	TrnLimsI;
	/* This sequence is necessary for IR001A/IR001B to work properly. */
	PROC SQL;CREATE INDEX SORTED2 ON lelimsindres01a (Samp_Id, SpecName, VarName, Res_Id, RowIx, ColumnIx);QUIT;

	************************************************************************************;
	*****  V23 - Added lelimsgist04d2 to hold Indvl_Tst_Rslt_NumDevices            *****;
	*****  V25 - Added lelimsgist04e2 to hold Indvl_Tst_Rslt_Location for BOU/EOU  *****;
	************************************************************************************;
	DATA    lelimsgist04a(KEEP=&IRKey ColumnIx Meth_Peak_Nm) 
		lelimsgist04b(KEEP=&IRKey ColumnIx Indvl_Meth_Stage_Nm) 
		lelimsgist04c(KEEP=&IRKey ColumnIx Indvl_Tst_Rslt_Nm)
		lelimsgist04d(KEEP=&IRKey Indvl_Tst_Rslt_Device)
		lelimsgist04d2(KEEP=&IRKey Indvl_Tst_Rslt_NumDevices)
		lelimsgist04e(KEEP=&IRKey Indvl_Tst_Rslt_Location)
		lelimsgist04e2(KEEP=&IRKey Indvl_Tst_Rslt_Location)
		lelimsgist04f(KEEP=&IRKey Indvl_Tst_Rslt_Time_Pt)
		lelimsgist04g(KEEP=&IRKey ColumnIx Indvl_Tst_Rslt_Val_Num)
		lelimsgist04h(KEEP=&IRKey ColumnIx Indvl_Tst_Rslt_Val_Char)
		lelimsgist04i(KEEP=&IRKey ColumnIx Indvl_Tst_Rslt_Prep)
		lelimsgist04j(KEEP=&IRKey VarName Tst_Parm_Nm)
		lelimsgist04k(KEEP=&IRKey ColumnIx VarName Tst_Parm_Val_Num Tst_Parm_Val_Char)
		lelimsgist04l(KEEP=&IRKey ColumnIx VarName Indvl_Tst_Rslt_Device)
		lelimsgist04X
		;
		SET lelimsindres01a;
		BY		Samp_Id SpecName VarName Res_Id RowIx ColumnIx;
		RETAIN	IndResReg  IndImpRsltNm  "               ";
		*************************************************************************;
		*****  V23 - Added Indvl_Tst_Rslt_NumDevices to check -vs- devices  *****;
		*************************************************************************;
		FORMAT	Indvl_Meth_Stage_Nm			$40.
			Indvl_Tst_Rslt_Device			$40.
			Indvl_Tst_Rslt_Location			$40.
			Indvl_Tst_Rslt_Prep			$40.
			Indvl_Tst_Rslt_Nm			$40.
			Indvl_Tst_Rslt_Row			8.
			Indvl_Tst_Rslt_Time_Pt			$4.
			Indvl_Tst_Rslt_Val_Num			8.4
			Indvl_Tst_Rslt_Val_Char			$80.
			Meth_Peak_Nm				$40.
			Meth_Spec_Nm				$40.
			Meth_Var_Nm				$40.
			Samp_Id					10.
			Tst_Parm_Nm				$40.
			Tst_Parm_Val_Num			8.
			Tst_Parm_Val_Char			$80.
			Indvl_Tst_Rslt_NumDevices		8.
			svc					$163.;
		IF SUBSTR(SampName,1,1) = 'T' THEN DELETE;
		svc = UPCASE(COMPRESS(SpecName||"/"||VarName||"/"||ColName||"/"));
		Meth_Spec_Nm = SpecName;
		Meth_Var_Nm = UPCASE(PUT(svc,$LVar.));
		IF Meth_Var_Nm = "" THEN Meth_Var_Nm = UPCASE(VarName);
		Meth_Peak_Nm = UPCASE(PUT(svc,$LPeak.));
		*********************************;
		*****  V18 - Added methods  *****;
		*****  V31 - Removed AM0995 *****;
		*********************************;
		IF	Meth_Peak_Nm = "" AND ( Meth_Spec_Nm NOT IN ('MDPIMICROSCOPICEVALUATION','ATM02016DISSHPLC','AM0957DISSUV','AM0857DISSUV',
			'AM0900DRUGRELEASEUV','AM0888DRUGRELEASEUV','AM0705759DRUGRELEASEHPLC','AM0840DRUGRELEASEUV','ATM02056DISSUV','AM0656AM0613DISSHPLC',
			'AM0794DISSHPLC','AM0854DISSHPLC','AM0648DISSHPLC','GENUSPDISS','AM0632AM0635DISSHPLC','AM0755DISSHPLC','AM0883DISSHPLC',
			'ATM02032DISSHPLC','AM0653DISSHPLC','AM0736DISSUV','AM0608DISSHPLC','AM0664DISSHPLC','MEANSPRAYPATTERN') AND 
                        INDEX(Meth_Spec_Nm,'CASCADE')=0 )
			THEN Meth_Peak_Nm = "NONE";	
		lmac = UPCASE(PUT(svc,$LMac.));
		Indvl_Meth_Stage_Nm = UPCASE(PUT(svc,$LStg.));
		IF Indvl_Meth_Stage_Nm = "" AND ( Meth_Spec_Nm NOT IN ('MDPIMICROSCOPICEVALUATION','AM0900DRUGRELEASEUV','AM0888DRUGRELEASEUV',
			'AM0705759DRUGRELEASEHPLC','AM0840DRUGRELEASEUV','ATM02056DISSUV','AM0656AM0613DISSHPLC','AM0794DISSHPLC','AM0854DISSHPLC',
			'AM0648DISSHPLC','GENUSPDISS','AM0632AM0635DISSHPLC','AM0755DISSHPLC','AM0883DISSHPLC','AM0653DISSHPLC','AM0664DISSHPLC',
			'AM0608DISSHPLC','MEANSPRAYPATTERN') AND 
			INDEX(Meth_Spec_Nm,'CASCADE')=0 )
			THEN Indvl_Meth_Stage_Nm = "NONE";
		*******************************************************;
		*** V17 - Modified DEVICE code for BLEND & CASCADE  ***;
		*******************************************************;
		IF INDEX(Meth_Spec_Nm,'BLENDASSAY')=0 THEN Indvl_Tst_Rslt_Device   = "NONE";
		Indvl_Tst_Rslt_Row = RowIx;
		*********************************;
		*****  V21 - Added method   *****;
		*********************************;
		IF ( INDEX(Meth_Spec_Nm,'CASCADE')>0 AND VarName = 'PARAMETERS' ) OR 
			( (INDEX(UPCASE(Meth_Spec_Nm),'DISS')>0 OR INDEX(UPCASE(Meth_Spec_Nm),'DRUGREL')>0) AND INDEX(UPCASE(ColName),'VESSEL') ) OR
			(INDEX(Meth_Spec_Nm,'MEANSPRAYPATTERN')>0) OR (INDEX(Meth_Spec_Nm,'AM0952')>0)
			THEN ColumnIx = ColumnIx;
	   		ELSE IF PUT(svc,$LLTDesc.) ^= '1' THEN ColumnIx = 1;

		*******************************************************************************************************************************************;
		*****  V18 - Added to accomodate ATM02064 which does not require peak for Mean Weight of Contents (but does for Concentration, etc.)  *****;
		*******************************************************************************************************************************************;
		IF ( INDEX(Meth_Spec_Nm,'ATM02064')>0 AND Meth_Var_Nm = 'MEANWTOFCONTENTS' ) OR ( INDEX(Meth_Spec_Nm,'ATM02064')>0 AND ColName = 'WTOFSUSP' ) THEN
			ColumnIx = 2;  /* arbitrary to avoid deleting "NONE" peaks in 04a merge below */

		********************************************;
		*****  V31 - Added WTOFSUSP to criteria ****;
		********************************************;
		IF ( INDEX(Meth_Spec_Nm,'ATM02047')>0 AND Meth_Var_Nm = 'MEANWTOFCONTENTS' ) OR ( INDEX(Meth_Spec_Nm,'ATM02047')>0 AND ColName = 'WTOFSUSP' ) THEN
			ColumnIx = 2;  /* arbitrary to avoid deleting "NONE" peaks in 04a merge below */

		*IF lmac = "" THEN OUTPUT lelimsgist04X;
		SELECT;
			WHEN (lmac = "")  DELETE;
			WHEN (lmac = "IR001A")	IndResReg  = ElemStrVal;				*** Advair Dose Special Processing ***;
			WHEN (lmac = "IR001B")	DO;							*** Advair Dose Special Processing ***;
				Indvl_Tst_Rslt_Location  = COMPRESS(IndResReg || ElemStrVal);
				IndResReg = "";
			END;
			WHEN (lmac = "IR002A")	DO;							*** Microscopic Evaluation Special Processing ***;
				Indvl_Tst_Rslt_Val_Char = ElemStrVal;
				Indvl_Tst_Rslt_Nm = SUBSTR(UPCASE(ColName),6,INDEX(ColName,'$')-6);     *** Modified V2 - From -7 to -6 ***;
			END;
			WHEN (lmac = "IR003A")	DO;						        *** Advair Impurities Special Processing ***;
				Meth_Peak_Nm  = UPCASE(LEFT(SUBSTR(ElemStrVal,1,INDEX(ElemStrVal,'-')-1)));
				Indvl_Tst_Rslt_Nm = LEFT(SUBSTR(ElemStrVal,INDEX(ElemStrVal,'-')+1));
				IF Indvl_Tst_Rslt_Nm IN ('GR103595X','GR97980X')
					THEN Indvl_Meth_Stage_Nm = Indvl_Tst_Rslt_Nm;
					ELSE Indvl_Meth_Stage_Nm = 'UNSPECIFIED';
			END;
			*** Added V4 - Macro IR003B added for Impurities change in LIMS ***;
			WHEN (lmac = "IR003B")	DO;							*** Advair Impurities Special Processing ***;
				Meth_Peak_Nm  = UPCASE(LEFT(SUBSTR(ElemStrVal,1,INDEX(ElemStrVal,' ')-1)));
				IndImpRsltNm  = LEFT(SUBSTR(ElemStrVal,INDEX(ElemStrVal,' ')+1));
				IF IndImpRsltNm = 'Group' THEN IndImpRsltNm = "";
			END;
			*** Added V4 - Macro IR003C added for Impurities change in LIMS ***;
			WHEN (lmac = "IR003C")	DO;							*** Advair Impurities Special Processing ***;
				Indvl_Tst_Rslt_Nm = COMPRESS(IndImpRsltNm) || ' ' || COMPRESS(ElemStrVal); 
				IF Indvl_Tst_Rslt_Nm IN ('GR103595X','GR97980X')
					THEN Indvl_Meth_Stage_Nm = Indvl_Tst_Rslt_Nm;
					ELSE Indvl_Meth_Stage_Nm = 'UNSPECIFIED';
			END;
			WHEN (lmac = "IR004A")	DO;							*** Advair Cascade Impaction Special Processing ***;
				IF INDEX(UPCASE(ElemStrVal),'-TOTAL') = 0
					AND INDEX(ElemStrVal,'-') > 0 THEN DO;
					Meth_Peak_Nm = UPCASE(SUBSTR(ElemStrVal,1,INDEX(ElemStrVal,'-')-1));
					Indvl_Meth_Stage_Nm = SUBSTR(ElemStrVal,INDEX(ElemStrVal,'-')+1,40);
				END;
				ELSE DELETE;
			END;
			WHEN (lmac = "IR005A")	DO;							*** Advair Cascade Impaction Special Processing ***;
				IF INDEX(ElemStrVal,'-') > 0 THEN DO;
					Indvl_Meth_Stage_Nm = SUBSTR(ElemStrVal,INDEX(ElemStrVal,'-')+1,40);
				END;
				ELSE DELETE;
			END;
			WHEN (lmac = "IR005B")	DO;							*** Cascade Impaction Special Processing ***;
				IF SUBSTR(ElemStrVal,1,1)='S' AND INDEX(UPCASE(ElemStrVal),'E') > 0 THEN DO;
					Indvl_Meth_Stage_Nm = SUBSTR(ElemStrVal,INDEX(UPCASE(ElemStrVal),'E')+1,40);
				END;
				ELSE 
					Indvl_Meth_Stage_Nm = SUBSTR(UPCASE(ElemStrVal),1);
			END;
			WHEN (lmac = "IR005C")	DO;
				IF INDEX(ElemStrVal,'SUM-') > 0 THEN DO;
					Indvl_Meth_Stage_Nm = SUBSTR(ElemStrVal,INDEX(ElemStrVal,'-')+1,40);
				END;
				ELSE 
					Indvl_Meth_Stage_Nm = SUBSTR(UPCASE(ElemStrVal),1);
			END;
			/* Added V24 - Relenza CI */
			WHEN (lmac = "IR005D")	DO;							*** Relenza Cascade Impaction Special Processing ***;
				IF SUBSTR(ElemStrVal,1,1)='S' AND INDEX(UPCASE(ElemStrVal),'E') > 0 THEN DO;
					Indvl_Meth_Stage_Nm = SUBSTR(ElemStrVal,INDEX(UPCASE(ElemStrVal),'E')+1,40);
				END;
				ELSE 
					Indvl_Meth_Stage_Nm = ElemStrVal;
			END;
			*******************************************************;
			*** V17 - Modified DEVICE code for macro IRDEV      ***;
			*******************************************************;
			WHEN (lmac = "IRDEV")	DO;
				IF INDEX(UPCASE(ElemStrVal),'PREP')>0 THEN Indvl_Tst_Rslt_Device   = COMPRESS(LEFT(ElemStrVal),'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ');
				                                      ELSE Indvl_Tst_Rslt_Device   = TRIM(LEFT(ElemStrVal));
			END;
			*******************************************************;
			*** V19 - Modified DEVICE code for macro IRDEV      ***;
			*******************************************************;
			WHEN (lmac = "IRTSTNM")	DO;
                                Indvl_Tst_Rslt_Nm   = TRIM(LEFT(ElemStrVal));
			END;
			WHEN (lmac = "IRLOC")	Indvl_Tst_Rslt_Location = ElemStrVal;
			WHEN (lmac = "IRNVAL")	DO;
				Indvl_Tst_Rslt_Val_Num = ElemNumVal;
				IF Indvl_Tst_Rslt_Val_Num = . AND ElemStrVal NE 'N/A' 
					THEN Indvl_Tst_Rslt_Val_Num = PUT(TRIM(ElemStrVal),8.);
				****************************************************;
				*** Added V4 - To Add & Fix <0.05 for StudyRpt   ***;
				****************************************************;
				IF Indvl_Tst_Rslt_Val_Num = . THEN DO;     /** IF Indvl_Tst_Rslt_Val_Num still missing ***/
					IF INDEX(ElemStrVal,'<') GT 0 OR INDEX(ElemStrVal,'LT') GT 0
						THEN DO;
							Indvl_Tst_Rslt_Val_Char = '<0.05';						
						END;		
					ELSE DO;
						Indvl_Tst_Rslt_Val_Char = TRIM(ElemStrVal);						
					END;
				END;
				***************************************************;
				*** Added V15 - Device # to avoid ITR dups      ***;
				***************************************************;
				IF (INDEX(Meth_Spec_Nm,'DRUGRELEASE') OR INDEX(Meth_Spec_Nm,'DISS'))  THEN DO;Indvl_Tst_Rslt_Device = LEFT(SUBSTR(ColName,7,1));END;
				******************************************;
				*** Added V18 - For MEANSPRAYPATTERN   ***;
				******************************************;
				IF Meth_Spec_Nm='MEANSPRAYPATTERN' THEN Meth_Peak_Nm='NONE';
			END;
			****************************************************************************;
			*****  V15 - Added IRPREP macro                                        *****;
			****************************************************************************;
			WHEN (lmac = "IRPREP")	Indvl_Tst_Rslt_Prep = UPCASE(ElemStrVal);
			/* Only want 1st word e.g. peak sometimes called Ondansetron HCl, other times Ondansetron */
			WHEN (lmac = "IRPEAK")	Meth_Peak_Nm  = UPCASE(SCAN(ElemStrVal,1,' '));
			WHEN (lmac = "IRTMPT")	DO;
				Indvl_Tst_Rslt_Time_Pt  = ElemStrVal;
				*******************************************************;
				*** Added V15 - Indvl Stage Name For Drug Release   ***;
				*******************************************************;
				SELECT;
					WHEN (ElemStrVal='1')  Suffix='ST';
					WHEN (ElemStrVal='2')  Suffix='ND';
					WHEN (ElemStrVal='3')  Suffix='RD';
					OTHERWISE DO;
						Suffix='TH';
					END;
				END;
                                *******************************;
                                *****  V18 - Added methods ****;
                                *******************************;
				IF (INDEX(Meth_Spec_Nm,'DRUGRELEASE') OR INDEX(Meth_Spec_Nm,'DISS')) AND 
                                        INDEX(Meth_Spec_Nm,'ATM02016DISSHPLC')=0 AND INDEX(Meth_Spec_Nm,'AM0957DISSUV')=0 AND 
					INDEX(Meth_Spec_Nm,'AM0857DISSUV')=0 AND INDEX(Meth_Spec_Nm,'AM0755DISSHPLC')=0 AND
					INDEX(Meth_Spec_Nm,'AM0632AM0635DISSHPLC')=0 AND INDEX(Meth_Spec_Nm,'AM0648DISSHPLC')=0 AND 
					INDEX(Meth_Spec_Nm,'AM0656AM0613DISSHPLC')=0 AND INDEX(Meth_Spec_Nm,'AM0664DISSHPLC')=0 AND 
					INDEX(Meth_Spec_Nm,'AM0854DISSHPLC')=0 AND INDEX(Meth_Spec_Nm,'AM0883DISSHPLC')=0 AND
					INDEX(Meth_Spec_Nm,'AM0653DISSHPLC')=0 AND INDEX(Meth_Spec_Nm,'AM0736DISSUV')=0 AND
					INDEX(Meth_Spec_Nm,'AM0608DISSHPLC')=0
					THEN DO;
					Indvl_Meth_Stage_Nm = TRIM(LEFT(ElemStrVal))|| Suffix ||' Hour';
				END;
			END;
			WHEN (lmac = "PNAME")	Tst_Parm_Nm  = ElemStrVal;
			WHEN (lmac = "PNVPN")	DO;
				Tst_Parm_Nm = UPCASE(ColName);
				Tst_Parm_Val_Num = ElemNumVal;
				IF Tst_Parm_Val_Num = . THEN Tst_Parm_Val_Num = %TO_NUM(ElemStrVal);
			END;
			WHEN (lmac = "PNVDEV")	DO;
				Indvl_Tst_Rslt_Device = LEFT(SUBSTR(ColName,7,1));
				Tst_Parm_Val_Num = ElemNumVal;
				IF Tst_Parm_Val_Num = . THEN Tst_Parm_Val_Num = %TO_NUM(ElemStrVal);
				Tst_Parm_Val_Char = ElemStrVal;
			END;
			*******************************************************;
			*** V23 - ADDED Macro to hold Number of Devices     ***;
			*******************************************************;
			WHEN (lmac = "IRNUMDEV")	DO;
				Indvl_Tst_Rslt_NumDevices   = TRIM(LEFT(ElemStrVal));
			END;
			*******************************************************;
			*** V25 - ADDED Macro to hold Number of Devices     ***;
			*******************************************************;
			WHEN (lmac = "SRNUMDEV")	DO;
				Indvl_Tst_Rslt_NumDevices   = TRIM(LEFT(ResStrVal));
			END;
			*******************************************************;
			*** V25 - ADDED Macro to hold BOU/EOU String        ***;
			*******************************************************;
			WHEN (lmac = "IRUSE")	DO;
				Indvl_Tst_Rslt_Location	    = TRIM(LEFT(ResStrVal));
			END;
			OTHERWISE;
		END;

		IF Meth_Peak_Nm = 'FLUTICASONE PROPIONATE' THEN Meth_Peak_Nm = 'FLUTICASONE';
		*** V4 Added  - For Impurities Change in LIMS ***;
		ELSE IF Meth_Peak_Nm IN ('GR103595X','GR97980X') THEN Meth_Peak_Nm = 'SALMETEROL';

		Indvl_Meth_Stage_Nm = UPCASE(Indvl_Meth_Stage_Nm);
		SELECT;
			WHEN (Indvl_Meth_Stage_Nm IN ('TP0', 'T&P&0'))
					Indvl_Meth_Stage_Nm = 'TP0';
			WHEN (Indvl_Meth_Stage_Nm IN ('01&2'))
					Indvl_Meth_Stage_Nm = '0-2';
			WHEN (Indvl_Meth_Stage_Nm IN ('1-5', '1THRU5'))
					Indvl_Meth_Stage_Nm = '1-5';
			WHEN (Indvl_Meth_Stage_Nm IN ('34', '3-4', '3&4'))
					Indvl_Meth_Stage_Nm = '3-4';
			WHEN (Indvl_Meth_Stage_Nm IN ('34&5'))
					Indvl_Meth_Stage_Nm = '3-5';
			WHEN (Indvl_Meth_Stage_Nm IN ('6F', '67F', '6&7&F', '6-7&F', '6&7&FILTER', '67&F'))
					Indvl_Meth_Stage_Nm = '6-F';
			WHEN (Indvl_Meth_Stage_Nm IN ('THROAT', 'T'))
					Indvl_Meth_Stage_Nm = 'THROAT';
			WHEN (Indvl_Meth_Stage_Nm IN ('PRESEPARATOR', 'P', 'PRESEP'))
					Indvl_Meth_Stage_Nm = 'PRESEPARATOR';
			WHEN (Indvl_Meth_Stage_Nm IN ('FILTER', 'F'))
					Indvl_Meth_Stage_Nm = 'FILTER';
                        /* V24 - Added for Relenza */
			WHEN (Indvl_Meth_Stage_Nm IN ('PRESEP&0'))
					Indvl_Meth_Stage_Nm = 'PRESEP-0';
                        /* V24 - Added for Relenza */
			WHEN (Indvl_Meth_Stage_Nm IN ('1TO3'))
					Indvl_Meth_Stage_Nm = '1-3';
                        /* V24 - Added for Relenza */
			WHEN (Indvl_Meth_Stage_Nm IN ('4&5'))
					Indvl_Meth_Stage_Nm = '4-5';
                        /* V24 - Added for Relenza */
			WHEN (Indvl_Meth_Stage_Nm IN ('FPM'))
					Indvl_Meth_Stage_Nm = '1-5';
                        /* V31 - Added for Ventolin unique stage */
			WHEN (Indvl_Meth_Stage_Nm IN ('2TO6'))
					Indvl_Meth_Stage_Nm = '2-6';
			OTHERWISE;
		END;

		/****************************************************************/
		/*** Added V9 - Making sure Meth_Var_Nm is same for TRS & ITR ***/
		/*** Added V23- Added output dataset lelimsgist04d2           ***/
		/*** Added V25- Added output dataset lelimsgist04e2           ***/
                /*** Added V31- Added PEAKINFOCALCSUMS rename to PEAKINFO     ***/
		/****************************************************************/
		IF Indvl_Tst_Rslt_Device   NOT = '' AND
		   Meth_Var_Nm = VarName		THEN OUTPUT lelimsgist04d;
		IF Indvl_Tst_Rslt_NumDevices   NOT = .  THEN OUTPUT lelimsgist04d2;
		IF Indvl_Tst_Rslt_Device   NOT = '' AND
		   Meth_Var_Nm NOT = VarName		THEN OUTPUT lelimsgist04l;
		IF INDEX(Meth_Spec_Nm,'CASCADE')>0 THEN DO;
      			IF Meth_Var_Nm='PEAKINFOCALCRESULTSTBL' THEN Meth_Var_Nm='PEAKINFO';     
      			IF Meth_Var_Nm='PEAKINFOCALCSUMSSX' THEN Meth_Var_Nm='PEAKINFO';     
      			IF Meth_Var_Nm='PEAKINFOCALCSUMSFP' THEN Meth_Var_Nm='PEAKINFO';     
      			IF Meth_Var_Nm='PEAKINFOCALCSUMS' THEN Meth_Var_Nm='PEAKINFO';     
		END;
		/* V24 - Added for Relenza */
		IF INDEX(Meth_Spec_Nm,'IMP')>0 AND Meth_Spec_Nm NOT IN ('ATM02066IMPHPLC','ATM02106IMPHPLC') THEN DO;
      			IF Meth_Var_Nm='PEAKINFOIMPURITIES' THEN Meth_Var_Nm='PEAKINFO';     
		END;
		IF Meth_Peak_Nm            NOT = '' 	THEN OUTPUT lelimsgist04a;
		IF Indvl_Meth_Stage_Nm     NOT = '' 	THEN OUTPUT lelimsgist04b;
		IF Indvl_Tst_Rslt_Nm       NOT = '' 	THEN OUTPUT lelimsgist04c;
		IF Indvl_Tst_Rslt_Location NOT = '' AND
			lmac ^= "IRUSE"               	THEN OUTPUT lelimsgist04e;
		IF Indvl_Tst_Rslt_Location NOT = '' AND
			lmac = "IRUSE"          	THEN OUTPUT lelimsgist04e2;
		IF Indvl_Tst_Rslt_Time_Pt  NOT = '' 	THEN OUTPUT lelimsgist04f;
		IF Indvl_Tst_Rslt_Val_Num  NOT = .  	THEN OUTPUT lelimsgist04g;
		IF Indvl_Tst_Rslt_Val_Char NOT = '' 	THEN OUTPUT lelimsgist04h;
		IF Indvl_Tst_Rslt_Prep     NOT = '' 	THEN OUTPUT lelimsgist04i;
		IF Tst_Parm_Nm             NOT = '' 	THEN OUTPUT lelimsgist04j;
		IF Tst_Parm_Val_Char       NOT = '' OR
		   Tst_Parm_Val_Num        NOT = .  	THEN OUTPUT lelimsgist04k;
	RUN;

	DATA lelimsgist04d;SET lelimsgist04d;
		IF INDEX(Meth_Spec_Nm,'CASCADE')>0 THEN DO;
      			IF Meth_Var_Nm='PEAKINFOCALCRESULTSTBL' THEN Meth_Var_Nm='PEAKINFO';     
      			IF Meth_Var_Nm='PEAKINFOCALCSUMSSX' THEN Meth_Var_Nm='PEAKINFO';     
      			IF Meth_Var_Nm='PEAKINFOCALCSUMSFP' THEN Meth_Var_Nm='PEAKINFO';     
			/* V24 - Added for Relenza */
      			IF Meth_Var_Nm='PEAKINFOCALCSUMS' THEN Meth_Var_Nm='PEAKINFO';     
		END;
		/* V24 - Added for Relenza */
		IF INDEX(Meth_Spec_Nm,'IMP')>0 AND Meth_Spec_Nm NOT IN ('ATM02066IMPHPLC','ATM02106IMPHPLC') THEN DO;
      			IF Meth_Var_Nm='PEAKINFOIMPURITIES' THEN Meth_Var_Nm='PEAKINFO';     
		END;
	RUN;
	DATA lelimsgist04l;SET lelimsgist04l;
		IF INDEX(Meth_Spec_Nm,'CASCADE')>0 THEN DO;
      			IF Meth_Var_Nm='PEAKINFOCALCRESULTSTBL' THEN Meth_Var_Nm='PEAKINFO';     
      			IF Meth_Var_Nm='PEAKINFOCALCSUMSSX' THEN Meth_Var_Nm='PEAKINFO';     
      			IF Meth_Var_Nm='PEAKINFOCALCSUMSFP' THEN Meth_Var_Nm='PEAKINFO';     
			/* V24 - Added for Relenza */
      			IF Meth_Var_Nm='PEAKINFOCALCSUMS' THEN Meth_Var_Nm='PEAKINFO';     
		END;
	RUN;
	%DEDUP(lelimsgist04a,Y,&IRKey ColumnIx Meth_Peak_Nm);
	DATA lelimsgist04a;
		SET		lelimsgist04a;
		BY		&IRKey ColumnIx Meth_Peak_Nm;
		IF		Meth_Peak_Nm = 'NONE' THEN DO;
			IF	FIRST.ColumnIx AND LAST.ColumnIx THEN;
			ELSE	DELETE;
		END;
	RUN;
	/* Sumres has varnames like MEAN1, MEAN2... and Indres' PctRelTbl TIMEPTs have ColumnIx=2 */
	DATA lelimsgist04b; SET lelimsgist04b;
			IF  INDEX(Meth_Spec_Nm,'ATM02016DISSHPLC') OR INDEX(Meth_Spec_Nm,'AM0957DISSUV') OR 
				INDEX(Meth_Spec_Nm,'AM0857DISSUV') OR INDEX(Meth_Spec_Nm,'ATM02056DISSUV') OR
				INDEX(Meth_Spec_Nm,'ATM02032DISSHPLC') OR INDEX(Meth_Spec_Nm,'AM0736DISSUV') OR
				INDEX(Meth_Spec_Nm,'AM0608DISSHPLC')
				THEN ColumnIx = 1;
	RUN;
	%DEDUP(lelimsgist04b,Y,&IRKey ColumnIx Indvl_Meth_Stage_Nm);
	DATA lelimsgist04b;
		SET		lelimsgist04b;
		BY		&IRKey ColumnIx Indvl_Meth_Stage_Nm;
		IF		Indvl_Meth_Stage_Nm = 'NONE' THEN DO;
			IF	FIRST.ColumnIx AND LAST.ColumnIx THEN;
			ELSE	DELETE;
		END;
	RUN;
	DATA lelimsgist04b; SET lelimsgist04b;
			IF  INDEX(Meth_Spec_Nm,'MEANSPRAYPATTERN') THEN ColumnIx = 1;
	RUN;
	%DEDUP(lelimsgist04c,Y,&IRKey ColumnIx Indvl_Tst_Rslt_Nm);
	%DEDUP(lelimsgist04d,Y,&IRKey Indvl_Tst_Rslt_Device);
	DATA lelimsgist04d;
		SET	lelimsgist04d;
		BY	&IRKey Indvl_Tst_Rslt_Device;
		IF	Indvl_Tst_Rslt_Device ='NONE' THEN DO;
			IF FIRST.Indvl_Tst_Rslt_Row AND LAST.Indvl_Tst_Rslt_Row THEN;
			ELSE DELETE;
		END;
	RUN;
	********************************************************************************;
	*** Added V23- Added DEDUP for dataset lelimsgist04d2                        ***;
	*** Added V25- Added DEDUP for dataset lelimsgist04e2                        ***;
	********************************************************************************;
	%DEDUP(lelimsgist04d2,Y,Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Indvl_Tst_Rslt_NumDevices);
	%DEDUP(lelimsgist04e,Y,&IRKey Indvl_Tst_Rslt_Location);
	%DEDUP(lelimsgist04e2,Y,Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Indvl_Tst_Rslt_Location);
	DATA lelimsgist04e2;SET lelimsgist04e2(DROP=Indvl_Tst_Rslt_Row RES_REPLICATE RES_ID);
	%DEDUP(lelimsgist04f,Y,&IRKey Indvl_Tst_Rslt_Time_Pt);
	%DEDUP(lelimsgist04g,Y,&IRKey ColumnIx Indvl_Tst_Rslt_Val_Num); 
	%DEDUP(lelimsgist04h,Y,&IRKey ColumnIx Indvl_Tst_Rslt_Val_Char);
	*****************************;
	*****  V15 - Added 04i  *****;
	*****************************;
	%DEDUP(lelimsgist04i,Y,&IRKey ColumnIx Indvl_Tst_Rslt_Prep);
	%DEDUP(lelimsgist04j,Y,&IRKey VarName Tst_Parm_Nm);
	%DEDUP(lelimsgist04k,Y,&IRKey ColumnIx VarName Tst_Parm_Val_Num Tst_Parm_Val_Char);
	%DEDUP(lelimsgist04l,Y,&IRKey ColumnIx VarName Indvl_Tst_Rslt_Device);
	********************************************************************************;
	*** Added V4 - Displays to log Spec/Var/ColNm Combinations not in PEC Table  ***;
	***            NOTE: SampName written is the Last SampName in that group     ***;
	********************************************************************************;
	DATA lelimsgist01AA;SET lelimsgist01A;
		Meth_Var_Nm=UPCASE(Meth_Var_Nm);
		ColName=UPCASE(Column_Nm);
	RUN;
	PROC SQL;CREATE INDEX SORTED3 ON lelimsgist04X (Meth_Spec_Nm, Meth_Var_Nm, ColName, SampName);QUIT;
	PROC SORT DATA=lelimsgist01AA NOEQUALS;BY Meth_Spec_Nm Meth_Var_Nm ColName;         RUN;
	DATA lelimsgist04X;
	MERGE lelimsgist04X(IN=IN1)
	      lelimsgist01aa(IN=IN2);
	BY Meth_Spec_Nm Meth_Var_Nm ColName;
	IF IN1 AND NOT IN2;
	Meth_Count+1;
	IF LAST.ColName THEN DO;
		PUT @1 '#' Meth_Count @7 SpecName @37 VarName @67 ColName @97 SampName;
		PUT @15  ElemStrVal; 
		OUTPUT;
		Meth_Count=0;
	END;
	RUN;

%MEND	TrnLimsI;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: TrnSamp                                                         *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Prepare lelimsgist05b for table insertion into the Samp         *;
*                     table.                                                          *;
*   INPUT:            lelimsgist03s                                                   *;
*   PROCESSING:       Read dataset, keeping all variables.                            *;
*   OUTPUT:           lelimsgist05b                                                   *;
***************************************************************************************;
%MACRO	TrnSamp;
	DATA lelimsgist05b;SET lelimsgist03s;
		***********************************************************************;
		*****  V15 - Eliminate where records get through but are not one of   *;
		*****        our known products (or the correct strength for a known  *;
		*****        product)                                                 *;
		***********************************************************************;
		IF Prod_Nm ^= '' AND Prod_Grp ^= '';
	RUN;
DATA _NULL_;SET lelimsgist05b; IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;	RUN;
%MEND	TrnSamp;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: TrnTRS                                                          *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Prepare lelimsgist05b for table insertion into the              *;
*                     Tst_Rslt_Summary table.                                         *;
*   INPUT:            lelimsgist03v and lelimsgist03w.                                *;
*   PROCESSING:       Merge lelimsgist03v and lelimsgist03w by Samp_Id,               *;
*                     keeping all variables.                                          *;
*   OUTPUT:           lelimsgist05c                                                   *;
***************************************************************************************;
%MACRO	TrnTRS;
DATA _NULL_;SET lelimsgist03v; IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;	RUN;
DATA _NULL_;SET lelimsgist03w; IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;	RUN;
	PROC SORT data=lelimsgist03v; BY Samp_Id Meth_Spec_Nm Lab_Tst_Meth_Spec_Desc;RUN;
	PROC SORT data=lelimsgist03w; BY Samp_Id Meth_Spec_Nm Lab_Tst_Meth_Spec_Desc;RUN;
	DATA lelimsgist05c LelimsStat05c(Keep=Samp_Id Meth_Spec_Nm);
		MERGE	lelimsgist03v(in=v)	
			lelimsgist03w(in=w);
		BY	Samp_Id Meth_Spec_Nm Lab_Tst_Meth_Spec_Desc;
		IF	Meth_Rslt_Numeric  = .  AND
			Meth_Rslt_Char = '' THEN DELETE;
		IF Summary_Meth_Stage_Nm='' THEN DELETE;
		OUTPUT lelimsgist05c;
		IF Meth_Rslt_Numeric = 0 THEN OUTPUT LelimsStat05c;
	RUN;

DATA _NULL_;SET lelimsgist05c; IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;	RUN;
%MEND	TrnTRS;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: TrnST                                                           *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Prepare lelimsgist05d for table insertion into the              *;
*                     Stage_Translation table.                                        *;
*   INPUT:            lelimsgist03v and lelimsgist03w.                                *;
*   PROCESSING:       Merge lelimsgist03v and lelimsgist03w by Samp_Id,               *;
*                     keeping only Samp_Id, Meth_Spec_Nm, Meth_Var_Nm                 *;
*                     Meth_Peak_Nm, Summary_Meth_Stage_Nm, and Lab_Tst_Desc.          *;
*                     Determine Indvl_Meth_Stage_Nm based upon                        *;
*                     Summary_Meth_Stage_Nm, writing multiple records where           *;
*                     necessary.                                                      *;
*   OUTPUT:           lelimsgist05d                                                   *;
***************************************************************************************;

%MACRO	TrnST;
	***************************************************************;
	*****  V26 - Change Summary_Meth_Stage_Nm to 6-F from 6F  *****;
	*****        Change Summary_Meth_Stage_Nm to 3-4 from 34  *****;
	***************************************************************;
	DATA lelimsgist05d;
		MERGE	lelimsgist03v(in=v)	
				lelimsgist03w(in=w);
		BY		Samp_Id Meth_Spec_Nm Lab_Tst_Meth_Spec_Desc;
		IF	Meth_Rslt_Numeric  = .  AND
			Meth_Rslt_Char = '' THEN DELETE;
		IF Summary_Meth_Stage_Nm='' THEN DELETE;
		IF Summary_Meth_Stage_Nm=' ' THEN DO;
			Summary_Meth_Stage_Nm = '1-5';
			OUTPUT lelimsgist05d;
			Summary_Meth_Stage_Nm = '3-4';
			OUTPUT lelimsgist05d;
			Summary_Meth_Stage_Nm = '6-F';
			OUTPUT lelimsgist05d;
			Summary_Meth_Stage_Nm = 'TP0';
			OUTPUT lelimsgist05d;
		END;
		ELSE DO;
			OUTPUT lelimsgist05d;
		END;
	RUN;

	DATA lelimsgist05d;	SET lelimsgist05d;
		LENGTH	Indvl_Meth_Stage_Nm $40;
		KEEP	Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm
				Lab_Tst_Desc Indvl_Meth_Stage_Nm;
		SELECT;
			WHEN (Summary_Meth_Stage_Nm = 'NONE') DO;
				Indvl_Meth_Stage_Nm = 'NONE';
				OUTPUT;
			END;
			/* V24 - Added for Relenza */
			WHEN (Summary_Meth_Stage_Nm IN ('TP0', 'T&P&0') AND Meth_Spec_Nm ne 'ATM02104CASCADEHPLC') DO;
				Indvl_Meth_Stage_Nm = 'TP0';
				OUTPUT;
				Indvl_Meth_Stage_Nm = 'THROAT';
				OUTPUT;
				Indvl_Meth_Stage_Nm = 'PRESEPARATOR';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '0';
				OUTPUT;
			END;
                        /* Includes Relenza */
			WHEN (Summary_Meth_Stage_Nm = '1-5') DO;
				Indvl_Meth_Stage_Nm = '1-5';
				OUTPUT;
				/* Relenza does not use 1-2 */
				IF Meth_Spec_Nm NE 'ATM02104CASCADEHPLC' THEN DO;
				Indvl_Meth_Stage_Nm = '1-2';
				OUTPUT;
				END;
				Indvl_Meth_Stage_Nm = '1';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '2';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '3';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '4';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '5';
				OUTPUT;
			END;
			WHEN (Summary_Meth_Stage_Nm IN ('34', '3-4', '3&4')) DO;
				Indvl_Meth_Stage_Nm = '3-4';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '3';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '4';
				OUTPUT;
			END;
			WHEN (Summary_Meth_Stage_Nm IN ('6F', '67F', '6-F', '6-7F', '6&7&F', '6&7&FILTER')) DO;
				Indvl_Meth_Stage_Nm = '6-F';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '6';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '7';
				OUTPUT;
				Indvl_Meth_Stage_Nm = 'FILTER';
				OUTPUT;
			END;
			WHEN (Summary_Meth_Stage_Nm = 'THROAT') DO;
				Indvl_Meth_Stage_Nm = 'THROAT';
				OUTPUT;
			END;
			WHEN (Summary_Meth_Stage_Nm = 'PRESEPARATOR') DO;
				Indvl_Meth_Stage_Nm = 'PRESEPARATOR';
				OUTPUT;
			END;
			WHEN (Summary_Meth_Stage_Nm = 'FILTER') DO;
				Indvl_Meth_Stage_Nm = 'FILTER';
				OUTPUT;
			END;
                        ****************************************;
                        *****  V15 - Added for MDI         *****;
                        ****************************************;
			WHEN (Summary_Meth_Stage_Nm = '0-2') DO;
				Indvl_Meth_Stage_Nm = '0-2';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '0';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '1';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '2';
				OUTPUT;
			END;
			WHEN (Summary_Meth_Stage_Nm = '3-5') DO;
				Indvl_Meth_Stage_Nm = '3-5';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '3';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '4';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '5';
				OUTPUT;
			END;
                        ****************************************;
                        *****  V24 - Added for Relenza     *****;
                        ****************************************;
			WHEN (Summary_Meth_Stage_Nm = '1-3') DO;
				Indvl_Meth_Stage_Nm = '1-3';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '1';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '2';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '3';
				OUTPUT;
			END;
                        ****************************************;
                        *****  V31 - Added for Ventolin    *****;
                        ****************************************;
			WHEN (Summary_Meth_Stage_Nm = '2-6') DO;
				Indvl_Meth_Stage_Nm = '2-6';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '2';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '3';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '4';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '5';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '6';
				OUTPUT;
			END;
                        ****************************************;
                        *****  V24 - Added for Relenza     *****;
                        ****************************************;
			WHEN (Summary_Meth_Stage_Nm = '4-5') DO;
				Indvl_Meth_Stage_Nm = '4-5';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '4';
				OUTPUT;
				Indvl_Meth_Stage_Nm = '5';
				OUTPUT;
			END;
                        ****************************************;
                        *****  V24 - Added for Relenza     *****;
                        ****************************************;
			WHEN (Summary_Meth_Stage_Nm = 'TP0' AND Meth_Spec_Nm = 'ATM02104CASCADEHPLC') DO;
				Indvl_Meth_Stage_Nm = 'TP0';
				OUTPUT;
				Indvl_Meth_Stage_Nm = 'PRESEP-0';
				OUTPUT;
				Indvl_Meth_Stage_Nm = 'TMP';
				OUTPUT;
			END;
			OTHERWISE DO;
				Indvl_Meth_Stage_Nm = Summary_Meth_Stage_Nm;
				OUTPUT;
			END;
		END;
	RUN;

	PROC SORT DATA=lelimsgist05d NODUP;
		BY	Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm
			Lab_Tst_Desc Indvl_Meth_Stage_Nm;
	RUN;

DATA _NULL_;SET lelimsgist05d; IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;	RUN;
%MEND	TrnST;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: TrnITR                                                          *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Prepare lelimsgist05e for table insertion into the              *;
*                     Indvl_Tst_Rslt table.                                           *;
*   INPUT:            Datasets: lelimsgist04a,                                        *;
*                     lelimsgist04b, lelimsgist04c, lelimsgist04d,                    *;
*                     lelimsgist04e, lelimsgist04f, and lelimsgist04g.                *;
*   PROCESSING:       Merge datasets by Samp_Id, Meth_Spec_Nm, Meth_Var_Nm,           *;
*                     and Indvl_Tst_Rslt_Row, keepin all datasets. Clean up           *;
*                     the table keys (device, peak, and stage).                       *;
*   OUTPUT:           Dataset: lelimsgist05e                                          *;
***************************************************************************************;
%MACRO	TrnITR;
DATA _NULL_;SET lelimsgist04a;
IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;	
RUN;
DATA _NULL_;SET lelimsgist04b;
IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;	
RUN;
DATA _NULL_;SET lelimsgist04c;
IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;	
RUN;
DATA _NULL_;SET lelimsgist04h;
IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;	
RUN;
DATA _NULL_;SET lelimsgist04i;
IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;	
RUN;
DATA _NULL_;SET lelimsgist04g;
IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;	
RUN;
	%MACRO ForEach(s);
		%LOCAL i f;

		%LET i=1;

		%DO %UNTIL (%QSCAN(&s, &i)=  );
			%LET f=%QSCAN(&s, &i); 
			 /*******************************************************************************/
			 /*****  V15 - For VESSEL make sure we're not sorting on the numeric value  *****/
			 /*****        or dropping indres records with blank meth_peak_nm           *****/
			 /*******************************************************************************/
			DATA &f; SET &f;
				IF INDEX(Meth_Spec_Nm,'ATM02016DISSHPLC') OR INDEX(Meth_Spec_Nm,'AM0957DISSUV') OR 
				INDEX(Meth_Spec_Nm,'AM0857DISSUV') OR INDEX(Meth_Spec_Nm,'AM0900DRUGRELEASEUV') OR
				INDEX(Meth_Spec_Nm,'AM0888DRUGRELEASEUV') OR INDEX(Meth_Spec_Nm,'AM0705759DRUGRELEASEHPLC') OR
				INDEX(Meth_Spec_Nm,'AM0840DRUGRELEASEUV') OR INDEX(Meth_Spec_Nm,'ATM02056DISSUV') OR
				INDEX(Meth_Spec_Nm,'AM0656AM0613DISSHPLC') OR INDEX(Meth_Spec_Nm,'AM0794DISSHPLC') OR
				INDEX(Meth_Spec_Nm,'AM0854DISSHPLC') OR INDEX(Meth_Spec_Nm,'AM0648DISSHPLC') OR
				INDEX(Meth_Spec_Nm,'GENUSPDISS') OR INDEX(Meth_Spec_Nm,'AM0664DISSHPLC') OR
				INDEX(Meth_Spec_Nm,'AM0632AM0635DISSHPLC') OR INDEX(Meth_Spec_Nm,'AM0755DISSHPLC') OR
				INDEX(Meth_Spec_Nm,'AM0883DISSHPLC') OR INDEX(Meth_Spec_Nm,'AM0653DISSHPLC') OR
				INDEX(Meth_Spec_Nm,'AM0736DISSUV') OR INDEX(Meth_Spec_Nm,'MEANSPRAYPATTERN') OR 
				INDEX(Meth_Spec_Nm,'AM0608DISSHPLC')
				THEN ColumnIx=1;
			RUN;
		%LET i=%EVAL(&i+1);
		%END;
	%MEND ForEach;
	%ForEach(lelimsgist04a lelimsgist04c lelimsgist04h lelimsgist04i lelimsgist04g)

	DATA lelimsgist05e;
		MERGE	lelimsgist04a						/* Meth_Peak_Nm			*/
			lelimsgist04b						/* Indvl_Meth_Stage_Nm		*/
			lelimsgist04c						/* Indvl_Tst_Rslt_Nm		*/
			lelimsgist04h						/* Indvl_Tst_Rslt_Val_Char	*/
			lelimsgist04i						/* Indvl_Tst_Rslt_Prep  	*/
			lelimsgist04g;						/* Indvl_Tst_Rslt_Val_Num	*/
		BY	&IRKey ColumnIx;
                IF Indvl_Tst_Rslt_Val_Num=. AND Indvl_Tst_Rslt_Val_Char='' THEN DELETE;
	RUN;

DATA _NULL_;SET lelimsgist05e;
IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;	
RUN;
DATA _NULL_;SET lelimsgist04d;
IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;	
RUN;
DATA _NULL_;SET lelimsgist04d2;
IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;	
RUN;
DATA _NULL_;SET lelimsgist04e;
IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;	
RUN;
DATA _NULL_;SET lelimsgist04e2;
IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;	
RUN;
DATA _NULL_;SET lelimsgist04f;
IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;	
RUN;

	DATA lelimsgist05e;
		MERGE	lelimsgist05e
			lelimsgist04d						/* Indvl_Tst_Rslt_Device	*/
			lelimsgist04e						/* Indvl_Tst_Rslt_Location	*/
			lelimsgist04f;						/* Indvl_Tst_Rslt_Time_Pt	*/
		BY	&IRKey;
		IF		Meth_Peak_Nm = ''
				THEN DELETE;					/* CI 13th Row			*/
		IF		Indvl_Meth_Stage_Nm = '' 
				THEN Indvl_Meth_Stage_Nm = 'NONE';		/* RESULTSTABLE			*/
		Indvl_Tst_Rslt_Row = SUM((Indvl_Tst_Rslt_Row*100), ColumnIx);
                IF Indvl_Tst_Rslt_Device='' THEN DELETE;
		DROP	ColumnIx;
	RUN;

	********************************************************************************;
	*** Added V23- Added MERGE to merge # of devices to rest of dataset          ***;
	*** Added V25- Added MERGE to merge BOU/EOU Location to rest of dataset      ***;
	********************************************************************************;
	PROC SQL;CREATE INDEX SORTED4 ON lelimsgist05e (Samp_Id, Meth_Spec_Nm, Meth_Var_Nm, Res_Loop, Res_Repeat);QUIT;
	PROC SQL;CREATE INDEX SORTED5 ON lelimsgist04d2 (Samp_Id, Meth_Spec_Nm, Meth_Var_Nm, Res_Loop, Res_Repeat);QUIT;
	PROC SORT DATA=lelimsgist04e2 NODUPKEY;BY Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat;RUN;
	DATA lelimsgist05e;
		MERGE	lelimsgist05e(IN=IN1)
			lelimsgist04d2(IN=IN2)						/* Indvl_Tst_Rslt_NumDevices	*/
			;
		BY	Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat;
		IF IN1;
	RUN;
	DATA lelimsgist05e lelimsgist05e2;SET lelimsgist05e;	
        	/* V31:  added ATM02003 for Ventolin */
		IF ( INDEX(METH_SPEC_NM,'ATM02065')>0 OR INDEX(METH_SPEC_NM,'ATM02003')>0 ) THEN OUTPUT lelimsgist05e2;ELSE OUTPUT lelimsgist05e;
	RUN;
	DATA lelimsgist05e2;
		MERGE	lelimsgist05e2(IN=IN1 DROP=Indvl_Tst_Rslt_Location)
			lelimsgist04e2(IN=IN3)						/* Indvl_Tst_Rslt_Location	*/
			;
		BY	Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat;
		IF IN1;
	RUN;
	DATA lelimsgist05e;SET lelimsgist05e lelimsgist05e2;RUN;
	
	PROC SQL;CREATE INDEX SORTED7 ON lelimsgist05e (Samp_Id, Res_Id, Meth_Spec_Nm, Meth_Peak_Nm, Indvl_Tst_Rslt_Row, Indvl_Meth_Stage_Nm);QUIT;
	DATA lelimsgist05e;RETAIN DEVICE 0;SET lelimsgist05e;
		BY Samp_Id Res_Id Meth_Spec_Nm Meth_Peak_Nm Indvl_Tst_Rslt_Row Indvl_Meth_Stage_Nm;
		IF INDEX(Meth_Spec_Nm,'CASCADE')>0 THEN DO;
			IF FIRST.Meth_Peak_Nm THEN Device=0;
			/* V24 - Added PRESEP-0 */
			IF Indvl_Meth_Stage_Nm IN ('TP0','THROAT','PRESEP-0') THEN Device+1;  /* avoid deleting 2nd loops */
			/* V30 - 6-F can be on both peakinfo (individual) and peakinfocalc* (summary) */
                        /* Diskus & Relenza */
                        IF Meth_Spec_Nm IN ('ADVAIRCASCADEHPLC', 'AM0908CASCADEHPLC', 'AM0908STABCASCADEHPLC', 'AM0908SUMMARYCASCADEHPLC', 
                                            'ATM02050CASCADEHPLC', 'ATM02050SUMMARYCASCADEHPLC', 'ATM02104CASCADEHPLC') THEN
				IF Indvl_Meth_Stage_Nm IN ('6-F') AND Indvl_Tst_Rslt_Device='NONE' THEN DELETE;

			/* Adv HFA */
                        IF Meth_Spec_Nm in ('ATM02065FULLCASCADEHPLC') THEN
				IF Indvl_Meth_Stage_Nm IN ('6-F','THROAT') AND Indvl_Tst_Rslt_Device='NONE' THEN DELETE;
                        /* V31 - Added for Ventolin which has THROAT in both PEAKINFOCALCSUMS and PEAKINFO */
                        IF Meth_Spec_Nm in ('ATM02003FULLCASCADEHPLC') THEN
				IF Indvl_Meth_Stage_Nm IN ('THROAT') AND Indvl_Tst_Rslt_Device='NONE' THEN DELETE;

			IF Indvl_Tst_Rslt_Device='NONE' THEN Indvl_Tst_Rslt_Device=TRIM(LEFT(' '||Device));
		END;
	RUN;


	**************************************************************************************************;
	*****  V22 - Renumber device from LIMS 1,2,3,4,1,2,3,4,2,3,4,5,6,7,8,5,6,7,8,6,7,8,9,10      *****;
	*****        (mfg) pattern to a sequence that will not force record deletion during later    *****;
	*****        NODUPKEY sorts.  The business has agreed to this renumbering scheme.            *****;
	*****  V23 - Added CASCADE to IF line to fix device numbers                                  *****;
	*****  V29 - Added Res_Loop to distinguish between BOU/EOU records without deleting          *****;
	**************************************************************************************************;
	PROC SQL;CREATE INDEX SORTEDx ON lelimsgist05e (Samp_Id, Indvl_Meth_Stage_Nm, Meth_Peak_Nm, Res_Loop);QUIT;
	DATA lelimsgist05e(DROP=i); 
		SET lelimsgist05e; 
		BY Samp_Id Indvl_Meth_Stage_Nm Meth_Peak_Nm Res_Loop;
		IF INDEX(Meth_Spec_Nm,'CASCADEHPLC')>0 OR INDEX(Meth_Spec_Nm,'CONTENTHPLC')>0 THEN DO;     
			IF FIRST.Samp_Id or FIRST.Indvl_Meth_Stage_Nm OR FIRST.Meth_Peak_Nm OR FIRST.Res_Loop THEN i=1;
			ELSE i+1;
			
			IF Indvl_Tst_Rslt_NumDevices^=. AND i > Indvl_Tst_Rslt_NumDevices THEN DELETE;				
			Indvl_Tst_Rslt_Device=LEFT(PUT(i, F4.));

		END;
	RUN;

	PROC SQL;CREATE INDEX SORTED8 ON lelimsgist05e (Samp_Id, Meth_Spec_Nm, Meth_Peak_Nm, Indvl_Tst_Rslt_Device, Indvl_Meth_Stage_Nm, Res_Loop);QUIT;
	DATA lelimsgist05e;SET lelimsgist05e(DROP=DEVICE);
		BY Samp_Id Meth_Spec_Nm Meth_Peak_Nm Indvl_Tst_Rslt_Device Indvl_Meth_Stage_Nm Res_Loop;
		******************************************************************************************;
		*** Added V18 - Added ATM02064CONTENTHPLC to avoid WT device dups                      ***;
		*** Added V20 - Added AND Indvl_Tst_Rslt_Val_Char='' to delete statement               ***;
	        *** Added V29 - Added Res_Loop to distinguish between BOU/EOU records without deleting ***;
		******************************************************************************************;	
      		IF INDEX(Meth_Spec_Nm,'CASCADE')>0 OR Meth_Spec_Nm ='ATM02064CONTENTHPLC' THEN DO;     
		IF 	Samp_Id			=	LAG(Samp_Id) 			AND
			Meth_Spec_Nm		=	LAG(Meth_Spec_Nm) 		AND
			Meth_Peak_Nm		=	LAG(Meth_Peak_Nm) 		AND
			Indvl_Tst_Rslt_Device	=	LAG(Indvl_Tst_Rslt_Device) 	AND
			Indvl_Meth_Stage_Nm 	=	LAG(Indvl_Meth_Stage_Nm) 	AND
			Res_Loop 		=	LAG(Res_Loop) 		   THEN DELETE;
			IF Indvl_Tst_Rslt_Val_Num=. AND Indvl_Tst_Rslt_Val_Char='' THEN DELETE;
			********************************************************************************;
			*****  V18 - Modify from 'VALVESTEM/ACTUATOR' so that Advair HFA Cascade   *****;
			*****        also works                                                    *****;
			********************************************************************************;
                        IF INDEX(Indvl_Meth_Stage_Nm,'ACTUATOR') THEN DELETE;
			/* V24 - Added for Relenza */
                        IF INDEX(Indvl_Meth_Stage_Nm,'DISKHALER') THEN DELETE;
		END;

		**********************************************************************************;
		*****  V18 - Added to drop imps not available in sumres (usually synthetics) *****;
		*****  V23 - Added DROP Statement to remove Indvl_Tst_Rslt_NumDevices        *****;
		**********************************************************************************;
		IF INDEX(UPCASE(Indvl_Tst_Rslt_Nm),'SYNTHETIC') OR INDEX(UPCASE(Indvl_Tst_Rslt_Nm),'UNSPECIFIED') OR INDEX(UPCASE(Indvl_Tst_Rslt_Nm),'AMPRENAVIR RELATED') OR
		   INDEX(UPCASE(Indvl_Tst_Rslt_Nm),'ONDANSETRON RELATED') OR INDEX(UPCASE(Indvl_Tst_Rslt_Nm),'ZIDOVUDINE RELATED') OR
		   INDEX(UPCASE(Indvl_Tst_Rslt_Nm),'PROCESS RELATED') OR INDEX(UPCASE(Indvl_Tst_Rslt_Nm),'ZIDOVUDINE UNSPECIFIED') OR 
                   /* V24 - Added 'GR152924X and RRT for Relenza */
		   INDEX(UPCASE(Indvl_Tst_Rslt_Nm),'ABACAVIR RELATED') OR INDEX(UPCASE(Indvl_Tst_Rslt_Nm),'BUPROPION UNSPECIFIED') OR
			Meth_Peak_Nm IN ('CYTOSINE','URACIL','GR109825X','SALICYLIC','UNKNOWN','GI138868X','GI138870X',
					'GR32066X','GR34456X','GR81349X','GI135143X','GR44671X','GR68753X','GR68763X','GR118813X',
                                        'ACTIVE','OTHER','GR152924X','RRT') THEN DELETE;
		/* Remove the PeakInfoImpurities copy of these Imps, we're using the PeakInfo one instead */
		IF (UPCASE(Indvl_Tst_Rslt_Nm) = 'BUPROPION SPECIFIED IMPURITIES') AND (Meth_Peak_Nm IN ('827U76')) THEN DELETE;
		IF (Meth_Spec_Nm = 'ATM02066IMPHPLC') AND (Meth_Peak_Nm = 'SALMETEROL') THEN DELETE;
		DROP Indvl_Tst_Rslt_NumDevices;
	RUN;

DATA _NULL_;SET lelimsgist05e;
IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;	
RUN;

%MEND	TrnITR;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: TrnTP                                                           *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Prepare lelimsgist05f for table insertion into the              *;
*                     Tst_Parm table.                                                 *;
*   INPUT:            Datasets: lelimsgist04j, lelimsgist04k, lelimsgist04l.          *;
*   PROCESSING:       Merge datasets by Samp_Id, Meth_Spec_Nm, Meth_Var_Nm,           *;
*                     and Indvl_Tst_Rslt_Row, keepin all datasets. Filter out         *;
*                     empty parms, valid parms with no associated test                *;
*                     results, and keeping only the desired test parameters.          *;
*   OUTPUT:           Dataset: lelimsgist05f                                          *;
***************************************************************************************;
%MACRO	TrnTP;
	DATA lelimsgist05f;
		MERGE	lelimsgist04k(IN=k)					/* Tst_Parm_Val_Num Tst_Parm_Val_Char 	*/
			lelimsgist04l(IN=l);					/* Indvl_Tst_Rslt_Device 	*/
		BY	&IRKey ColumnIx VarName;
		DROP	ColumnIx;
	RUN;
	PROC SORT DATA=lelimsgist05f NODUP;
		BY	&IRKey VarName;
	RUN;
	DATA lelimsgist05f;
		MERGE	lelimsgist04j(IN=j)					/* Tst_Parm_Nm			*/
			lelimsgist05f(IN=f);
		BY	&IRKey VarName;
	RUN;

	DATA lelimsgist05f;
		SET	lelimsgist05f;
		IF INDEX(Meth_Spec_Nm,'CASCADE')>0 THEN DO;
				IF	INDEX(UPCASE(Tst_Parm_Nm),'% RELATIVE HUMIDITY') 	> 0 OR
					INDEX(UPCASE(Tst_Parm_Nm),'TEMPERATURE')		> 0 OR
					INDEX(UPCASE(Tst_Parm_Nm),'CASCADE IMPACTOR #')		> 0 OR
					INDEX(UPCASE(Tst_Parm_Nm),'SHOT WT')			> 0;
		END;

		ELSE IF		Meth_Spec_Nm = 'ADVAIRMDPIBLENDASSAYHPLC' THEN DO;
				IF	INDEX(UPCASE(Tst_Parm_Nm),'DOSEWEIGHT')			> 0;
		END;

		ELSE DO;
			DELETE;
		END;

		cntr = 0;

		IF		INDEX(UPCASE(Tst_Parm_Nm),'% RELATIVE HUMIDITY') > 1 THEN DO;
				cntr = COMPRESS(SUBSTR(Tst_Parm_Nm,1,INDEX(UPCASE(Tst_Parm_Nm),'% RELATIVE HUMIDITY')-1),"- ")-1;
				Tst_Parm_Nm = SUBSTR(Tst_Parm_Nm,INDEX(UPCASE(Tst_Parm_Nm),'% RELATIVE HUMIDITY'));
		END;
		IF		INDEX(UPCASE(Tst_Parm_Nm),'TEMPERATURE') > 1 THEN DO;
				cntr = COMPRESS(SUBSTR(Tst_Parm_Nm,1,INDEX(UPCASE(Tst_Parm_Nm),'TEMPERATURE')-1),"- ")-1;
				Tst_Parm_Nm = SUBSTR(Tst_Parm_Nm,INDEX(UPCASE(Tst_Parm_Nm),'TEMPERATURE'));
		END;
		IF		INDEX(UPCASE(Tst_Parm_Nm),'CASCADE IMPACTOR #') > 1 THEN DO;
				cntr = COMPRESS(SUBSTR(Tst_Parm_Nm,1,INDEX(UPCASE(Tst_Parm_Nm),'CASCADE IMPACTOR #')-1),"- ")-1;
				Tst_Parm_Nm = SUBSTR(Tst_Parm_Nm,INDEX(UPCASE(Tst_Parm_Nm),'CASCADE IMPACTOR #'));
		END;
		IF		INDEX(UPCASE(Tst_Parm_Nm),'SHOT WT') > 1 THEN DO;
				cntr = COMPRESS(SUBSTR(Tst_Parm_Nm,1,INDEX(UPCASE(Tst_Parm_Nm),'SHOT WT')-1),"- ")-1;
				Tst_Parm_Nm = SUBSTR(Tst_Parm_Nm,INDEX(UPCASE(Tst_Parm_Nm),'SHOT WT'));
		END;

                /* Eliminate the numeric since the char is filled already */
		IF		INDEX(UPCASE(Tst_Parm_Nm),'CASCADE IMPACTOR #') > 0 THEN Tst_Parm_Val_Num = .;
                /* Eliminate the char since the numeric is filled already */
		IF		INDEX(UPCASE(Tst_Parm_Nm),'TEMPERATURE') > 0 OR
				INDEX(UPCASE(Tst_Parm_Nm),'% RELATIVE HUMIDITY') > 0 OR
				INDEX(UPCASE(Tst_Parm_Nm),'SHOT WT') > 0 THEN Tst_Parm_Val_Char = '';

		IF cntr < 0 THEN cntr = 0;

                if Indvl_Tst_Rslt_Device ^= 'NONE' then
                  Indvl_Tst_Rslt_Device = TRIM(LEFT(' ' || Indvl_Tst_Rslt_Device + (cntr * 6)));

		DROP	cntr Res_Id Indvl_Tst_Rslt_Row;
	RUN;
	
	*****************************************************************************************************************;
	*** Added V4 - Checks if Indl_Tst_Rslt_Device match by (Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat) ***; 
	***            If not, Indvl_Tst_Rslt_Device is added by 6 and the match is re-executed                       ***;
	*****************************************************************************************************************;
	PROC SORT	DATA=lelimsgist05f NOEQUALS;
		BY	Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Indvl_Tst_Rslt_Device Tst_Parm_Nm;
	RUN;
	DATA lelimsgist06e;
		SET	lelimsgist05e;
		KEEP	Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Indvl_Tst_Rslt_Device;
	RUN;
	PROC SORT	DATA=lelimsgist06e NODUP;
		BY	Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Indvl_Tst_Rslt_Device;
	RUN;
	DATA lelimsgist05f lelimsgist05fno lelimsgist06eno;
		MERGE	lelimsgist06e(IN=e)
			lelimsgist05f(IN=f);
		BY	Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Indvl_Tst_Rslt_Device;
		IF	e AND f     then output lelimsgist05f;	
		IF	e AND not f then output lelimsgist05fno;	
		IF	f AND not e then output lelimsgist06eno;	
		RENAME	VarName = Lims_Var_Nm;
	RUN;
	DATA lelimsgist06eno;SET lelimsgist06eno;
		IF Indvl_Tst_Rslt_Device NE 'NONE' THEN Indvl_Tst_Rslt_Device=Indvl_Tst_Rslt_Device + 6;
		Indvl_Tst_Rslt_Device=TRIM(LEFT(' '||Indvl_Tst_Rslt_Device));
	RUN;
	PROC SORT	DATA=lelimsgist06eno NOEQUALS;
		BY	Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Indvl_Tst_Rslt_Device;
	RUN;
	DATA lelimsgist05fno;SET lelimsgist05fno;
		Indvl_Tst_Rslt_Device=TRIM(LEFT(' '||Indvl_Tst_Rslt_Device));
	PROC SORT	DATA=lelimsgist05fno NOEQUALS;
		BY	Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Indvl_Tst_Rslt_Device;
	RUN;
	DATA yeslimsgist05f;
		MERGE	lelimsgist05fno(IN=e)
			lelimsgist06eno(IN=f);
		BY	Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Indvl_Tst_Rslt_Device;
		IF	e AND f;	
		PUT	Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Indvl_Tst_Rslt_Device e f;
	RUN;
	DATA lelimsgist05f;SET lelimsgist05f yeslimsgist05f;	
		BY	Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Indvl_Tst_Rslt_Device;
	RUN;	
	****************************************************************************************************************;

	PROC SORT	DATA=lelimsgist05f NOEQUALS;
		BY	Samp_Id Meth_Spec_Nm Meth_Var_Nm Indvl_Tst_Rslt_Device Tst_Parm_Nm;
	RUN;
	DATA lelimsgist06e;
		SET	lelimsgist05e;
		KEEP	Samp_Id Meth_Spec_Nm Meth_Var_Nm Indvl_Tst_Rslt_Device;
	RUN;
	PROC SORT	DATA=lelimsgist06e NODUP;
		BY	Samp_Id Meth_Spec_Nm Meth_Var_Nm Indvl_Tst_Rslt_Device;
	RUN;
	DATA lelimsgist05f;								/* Remove Invalid Devices (i.e. n/a)*/
		MERGE	lelimsgist06e(IN=e)
			lelimsgist05f(IN=f);
		BY	Samp_Id Meth_Spec_Nm Meth_Var_Nm Indvl_Tst_Rslt_Device;
		IF	e AND f;
	RUN;

%MEND	TrnTP;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: TrnGetMaterial                                                  *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Prepare lelimsgist05b for table insertion into the Samp         *;
*                     table.                                                          *;
*   INPUT:            lelimsgist03s                                                   *;
*   PROCESSING:       Finds all the Material Numbers needed for the Genealogy.        *;
*   OUTPUT:           lelimsgist05b                                                   *;
***************************************************************************************;
%MACRO	TrnGetMaterial;
OPTIONS COMPRESS=NO;

	PROC SQL;
		CONNECT TO ORACLE(USER=&OraId ORAPW=&OraPsw BUFFSIZE=20000 READBUFF=20000 PATH="&OraPath" DBINDEX=YES);
		CREATE TABLE AMAPS_History AS SELECT * FROM CONNECTION TO ORACLE (
			SELECT DISTINCT
				AMH.AMAPS_Prod_Matl_Nbr		,
				AMH.AMAPS_Prod_Batch_Nbr	,
				AMH.AMAPS_Comp_Matl_Nbr		,
				AMH.AMAPS_Comp_Batch_Nbr	,
				AMH.AMAPS_Matl_Desc		,
				AMH.AMAPS_Matl_Mfg_Dt		,
				AMH.AMAPS_Matl_Exp_Dt		,
				AMH.AMAPS_Matl_Typ		
			FROM	AMAPS_Matl_History		AMH
			);
		DISCONNECT FROM ORACLE;
		QUIT;
		%PUT &SQLXMSG;
		%PUT &SQLXRC;
		%LET HSQLXRC = &SQLXRC;
		%LET HSQLXMSG = &SQLXMSG;
	RUN;

	%MACRO BuildBackward(InTable,OutTable,type);
		PROC SQL;
		CREATE TABLE &OutTable AS SELECT * FROM (
		SELECT	DISTINCT 			
			PMD.*	,
			LR.*	
		FROM   	&InTable		pmd,
			AMAPS_History		lr
		WHERE   pmd.Comp_Matl_Nbr 	= lr.AMAPS_Comp_Matl_Nbr 
		AND 	pmd.Comp_Batch_Nbr 	= lr.AMAPS_Comp_Batch_Nbr 		
		);
		QUIT;
		RUN;

		PROC SORT DATA=&OUTTABLE NODUPKEY;BY AMAPS_PROD_MATL_NBR AMAPS_PROD_BATCH_NBR;RUN;

		DATA &OUTTABLE;LENGTH TYPE 5;SET &OUTTABLE;
		type=&TYPE;
		RUN;
	%MEND BuildBackward;

	%MACRO BuildForward(InTable,OutTable,type);
		PROC SQL;										
		CREATE TABLE &OutTable AS SELECT * FROM (
		SELECT	DISTINCT 			
			PMD.*	,
			LR.*	
		FROM   	&InTable		pmd LEFT JOIN
			AMAPS_History		lr
		ON      pmd.Matl_Nbr 	= lr.AMAPS_Prod_Matl_Nbr 
		AND 	pmd.Batch_Nbr 	= lr.AMAPS_Prod_Batch_Nbr 
		);
		QUIT;
		RUN;

		PROC SORT DATA=&OUTTABLE NODUPKEY;BY AMAPS_COMP_MATL_NBR AMAPS_COMP_BATCH_NBR;RUN;

		DATA &OUTTABLE;LENGTH TYPE 5;SET &OUTTABLE;
			type=&TYPE;
		RUN;
	%MEND BuildForward;

	%MACRO RunThru;

		DATA select_OUTALL;RUN;

		PROC SORT DATA=lelimsgist07a NODUPKEY;BY MATL_NBR BATCH_NBR;RUN;
		DATA TEMP_LR2;SET lelimsgist07a;
			Comp_Matl_Nbr = Matl_Nbr;
			Comp_Batch_Nbr = Batch_Nbr;
			Keep Comp_Matl_Nbr Comp_Batch_Nbr Matl_Nbr Batch_Nbr; 
		RUN;
		PROC SORT DATA=TEMP_LR2 NODUPKEY;BY COMP_MATL_NBR COMP_BATCH_NBR;RUN;

		%BuildBackward(TEMP_LR2,SELECT_1,-1);
		DATA SELECT_2;SET SELECT_1;
			Comp_Batch_Nbr=AMAPS_Prod_Batch_Nbr;Comp_Matl_Nbr=AMAPS_Prod_Matl_Nbr;
			DROP AMAPS_Prod_Batch_Nbr AMAPS_Prod_Matl_Nbr ;
		RUN;
		DATA select_OUTALL;SET select_OUTALL select_1;RUN;

		%DO LOOP=2 %TO 30 %BY 2;
			%LET OUTLOOP1=%EVAL(&LOOP+1);
			%LET OUTLOOP2=%EVAL(&LOOP+2);
			%LET LoopVal =&Loop*-1;
			%LET TempLoop=%EVAL(&LOOPVAL);
			%BuildBackward(SELECT_&LOOP,SELECT_&OUTLOOP1,&TempLoop);
			DATA select_&OUTLOOP2;SET select_&OUTLOOP1;
				Comp_Batch_Nbr=AMAPS_Prod_Batch_Nbr;Comp_Matl_Nbr=AMAPS_Prod_Matl_Nbr;
				DROP AMAPS_Prod_Batch_Nbr AMAPS_Prod_Matl_Nbr ;
			RUN;
			DATA select_OUTALL;SET select_OUTALL select_&OUTLOOP1;RUN;

			%IF &LOOP > 4 %THEN %DO;
				PROC SORT DATA=select_&OUTLOOP2;BY Comp_Matl_Nbr Comp_Batch_Nbr ;RUN;
				PROC SORT DATA=select_OUTALL;   BY Comp_Matl_Nbr Comp_Batch_Nbr ;RUN;
				DATA select_&OUTLOOP2;
				MERGE select_&OUTLOOP2(IN=IN1)
					  select_OUTALL(IN=IN2);
				BY Comp_Matl_Nbr Comp_Batch_Nbr;
				IF IN1 AND NOT IN2;
				RUN;
			%END;
		%END;

		%LET templr=lelimsgist07a;
		%LET NumTimes=0;

		DATA TotalBackward;
		SET 
			%DO SETS=29 %TO 1 %BY -2;
				SELECT_&SETS
			%END;
			NOBS=NUMTIMES;
			CALL SYMPUT('NumTimes',NumTimes);
		RUN;
		
		PROC SORT DATA=TotalBackward NODUPKEY;BY Comp_Batch_Nbr Comp_Matl_Nbr;RUN;

		%IF %SUPERQ(NumTimes)>0 %THEN %LET templr=;
	
		DATA OUTALL;RUN;

		DATA TEMP_LR1;SET TotalBackward &templr;
			Matl_Nbr=Comp_Matl_Nbr;
			Batch_Nbr=Comp_Batch_Nbr;
			KEEP Batch_Nbr       Matl_Nbr ;
		RUN;
		PROC SORT DATA=TEMP_LR1 NODUPKEY;BY MATL_NBR BATCH_NBR;RUN;

		%BuildForward(TEMP_LR1,SELECT1,1);

		DATA SELECT2;SET SELECT1;
			Prod_Batch_Nbr=AMAPS_Comp_Batch_Nbr;Prod_Matl_Nbr=AMAPS_Comp_Matl_Nbr;
			DROP AMAPS_Comp_Batch_Nbr AMAPS_Comp_Matl_Nbr ;
		RUN;
			DATA selectOUTALL;SET OUTALL select1;RUN;

	%DO LOOP=2 %TO 30 %BY 2;
		%LET OUTLOOP1=%EVAL(&LOOP+1);
		%LET OUTLOOP2=%EVAL(&LOOP+2);
		%BuildForward(SELECT&LOOP,SELECT&OUTLOOP1,&LOOP);
		DATA select&OUTLOOP2;SET select&OUTLOOP1;
			Batch_Nbr=AMAPS_Comp_Batch_Nbr;Matl_Nbr=AMAPS_Comp_Matl_Nbr;
			DROP AMAPS_Comp_Batch_Nbr AMAPS_Comp_Matl_Nbr ;
		RUN;
		DATA selectOUTALL;SET selectOUTALL select&OUTLOOP1;RUN;

			%IF &LOOP > 4 %THEN %DO;
				PROC SORT DATA=select&OUTLOOP2;BY Prod_Matl_Nbr Prod_Batch_Nbr ;RUN;
				PROC SORT DATA=selectOUTALL;   BY Prod_Matl_Nbr Prod_Batch_Nbr ;RUN;
				DATA select&OUTLOOP2;
				MERGE select&OUTLOOP2(IN=IN1)
					  selectOUTALL(IN=IN2);
				BY Prod_Matl_Nbr Prod_Batch_Nbr;
				IF IN1 AND NOT IN2;
				RUN;
			%END;
	%END;

	DATA TotalForward;
	SET 
	%DO SETS=1 %TO 29 %BY 2;
		SELECT&SETS
	%END;
	;
	RUN;

	DATA lelimsgist_TOTAL1 lelimsgist_TOTAL2;SET TotalForward;RUN;

	DATA lelimsgist_TOTAL2;SET lelimsgist_TOTAL2;
		Prod_Matl_Nbr=AMAPS_Prod_Matl_Nbr;
		Prod_Batch_Nbr=AMAPS_Prod_Batch_Nbr;
		Comp_Matl_Nbr=AMAPS_Comp_Matl_Nbr;
		Comp_Batch_Nbr=AMAPS_Comp_Batch_Nbr;
		Matl_Nbr=AMAPS_Comp_Matl_Nbr;
		Batch_Nbr=AMAPS_Comp_Batch_Nbr;
	RUN;

	DATA lelimsgist_MatlList;SET lelimsgist_TOTAL1 lelimsgist_TOTAL2;KEEP MATL_NBR BATCH_NBR PROD_MATL_NBR PROD_BATCH_NBR COMP_MATL_NBR COMP_BATCH_NBR;RUN;

	PROC SORT DATA=lelimsgist_MatlList NODUPKEY;BY MATL_NBR BATCH_NBR PROD_MATL_NBR PROD_BATCH_NBR COMP_MATL_NBR COMP_BATCH_NBR;RUN;

	%MEND RunThru;

	%RunThru;

	OPTIONS COMPRESS=YES;
%MEND TrnGetMaterial;

%MACRO	MultipleSqlDel(dsn=,table=,key1=,Key2=,SortBy=);
*******************************************************************************;
*                     PROGRAM HEADER                                          *;
*-----------------------------------------------------------------------------*;
*  PROJECT NUMBER: ZEO-986025-1                                               *;
*  PROGRAM NAME: SqlDel.SAS                     SAS VERSION: 8.2              *;
*  DEVELOPED BY: Michael Hall                   DATE: 09/12/2002              *;
*  PROJECT REPRESENTATIVE: Carol Hiser                                        *;
*  PURPOSE: This program deletes records from a database table if a key       *;
*           variable exists in the database table and a designated dataset.   *;
*  SINGLE USE OR MULTIPLE USE? (SU OR MU) MU                                  *;
*  PROGRAM ASSUMPTIONS OR RESTRICTIONS: The LIMS database must be up and      *;
*			accessable for this program to function correctly.    *;
*-----------------------------------------------------------------------------*;
*  OTHER SAS PROGRAMS, MACROS OR MACRO VARIABLES USED IN THIS PROGRAM:        *;
*           SAS Programs                                                      *;
*               UpdActLg - Writes a record to the Activity Log.               *;
*           Macro Variables:                                                  *;
*               Dsn      - SAS Dataset containing the keys to delete.         *;
*               Table    - Table rom which to purge the records.              *;
*               Key      - Field to identify the records to purge.            *;
*               CondCode - Return Code of this program.                       *;
*               SqlXRc   - SAS Macro variable containing the Oracle return    *;
*                          code.                                              *;
*               SqlXMsg  - SAS Macro variable containing the Oracle return    *;
*                          message text.                                      *;
*               HSqlXRc  - Copy of SqlXRc to pass the DELETE return code      *;
*                          rather than the DISCONNECT return code.            *;
*               HSqlXMsg - Copy of SqlXMsg to pass the DELETE return code     *;
*                          rather than the DISCONNECT return code.            *;
*           Global variable passed by calling program:                        *;
*               OraId    - LINKS Database Id.                                 *;
*               OraPsw   - LINKS Database Password.                           *;
*               OraPath  - LINKS Database Server Id.                          *;
*-----------------------------------------------------------------------------*;
*  DESCRIPTION OF OUTPUT: Data purged from the designated table.              *;
*-----------------------------------------------------------------------------*;
*******************************************************************************;
*                     HISTORY OF CHANGE                                       *;
* +-----------+---------+--------------+------------------------------------+ *;
* |   DATE    | VERSION | NAME         | Description                        | *;
* +-----------+---------+--------------+------------------------------------+ *;
* |09/12/2002 |    1.0  | Michael Hall | Original                           | *;
* +-----------+---------+--------------+------------------------------------+ *;
*******************************************************************************;

*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SetUp                                                   *;
*   REQUIREMENT:      N/A                                                     *;
*   PURPOSE:          Prepare for processing.                                 *;
*   INPUT:            None.                                                   *;
*   PROCESSING:       Set initial macro variable values.                      *;
*   OUTPUT:           Macro variables lnvar and hsqlxrc.                      *;
*******************************************************************************;
	DATA _NULL_;
			CALL SYMPUT('lnvar',0);
			CALL SYMPUT('HSQLXRC',0);
	RUN;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SqlDelA                                                 *;
*   REQUIREMENT:      N/A                                                     *;
*   PURPOSE:          Obtain a list of Keys from the designated table.        *;
*   INPUT:            Macro variables: table, oraid, orapsw, orapath, key     *;
*   PROCESSING:       Use the passed parameters of oraid, orapsw and orapath  *;
*                     to connect to database.                                 *;
*	              Create sqldela data set by selecting distinct values of *;
*                     the &key variable from the &table table. Sort by key.   *;
*   OUTPUT:           SAS dataset sqldela                                     *;
*******************************************************************************;
	PROC SQL;
		CONNECT TO ORACLE(USER=&oraid ORAPW=&orapsw BUFFSIZE=5000 PATH="&orapath");
		CREATE TABLE sqldela AS SELECT * FROM CONNECTION TO ORACLE
			(SELECT DISTINCT &key1, &Key2 FROM &table);
		%PUT &SQLXRC;
		%PUT &SQLXMSG;
		%LET HSQLXRC = &SQLXRC;
		%LET HSQLXMSG = &SQLXMSG;
		DISCONNECT FROM ORACLE;
		QUIT;
	RUN;

	%IF &HSQLXRC ^= 0	%THEN %LET CondCode = 8;
	 %ELSE %LET CondCode = 0;

	PROC SORT DATA=sqldela;
		BY	&SortBy;
	RUN;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SqlDelB                                                 *;
*   REQUIREMENT:      N/A                                                     *;
*   PURPOSE:          Obtain unique list of keys from input dataset.          *;
*   INPUT:            SAS dataset &dsn, Macro variables &dsn, &key            *;
*   PROCESSING:       Sort &dsn dataset, deleting duplicate values of &key    *;
*                     variable.                                               *;
*   OUTPUT:           SAS dataset sqldelb (with one variable, &key)           *;
*******************************************************************************;
	PROC SORT DATA=&dsn(KEEP=&SortBy) OUT=sqldelb NODUPKEY;
		BY	&SortBy;
	RUN;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SqlDelC                                                 *;
*   REQUIREMENT:      N/A                                                     *;
*   PURPOSE:          Obtain a list of unique keys to delete from the table.  *;
*   INPUT:            SAS dataset sqldela, sqldelb, Macro variable &key       *;
*   PROCESSING:       Merge datasets by &key, only where observations exist   *;
*                     in both datasets.                                       *;
*   OUTPUT:           SAS dataset sqldelc                                     *;
*******************************************************************************;
	DATA sqldelc;
			MERGE 	sqldela(IN=a)
					sqldelb(IN=b);
			BY		&SortBy;
			IF		a AND b;
	RUN;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: LoadMVar                                                *;
*   REQUIREMENT:      N/A                                                     *;
*   PURPOSE:          Store the list of unique keys as macro variables.       *;
*   INPUT:            SAS dataset sqldelc, Macro variable &key                *;
*   PROCESSING:       Create a variable lnvar that increments by 1 for each   *;
*                     observation in dataset.  Create macro variable          *;
*                     keytext1, keytext2, keytext3...for every observation in *;
*                     dataset. Create macro variable lnvar that is set to the *;
*                     number of observations.                                 *;
*   OUTPUT:           Macro variables keytxt#, lnvar                          *;
*******************************************************************************;
	DATA _NULL_;
			SET		sqldelc;
			RETAIN lnvar 0;
			lnvar = lnvar + 1;
			keytxt1 = COMPRESS("'" || &key1 || "'");
			CALL SYMPUT('keytxt1'||COMPRESS(PUT(_N_,5.)),keytxt1);
			keytxt2 = COMPRESS("'" || &key2 || "'");
			CALL SYMPUT('keytxt2'||COMPRESS(PUT(_N_,5.)),keytxt2);
			CALL SYMPUT('lnvar',lnvar);
	RUN;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: Delete                                                  *;
*   REQUIREMENT:      N/A                                                     *;
*   PURPOSE:          Delete the records.                                     *;
*   INPUT:            Macro variables lnvar, oraid, orapw, orapath, keytxt#,  *;
*                     table, key                                              *;
*   PROCESSING:       Connect to oracle database according to macro variables *;
*                     oraid, orapw and orapath.  Loop from 1 to the value of  *;
*                     lnvar: Delete from &table table where &key = &keytxt#.  *;
*   OUTPUT:           Observations will be deleted from database.             *;
*******************************************************************************;

	%IF &CondCode = 0 %THEN %DO;
		%IF &lnvar > 0 %THEN %DO;
			PROC SQL;
				CONNECT TO ORACLE(USER=&oraid ORAPW=&orapsw BUFFSIZE=5000 PATH="&orapath");
				%DO i=1 %TO &lnvar;
					EXECUTE (DELETE FROM &table 
					WHERE &key1 = &&keytxt1&i AND &key2 = &&keytxt2&i) BY ORACLE;
					%IF &SQLXRC ^= 0 %THEN %DO;
						%PUT &SQLXRC;
						%PUT &SQLXMSG;
						%LET HSQLXRC = &SQLXRC;
						%LET HSQLXMSG = &SQLXMSG;
						%END;
					%END;
				DISCONNECT FROM ORACLE;
				QUIT;
			RUN;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: ErrorChk                                                *;
*   REQUIREMENT:      N/A                                                     *;
*   PURPOSE:          Set the return code.                                    *;
*   INPUT:            Macro variables HSQLXRC and HSQLXMSG.                   *;
*   PROCESSING:       Set Macro Return Code                                   *;
*   OUTPUT:           CondCode                                                *;
*******************************************************************************;

			%IF &HSQLXRC = 0 %THEN %DO;
				%IF &HSQLXMSG = '' OR &HSQLXMSG = ' ' OR &HSQLXMSG = %THEN %LET CondCode = 0;
				 %ELSE %LET CondCode = 4;
				%END;
			 %ELSE %LET CondCode = 12;
			%END;
		 %ELSE %LET CondCode = 2;
		%END;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: Notify                                                  *;
*   REQUIREMENT:      N/A                                                     *;
*   PURPOSE:          Log the results in the Activity Log.                    *;
*   INPUT:            Macro variables CondCode, lnvar, Key, Table.            *;
*   PROCESSING:       Call UpdActLg with appropriate message.                 *;
*   OUTPUT:           None.                                                   *;
*******************************************************************************;
	%IF &CondCode = 0 %THEN %DO;
			%UpdActLg(uid=SysOper,req=SqlDel,cond=Purged &lnvar &Key1 &Key2 from &Table!);
			%END;
	%IF &CondCode = 2 %THEN %DO;
			%UpdActLg(uid=SysOper,req=SqlDel,cond=No &Key1 &Key2 to Purge!);
			%END;
	%IF &CondCode > 2 %THEN %DO;
		%IF &CondCode = 8 %THEN %DO;
			%UpdActLg(uid=SysOper,req=SqlDel,cond=&Table not found. Failed with CondCode: &CondCode!);
			%END;
		 %ELSE %DO;
			%UpdActLg(uid=SysOper,req=SqlDel,cond=Failed to Purge &lnvar &Key1, &Key2 from &Table. Failed with CondCode: &CondCode!);
			%END;
		%END;
%MEND	MultipleSqlDel;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: VerData                                                         *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Verify the data is ready to load into the database              *;
*                     without any database constraint errors.                         *;
*   INPUT:            Datasets: lelimsgist05a, lelimsgist05b, lelimsgist05c,          *;
*                     lelimsgist05d, lelimsgist05e, and lelimsgist05f.                *;  
*                     Macro variable: Condcode                                        *;
*   PROCESSING:       Ensure there are no duplicate primary keys to be                *;
*                     inserted into each table. Next, ensure that every child         *;
*                     record will have a parent relationship for each table.          *;
*   OUTPUT:           &CondCode, &JobStep, &StepRC, and &ErrMsg to indicate           *;
*                     the results. If everything is ready to load, then               *;
*                     &CondCode will be zero and the others will not be               *;
*                     populated.                                                      *;
***************************************************************************************;
%MACRO	VerData;
	%LOCAL HErrMsg;
	DATA trash;
		trsh = 1;
	RUN;

	*****************************************************************************************;
	*** Checks that all ITR Samples are in TRS File so no relationship problems           ***;
	*** Removes Sample Test from TRS, ST and ITR if there is a problem                    ***;
	*****************************************************************************************;
	PROC SORT DATA=lelimsgist05e OUT=lelimsgist05ee(KEEP=Samp_Id Meth_Spec_Nm) NODUPKEY;BY Samp_Id Meth_Spec_Nm;RUN;
	PROC SORT DATA=lelimsgist05c OUT=lelimsgist05cc(KEEP=Samp_Id Meth_Spec_Nm) NODUPKEY;BY Samp_Id Meth_Spec_Nm;RUN;
	PROC SORT DATA=lelimsgist05b;BY Samp_Id;RUN;
	
	****************************;
	***  Samples to Remove   ***;
	****************************;
	DATA	lelimsgist05e1 lelimsgist05e2;
	MERGE	lelimsgist05ee(IN=IN1)
		lelimsgist05cc(IN=IN2);
	BY Samp_Id Meth_Spec_Nm;
	IF IN1 AND NOT IN2 THEN OUTPUT lelimsgist05e1;
 	IF IN2 AND NOT IN1 AND INDEX(METH_SPEC_NM,'CASCADE')>0 THEN OUTPUT lelimsgist05e2; 
	RUN;

	***** Verify Removed Samples *****;
	DATA _NULL_;SET lelimsgist05e1;PUT Samp_Id Meth_Spec_Nm;RUN;
	DATA _NULL_;SET lelimsgist05e2;PUT Samp_Id Meth_Spec_Nm;RUN;

	DATA	lelimsgist05ee;SET	lelimsgist05e1 lelimsgist05e2;RUN;
	PROC SORT DATA=lelimsgist05ee;BY Samp_Id Meth_Spec_Nm;RUN;

	****************************;
	***  TP Sample Removal   ***;
	****************************;
	DATA	lelimsgist05f;
	MERGE	lelimsgist05f(IN=IN1)
		lelimsgist05ee(IN=IN2);
	BY Samp_Id Meth_Spec_Nm;
	IF IN1 AND NOT IN2 THEN OUTPUT lelimsgist05f;
	RUN;

	****************************;
	***  ITR Sample Removal  ***;
	****************************;
	DATA	lelimsgist05e;
	MERGE	lelimsgist05e(IN=IN1)
		lelimsgist05ee(IN=IN2);
	BY Samp_Id Meth_Spec_Nm;
	IF IN1 AND NOT IN2 THEN OUTPUT lelimsgist05e;
	RUN;
	
	****************************;
	***  ST Sample Removal   ***;
	****************************;

	DATA	lelimsgist05d;
	MERGE	lelimsgist05d(IN=IN1)
		lelimsgist05ee(IN=IN2);
	BY Samp_Id Meth_Spec_Nm;
	IF IN1 AND NOT IN2 THEN OUTPUT lelimsgist05d;
	RUN;

	****************************;
	***  TRS Sample Removal  ***;
	****************************;

	DATA	lelimsgist05c;
	MERGE	lelimsgist05c(IN=IN1)
		lelimsgist05ee(IN=IN2);
	BY Samp_Id Meth_Spec_Nm;
	IF IN1 AND NOT IN2 THEN OUTPUT lelimsgist05c;
	RUN;

	****************************;
	***  Samp Sample Removal ***;
	****************************;
	/*** TAKEN OUT TO SEE IF A DIFFERENCE IS MADE 
	PROC SORT DATA=lelimsgist05c OUT=lelimsgist05co(KEEP=Samp_Id Meth_Spec_Nm) NODUPKEY;BY Samp_Id Meth_Spec_Nm;RUN;
	PROC FREQ DATA=lelimsgist05co;TABLES SAMP_ID / OUT=lelimsgist05co;RUN;

	PROC SORT DATA=lelimsgist05ee OUT=lelimsgist05ee(KEEP=Samp_Id) NODUPKEY;BY Samp_Id;RUN;
	DATA	lelimsgist05ee(KEEP=Samp_Id);
	MERGE	lelimsgist05ee(IN=IN1)
		lelimsgist05e(IN=IN2);
	BY Samp_Id;
	IF IN1 AND NOT IN2 THEN OUTPUT lelimsgist05ee;
	RUN;

	DATA	lelimsgist05b(DROP=COUNT PERCENT);
	MERGE	lelimsgist05b(IN=IN1)
		lelimsgist05ee(IN=IN2)
		lelimsgist05co(IN=IN3);
	BY Samp_Id;
	IF IN1 AND NOT IN2 THEN OUTPUT lelimsgist05b;
	IF IN1 AND IN2 AND COUNT > 1 THEN OUTPUT lelimsgist05b;
	RUN;

	DATA _NULL_;SET lelimsgist05b;
	      PUT Samp_Id Stability_Study_Nbr_Cd Stability_Study_Grp_Cd Stability_Samp_Stor_Cond Stability_Samp_Time_Point;     
	RUN;
	***/
	*********************************************************************************************************;
	%IF &CondCode = 0 %THEN %DO;						/* Check for Dups on Samp	*/
		PROC SORT DATA=lelimsgist05b NOEQUALS 
			OUT=lelimsgist06b(KEEP=Matl_Nbr Batch_Nbr Samp_Id);
			BY 	Matl_Nbr Batch_Nbr Samp_Id;
		RUN; 

		DATA lelimsgist07b;
			SET lelimsgist06b;
			BY	Matl_Nbr Batch_Nbr Samp_Id;
			IF FIRST.Samp_Id AND LAST.Samp_Id THEN DELETE;
			PUT	Matl_Nbr Batch_Nbr Samp_Id;
		RUN;
		DATA _NULL_;							/* Flag error if necessary	*/
			SET	lelimsgist07b
				trash;
			IF	_N_ = 1 THEN DO;
				IF trsh = 1 THEN DO;
					CALL SYMPUT('CondCode',0);
				END;
				ELSE DO;
				 	CALL SYMPUT('CondCode',12);
					CALL SYMPUT('JobStep','VerData (Samp NoDup)');
				 	CALL SYMPUT('StepRC',12);
					CALL SYMPUT('ErrMsg','Duplicates found in Samp');
				END;
			END;
		RUN;
	%END;
	%IF &CondCode = 0 %THEN %DO;						/* Check for Dups on TRS	*/
		PROC SORT DATA=lelimsgist05c NOEQUALS
			OUT=lelimsgist06c(KEEP=	Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm
						Summary_Meth_Stage_Nm Lab_Tst_Desc);
			BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm
					Lab_Tst_Desc;
		RUN;
		DATA lelimsgist07c;
			SET lelimsgist06c;
			BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm
					Lab_Tst_Desc;
			IF FIRST.Lab_Tst_Desc AND LAST.Lab_Tst_Desc THEN DELETE;
			PUT		Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm
					Lab_Tst_Desc;
		RUN;
		DATA _NULL_;							/* Flag error if necessary	*/
			SET	lelimsgist07c
				trash;
			IF	_N_ = 1 THEN DO;
				IF trsh = 1 THEN DO;
					CALL SYMPUT('CondCode',0);
				END;
				 ELSE DO;
				 	CALL SYMPUT('CondCode',12);
					CALL SYMPUT('JobStep','VerData (TRS NoDup)');
				 	CALL SYMPUT('StepRC',12);
					CALL SYMPUT('ErrMsg','Duplicates found in Tst_Rslt_Summary');
				END;
			END;
		RUN;
	%END;
	%IF &CondCode = 0 %THEN %DO;						/* Check for Dups on ST		*/
		PROC SORT	DATA=lelimsgist05d NOEQUALS
					OUT=lelimsgist06d(KEEP=	Samp_Id Meth_Spec_Nm Meth_Var_Nm
								Meth_Peak_Nm Summary_Meth_Stage_Nm
								Lab_Tst_Desc Indvl_Meth_Stage_Nm);
			BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm
					Lab_Tst_Desc Indvl_Meth_Stage_Nm;
		RUN;
		DATA lelimsgist07d;
			SET lelimsgist06d;
			BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm
					Lab_Tst_Desc Indvl_Meth_Stage_Nm;
			IF FIRST.Indvl_Meth_Stage_Nm AND LAST.Indvl_Meth_Stage_Nm THEN DELETE;
			PUT		Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm
					Lab_Tst_Desc Indvl_Meth_Stage_Nm;
		RUN;
		DATA _NULL_;							/* Flag error if necessary	*/
			SET	lelimsgist07d
				trash;
			IF	_N_ = 1 THEN DO;
				IF trsh = 1 THEN DO;
					CALL SYMPUT('CondCode',0);
				END;
				ELSE DO;
				 	CALL SYMPUT('CondCode',12);
					CALL SYMPUT('JobStep','VerData (ST NoDup)');
				 	CALL SYMPUT('StepRC',12);
					CALL SYMPUT('ErrMsg','Duplicates found in Stage_Translation');
				END;
			END;
		RUN;
	%END;
	%IF &CondCode = 0 %THEN %DO;						/* Check for Dups on ITR	*/

		PROC SORT	DATA=lelimsgist05e NOEQUALS
					OUT=lelimsgist06e(KEEP=	Samp_Id Meth_Spec_Nm Meth_Var_Nm
								Meth_Peak_Nm Indvl_Meth_Stage_Nm
								Res_Id Indvl_Tst_Rslt_Row
								Indvl_Tst_Rslt_Device);
			BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm
					Indvl_Meth_Stage_Nm Res_Id Indvl_Tst_Rslt_Row
					Indvl_Tst_Rslt_Device;
		RUN;
		DATA lelimsgist07e;
			SET lelimsgist06e;
			BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm
					Indvl_Meth_Stage_Nm Res_Id Indvl_Tst_Rslt_Row
					Indvl_Tst_Rslt_Device;
			IF FIRST.Indvl_Tst_Rslt_Device AND LAST.Indvl_Tst_Rslt_Device THEN DELETE;
			PUT		Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm
					Indvl_Meth_Stage_Nm Res_Id Indvl_Tst_Rslt_Row
					Indvl_Tst_Rslt_Device;
		RUN;
		DATA _NULL_;							/* Flag error if necessary	*/
			SET	lelimsgist07e
				trash;
			IF	_N_ = 1 THEN DO;
				IF trsh = 1 THEN DO;
					CALL SYMPUT('CondCode',0);
				END;
				ELSE DO;
				 	CALL SYMPUT('CondCode',12);
					CALL SYMPUT('JobStep','VerData (ITR NoDup)');
				 	CALL SYMPUT('StepRC',12);
					CALL SYMPUT('ErrMsg','Duplicates found in Indvl_Tst_Rslt');
				END;
			END;
		RUN;
	%END;
	%IF &CondCode = 0 %THEN %DO;						/* Check for Dups on TP		*/
		PROC SORT	DATA=lelimsgist05f NOEQUALS
					OUT=lelimsgist06f(KEEP=	Samp_Id Meth_Spec_Nm Meth_Var_Nm
								Res_Loop Res_Repeat Res_Replicate
								Indvl_Tst_Rslt_Device Tst_Parm_Nm);
			BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm
					Res_Loop Res_Repeat	Res_Replicate
					Indvl_Tst_Rslt_Device Tst_Parm_Nm;
		RUN;
		DATA lelimsgist07f;
			SET lelimsgist06f;
			BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Res_Replicate
					Indvl_Tst_Rslt_Device Tst_Parm_Nm;
			IF FIRST.Tst_Parm_Nm AND LAST.Tst_Parm_Nm THEN DELETE;
			PUT		Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Res_Replicate
					Indvl_Tst_Rslt_Device Tst_Parm_Nm;
		RUN;
		DATA _NULL_;							/* Flag error if necessary	*/
			SET	lelimsgist07f
				trash;
			IF	_N_ = 1 THEN DO;
				IF trsh = 1 THEN DO;
					CALL SYMPUT('CondCode',0);
				END;
				ELSE DO;
				 	CALL SYMPUT('CondCode',12);
					CALL SYMPUT('JobStep','VerData (TP NoDup)');
				 	CALL SYMPUT('StepRC',12);
					CALL SYMPUT('ErrMsg','Duplicates found in Tst_Parm');
				END;
			END;
		RUN;
	%END;
	%IF &CondCode = 0 %THEN %DO;	
		*****************************************************************************************;
		*** Sends an email if a record from the Samp Table is not found in the LINKS_Material ***;
		*****************************************************************************************;
		PROC SORT DATA=lelimsgist05a OUT=lelimsgist06a(KEEP=Matl_Nbr Batch_Nbr) NODUPKEY;
			BY		Matl_Nbr Batch_Nbr;
		RUN;

		PROC SORT DATA=lelimsgist05b OUT=lelimsgist06b(KEEP=Matl_Nbr Batch_Nbr) NODUPKEY;
			BY		Matl_Nbr Batch_Nbr;
		RUN;
		DATA	lelimsgist07a;						/*** Check for LM-Samp Relationship	***/
			MERGE	lelimsgist06a(IN=P)
				lelimsgist06b(IN=C);
			BY		Matl_Nbr Batch_Nbr;
			IF		Matl_Nbr ^= '' AND Batch_Nbr ^= '' THEN DO;
					IF P		THEN DELETE;
					PUT Matl_Nbr Batch_Nbr;
					CALL SYMPUT('LMCheck',12);
                                        CALL SYMPUT('StepRc',12);
					CALL SYMPUT('JobStep','VerData (LM-Samp)');
					CALL SYMPUT('ErrMsg','Relationship problems between LINKS_Material and Samp');
			END;
		RUN;
		%TimeCheck;
	%END;
	%IF &LMCheck = 12 %THEN %DO;						/*** Gets Genealogy from AMAPS		***/

		%TrnGetMaterial;

		%LET JobStep =;
		%LET ErrMsg  =;
		DATA	lelimsgist07a;
			MERGE	lelimsgist_MatlList(IN=P)
				lelimsgist07a(IN=C);
			BY		Matl_Nbr Batch_Nbr;
			IF		Matl_Nbr ^= '' AND Batch_Nbr ^= '' THEN DO;
					IF P		THEN DELETE;
					PUT Matl_Nbr Batch_Nbr;
					CALL SYMPUT('CondCode',12);
                                        CALL SYMPUT('StepRc',12);
					CALL SYMPUT('JobStep','VerData (LM-Samp)');
					CALL SYMPUT('ErrMsg','Relationship problems between LINKS_Material and Samp');
			END;
		RUN;

 		%IF &LMCheck = 12 %THEN %DO;
			%RdAMAPS;    			
			%IF &RunAMAPS = 1 %THEN %LdMaterial;
		%END;

		%IF &LMCheck = 12 %THEN %DO;					/*** Update LM-Samp Relationship	***/

			%LET CodeCode=0;
			%MissingMaterialBatch;			

			DATA _NULL_;							/*** Set Faillog for email		***/
				CALL SYMPUT('FailLog','LELimsGist-LM.log');
			RUN;
			FILENAME ItrLmErr "&CtlDir.LELimsGist-LM.log";
			DATA _NULL_;
				FILE	ItrLmErr;
				SET		lelimsgist07a;
				IF _N_ = 1 THEN DO;
					PUT "LM- Material #          Batch#";
				END;
				PUT "TP- "
					Matl_Nbr		$18.	"  "
					Batch_Nbr		$10.	"  ";
			RUN;

			%LET HErrMsg    = &ErrMsg;
			%LET ErrMsg     = List of LM_Material broken links;
				*** Send LM missing Email	***;

			***** sends this email if missing Material Numbers *****;
			%SendMsg(Subject=LELimsGist - Missing Material Number(s) in LINKS_Material Table); 

			%LET ErrMsg     = &HErrMsg;

			DATA _NULL_;							/* sets FailLog	*/
				CALL SYMPUT('FailLog','N');
			RUN;
		%END;
	%END;

	%IF &CondCode = 0 %THEN %DO;						/* Check for Samp - TRS Relationship*/
		PROC SORT DATA=lelimsgist05b(KEEP=Samp_Id) OUT=lelimsgist06b NODUPKEY;
			BY		Samp_Id;
		RUN;
		PROC SORT DATA=lelimsgist05c(KEEP=Samp_Id) OUT=lelimsgist06c NODUPKEY;
			BY		Samp_Id;
		RUN;
		DATA		lelimsgist07b;
			MERGE	lelimsgist06b(IN=P)
					lelimsgist06c(IN=C);
			BY		Samp_Id;
			IF		Samp_Id	^= ''	THEN DO;
				IF P			THEN DELETE;
				PUT Samp_Id;
			END;
		RUN;
		DATA _NULL_;							/* Flag error if necessary	*/
			SET	lelimsgist07b
				trash;
			IF	_N_ = 1 THEN DO;
				IF trsh = 1 THEN DO;
					CALL SYMPUT('CondCode',0);
				END;
				ELSE DO;
					 	CALL SYMPUT('CondCode',12);
						CALL SYMPUT('JobStep','VerData (Samp-TRS)');
					 	CALL SYMPUT('StepRC',12);
						CALL SYMPUT('ErrMsg','Relationship problems between Samp and Tst_Rslt_Summary');
				END;
			END;
		RUN;
	%END;
	%IF &CondCode = 0 %THEN %DO;						/* Check for TRS - ST Relationship	*/
		PROC SORT	DATA=lelimsgist05c
					OUT=lelimsgist06c(KEEP=Samp_Id Meth_Spec_Nm Meth_Var_Nm
							Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc) NODUPKEY;
			BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm
					Summary_Meth_Stage_Nm Lab_Tst_Desc;
		RUN;
		PROC SORT	DATA=lelimsgist05d
					OUT=lelimsgist06d(KEEP=Samp_Id Meth_Spec_Nm Meth_Var_Nm
							Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc) NODUPKEY;
			BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm
					Summary_Meth_Stage_Nm Lab_Tst_Desc;
		RUN;
		%LET Status4Chk=0;
		DATA	lelimsgist07c;
			MERGE	lelimsgist06c(IN=P)
					lelimsgist06d(IN=C);
			BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm
						Lab_Tst_Desc;
			IF		Samp_Id				^= ''	AND
					Meth_Spec_Nm			^= ''	AND
					Meth_Var_Nm			^= ''	AND
					Meth_Peak_Nm			^= ''	AND
					Summary_Meth_Stage_Nm		^= ''	AND
					Lab_Tst_Desc			^= ''	THEN DO;
						IF P 				THEN DELETE;
					END;
						PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm 
							Lab_Tst_Desc;
		RUN;
		DATA _NULL_;							/* Flag error if necessary		*/
			SET	lelimsgist07c
				trash;
			IF	_N_ = 1 THEN DO;
				IF trsh = 1 THEN DO;
					CALL SYMPUT('CondCode',0);
				END;
				ELSE DO;
				 	CALL SYMPUT('CondCode',12);
					CALL SYMPUT('JobStep','VerData (TRS-ST)');
				 	CALL SYMPUT('StepRC',12);
					CALL SYMPUT('ErrMsg','Relationship problems between Tst_Rslt_Summary and Stage_Translation');
				END;
			END;
		RUN;
	%END;
	%IF &CondCode = 0 %THEN %DO;						/* Check for ST - ITR Relationship	*/
		PROC SORT	DATA=lelimsgist05d
					OUT=lelimsgist06d(KEEP=Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm
						Indvl_Meth_Stage_Nm) NODUPKEY;
			BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Indvl_Meth_Stage_Nm;
		RUN;
		PROC SORT	DATA=lelimsgist05e
					OUT=lelimsgist06e(KEEP=Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm
						Indvl_Meth_Stage_Nm) NODUPKEY;
			BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Indvl_Meth_Stage_Nm;
		RUN;
DATA _NULL_;SET lelimsgist06d;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;
DATA _NULL_;SET lelimsgist06e;IF SAMP_ID IN (&sampnum) THEN PUT _ALL_;RUN;
		DATA	lelimsgist07d;
			MERGE	lelimsgist06d(IN=P)
					lelimsgist06e(IN=C);
			BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Indvl_Meth_Stage_Nm;
			IF		Samp_Id				^= ''	AND
					Meth_Spec_Nm			^= ''	AND
					Meth_Var_Nm			^= ''	AND
					Meth_Peak_Nm			^= ''	AND
					Indvl_Meth_Stage_Nm		^= ''	THEN DO;
						IF P 				THEN DELETE;
					END;					
						PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Indvl_Meth_Stage_Nm;
		RUN;
		DATA _NULL_;							/* Flag error if necessary	*/
			SET	lelimsgist07d
				trash;
			IF	_N_ = 1 THEN DO;
				IF trsh = 1 THEN DO;
					CALL SYMPUT('CondCode',0);
				END;
				ELSE DO;
				 	CALL SYMPUT('CondCode',12);
				END;
			END;
		RUN;
		********************************************************;
		*****  V19 - Added to send out email with bad data *****;
		********************************************************;
		%IF &CondCode = 12 %THEN %DO;
					DATA _NULL_;							/*** Set Faillog for email		***/
						CALL SYMPUT('FailLog','LELimsGist-LM.log');
					RUN;
					FILENAME ItrLmErr "&CtlDir.LELimsGist-LM.log";
					DATA _NULL_;
						FILE	ItrLmErr;
						SET		lelimsgist07D;
						IF _N_ = 1 THEN DO;
							PUT "LM- Sample #     Spec-Name              Var-Name            Peak-Name          Stage-Name" / ;
						END;
						PUT "TP- "
					        Samp_Id 		10.	"  "
						Meth_Spec_Nm 		$30.	"  "
						Meth_Var_Nm 		$30.	"  "
						Meth_Peak_Nm 		$30.	"  "
						Indvl_Meth_Stage_Nm	$20.	"  "	
						;
					RUN;
	
					%LET HErrMsg    = &ErrMsg;
					%LET ErrMsg     = 07d error;
	
					%SendMsg(Subject=LELimsGist - Relationship problems between Stage_Translation and Indvl_Tst_Rslt); 

					%SampleRemoval;
		%END;
	%END;
	%IF &CondCode = 0 %THEN %DO;						/* Check for ITR - TP Relationship	*/
		PROC SORT	DATA=lelimsgist05e
					OUT=lelimsgist06e(KEEP=Samp_Id Meth_Spec_Nm Meth_Var_Nm
							 Res_Loop Res_Repeat Indvl_Tst_Rslt_Device) NODUPKEY;
			BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat
					Indvl_Tst_Rslt_Device;
		RUN;
		PROC SORT	DATA=lelimsgist05f
					OUT=lelimsgist06f(KEEP=Samp_Id Meth_Spec_Nm Meth_Var_Nm
							 Res_Loop Res_Repeat Indvl_Tst_Rslt_Device) NODUPKEY;
			BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat
					Indvl_Tst_Rslt_Device;
		RUN;
		DATA	lelimsgist07e;
			MERGE	lelimsgist06e(IN=P)
					lelimsgist06f(IN=C);
			BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat
					Indvl_Tst_Rslt_Device;
			IF		Samp_Id				^= ''	AND
					Meth_Spec_Nm			^= ''	AND
					Meth_Var_Nm			^= ''	AND
					Indvl_Tst_Rslt_Device		^= ''	THEN DO;
						IF P 				THEN DELETE;
					END;
						PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat 
							Indvl_Tst_Rslt_Device;
		RUN;
		DATA _NULL_;								/*** Flag error if necessary	***/
			SET	lelimsgist07e
				trash;
			IF	_N_ = 1 THEN DO;
				IF trsh = 1 THEN DO;
					CALL SYMPUT('CondCode',0);
				END;
				ELSE DO;
					CALL SYMPUT('CondCode',12);
					CALL SYMPUT('JobStep','VerData (ITR-TP)');
				 	CALL SYMPUT('StepRC',12);
					CALL SYMPUT('ErrMsg','Relationship problems between Indvl_Tst_Rslt and Tst_Parm');
				END;
			END;
		RUN;
		%IF &CondCode = 12 %THEN %DO;						/*** ITR-TP unlink Error Handling ***/
			DATA _NULL_;							/*** Set Faillog		***/
				CALL SYMPUT('FailLog','LELimsGist-TP.log');
			RUN;
											/* Prepare for ITR-TP unlink removal*/
			PROC SORT DATA=lelimsgist07e NOEQUALS;
				BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat
						Indvl_Tst_Rslt_Device;
			RUN;
			PROC SORT	DATA=lelimsgist05f NOEQUALS;
				BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat
						Indvl_Tst_Rslt_Device;
			RUN;
			DATA lelimsgist05f;						/* Remove ITR-TP unlinked rows		*/
				MERGE	lelimsgist07e(IN=x)
						lelimsgist05f(IN=f);
				BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat
						Indvl_Tst_Rslt_Device;
				IF		x THEN DELETE;
			RUN;
											/* Prepare for ITR-TP unlink Email	*/
			DATA	lelimsgist07f;
				SET		lelimsgist07e;
				KEEP	Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat;
			RUN;
			PROC SORT NODUP;
				BY		Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat;
			RUN;
			FILENAME ItrTpErr "&CtlDir.LELimsGist-TP.log";
			DATA lelimsgist06f;
				SET		lelimssumres01a;
				KEEP	Samp_Id SampName;
			RUN;
			PROC SORT DATA=lelimsgist06f NODUP;
				BY		Samp_Id;
			RUN;
			DATA lelimsgist07v;
				MERGE	lelimsgist07f(IN=i)
						lelimsgist06f(IN=s);
				BY		Samp_Id;
				IF		i;
			RUN;
			PROC SORT DATA=lelimsgist07v NOEQUALS;
				BY		SampName Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat;
			RUN;
			DATA _NULL_;
				FILE	ItrTpErr;
				SET		lelimsgist07v;
				IF _N_ = 1 THEN DO;
					PUT "TP- SampId  Samp Name                   Spec Name                   Var Name           Loop    Repeat";
				END;
				PUT "TP- "
					Samp_Id			6.	"  "
					SampName		$25.	"  "
					Meth_Spec_Nm		$20.	"  "
					Meth_Var_Nm		$20.	"  "
					Res_Loop 		2.	"  "
					Res_Repeat 		2.	"  ";
			RUN;
			%LET HErrMsg    = &ErrMsg;
			%LET ErrMsg     = List of ITR-TP broken links;
											/* Send ITR-TP unlink Email	*/
			%SendMsg(Subject=LELimsGist - Missing Parent(s) for Parm Table); 
			%LET ErrMsg     = &HErrMsg;
			DATA _NULL_;							/* Reset CondCode & FailLog	*/
				CALL SYMPUT('CondCode',0);
				CALL SYMPUT('FailLog','N');
			RUN;
		%END;
	%END;
%MEND	VerData;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: LdData                                                          *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Control the process of loading the prepared data into           *;
*                     the LINKS Database.                                             *;
*   INPUT:            lelimsgist05a, lelimsgist05b, lelimsgist05c,                    *;
*                     lelimsgist05d, lelimsgist05e, and lelimsgist05f.                *;
*   PROCESSING:       Call LdrBld external macro to build the files needed by         *;
*                          LdrRun.                                                    *;
*                     Set the Update-In-Progress flag.                                *;
*                     Call SqlDel to purge the old data from all tables               *;
*                          except the Samp table.                                     *;
*                     Intelligently update the Samp table.                            *;
*                     Call LdrRun to load all the other files into their              *;
*                          respective table.                                          *;
*   OUTPUT:           Data stored in the LINKS Databases.                             *;
***************************************************************************************;
%MACRO	LdData;
	************************************************************************;
	*****  V28 - Added check to verify methods being written to LINKS  *****;
	************************************************************************;
	PROC SORT DATA=lelimsgist05b OUT=OUT05B(KEEP=Samp_Id) NODUPKEY;BY Samp_Id; RUN;
	PROC SORT DATA=lelimsgist05c OUT=OUT05C(KEEP=Samp_Id Meth_Spec_Nm) NODUPKEY;BY Samp_Id Meth_Spec_Nm; RUN;
	PROC SORT DATA=lelimsgist05d OUT=OUT05D(KEEP=Samp_Id Meth_Spec_Nm) NODUPKEY;BY Samp_Id Meth_Spec_Nm; RUN;
	PROC SORT DATA=lelimsgist05e OUT=OUT05E(KEEP=Samp_Id Meth_Spec_Nm) NODUPKEY;BY Samp_Id Meth_Spec_Nm; RUN;
	PROC SORT DATA=lelimsgist05f OUT=OUT05F(KEEP=Samp_Id Meth_Spec_Nm) NODUPKEY;BY Samp_Id Meth_Spec_Nm; RUN;
	***** Verify Samp Table *****;
	DATA _NULL_;SET OUT05B;PUT Samp_Id;RUN;   
	***** Verify TRS Table  *****;
	DATA _NULL_;SET OUT05C;PUT Samp_Id Meth_Spec_Nm;RUN;
	***** Verify ST Table   *****;
	DATA _NULL_;SET OUT05D;PUT Samp_Id Meth_Spec_Nm;RUN;
	***** Verify ITR Table  *****;
	DATA _NULL_;SET OUT05E;PUT Samp_Id Meth_Spec_Nm;RUN;
	***** Verify TP Table   *****;
	DATA _NULL_;SET OUT05F;PUT Samp_Id Meth_Spec_Nm;RUN;
	************************************************************************;

	DATA lelimsgist05b lelimsgist05b2;
	MERGE lelimsgist05b(IN=IN1)
	      Samp_List(IN=IN2);
	BY SAMP_ID;
	IF IN1 AND IN2     THEN OUTPUT lelimsgist05b2;
	IF IN1 AND NOT IN2 THEN OUTPUT lelimsgist05b;
	RUN;

        ***************************************************;
        *****  V15 - Adjusted to speed up processing  *****;
        ***************************************************;
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
	*-------------------------------------------------------------------------------------*;
	%LET SampFull=0;
	DATA _NULL_;SET lelimsgist05b;
		Numb=1;
		CALL SYMPUT('SampFull',Numb);
	RUN;

	%IF &CondCode = 0 AND &SampFull = 1 %THEN %DO;
		%LdrBld(dsn=lelimsgist05b,table=Samp);
		%IF &CondCode ^= 0 %THEN %DO;
			DATA _NULL_;
				StepRc = &CondCode;
				CALL SYMPUT('JobStep','LdData (LdrBld-Samp)');
				CALL SYMPUT('StepRc',StepRc);
				IF StepRc = 4 THEN CALL SYMPUT('ErrMsg','Empty dataset for Samp');
				 ELSE CALL SYMPUT('ErrMsg','Loader Build problems with Samp');
			RUN;
		%END;
	%END;
	%IF &CondCode = 0 %THEN %DO;
		%LdrBld(dsn=lelimsgist05c,table=Tst_Rslt_Summary);
		%IF &CondCode ^= 0 %THEN %DO;
			DATA _NULL_;
				StepRc = &CondCode;
				CALL SYMPUT('JobStep','LdData (LdrBld-TRS)');
				CALL SYMPUT('StepRc',StepRc);
				IF StepRc = 4 THEN CALL SYMPUT('ErrMsg','Empty dataset for Tst_Rslt_Summary');
				 ELSE CALL SYMPUT('ErrMsg','Loader Build problems with Tst_Rslt_Summary');
			RUN;
		%END;
	%END;
	%IF &CondCode = 0 %THEN %DO;
		%LdrBld(dsn=lelimsgist05d,table=Stage_Translation);
		%IF &CondCode ^= 0 %THEN %DO;
			DATA _NULL_;
				StepRc = &CondCode;
				CALL SYMPUT('JobStep','LdData (LdrBld-ST)');
				CALL SYMPUT('StepRc',StepRc);
				IF StepRc = 4 THEN CALL SYMPUT('ErrMsg','Empty dataset for Stage_Translation');
				 ELSE CALL SYMPUT('ErrMsg','Loader Build problems with Stage_Translation');
			RUN;
		%END;
	%END;
	%IF &CondCode = 0 %THEN %DO;
		%LdrBld(dsn=lelimsgist05e,table=Indvl_Tst_Rslt);
		%IF &CondCode ^= 0 %THEN %DO;
			DATA _NULL_;
				StepRc = &CondCode;
				CALL SYMPUT('JobStep','LdData (LdrBld-ITR)');
				CALL SYMPUT('StepRc',StepRc);
				IF StepRc = 4 THEN CALL SYMPUT('ErrMsg','Empty dataset for Indvl_Tst_Rslt');
				 ELSE CALL SYMPUT('ErrMsg','Loader Build problems with Indvl_Tst_Rslt');
			RUN;
		%END;
	%END;

	%IF &CondCode = 0 %THEN %DO;
		%LdrBld(dsn=lelimsgist05f,table=Tst_Parm);
					** Note: CC:4 is returned on empty input dataset.	**;
					** This is acceptable for the TP table only.		**;
		%IF &CondCode > 4 %THEN %DO;
			DATA _NULL_;
				StepRc = &CondCode;
				CALL SYMPUT('JobStep','LdData (LdrBld-TP)');
				CALL SYMPUT('StepRc',StepRc);
				CALL SYMPUT('ErrMsg','Loader Build problems with Tst_Parm');
			RUN;
		%END;
		%ELSE %IF &CondCode = 4 %THEN %DO;
			%LET Tst_Parm_Flag = Y;
			%LET CondCode = 0;
		%END;
		%ELSE %LET CondCode = 0;
	%END;

	%IF &CondCode = 0 %THEN %DO;
		OPTIONS NOMLOGIC;
		DATA _NULL_;							*** Create DB-update-in-progress flag ***;
			FILE "&CtlDir.CkRptFlg.txt";
			PUT		@1 'x';
		RUN;
		*** NOTE: Use dsn=lelimsgist05b to ensure complete cleanup of database ***;
		PROC SORT DATA=lelimsgist05c OUT=lelimsgist05cc(KEEP=Samp_Id Meth_Spec_Nm) NODUPKEY;BY Samp_Id Meth_Spec_Nm;RUN;

		%IF &CondCode < 4 %THEN %MultipleSqlDel(dsn=lelimsgist05cc,table=Tst_Parm,         key1=Samp_Id,key2=Meth_Spec_Nm,SortBy=Samp_Id Meth_Spec_Nm);
		%IF &CondCode < 4 %THEN %MultipleSqlDel(dsn=lelimsgist05cc,table=Indvl_Tst_Rslt,   key1=Samp_Id,key2=Meth_Spec_Nm,SortBy=Samp_Id Meth_Spec_Nm);
		%IF &CondCode < 4 %THEN %MultipleSqlDel(dsn=lelimsgist05cc,table=Stage_Translation,key1=Samp_Id,key2=Meth_Spec_Nm,SortBy=Samp_Id Meth_Spec_Nm);
		%IF &CondCode < 4 %THEN %MultipleSqlDel(dsn=lelimsgist05cc,table=Tst_Rslt_Summary, key1=Samp_Id,key2=Meth_Spec_Nm,SortBy=Samp_Id Meth_Spec_Nm);
		%IF &CondCode < 4 %THEN %DO;
			%LET CondCode = 0;
		%END;
		%ELSE %DO;
			DATA _NULL_;
				StepRc = &CondCode;
				ErrMsg = "&HSQLXMSG";
				CALL SYMPUT('JobStep','LdData (SqlDel)');
				CALL SYMPUT('StepRc',StepRc);
				CALL SYMPUT('ErrMsg',ErrMsg);
			RUN;
		%END;
		OPTIONS MLOGIC;
	%END;

	%IF &CondCode = 0 AND &SampFull = 1 %THEN %DO;					*** Insert lower tables	***;
		%LdrRun(dsn=lelimsgist05b,uid=SysOper,req=LELimsGist);
		%IF &CondCode ^= 0 %THEN %DO;						*** lelimsgist05b failed       ***;
			DATA _NULL_;
				StepRc = &CondCode;
				CALL SYMPUT('JobStep','LdData (LdrRun-Samp)');
				CALL SYMPUT('StepRc',StepRc);
				CALL SYMPUT('FailLog','lelimsgist05b.log');
				CALL SYMPUT('ErrMsg','Loader Run problems with Samp');
			RUN;
		%END;
	%END;
	%IF &CondCode = 0 %THEN %DO;
		%LdrRun(dsn=lelimsgist05c,uid=SysOper,req=LELimsGist);
		%IF &CondCode ^= 0 %THEN %DO;						*** lelimsgist05c failed	***;
			DATA _NULL_;
				StepRc = &CondCode;
				CALL SYMPUT('JobStep','LdData (LdrRun-TRS)');
				CALL SYMPUT('StepRc',StepRc);
				CALL SYMPUT('FailLog','lelimsgist05c.log');
				CALL SYMPUT('ErrMsg','Loader Run problems with Tst_Rslt_Summary');
			RUN;
		%END;
	%END;
	%IF &CondCode = 0 %THEN %DO;
		%LdrRun(dsn=lelimsgist05d,uid=SysOper,req=LELimsGist);
		%IF &CondCode ^= 0 %THEN %DO;						*** lelimsgist05d failed  	***;
			DATA _NULL_;
				StepRc = &CondCode;
				CALL SYMPUT('JobStep','LdData (LdrRun-ST)');
				CALL SYMPUT('StepRc',StepRc);
				CALL SYMPUT('FailLog','lelimsgist05d.log');
				CALL SYMPUT('ErrMsg','Loader Run problems with Stage_Translation');
			RUN;
		%END;
	%END;
	%IF &CondCode = 0 %THEN %DO;
		%LdrRun(dsn=lelimsgist05e,uid=SysOper,req=LELimsGist);
		%IF &CondCode ^= 0 %THEN %DO;						*** lelimsgist05e failed	***;
			DATA _NULL_;
				StepRc = &CondCode;
				CALL SYMPUT('JobStep','LdData (LdrRun-ITR)');
				CALL SYMPUT('StepRc',StepRc);
				CALL SYMPUT('FailLog','lelimsgist05e.log');
				CALL SYMPUT('ErrMsg','Loader Run problems with Indvl_Tst_Rslt');
			RUN;
		%END;
	%END;
	%IF &CondCode = 0 AND &Tst_Parm_Flag = N %THEN %DO;
		%LdrRun(dsn=lelimsgist05f,uid=SysOper,req=LELimsGist);
		%IF &CondCode > 4 %THEN %DO;						*** lelimsgist05f faile   	***;
			DATA _NULL_;
				StepRc = &CondCode;
				CALL SYMPUT('JobStep','LdData (LdrRun-TP)');
				CALL SYMPUT('StepRc',StepRc);
				CALL SYMPUT('FailLog','lelimsgist05f.log');
				CALL SYMPUT('ErrMsg','Loader Run problems with Tst_Parm');
			RUN;
		%END;
		%ELSE %LET CondCode = 0;
	%END;

%MEND	LdData;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: RdAMAPS                                                         *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          If LINKS_Material doesn't contain a Material Number found in    *;
*                     LIMS, search the AMAPS_MATL_HISTORY table.                      *;
*   INPUT:            lelimsgist_MatlList                                             *;
*   PROCESSING:       Read dataset, create AMAPS file for checking.                   *;
*   OUTPUT:           Load LINKS_Material/Genealogy Tables                            *;
***************************************************************************************;
%MACRO	RdAMAPS;

	%LET RunAMAPS=0;	
	%LET Ld_LMTable=0;	
	%LET Ld_LMGTable=0;	

	DATA _NULL_;SET lelimsgist_MatlList;	CALL SYMPUT('RunAMAPS',1); RUN;
	
	%IF &RunAMAPS = 1 %THEN %DO;	

		PROC SQL;
		CREATE TABLE lelimsgist_OUTLM AS SELECT * FROM (
			SELECT DISTINCT
				AMH.AMAPS_Prod_Matl_Nbr			,
				AMH.AMAPS_Prod_Batch_Nbr		,
				AMH.AMAPS_Comp_Matl_Nbr			,
				AMH.AMAPS_Comp_Batch_Nbr		,
				AMH.AMAPS_Matl_Desc			,
				AMH.AMAPS_Matl_Mfg_Dt			,
				AMH.AMAPS_Matl_Exp_Dt			,
				AMH.AMAPS_Matl_Typ
			FROM	AMAPS_History			AMH,
				lelimsgist_MatlList		ASM
			WHERE   (AMH.AMAPS_Comp_Matl_Nbr = ASM.Comp_Matl_Nbr AND AMH.AMAPS_Comp_Batch_Nbr = ASM.Comp_Batch_Nbr
			AND     AMH.AMAPS_Prod_Matl_Nbr  = ASM.Prod_Matl_Nbr AND AMH.AMAPS_Prod_Batch_Nbr = ASM.Prod_Batch_Nbr)
			OR      (AMH.AMAPS_Comp_Matl_Nbr = ASM.Prod_Matl_Nbr AND AMH.AMAPS_Comp_Batch_Nbr = ASM.Prod_Batch_Nbr
			AND     AMH.AMAPS_Prod_Matl_Nbr  = ASM.Prod_Matl_Nbr AND AMH.AMAPS_Prod_Batch_Nbr = ASM.Prod_Batch_Nbr)
		);		
		CREATE TABLE lelimsgist_OUTLMG AS SELECT * FROM (
			SELECT DISTINCT
				AMH.AMAPS_Prod_Matl_Nbr			,
				AMH.AMAPS_Prod_Batch_Nbr		,
				AMH.AMAPS_Comp_Matl_Nbr			,	
				AMH.AMAPS_Comp_Batch_Nbr		
			FROM	AMAPS_History			AMH,
				lelimsgist_MatlList		ASM
			WHERE   AMH.AMAPS_Comp_Matl_Nbr = ASM.Comp_Matl_Nbr AND AMH.AMAPS_Comp_Batch_Nbr = ASM.Comp_Batch_Nbr
			AND     AMH.AMAPS_Prod_Matl_Nbr = ASM.Prod_Matl_Nbr AND AMH.AMAPS_Prod_Batch_Nbr = ASM.Prod_Batch_Nbr
		);
		QUIT;
		%PUT &SQLXMSG;
		%PUT &SQLXRC;
		%LET HSQLXRC = &SQLXRC;
		%LET HSQLXMSG = &SQLXMSG;
		RUN;

DATA _NULL_;SET lelimsgist_OUTLM;PUT _ALL_;RUN;

		DATA lelimsgist_LM(KEEP=Matl_Nbr Batch_Nbr Matl_Desc Matl_Mfg_Dt Matl_Exp_Dt Matl_Typ);
		SET lelimsgist_OUTLM;
			Matl_Nbr	= AMAPS_Comp_Matl_Nbr;
			Batch_Nbr	= AMAPS_Comp_Batch_Nbr;
			Matl_Desc	= AMAPS_Matl_Desc;
			Matl_Mfg_Dt	= AMAPS_Matl_Mfg_Dt;
			Matl_Exp_Dt	= AMAPS_Matl_Exp_Dt;
			Matl_Typ	= AMAPS_Matl_Typ;
		RUN;
	
		DATA lelimsgist_LMG(KEEP=Prod_Matl_Nbr Prod_Batch_Nbr Comp_Matl_Nbr Comp_Batch_Nbr);
		SET lelimsgist_OUTLMG;
			Prod_Matl_Nbr	= AMAPS_Prod_Matl_Nbr;
			Prod_Batch_Nbr	= AMAPS_Prod_Batch_Nbr;
			Comp_Matl_Nbr	= AMAPS_Comp_Matl_Nbr;
			Comp_Batch_Nbr	= AMAPS_Comp_Batch_Nbr;
		RUN;

		PROC SORT DATA=lelimsgist_LM  NODUPKEY;BY Matl_Nbr Batch_Nbr; RUN;
		PROC SORT DATA=lelimsgist_LMG NODUPKEY;BY Prod_Matl_Nbr Prod_Batch_Nbr Comp_Matl_Nbr Comp_Batch_Nbr; RUN;

DATA _NULL_;SET lelimsgist_LM;PUT Matl_Nbr Batch_Nbr;RUN;

		DATA lelimsgist_LM(KEEP=Matl_Nbr Batch_Nbr Matl_Desc Matl_Mfg_Dt Matl_Exp_Dt Matl_Typ);
		MERGE lelimsgist_LM(IN=INSEL1)
		      lelimsgist05_LM(IN=INSEL2);
		BY Matl_Nbr Batch_Nbr;
		IF INSEL1 AND NOT INSEL2;
		CALL SYMPUT('Ld_LMTable',1);
		IF Matl_Typ IN ('',' ') THEN Matl_Typ='AMAP';
		RUN;

		DATA lelimsgist_LMG(KEEP=Prod_Matl_Nbr Prod_Batch_Nbr Comp_Matl_Nbr Comp_Batch_Nbr Proc_Ord);
		MERGE lelimsgist_LMG(IN=INSEL1)
		      lelimsgist05_LMG(IN=INSEL2);
		BY Prod_Matl_Nbr Prod_Batch_Nbr Comp_Matl_Nbr Comp_Batch_Nbr;
		IF INSEL1 AND NOT INSEL2;
		Proc_Ord='AMAPS';
		CALL SYMPUT('Ld_LMGTable',1);
		RUN;
		
	%END;

%MEND	RdAMAPS;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: LdMaterial                                                      *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          If LINKS_Material doesn't contain a Material Number found in    *;
*                     LIMS, search the AMAPS_MATL_HISTORY table.                      *;
*   INPUT:            lelimsgist_MatlList                                             *;
*   PROCESSING:       Read dataset, create AMAPS file for checking.                   *;
*   OUTPUT:           Load LINKS_Material/Genealogy Tables                            *;
***************************************************************************************;
%MACRO	LdMaterial;

		DATA _NULL_;
			CALL SYMPUT('JobStep','LdData (LINKS_Material)');
		RUN;

		%IF &LMCheck = 12 AND &Ld_LMTable = 1  %THEN %DEDUP(lelimsgist_LM,Y,Matl_Nbr Batch_Nbr); 
		%IF &LMCheck = 12 AND &Ld_LMTable = 1  %THEN %LdrBld(dsn=lelimsgist_LM,table=LINKS_Material);
		%IF &LMCheck = 12 AND &Ld_LMTable = 1  %THEN %LdrRun(dsn=lelimsgist_LM,uid=SysOper,req=LELimsGist);

		DATA _NULL_;
			CALL SYMPUT('JobStep','LdData (LINKS_Material_Genealogy)');
		RUN;

		%IF &LMCheck = 12 AND &Ld_LMGTable = 1 %THEN %DEDUP(lelimsgist_LMG,Y,Prod_Matl_Nbr Prod_Batch_Nbr Comp_Matl_Nbr Comp_Batch_Nbr); 
		%IF &LMCheck = 12 AND &Ld_LMGTable = 1 %THEN %LdrBld(dsn=lelimsgist_LMG,table=LINKS_Material_Genealogy);
		%IF &LMCheck = 12 AND &Ld_LMGTable = 1 %THEN %LdrRun(dsn=lelimsgist_LMG,uid=SysOper,req=LELimsGist);

%MEND	LdMaterial;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: MissingMaterialBatch                                            *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          If LINKS_Material doesn't contain a Material Number found in    *;
*                     LIMS, and its not in AMAPS, we'll insert a manual record        *;
*   INPUT:            lelimsgist07a                                                   *;
*   PROCESSING:       Read dataset, create file for checking.                         *;
*   OUTPUT:           Load LINKS_Material/Genealogy Tables                            *;
***************************************************************************************;
%MACRO	MissingMaterialBatch;

	%LET MissCnt=0;
	DATA lelimsgist07a;SET lelimsgist07a(KEEP=Matl_Nbr Batch_Nbr);
			IF Matl_Nbr='' or Batch_Nbr='' THEN DO;
				PUT _ALL_;
				DELETE;
			END;
		MissCnt=1;
		CALL SYMPUT('MissCnt',MissCnt);
	RUN;

	%IF &MissCnt = 1 %THEN %DO;

	PROC SQL;
		CREATE TABLE lelimsgist05_LMOUT AS SELECT * FROM (
			SELECT DISTINCT
				LM.Matl_Nbr			,
				LM.MAtl_Desc		
			FROM	lelimsgist05_LM			LM
		);
		CREATE TABLE lelimsgist_Manl AS SELECT * FROM (
		SELECT DISTINCT
				MAN.*  			,
				LM.Matl_Desc			
			FROM	lelimsgist07a			MAN LEFT JOIN
				lelimsgist05_LMOUT		LM
			ON     (MAN.Matl_Nbr = LM.Matl_Nbr)
		);		
		QUIT;
		%PUT &SQLXMSG;
		%PUT &SQLXRC;
		%LET HSQLXRC = &SQLXRC;
		%LET HSQLXMSG = &SQLXMSG;
		RUN;

		PROC SORT DATA=lelimsgist_Manl NODUPKEY;BY MATL_NBR BATCH_NBR;RUN;

		DATA lelimsgist_LM(KEEP=Matl_Nbr Batch_Nbr Matl_Desc Matl_Mfg_Dt Matl_Exp_Dt Matl_Typ);SET lelimsgist_Manl;
			PUT 'START - ' _ALL_;
			IF Matl_Nbr^='';
			IF Matl_Desc='' THEN Matl_Desc='Waiting for update from SAP';
			Matl_Typ='LINK';
			TODATE=TODAY();
			To_Dt=DATEPART(TODATE);To_Month=UPCASE(PUT(TODATE,monname3.));To_Day=PUT(DAY(TODATE),Z2.);To_Year=YEAR(TODATE);
			Matl_Mfg_Dt1="'"||TRIM(LEFT(To_Day))||'-'||TRIM(LEFT(To_Month))||'-'||TRIM(LEFT(To_Year))||"'";
			Matl_Mfg_Dt=TRIM(LEFT(To_Day))||'-'||TRIM(LEFT(To_Month))||'-'||TRIM(LEFT(To_Year));
	       		Matl_Exp_Dt='01-JAN-1960';
			PUT 'END - ' _ALL_;
		RUN;
	
		%DEDUP(lelimsgist_LM,Y,Matl_Nbr Batch_Nbr); 
		%LdrBld(dsn=lelimsgist_LM,table=LINKS_Material);
		%LdrRun(dsn=lelimsgist_LM,uid=SysOper,req=LELimsGist);

	%END;

%MEND	MissingMaterialBatch;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: TimeCheck                                                       *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Checks Lelimsgist.txt file to see if first run of the day.      *;
*   INPUT:            LeLimsGist.txt file on Server                                   *;
*   PROCESSING:       Checks the time of day the Lelimsgist.txt file was created.     *;
*   OUTPUT:           TimeCheck Macro Variable                                        *;
***************************************************************************************;
%MACRO TimeCheck;
		%LET TimeCheck=0;

		DATA _NULL_;
			dirrc1 = SYSTEM("DIR &CtlDir.LELimsGist.txt >&CtlDir.LELimsGist.dts");
			CALL SYMPUT('CondCode',0);
		RUN;
		DATA _NULL_;FORMAT runmth runday runhr runmin $2. runyr $4. runcyc $1. CURTIME STTIME ENDTIME DATETIME19.;
			INFILE "&CtlDir.LELimsGist.dts"
					LENGTH=flen TRUNCOVER END=eofflg DLM='=';
			LENGTH 	instr		$200;
			INPUT @1 instr $200.;
			PUT INSTR;
			IF INDEX(UPCASE(instr),"LELIMSGIST.TXT") > 0 THEN DO;
				runmth = SUBSTR(instr,1,2);
				runday = SUBSTR(instr,4,2);
				runyr  = SUBSTR(instr,7,4);
				runhr  = SUBSTR(instr,13,2);
				runmin = SUBSTR(instr,16,2);
				runcyc = SUBSTR(instr,19,1);
				IF runcyc = "p" and runhr ^= 12 THEN runhr = runhr + 12;
				curtime = DHMS(MDY(runmth,runday,runyr),runhr,runmin,0);
                                /* 2007-04 MS Scheduler 1st run is at 8am so use 7 and 9*/
				StTime  = DHMS(MDY(runmth,runday,runyr),7,0,0);
				EndTime = DHMS(MDY(runmth,runday,runyr),9,0,0);
				nxttime = DATETIME();
				nbrmin = INTCK('Minutes',curtime,DATETIME());
				IF curtime ge StTime AND curtime lt EndTime THEN CALL SYMPUT('TimeCheck',1);
				PUT _ALL_;
			END;
		RUN;
%MEND	TimeCheck;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SampleRemoval                                                   *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Removes samples caused by bad or missing data                   *;
*   INPUT:            LeLimsGist05 files                                              *;
*   PROCESSING:       Removes bad samples from output datasets to prevent stopage in  *;
*                     processing the rest of the good data                            *;
*   OUTPUT:           Updated LeLimsGist05 files                                      *;
***************************************************************************************;
***************************************************************;
*****  V19 - Added Macro SampleRemoval to skip over bad data **;
***************************************************************;
%MACRO SampleRemoval;
	DATA lelimsgist07d2(KEEP=Samp_Id Meth_Spec_Nm);SET lelimsgist07d;RUN;
		
	****************************;
	***  TP Sample Removal   ***;
	****************************;

	DATA	lelimsgist05f;
	MERGE	lelimsgist05f(IN=IN1)
		lelimsgist07d2(IN=IN2);
	BY Samp_Id Meth_Spec_Nm;
	IF IN1 AND IN2 THEN DELETE;
	IF IN1;
	RUN;

	****************************;
	***  ITR Sample Removal  ***;
	****************************;

	DATA	lelimsgist05e;
	MERGE	lelimsgist05e(IN=IN1)
		lelimsgist07d2(IN=IN2);
	BY Samp_Id Meth_Spec_Nm;
	IF IN1 AND IN2 THEN DELETE;
	IF IN1;
	RUN;
	
	****************************;
	***  ST Sample Removal   ***;
	****************************;

	DATA	lelimsgist05d;
	MERGE	lelimsgist05d(IN=IN1)
		lelimsgist07d2(IN=IN2);
	BY Samp_Id Meth_Spec_Nm;
	IF IN1 AND IN2 THEN DELETE;
	IF IN1;
	RUN;

	****************************;
	***  TRS Sample Removal  ***;
	****************************;

	DATA	lelimsgist05c;
	MERGE	lelimsgist05c(IN=IN1)
		lelimsgist07d2(IN=IN2);
	BY Samp_Id Meth_Spec_Nm;
	IF IN1 AND IN2 THEN DELETE;
	IF IN1;
	RUN;

	%LET CondCode=0;

	DATA _NULL_;
	*************************************************;
	*** Deletes Flag after email is sent          ***;
	*************************************************;
		delrc = SYSTEM("Del &CtlDir.Success*.*");
		PUT '+++ SYSTEM CHECK: Success*.* Delete' +2 delrc 6.;
	RUN;

%MEND	SampleRemoval;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: CleanUp                                                         *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Cleanup after a run.                                            *;
*                       If successful, the files are purged for subsequent            *;
*                          runs and an entry is logged in Activity Log by             *;
*                          calling UpdActLg with the success.                         *;
*                       If unsuccessful, the files are kept, an Email is sent         *;
*                          to all LINKS System Administrators and the failure         *;
*                          is recorded in the Activity Log by calling                 *;
*                          UpdActLg with the failure.                                 *;
*   INPUT:            &CondCode                                                       *;
*   PROCESSING:       If &CondCode = 0 then delete all run files.                     *;
*                     If &CondCode < 3, a previous run has not completed.             *;
*                        Thus, check for the processing time of the previous          *;
*                        run. If it is greater than 60, flag an error and             *;
*                        perform normal error processing.                             *;
*                     If  &CondCode >= 3 perform normal error processing,             *;
*                        which is:                                                    *;
*                        A) Log the failure in the Activity Log,                      *;
*                        B) Notify all LINKS System Administrators via Email          *;
*                           of the failure.                                           *;
*   OUTPUT:           Entry in the Activity Log, and possibly an Email in the         *;
*                     event of a failure.                                             *;
***************************************************************************************;
%MACRO	CleanUp;
	**********************************************************************************;
	*                       Creates Genealogy Matrix                                 *;
	*--------------------------------------------------------------------------------*;
	%IF &CondCode = 0 AND &FullRun = Y %THEN %DO; 			
		%LeGenealogy;
		DATA _NULL_;
			delrc = SYSTEM("Del &CtlDir.CkRptFlg.txt");
			PUT '+++ SYSTEM CHECK: CkRptFlg.txt Delete' +2 delrc 6.;
			IF delrc ^= 0 THEN DO;
				PUT '+++ ERROR: CkRptFlg.txt Delete failed!' +2 delrc 6.;
				CALL SYMPUT('JobStep','CleanUp (Del CkRptFlg)');
				CALL SYMPUT('StepRC',delrc);
				CALL SYMPUT('CondCode',delrc);
			END;
		RUN;
	%END;

	**********************************************************************************;
	*                       Creates MetaData Combined File                           *;
	*--------------------------------------------------------------------------------*;
	%IF &CondCode = 0 AND &FullRun = Y %THEN %DO; 			
		%LeMetaData;
	%END;

 	******************************************************************************************;
	*** Added V4 - Email Stating Program Successfully Running (1X Daily If All Goes Right) ***;
	******************************************************************************************;
	%IF &CondCode = 0 %THEN %DO; 			
		%IF &TimeCheck = 1 %THEN %DO;
			DATA _NULL_;
				*************************************************;
				*** Deletes Flag at the Beginning of each day ***;
				*************************************************;
				delrc = SYSTEM("Del &CtlDir.Success*.*");
				PUT '+++ SYSTEM CHECK: Success*.* Delete' +2 delrc 6.;
			RUN;
		%END;
	%END;
	DATA _NULL_;
		dirrc2 = SYSTEM("DIR &CtlDir.SuccessFlg.txt >&CtlDir.SuccessFlg.dts");
	RUN;
	%IF &CondCode = 0 %THEN %DO; 							
		%LET Success = 2;
		DATA _NULL_;
			INFILE "&CtlDir.SuccessFlg.dts"
					LENGTH=flen TRUNCOVER END=eofflg DLM='=';
			LENGTH 	instr		$200;
			INPUT @1 instr $200.;
			PUT INSTR;
			IF INDEX(UPCASE(instr),"SUCCESSFLG.TXT") > 0 THEN DO;
				CALL SYMPUT('Success',0);
			END;
		RUN;
		%IF &Success = 2 %THEN %DO;
			DATA _NULL_;
				FILE "&CtlDir.SuccessFlg.txt";
				PUT		@1 'x';
			RUN;
		%END;
	%END;
	%IF &CondCode = 0 %THEN %DO; /* Clear DB-update-in-progress   */
		DATA _NULL_;
			delrc = SYSTEM("Del &CtlDir.CkRptFlg.txt");
			PUT '+++ SYSTEM CHECK: CkRptFlg.txt Delete' +2 delrc 6.;
			IF delrc ^= 0 THEN DO;
				PUT '+++ ERROR: CkRptFlg.txt Delete failed!' +2 delrc 6.;
				CALL SYMPUT('JobStep','CleanUp (Del CkRptFlg)');
				CALL SYMPUT('StepRC',delrc);
				CALL SYMPUT('CondCode',delrc);
			END;
		RUN;
	%END;
	%IF &CondCode = 0 %THEN %DO; 							/*** Clear work files           ***/
		DATA _NULL_;
			delrc = SYSTEM("Del &CtlDir.lelimsgist*.*");
			PUT '+++ SYSTEM CHECK: LeLimsGist*.* Delete' +2 delrc 6.;
			IF delrc ^= 0 THEN DO;
				PUT '+++ ERROR: LeLimsGist*.* Delete failed!' +2 delrc 6.;
				CALL SYMPUT('JobStep','CleanUp (Del LimsGist*.*)');
				CALL SYMPUT('StepRC',delrc);
				CALL SYMPUT('CondCode',delrc);
			END;
		RUN;
	%END;
	*************************************************************;
	*** Writes New Table Count To File if Loaded Successfully ***;
	*************************************************************;
	%IF &CondCode = 0 %THEN %DO;							
		%TrnTableCnt;
			
		DATA _NULL_;SET TableCnt;							
			Run_Date  = Today();
			NormalRun = "&NormalRun";
			FullRun   = "&FullRun";
			DebugRun  = "&DebugRun";
			SampNum   = &SampNum;
			FILE "&CtlDir.LimsGistTableCount.txt";
			PUT	@1  	TableNm  	$4.
			    	@10 	Count___ 	8. 
			    	@25 	Run_Date 	DATE9. 
			      	@35     NormalRun       $1.
			      	@36     FullRun         $1.
			        @37     DebugRun        $1.
			        @40     SampNum         8.;
		RUN;
	%END;
	****************************************************;
	*** Added V4 - Daily 1x email if successful run  ***;
	****************************************************;
	%IF &CondCode = 0 %THEN %DO;							/*** Log Successful Run    	***/
		%UpdActLg(uid=SysOper,req=LELimsGist,cond=LIMS & GIST Extraction - Successful);
		%IF &Success = 2 %THEN %DO;						/*** Daily Email that all is ok ***/
		 	%SendMsg(Subject=LELimsGist Is Completing Without Errors);
		%END;
	%END;
	%ELSE %DO;
		%IF &CondCode = 2 %THEN %DO;						/*** Job Currently Running 	***/
			DATA _NULL_;
				dirrc = SYSTEM("DIR &CtlDir.LELimsGist.txt >&CtlDir.LELimsGist.dts");				dirrc = SYSTEM("DIR &CtlDir.LELimsGist.dts");
				CALL SYMPUT('CondCode',0);
			RUN;
                        *********************************************************************;
                        *****  V15 - Adjusted for 4 digit year (Windows Server change)  *****;
                        *********************************************************************;
			DATA _NULL_;
				INFILE "&CtlDir.LELimsGist.dts"
						LENGTH=flen TRUNCOVER END=eofflg DLM='=';
				LENGTH 	instr		$200;
				INPUT @1 instr $200.;
				IF INDEX(UPCASE(instr),"LELIMSGIST.TXT") > 0 THEN DO;
					runmth = SUBSTR(instr,1,2);
					runday = SUBSTR(instr,4,2);
					runyr  = SUBSTR(instr,7,4);
					runhr  = SUBSTR(instr,13,2);
					runmin = SUBSTR(instr,16,2);
					runcyc = SUBSTR(instr,19,1);
					*********************************************************************************;
					*** Modified V8 - Added ^= 12 To Line Below To Fix Military Time For 12:00pm  ***;
					*********************************************************************************;
					IF runcyc = "p" AND runhr ^= 12 THEN runhr = runhr + 12;
					curtime = DHMS(MDY(runmth,runday,runyr),runhr,runmin,0);
					nxttime = DATETIME();
					nbrmin = INTCK('Minutes',curtime,DATETIME());
				END;
				IF nbrmin > 60 THEN DO;
					JobStep = 'Excessive RunTime (' || PUT(nbrmin,4.) || ' Minutes)';
					CALL SYMPUT('JobStep','Excessive RunTime');
					CALL SYMPUT('StepRC',12);
					CALL SYMPUT('CondCode',12);
				END;

			RUN;
			DATA _NULL_;							/* Delete time running file */
				delrc = SYSTEM("Del &CtlDir.LELimsGist.dts");
				delrc = SYSTEM("Del &CtlDir.LELimsGist.txt");
			RUN;
			%IF &CondCode = 0 %THEN %DO;					/* Job Currently Running    */
				%UpdActLg(uid=SysOper,req=LELimsGist,cond=LIMS & GIST Currently Running!);
			%END;
		%END;
	%END;

	%IF &CondCode ^= 0 %THEN %DO;							/* Job Failed!              */
		LIBNAME OUT1 "&CtlDir";

		DATA _NULL_;
			delrc = SYSTEM("Del &CtlDir.Success*.*");
			PUT '+++ SYSTEM CHECK: Success*.* Delete' +2 delrc 6.;
			IF delrc ^= 0 THEN DO;
				PUT '+++ ERROR: Success*.* Delete failed!' +2 delrc 6.;
			END;
		RUN;

		**********************************************************;
		*****  V15 - Added to debug product name collisions  *****;
		**********************************************************;
		%IF "&FailLog" = "LELimsGistProduct.log" %THEN %DO;
			/* Build email body */
			PROC SORT data=errorProduct NODUPKEY; BY errorProd_Nm ProductNm svc; RUN;
			DATA _NULL_;
				SET errorProduct;
				FILE "&CtlDir.LELimsGistProduct.log"; 
				PUT 'TP- ' errorProd_Nm= ProductNm= svc=; 
				FILE LOG;
			RUN;
                %END;

	 	%SendMsg(Subject=LELimsGist Failed in Step &jobstep : &steprc);
		%UpdActLg(uid=SysOper,req=LELimsGist,cond=LIMS & GIST Extraction - Failed! &JobStep);

		DATA _NULL_;					/* Delete currently running flag */
			delrc = SYSTEM("Del &CtlDir.LELimsGist.txt");
		RUN;

		******************************************************************;
		*** Added V4 - Error Handling Messages                         ***;
		******************************************************************;
		*** 1- Data Files Written To Server For Error Tracing Purposes ***;
		***    (Files will be deleted on next completed nonerror run)  ***;
		******************************************************************;

		%IF "&NormalRun" = "Y" %THEN %DO;
			DATA OUT1.LeLimsGist_SumRes01a;   SET LeLimsSumRes01a;RUN;
			DATA OUT1.LeLimsGist_IndRes01a;   SET LeLimsIndRes01a;RUN; 
			DATA OUT1.LeLimsGist_01a;         SET LeGist01a;      RUN; 

		******************************************************************;
		*** 2- Data Files Written To Server To Check For New Specs     ***;
		***    (Files will be deleted on next completed nonerror run)  ***;
		******************************************************************;

			DATA OUT1.LeLimsGist_SumResX;     SET lelimsgist03X;  RUN;	
			DATA OUT1.LeLimsGist_IndResX;     SET lelimsgist04X;  RUN;	

		%END;
		******************************************************************;
		*** 3- Error Records Written To Log For Error Tracing Purposes ***;
		******************************************************************;

		**************************************************;
		*** Duplicates Found Error Section             ***;
		**************************************************;
		%IF "&JobStep" = "VerData (Samp NoDup)" %THEN %DO;
			DATA _NULL_;SET lelimsgist07b;
				PUT Samp_Id;
			RUN;
		%END;
		%IF "&JobStep" = "VerData (TRS NoDup)" %THEN %DO;
			DATA _NULL_;SET lelimsgist07c;
				PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc;
			RUN;
		%END;
		%IF "&JobStep" = "VerData (ST NoDup)" %THEN %DO;
			DATA _NULL_;SET lelimsgist07d;
				PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Indvl_Meth_Stage_Nm;
			RUN;
		%END;
		%IF "&JobStep" = "VerData (ITR NoDup)" %THEN %DO;
			DATA _NULL_;SET lelimsgist07e;
				PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Indvl_Tst_Rslt_Device;
			RUN;
		%END;
		%IF "&JobStep" = "VerData (TP NoDup)" %THEN %DO;
			DATA _NULL_;SET lelimsgist07f;
				PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Res_Replicate 
				Indvl_Tst_Rslt_Device Tst_Parm_Nm;
			RUN;
		%END;
		**************************************************;
		*** Relationship Error Section                 ***;
		**************************************************;

		%IF "&JobStep" = "VerData (LM-Samp)" %THEN %DO;
			DATA _NULL_;SET lelimsgist06a;
				PUT Matl_Nbr Batch_Nbr; 
			RUN;
			DATA _NULL_;SET lelimsgist06b;
				PUT Matl_Nbr Batch_Nbr; 
			RUN;
		%END;
		%IF "&JobStep" = "VerData (Samp-TRS)" %THEN %DO;
			DATA _NULL_;SET lelimsgist06b;
				PUT Samp_Id; 
			RUN;
			DATA _NULL_;SET lelimsgist06c;
				PUT Samp_Id; 
			RUN;
		%END;
		%IF "&JobStep" = "VerData (TRS-ST)" %THEN %DO;
			DATA _NULL_;SET lelimsgist06c;
				PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc;
			RUN;
			DATA _NULL_;SET lelimsgist06d;
				PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc;
			RUN;
		%END;
		%IF "&JobStep" = "VerData (ST-ITR)" %THEN %DO;
			DATA _NULL_;SET lelimsgist06d;
				PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Indvl_Meth_Stage_Nm;
			RUN;
			DATA _NULL_;SET lelimsgist06e;
				PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Indvl_Meth_Stage_Nm;
			RUN;
		%END;
		%IF "&JobStep" = "VerData (ITR-TP)" %THEN %DO;
			DATA _NULL_;SET lelimsgist06e;
				PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Indvl_Tst_Rslt_Device;
			RUN;
			DATA _NULL_;SET lelimsgist06f;
				PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Indvl_Tst_Rslt_Device;
			RUN;
		%END;
		**************************************************;
		*** Error Loading AMAPS Data into LINKS Tables ***;
		**************************************************;

		%IF "&JobStep" = "LdData (LINKS_Material)" OR "&JobStep" = "LdData (LINKS_Material_Genealogy)" %THEN %DO;
			DATA _NULL_;SET lelimsgist_LM;
				IF _N_ LE 250 THEN PUT Matl_Nbr Batch_Nbr Matl_Desc Matl_Mfg_Dt Matl_Exp_Dt Matl_Typ;
			RUN;
			DATA _NULL_;SET lelimsgist_LMG;
				IF _N_ LE 250 THEN PUT Prod_Matl_Nbr Prod_Batch_Nbr Comp_Matl_Nbr Comp_Batch_Nbr;
			RUN;
		%END;

		****************************************************;
		*** LdrRun Errors loading data into LINKS Tables ***;
		****************************************************;

		%IF "&JobStep" = "LdData (LdrRun-Samp)" %THEN %DO;
			DATA _NULL_;SET lelimsgist05b;	
				IF _N_ LE 250 THEN PUT _ALL_;	
			RUN;
		%END;
		%IF "&JobStep" = "LdData (LdrRun-TRS)" %THEN %DO;
			DATA _NULL_;SET lelimsgist05c;
				IF _N_ LE 250 THEN PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc;
			RUN;
		%END;
		%IF "&JobStep" = "LdData (LdrRun-ST)" %THEN %DO;
			DATA _NULL_;SET lelimsgist05d;
				IF _N_ LE 250 THEN PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Indvl_Meth_Stage_Nm;
			RUN;
		%END;
		%IF "&JobStep" = "LdData (LdrRun-ITR)" %THEN %DO;
			DATA _NULL_;SET lelimsgist05e;
				IF _N_ LE 250 THEN PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Indvl_Tst_Rslt_Device;
			RUN;
		%END;
		%IF "&JobStep" = "LdData (LdrRun-TP)" %THEN %DO;
			DATA _NULL_;SET lelimsgist05f;
				IF _N_ LE 250 THEN PUT _ALL_;
			RUN;
		%END;

		*******************************************************;
		*** Undefined Errors Loading Data into LINKS Tables ***;
		*******************************************************;

		%IF 	"&JobStep" ^= "VerData (Samp NoDup)" 			AND
			"&JobStep" ^= "VerData (TRS NoDup)" 			AND
			"&JobStep" ^= "VerData (ST NoDup)" 			AND
			"&JobStep" ^= "VerData (ITR NoDup)"			AND
			"&JobStep" ^= "VerData (TP NoDup)" 			AND
			"&JobStep" ^= "VerData (LM-Samp)" 			AND
			"&JobStep" ^= "VerData (Samp-TRS)" 			AND
			"&JobStep" ^= "VerData (TRS-ST)" 			AND
			"&JobStep" ^= "VerData (ST-ITR)" 			AND
			"&JobStep" ^= "VerData (ITR-TP)" 			AND
			"&JobStep" ^= "LdData (LdrRun-Samp)" 			AND
			"&JobStep" ^= "LdData (LdrRun-TRS)" 			AND
			"&JobStep" ^= "LdData (LdrRun-ST)" 			AND
			"&JobStep" ^= "LdData (LdrRun-ITR)" 			AND
			"&JobStep" ^= "LdData (LdrRun-TP)" 			AND
			"&JobStep" ^= "LdData (LINKS_Material)" 		AND
			"&JobStep" ^= "LdData (LINKS_Material_Genealogy)" 	%THEN %DO;

			DATA _NULL_;SET lelimsgist05b;	
				IF _N_ LE 250 THEN PUT _ALL_;	
			RUN;
			DATA _NULL_;SET lelimsgist05c;	
				IF _N_ LE 250 THEN PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc;
			RUN;
			DATA _NULL_;SET lelimsgist05d;	
				IF _N_ LE 250 THEN PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Indvl_Meth_Stage_Nm;
			RUN;
			DATA _NULL_;SET lelimsgist05e;	
				IF _N_ LE 250 THEN PUT Samp_Id Meth_Spec_Nm Meth_Var_Nm Res_Loop Res_Repeat Indvl_Tst_Rslt_Device;
			RUN;
			DATA _NULL_;SET lelimsgist05f;	
				IF _N_ LE 250 THEN PUT _ALL_;	
			RUN;
		%END;
	%END;
%MEND	CleanUp;
***************************************************************************************;
*                       MODULE HEADER                                                 *;
*-------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: LELimsGist                                                      *;
*   REQUIREMENT:      N/A                                                             *;
*   PURPOSE:          Control the processing of the LELimsGist program.               *;
*   INPUT:            None.                                                           *;
*   PROCESSING:       Call each module as needed.                                     *;
*   OUTPUT:           None.                                                           *;
***************************************************************************************;
%MACRO	LELimsGist;
	*************************************************************************;
	*                       CHECK RUN STATUS                                *;
	*-----------------------------------------------------------------------*;
	DATA _NULL_;
		curdt = DATETIME();
		PUT '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
		PUT "++   " +1 curdt DATETIME19. +1 "                          ++ Begin";
		PUT '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
	RUN;
	%SetUp;

	%IF &CondCode = 0 %THEN %CkRptFlg;
	DATA _NULL_;
		curdt = DATETIME();
		PUT '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
		PUT "++   " +1 curdt DATETIME19. +1 "                          ++ Setup";
		PUT '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
	RUN;
	%IF &CondCode = 0 %THEN %DO;
		%TrnTableChk;
		%TrnTableCnt;
	%END;

	DATA _NULL_;
		date1=&RunDate-1;
		startdate="'"||trim(left(put(date1,DATE9.)))||"'";
		CALL SYMPUT('startdate',startdate);
	RUN;

	*************************************************************************;
	*                       EXTRACT DATA                                    *;
	*-----------------------------------------------------------------------*;
	%IF &CondCode = 0 AND &NormalRun = Y %THEN %DO;
		*************************************************************************;
		*  V21 - Gather samples to be passed to Indres & Sumres                 *;
		*-----------------------------------------------------------------------*;
		%GLOBAL NumLoops;
		%DO I=1 %TO 50;
			%GLOBAL Sample_List&i;
		%END;
		
		%LET datefltr =%STR( (TO_CHAR(R.ResEntTs,'DDMONYYYY') >= TO_DATE(&startdate,'DDMONYYYY') ));
		%LET datefltr2=%STR( (TO_CHAR(SS.EntryTs,'DDMONYYYY') >= TO_DATE(&startdate,'DDMONYYYY') ));
		%LET datefltr3=%STR( (TO_CHAR(PLS.EntryTs,'DDMONYYYY') >= TO_DATE(&startdate,'DDMONYYYY') ));
		
		PROC SQL;
			CONNECT TO ORACLE(USER=&limsid ORAPW=&limspsw BUFFSIZE=25000 READBUFF=25000 PATH="&limspath" dbindex=yes);
			CREATE TABLE lelimsresults AS SELECT * FROM CONNECTION TO ORACLE (
				SELECT DISTINCT
						R.SampId				AS Samp_Id
				FROM	Result					R
				WHERE 	&datefltr
			);
			CREATE TABLE lelimssampstat AS SELECT * FROM CONNECTION TO ORACLE (
				SELECT DISTINCT
						SS.SampId				AS Samp_Id
				FROM	SampleStat				SS
				WHERE 	&datefltr2
			);
			CREATE TABLE lelimsprocstat AS SELECT * FROM CONNECTION TO ORACLE (
				SELECT DISTINCT
						PLS.SampId				AS Samp_Id
				FROM	ProcLoopStat				PLS
				WHERE 	&datefltr3
			);
			%PUT &SQLXRC;
			%PUT &SQLXMSG;
			%LET HSQLXRC  = &SQLXRC;
			%LET HSQLXMSG = &SQLXMSG;
			DISCONNECT FROM ORACLE;
			QUIT;
		RUN;
		
		DATA TOTALSAMP;SET lelimsresults lelimssampstat lelimsprocstat;RUN;
		PROC SORT DATA=TOTALSAMP OUT=TOTSAMPOUT NODUPKEY;BY SAMP_ID;RUN;
		
		DATA _NULL_;retain list;retain cnt LOOP;format list: $9500.;SET TOTSAMPOUT END=eofflg;
			IF _N_=1 OR CNT=501 THEN DO;
				CNT=0;
				MAXLOOP=500;
				LOOP+1;
			END;
			CNT+1;
			IF cnt=1 THEN DO;list = trim(samp_Id);END;
				ELSE if samp_Id^=. THEN DO;list = trim(left(list))||','||trim(left(samp_id));END;
			IF CNT=501 or eofflg THEN DO;
				CALL SYMPUT('Sample_List'||COMPRESS(PUT(LOOP,5.)),'R.SampId IN ('||TRIM(LEFT(list))||')');
				CALL SYMPUT("NumLoops", loop);
			END;
		RUN;
	%END;

	%IF &CondCode = 0 %THEN %DO;

		*************************************************************************;
		*  V21 - Changed Date Criteria to look at a different LIMS date         *;
		*        Created 2 new date filters for new queries in LeLimsSumRes     *;
		*-----------------------------------------------------------------------*;
		%LET limsfltr = %STR(AND SUBSTR(R.SampName,1,1) NOT IN ('T'));
		%IF %SUPERQ(TableFlag)=0 
			%THEN %DO;
				%LET datefltr =%STR(AND (TO_CHAR(R.ResEntTs,'DDMONYYYY') >= TO_DATE(&startdate,'DDMONYYYY') ));
				%LET datefltr2=%STR(AND (TO_CHAR(SS.EntryTs,'DDMONYYYY') >= TO_DATE(&startdate,'DDMONYYYY') ));
				%LET datefltr3=%STR(AND (TO_CHAR(PLS.EntryTs,'DDMONYYYY') >= TO_DATE(&startdate,'DDMONYYYY') ));
			%END;
			%ELSE %LET datefltr = ;

		%IF &NormalRun = Y %THEN %DO;
			%LELimsSumRes;    
		%END;
		%ELSE %DO;
			LIBNAME OUT1 "&CtlDir";
			DATA LeLimsSumRes01a;   SET OUT1.LeLimsSumRes01a; &LimitSamps ;RUN;
		%END;

		%IF &CondCode ^= 0 %THEN %DO;
			%IF "&JobStep" = "N" %THEN %DO;
				%LET jobstep = LELimsSumRes;
				%LET steprc = &CondCode;
				%LET ErrMsg = &HSqlXMsg;
			%END;
		%END;
		DATA _NULL_;
			curdt = DATETIME();
			PUT '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
			PUT "++   " +1 curdt DATETIME19. +1 "                          ++ LELimsSumRes";
			PUT '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
		RUN;
	%END;
		
	*************************************************************************;
	*  V21 - Changed Date Criteria to look at a different LIMS date         *;
	*-----------------------------------------------------------------------*;
	%IF &CondCode = 0 %THEN %DO;
		%LET limsfltr = %STR(AND SUBSTR(R.SampName,1,1) NOT IN ('T') AND VC.ColName IS NOT NULL);
		%IF %SUPERQ(TableFlag)=0 
			%THEN %LET datefltr =%STR(AND (TO_CHAR(R.ResEntTs,'DDMONYYYY') >= TO_DATE(&startdate,'DDMONYYYY') ));
			%ELSE %LET datefltr = ;

		%IF &NormalRun = Y %THEN %DO;
			%LELimsIndRes;   
		%END;
		%ELSE %DO;
			DATA LeLimsIndRes01a;   SET OUT1.LeLimsIndRes01a; &LimitSamps ;RUN;
		%END;

		%IF &CondCode ^= 0 %THEN %DO;
			%IF "&JobStep" = "N" %THEN %DO;
				%LET jobstep = LELimsIndRes;
				%LET steprc = &CondCode;
				%LET ErrMsg = &HSqlXMsg;
			%END;
		%END;
		DATA _NULL_;
			curdt = DATETIME();
			PUT '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
			PUT "++   " +1 curdt DATETIME19. +1 "                          ++ LELimsIndRes";
			PUT '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
		RUN;
	%END;
	%IF &CondCode = 0 %THEN %DO;
		%IF &NormalRun = Y %THEN %DO;
			%LEGist;
		%END;
		%ELSE %DO;
			DATA LeGist01a;   SET OUT1.LeGist01a; RUN;
		%END;
		
		%IF &CondCode ^= 0 %THEN %DO;
			%IF "&JobStep" = "N" %THEN %DO;
				%LET jobstep = LEGist;
				%LET steprc = &CondCode;
				%LET ErrMsg = &HSqlXMsg;
			%END;
		%END;
		DATA _NULL_;
			curdt = DATETIME();
			PUT '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
			PUT "++   " +1 curdt DATETIME19. +1 "                          ++ LEGist";
			PUT '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
		RUN;
	%END;
	*************************************************************************;
	*                       Translate Data                                  *;
	*-----------------------------------------------------------------------*;
	****************************************************************************;
	*****  V15 - Test CondCode before each macro call                      *****;
	****************************************************************************;
	%IF &CondCode = 0 %THEN %TrnFmts;
	%IF &CondCode = 0 %THEN %TrnGist;
	%IF &CondCode = 0 %THEN %TrnLimsS;
	%IF &CondCode = 0 %THEN %TrnLMRead;
	%IF &CondCode = 0 %THEN %TrnSamp;
	%IF &CondCode = 0 %THEN %TrnTRS;
	%IF &CondCode = 0 %THEN %TrnST;
	%IF &CondCode = 0 %THEN %TrnLimsI;
	%IF &CondCode = 0 %THEN %TrnITR;
	%IF &CondCode = 0 %THEN %TrnTP;

	DATA _NULL_;
		curdt = DATETIME();
		PUT '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
		PUT "++   " +1 curdt DATETIME19. +1 "                          ++ Translate";
		PUT '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
	RUN;

	**********************************************************************************;
	*                       Load DATA                                                *;
	*--------------------------------------------------------------------------------*;
	%IF &CondCode = 0 %THEN	%DO;
		%IF &CondCode = 0 %THEN	%VerData;
 		%IF &CondCode = 0 %THEN	%LdData;    			 

		DATA _NULL_;
			curdt = DATETIME();
			PUT '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
			PUT "++   " +1 curdt DATETIME19. +1 "                          ++ Load";
			PUT '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
		RUN;
	%END;

	**********************************************************************************;
	*                       Clean Up                                                 *;
	*--------------------------------------------------------------------------------*;
	%CleanUp;

	DATA _NULL_;
		curdt = DATETIME();
		PUT '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
		PUT "++   " +1 curdt DATETIME19. +1 "                          ++ End";
		PUT '++++++++++++++++++++++++++++++++++++++++++++++++++++++';
	RUN;

        %IF %QUOTE(&LimitSamps) ^=  %THEN %PUT WARNING: data has been restricted to a subset of available samples;

	%IF &CondCode ^= 0 %THEN	%DO;
		DATA _NULL_;
			delrc = SYSTEM("Del &CtlDir.CkRptFlg.txt");
			PUT '+++ SYSTEM CHECK: CkRptFlg.txt Delete' +2 delrc 6.;
			IF delrc ^= 0 THEN DO;
				PUT '+++ ERROR: CkRptFlg.txt Delete failed!' +2 delrc 6.;
				CALL SYMPUT('JobStep','CleanUp (Del CkRptFlg)');
				CALL SYMPUT('StepRC',delrc);
				CALL SYMPUT('CondCode',delrc);
			END;
		RUN;
		DATA _NULL_;
			ABORT RETURN 1;
		RUN;
	%END;

	*******************************************************************************;
	***  V18 - Log overflows at around 100,000 lines so minimize printing to it ***;
	*******************************************************************************;
	DATA MVARS;
		SET SASHELP.vmacro;
	RUN;
	DATA _NULL_;
		SET mvars;
		IF SCOPE = 'GLOBAL' AND NAME =: 'TVAR' THEN
	  	CALL EXECUTE('%SYMDEL '||TRIM(LEFT(NAME))||';');
	RUN;
	%PUT _USER_;
%MEND	LELimsGist;
%LELimsGist;
ENDSAS;

