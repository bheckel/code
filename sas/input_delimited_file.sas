options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: input_delimited_file.sas
  *
  *  Summary: Canonical input read of a delimited file.
  *
  *  Created: Mon 05 May 2008 08:14:21 (Bob Heckel)
  * Modified: Wed 11 Jun 2008 09:38:36 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

filename F "fw.txt";

data fw;
  length source $60;
  infile F DLM=';' DSD MISSOVER  LRECL=2600 FIRSTOBS=1;
  input datestamp :MMDDYY9.  /* use a preceding FORMAT datestamp MMDDYYD9. if you want it pretty */
        RecordType :$40.
        EventType :$40. 
        Product :$40.
        sProdCode :$40.
        /* ... */
        ;

  source = 'freew';
run;

endsas;
4/25/2008 4:18:58 PM;O;1;4117352 - 2001;4117352 - 2001;Valtrex 1000mg  (Fldr-DFD);20200177 - Fette 4;4/25/2008 4:18:53 PM;-1;10;;4117352 - 1003-5-89-94;SD - Fette 4;Test place module;ZEBWD07D13082;ADMIN;SD_99990010;;Hardness;0;0;30.0;1;Kp;11;0;71;;10;30;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;0.00;0.00;;;;;;;;;9;--- -> SD_99990010;-1;2;;2;;
4/25/2008 4:26:30 PM;O;1;4117352 - 2001;4117352 - 2001;Valtrex 1000mg  (Fldr-DFD);20200177 - Fette 4;4/25/2008 4:26:25 PM;-1;10;;;SD - Fette 4;Test place module;ZEBWD07D13082;ADMIN;SD_99990010;;Hardness;0;0;30.0;1;Kp;11;0;71;;10;30;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;0.00;0.00;;;;;;;;;12;SD_99990010;-1;-1;;-1;;
4/27/2008 2:49:46 PM;O;1;4117352 - 2001;4117352 - 2001;Valtrex 1000mg  (Fldr-DFD);20200177 - Fette 4;4/27/2008 2:49:41 PM;-1;10;;4117352 - 1003-5-89-94;SD - Fette 4;Test place module;ZEBWD07D13082;ADMIN;SD_9990011;;Hardness;0;0;30.0;1;Kp;11;0;71;;10;30;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;0.00;0.00;;;;;;;;;9;--- -> SD_9990011;-1;3;;3;;




data l.base_CANSafter2;
  infile f_CANS delimiter = ',' MISSOVER DSD firstobs=2;

  informat can_lot $10.;
  informat can_conductivity 6.2;
  informat can_extractives 6.2;
  informat can_weight 6.2;

  input	can_lot
        can_conductivity
        can_extractives
        can_weight
        ;
run;
 /* same */
data l.base_CANSafter2;
  infile f_CANS delimiter = ',' MISSOVER DSD firstobs=2;

  input can_lot :$10.
        can_conductivity :6.2
        can_extractives :6.2
        can_weight :6.2
        ;
run;




filename F 'C:\cygwin\home\bheckel\projects\datapost\tmp\ADVAIR_HFA\INPUT_DATA_FILES\BASE files_to_Compile\CSV_BaseFile_BatchProduction.csv';

*************************************************************************;
%macro readinPRODUCTIONcsv;
*************************************************************************;
  data WORK.base_production;
    infile F delimiter=',' MISSOVER DSD LRECL=1000 firstobs=2; 

    format mfg_date MMDDYY10.
           propellant_supply_pres 8.
           heat_stress_temp percent_yield 8.1
           fill_time_total_hr 8.3
           ;

    input mfg_matl_code :$40.
          mfg_batch :$40.
          mfg_date :DATE9.
          FP_batch :$40.
          SX_batch :$40.
          valve_lot :$40.
          can_lot :$40.
          p134a_lot :$40.
          vesl_evac_pres :8.
          agtatr_speed :8.
          TMPrecirc_start_time :DATETIME16.
          recirc_pres :8.
          susp_wt_final :8.
          recirc_susp_wt_lines :8.
          propellant_supply_temp :8.
          propellant_supply_pres :8.
          TMPfill_start_time :DATETIME16.
          recirc_time_total_hr :8.
          fill_time_total_hr :8.
          recirc_temp_fill_start :8.
          valve_tare_wt :8.
          can_tare_wt :8.
          heat_stress_temp :8.
          TMPfill_end_time :DATETIME16.
          wt_reject :8.
          cans_to_quarantine :8.
          percent_yield :8.
          quarantine_time_bbox :8.
          pkg_batch :$40.
          pkg_matl_code :$40.
          pkg_date :MMDDYY8.
          actuator_mat_num :$40.
          foil_mat_num :$40.
          pkg_spray_test_rejects :8.
          pkg_wt_rejects :8.
          pkg_yield :8.
          TMPpkg_start_time :DATETIME16.
          TMPpkg_end_time :DATETIME16.
          pkg_total_time_hr :8.
          production_comment :8.
          ;
  run;

data base_production(drop=TMP:);
  /* Reorder */
  retain mfg_matl_code mfg_batch mfg_date;
  set base_production(where=(mfg_batch~=''));

  recirc_start_time = put(datepart(TMPrecirc_start_time), MMDDYY10.);
  fill_start_time = put(datepart(TMPfill_start_time), MMDDYY10.);
  fill_end_time = put(datepart(TMPfill_end_time), MMDDYY10.);
  pkg_start_time = put(datepart(TMPpkg_start_time), MMDDYY10.);
  pkg_end_time = put(datepart(TMPpkg_end_time), MMDDYY10.);
run;
