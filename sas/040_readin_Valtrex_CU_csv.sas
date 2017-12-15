
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Read-in external data
 *  DESIGN COMPONENT: Read-in
 *  INPUT:            Converted worksheet from the Value Stream
 *  PROCESSING:       Parse into a temporary dataset
 *  OUTPUT:           Temporary dataset
 *******************************************************************************
 */

%macro readin_CU_FILE(prodnm);
  /* Note: No stability data exists */
  %global CURRMETH; 
  %let CURRMETH = AM0612;

  %abendIfFileNotExist(&ANALYT\&F040, LIMS PAR file);

  filename PAR "&ANALYT\&F040";

  data base_CU;
    infile PAR delimiter=',' MISSOVER LRECL=32767 DSD;

    format CU_createdate CU_testdate DATE9.;

    input CU_Description :$100.
      CU_createdate :DATE9.
      CU_Samplename :$30.
      CU_status :$30.
      CU_procedure :$100.
      CU_table :$100.
      CU_testdate :MMDDYY8.
      CU_loop :8.2
      CU_name :$30.
      CU_peak :$30.
      CU_vial_btl_avg :8.2
      CU_result_comment :$30.
      ;

    /*******************************************/
    /* Begin Business Requirement Column Input */
    /*******************************************/

    /* V4: renamed macro call parameters */
    %description(CU_Description);

    %product;

    %strength(CU_Description);

    %granulator(CU_Description);

    %study(CU_SampleName);

    %storage_condition(CU_SampleName);

    %time_point(CU_SampleName);

    %market(CU_Description);

    %mfg_batch(CU_SampleName);

    %gsk_identifier(CU_SampleName);

    %status(CU_Status);

    %test(CU_Table);

    %test_date(CU_Testdate);

    /* analyst, instrument, test_level built in %distribCUIA */

    %result(CU);

    /* Hold for next steps */
    length tbl nm $100;
    tbl = CU_Table;
    nm = CU_Name;

    drop CU_:;
  run;

  %distribCUIA(CU);  /* across real methods */

  %mapTSRtoBatch(CU, map_TSRtoBatch);  /* get mfg_batch for study eq T0* if not already filled */

  /* Reorder per BR */
  data base_CU;
    retain description product strength granulator study storage_condition
           time_point market mfg_batch gsk_identifier status test test_date 
           analyst instrument result
           ;
    set base_CU;
    if test eq '' and result eq '' then
      delete;
  run;
%mend readin_CU_FILE;
%readin_CU_FILE(&PRODUCT);
