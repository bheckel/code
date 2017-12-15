/*******************************************************************************
 *                              PROGRAM HEADER                                
 *------------------------------------------------------------------------------
 *  PROGRAM NAME: plotting_ADVAIR_analytical_trends.sas
 *                                                                            
 *  CREATED BY: Jamie Arroway
 *                                                                            
 *  DATE CREATED: 2008
 *                                                                            
 *  SAS VERSION: 8.2
 *                                                                            
 *  PURPOSE: Build Advair HFA plots
 *                                                                           
 *  ASSUMPTIONS AND RESTRICTIONS: 0_MAIN_AdvairHFA.sas has been executed 
 *                                                                            
 *  SAS PROGRAMS USED BY THIS PROGRAM: none
 *
 *  SAS MACROS USED IN THIS PROGRAM: none external
 *
 *  SAS MACROVARIABLES USED BY THIS PROGRAM: see %global statement below
 *                                                                            
 *  DESCRIPTION OF OUTPUT: .cgm files
 *
 *  NOTE: errors like these are normal due to no minimum specs:
 *  WARNING: The reference line at 0 on the vertical axis labeled avgSX_TDC_suspension is out of ...
 *  WARNING: The reference line at -99 on the vertical axis labeled avgSX_TDC_suspension is out of ...
 *
 *------------------------------------------------------------------------------
 *                     PROJECT INFORMATION                                    
 *------------------------------------------------------------------------------
 *  PROJECT NUMBER: N/A
 *  PROJECT REPRESENTATIVE: Jamie Arroway
 *
 *------------------------------------------------------------------------------
 *                     HISTORY OF CHANGE                                      
 *-------------+---------+--------------------+---------------------------------
 *     Date    | Version | Modification By    | Nature of Modification              
 *-------------+---------+--------------------+---------------------------------
 *  2008       |    1.0  | Jamie Arroway      | Original
 *-------------+---------+--------------------+---------------------------------
 *  19-May-09  |    2.0  | Margaret Byrum     | Spec changes
 *-------------+---------+--------------------+---------------------------------
 *  20-May-09  |    3.0  | Margaret Byrum     | DTU additions & 
 *             |         |                    | correct overall mean calculation
 *-------------+---------+--------------------+---------------------------------
 *  09-Jun-09  |    4.0  | Bob Heckel         | Modified TITLE statements to 
 *             |         |                    | avoid LOG error messages
 *-------------+---------+--------------------+---------------------------------
 *  25-Sep-09  |    6.0  | Margaret Byrum     | Spec limit changes per PRS02080
 *             |         |                    | version 7. (FP sum 6,7, filter)
 *-------------+---------+--------------------+---------------------------------
 *  07-Dec-09  |    7.0  | Bob Heckel         | Add VHFA 60
 *             |         |                    | 
 *-------------+---------+--------------------+---------------------------------
 *  17-Mar-10  |    8.0  | Bob Heckel         | Modify proc gplot for better
 *             |         |                    | readability.
 *             |         |                    | Removed increment parameter
 *             |         |                    | from %plotter calls, now 
 *             |         |                    | automated.
 *******************************************************************************
 */

 /* Allow this module to optionally run standalone */
/***%macro m;%if %superq(OUTP)=  %then %do; %global OUTP; %let OUTP=\\zebwd08D26987\Advair_HFA\Output_Compiled_Data;%end;%mend;%m;***/
%macro m;%if %superq(OUTP)=  %then %do; %global OUTP; %let OUTP=\\rtpsawnv0312\pucc\Advair_HFA\Output_Compiled_Data;%end;%mend;%m;

libname outDir "&OUTP";

data release_individuals;
  set outDir.analytical_individuals_release;
*  if storage_condition='Release';
run;
* seperate data by TEST;
data
  FP_CI_Throat
  FP_CI_0to2
  FP_CI_3to5
  FP_CI_6toF
  FP_CI_Total_ExDevice
  FP_DTU_BEG
  FP_DTU_END
  FP_TDC_can_wall
  FP_TDC_concentration
  FP_TDC_total_mass
  FP_TDC_suspension
  FP_TDC_valve
  SX_CI_Throat
  SX_CI_0to2
  SX_CI_3to5
  SX_CI_6toF
  SX_CI_Total_ExDevice
  SX_DTU_BEG
  SX_DTU_END
  SX_TDC_can_wall
  SX_TDC_concentration
  SX_TDC_total_mass
  SX_TDC_suspension
  SX_TDC_valve
  Leak
  shot_weight
  moisture
  content_weight
  total_imp_max
  ;
  set release_individuals;
  batchTestDate = trim(mfg_batch)||" - "||put(test_date,date7.);
  batchMfgDate = trim(mfg_batch)||" - "||put(mfg_date,date7.);

  if test='FP_CI_Throat' then do;
    FP_CI_Throat = result;
    output FP_CI_Throat;
  end;
  else if test='FP_CI_0to2' then do;
    FP_CI_0to2 = result;
    output FP_CI_0to2;
  end;
  else if test='FP_CI_3to5' then do;
    FP_CI_3to5 = result;
    output FP_CI_3to5;
  end;
  else if test='FP_CI_6toF' then do;
    FP_CI_6toF = result;
    output FP_CI_6toF;
  end;
  else if test='FP_CI_Total_ExDevice' then do;
    FP_CI_Total_ExDevice = result;
    output FP_CI_Total_ExDevice;
  end;
  else if test='FP_DTU_BEG' then do;
    FP_DTU_BEG = result;
    output FP_DTU_BEG;
  end;
  else if test='FP_DTU_END' then do;
    FP_DTU_END = result;
    output FP_DTU_END;
  end;
  else if test='FP_TDC_can_wall' then do;
    FP_TDC_can_wall = result;
    output FP_TDC_can_wall;
  end;
  else if test='FP_TDC_concentration' then do;
    FP_TDC_concentration = result;
    output FP_TDC_concentration;
  end;
  else if test='FP_TDC_total_mass' then do;
    FP_TDC_total_mass = result;
    output FP_TDC_total_mass;
  end;
  else if test='FP_TDC_suspension' then do;
    FP_TDC_suspension = result;
    output FP_TDC_suspension;
  end;
  else if test='FP_TDC_valve' then do;
    FP_TDC_valve = result;
    output FP_TDC_valve;
  end;
  else if test='SX_CI_Throat' then do;
    SX_CI_Throat = result;
    output SX_CI_Throat;
  end;
  else if test='SX_CI_0to2' then do;
    SX_CI_0to2 = result;
    output SX_CI_0to2;
  end;
  else if test='SX_CI_3to5' then do;
    SX_CI_3to5 = result;
    output SX_CI_3to5;
  end;
  else if test='SX_CI_6toF' then do;
    SX_CI_6toF = result;
    output SX_CI_6toF;
  end;
  else if test='SX_CI_Total_ExDevice' then do;
    SX_CI_Total_ExDevice = result;
    output SX_CI_Total_ExDevice;
  end;
  else if test='SX_DTU_BEG' then do;
    SX_DTU_BEG = result;
    output SX_DTU_BEG;
  end;
  else if test='SX_DTU_END' then do;
    SX_DTU_END = result;
    output SX_DTU_END;
  end;
  else if test='SX_TDC_can_wall' then do;
    SX_TDC_can_wall = result;
    output SX_TDC_can_wall;
  end;
  else if test='SX_TDC_concentration' then do;
    SX_TDC_concentration = result;
    output SX_TDC_concentration;
  end;
  else if test='SX_TDC_total_mass' then do;
    SX_TDC_total_mass = result;
    output SX_TDC_total_mass;
  end;
  else if test='SX_TDC_suspension' then do;
    SX_TDC_suspension = result;
    output SX_TDC_suspension;
  end;
  else if test='SX_TDC_valve' then do;
    SX_TDC_valve = result;
    output SX_TDC_valve;
  end;
  else if test='Leak_mg_per_yr' then do;
    Leak = result;
    output Leak;
  end;
  else if test='shot_weight' then do;
    shot_weight = result;
    output shot_weight;
  end;
  else if test='moisture' then do;
    moisture = result;
    output moisture;
  end;
  else if test='content_weight' then do;
    content_weight = result;
    output content_weight;
  end;
  else if test='total_imp_max' then do;
    total_imp_max = result;
    output total_imp_max;
  end;

run;

**********************************************************************;
* clean up datasets;
data FP_CI_Throat; set FP_CI_Throat;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  FP_CI_Throat;
run;    
data FP_CI_0to2; set FP_CI_0to2;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  FP_CI_0to2;
run;    
data FP_CI_3to5; set FP_CI_3to5;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  FP_CI_3to5;
run;
data FP_CI_6toF; set FP_CI_6toF;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  FP_CI_6toF;
run;
data FP_CI_Total_ExDevice; set FP_CI_Total_ExDevice;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  FP_CI_Total_ExDevice;
run;
data FP_DTU_BEG; set FP_DTU_BEG;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  FP_DTU_BEG;
run;
data FP_DTU_END; set FP_DTU_END;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  FP_DTU_END;
run;
data FP_TDC_can_wall; set FP_TDC_can_wall;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  FP_TDC_can_wall;
run;
data FP_TDC_concentration; set FP_TDC_concentration;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  FP_TDC_concentration;
run;
data FP_TDC_total_mass; set FP_TDC_total_mass;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  FP_TDC_total_mass;
run;
data FP_TDC_suspension; set FP_TDC_suspension;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  FP_TDC_suspension;
run;
data FP_TDC_valve; set FP_TDC_valve;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  FP_TDC_valve;
run;
data SX_CI_Throat; set SX_CI_Throat;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  SX_CI_Throat;
run;    
data SX_CI_0to2; set SX_CI_0to2;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  SX_CI_0to2;
run;
data SX_CI_3to5; set SX_CI_3to5;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  SX_CI_3to5;
run;
data SX_CI_6toF; set SX_CI_6toF;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  SX_CI_6toF;
run;
data SX_CI_Total_ExDevice; set SX_CI_Total_ExDevice;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  SX_CI_Total_ExDevice;
run;
data SX_DTU_BEG; set SX_DTU_BEG;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  SX_DTU_BEG;
run;
data SX_DTU_END; set SX_DTU_END;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  SX_DTU_END;
run;
data SX_TDC_can_wall; set SX_TDC_can_wall;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  SX_TDC_can_wall;
run;
data SX_TDC_concentration; set SX_TDC_concentration;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  SX_TDC_concentration;
run;
data SX_TDC_total_mass; set SX_TDC_total_mass;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  SX_TDC_total_mass;
run;
data SX_TDC_suspension; set SX_TDC_suspension;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  SX_TDC_suspension;
run;
data SX_TDC_valve; set SX_TDC_valve;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  SX_TDC_valve;
run;
data Leak; set Leak;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  Leak;
run;
data shot_weight; set shot_weight;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  shot_weight;
run;
data moisture; set moisture;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  moisture;
run;
data content_weight; set content_weight;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  content_weight;
run;
data total_imp_max; set total_imp_max;
  keep batchTestDate batchMfgDate mfg_batch pkg_batch mfg_date pkg_date
     mfg_matl_code pkg_matl_code test_date device dose strength DATASTATUS
  total_imp_max;
run;
/* 20 May 2009 Margaret Byrum:  
*  calculate FP and SX DTU Difference betwween DTU END and DTU BEGin 
*  which is DTU END minus DTU BEG
*/
*FP;
proc sort data = FP_DTU_BEG;
  by mfg_batch test_date;
proc sort data = FP_DTU_END;
  by mfg_batch test_date;
run;
data FP_DTU_DIFF;
  merge FP_DTU_BEG FP_DTU_END;
  by mfg_batch test_date;
  FP_DTU_DIFF = FP_DTU_END - FP_DTU_BEG;
  drop FP_DTU_BEG FP_DTU_END;
run;
* SX;
proc sort data = SX_DTU_BEG;
  by mfg_batch test_date;
proc sort data = SX_DTU_END;
  by mfg_batch test_date;
run;
data SX_DTU_DIFF;
  merge SX_DTU_BEG SX_DTU_END;
  by mfg_batch test_date;
  SX_DTU_DIFF = SX_DTU_END - SX_DTU_BEG;
  drop SX_DTU_BEG SX_DTU_END;
run;


*******************************************************************;
** CALCULATION IS NO LONGER NECESSARY, SINCE CI_TOTAL COMES DIRECTLY FROM LINKS;
/*
* calculate FP and SX CI_mass_balance;
*FP;
proc sort data = FP_CI_Throat;
  by mfg_batch device;
proc sort data = FP_CI_0to2;
  by mfg_batch device;
proc sort data = FP_CI_3to5;
  by mfg_batch device;
proc sort data = FP_CI_6toF;
  by mfg_batch device;
run;
data FP_CI_mass_balance;
  merge FP_CI_Throat FP_CI_0to2 FP_CI_3to5 FP_CI_6toF;
  by mfg_batch device;
  FP_CI_mass_balance = FP_CI_Throat + FP_CI_0to2 + FP_CI_3to5 + FP_CI_6toF;
  drop FP_CI_Throat FP_CI_0to2 FP_CI_3to5 FP_CI_6toF;
run;
* SX;
proc sort data = SX_CI_Throat;
  by mfg_batch device;
proc sort data = SX_CI_0to2;
  by mfg_batch device;
proc sort data = SX_CI_3to5;
  by mfg_batch device;
proc sort data = SX_CI_6toF;
  by mfg_batch device;
run;
data SX_CI_mass_balance;
  merge SX_CI_Throat SX_CI_0to2 SX_CI_3to5 SX_CI_6toF;
  by mfg_batch device;
  SX_CI_mass_balance = SX_CI_Throat + SX_CI_0to2 + SX_CI_3to5 + SX_CI_6toF;
  drop SX_CI_Throat SX_CI_0to2 SX_CI_3to5 SX_CI_6toF;
run;

*/

*******************************************************************;
*******************************************************************;
*******************************************************************;
*******************************************************************;
*******************************************************************;
/*
%let varname=FP_CI_0to2;
%let minSpec = 10;
%let maxSpec = 18;
%let minMeanSpec = 3;
%let maxMeanSpec = 5;
%let strength = '45-21';
%let increment=1.0;
%let dateText='Manufacturing';
%let duration='all';
%let outFileName = FP_CI_02_LOW;

%plotter(FP_CI_Total,'all','Test','115-21',-99,98,132,0,0,FP_CI_Total_MID_);
%let varname=FP_CI_Total;
%let minSpec = 98;
%let maxSpec = 132;
%let minMeanSpec = 9;
%let maxMeanSpec = 9;
%let strength = '115-21';
%let increment=0;
%let dateText='Test';
%let duration='all';
%let outFileName = FP_CI_Total_MID_;

%plotter(FP_TDC_suspension,'all','Test','45-21',-99,0,0,0,2,FP_TDC_suspension_LOW_);
%let varname=FP_TDC_suspension;
%let duration='all';
%let dateText='Test';
%let strength='45-21';
%let minSpec=-99;
%let maxSpec=0;
%let minMeanSpec=0;
%let maxMeanSpec=0;
%let increment=2;
%let outFileName=FP_TDC_suspension_LOW_;
*/


%macro plotter(varname, duration, dateText, dose, strength, minSpec, maxSpec, minMeanSpec, maxMeanSpec, outFileName);
   data _null_;
     format today_date mmddyy9.;
     today_date = today();
     call symput('today_date', PUT(today_date, DATE8.)); 
  run;

  data _null_;
    if "&dateText" = 'Manufacturing' then do;
      call symput('dateSort','mfg_date');
      call symput('batchDate','batchMfgDate');
    end;
    else if "&dateText" = 'Test' then do;
      call symput('dateSort','test_date');
      call symput('batchDate','batchTestDate');
    end;
  run;

  /* Calculate means and merge with individuals */
  
  data individ&varname.;
    set &varname.;
    if dose eq "&dose" and strength eq "&strength";
  run;

  * overall mean;
  proc means data=individ&varname. noprint;
    var &varname.;
    output out=overallmean&varname.(drop= _type_ _freq_) 
      mean=overallavg&varname.;
  run;
  /* 20 May 2009 Margaret Byrum
  * remove this code, this calculates the average of all - which is correct only if
  * duration is all.  need to wait and calculate the average after we know duration 
  data _null_;
    set overallmean&varname.;
    call symput('overallavg',overallavg&varname.);
  run; */

  * mean by mfg_batch and date (&dateSort = either mfg_date or test_date);
  proc sort data=individ&varname.;
    by mfg_batch &dateSort.;
  proc means data=individ&varname. noprint;
    by mfg_batch &dateSort.;
    var &varname.;
    output out=means&varname.(drop= _type_ _freq_) 
      mean=avg&varname.;
  run;

  * combine means with individual values;
  data meanMerge&varname.;
    merge individ&varname. means&varname.;
    by mfg_batch &dateSort.;
  run;
  proc datasets NOlist;
    delete
      individ&varname. 
      means&varname. 
      overallmean&varname.;
  run;quit;

  **********************************************;
  **********************************************;
  *add batchCounter by date (&dateSort = either mfg_date or test_date);
  proc sort data=meanMerge&varname.;
    by &dateSort. mfg_batch;
  run;
  data plot&varname.;
    RETAIN BATCHOBS 0; 
    FORMAT BATCHN $10.; 
    set meanMerge&varname.;

    if "&duration" eq 'all' then do;
       if strength eq "&strength";
        end;
    else if "&duration" eq 'one year' then do;        
       if &dateSort.>= (today()-365) and strength = "&strength";
        end;

    by &dateSort. mfg_batch;

    IF first.mfg_batch then  BATCHOBS+1; 
    * make the batchCounter (batchobs) into sortable by alphanumeric: '1' = '01';
    if batchobs <10 then batchN="0"||left(TRIM(substr(LEFT(BATCHOBS),1)))||"0";
    else if batchobs>99 then batchN="99"||left(TRIM(substr(LEFT(BATCHOBS),1)));
    else batchN=left(TRIM(substr(LEFT(BATCHOBS),1)))||"0";

    keep batchn &batchDate. mfg_batch &dateSort. 
      &varname. avg&varname. strength DATASTATUS;
  run;

  /* 20 May 2009 Margaret Byrum: now that the dataset only contains records for the 
  * duration, calculate the overall average 
  */
  proc means data=plot&varname. noprint;
    var &varname.;
    output out=durationmean&varname.(drop= _type_ _freq_) 
      mean=durationavg&varname.;
  run;
  data _null_;
    set durationmean&varname.;
    call symput('overallavg',durationavg&varname.);
  run; 
  
  * create format for sorting index;
  DATA formatdata;
    LENGTH  START  $10.
    label   $20.
    FMTNAME  $15.
    ;
    SET plot&varname.;

    RETAIN FMTNAME;
    FMTNAME = "$batch";
    IF _N_ = 1 THEN DO;  
      HLO = 'O'; LABEL = ''; START = ' '; OUTPUT; HLO = ' '; 
    END;
    START = BATCHn;
    label = &batchDate.;
    KEEP START LABEL HLO FMTNAME;
    OUTPUT;
  RUN;
  PROC SORT NODUPKEY DATA=formatdata;
    BY FMTNAME START HLO;
  RUN;
  PROC FORMAT CNTLIN=formatdata;
  RUN;

  proc means data=plot&varname. noprint;
    var &varname.;
    output out=MinMax(drop= _type_ _freq_) 
      min=min
      max=max
    ;
  run;

  data MinMax;
    set MinMax;
    yinc = (max-min)*0.1;

    if (min < &minSpec. or &minSpec.=-99) then minVal=min-yinc;
      else minVal = &minSpec.-yinc;
    if max > &maxSpec. then maxVal=max+yinc;
      else maxVal = &maxSpec.+yinc;

    if minVal<0 then minVal=0;

    call symput('minPlot',minVal);
    call symput('maxPlot',maxVal);
    call symput('yincrement',yinc);
  run;

  goptions dev=cgmmw6c rotate=landscape htext=0.90 hsize=0 vsize=0 gsfname=gsf2 gsfmode=replace;
  filename gsf2 "&OUTP\PLOTs\&dateSort.\&outFileName.&dateSort..cgm";
    
  PROC SORT DATA = plot&varname(keep = DATASTATUS) out = outfreq;
      by descending DATASTATUS;
  run;

  data outfreq;
    set outfreq(obs=1);
    App_status=DATASTATUS;
    call symput('App_status',App_status);
  run;

    %if &App_status = Approved %then %Approved;
  %else %Unapproved;
    

  proc datasets NOlist;
    delete
      meanMerge&varname.;
  run;quit;

%mend plotter;

 /* v8 rsh86800 reorganized */
%macro Approved;
  proc gplot data=plot&varname.;
    title1 h=2 "Advair HFA &dose: [ &varname ] by &dateText date";
    title2 ' ';
    title3 h=1.25 "Strength: &strength (&duration)";

    footnote1 h=0.70 "Plot created &today_date";
    footnote2 ' ';  /* cosmetic - add space to bottom of graph */
    
    symbol1 i=none w=0.25 h=0.25 v=dot c=blue;
    symbol2 i=none w=1.25 h=1.25 v=dot c=green interpol=join;
        
    axis1 label=NONE order=(&minPlot to &maxPlot by &yincrement) major=none minor=none; 
    axis2 label=NONE value=(height=0.65);
    axis3 label=NONE order=(&minPlot to &maxPlot by &yincrement) value=none major=none minor=none;
    axis4 label=NONE value=(height=0.65);                                     

    plot &varname.*batchn / vaxis=axis1 haxis=axis2 frame
                            vref=&minMeanSpec. &maxMeanSpec. &minSpec. &maxSpec. &overallavg.
                            lvref=(3 3 2 2 1)
                            cvref=(green,green,blue,blue,purple) NOlegend
                            ;

    plot2 avg&varname.*batchn / vaxis=axis3 haxis=axis4 frame
                                vref=&minMeanSpec. &maxMeanSpec. &minSpec. &maxSpec. &overallavg.
                                lvref=(3 3 2 2 1)
                                cvref=(green,green,blue,blue,purple) legend
                                ;

    format batchn $batch.;
  run;
  quit;
%mend Approved;

 /* v8 rsh86800 reorganized */
%macro Unapproved;
  proc gplot data=plot&varname;
    title1 h=2 "Advair HFA &dose: [ &varname ] by &dateText date";
    title2 ' ';
    title3 h=1.25 "Strength: &strength (&duration)";

    footnote1 h=0.70 "Plot created &today_date";
    footnote2 ' ';  /* cosmetic - add space to bottom of graph */
                 
    symbol1 i=none w=0.25 h=0.25 v=dot c=blue;
    symbol2 i=none w=1.25 h=0.25 v=dot c=red ;
    symbol3 i=none w=1.25 h=1.25 v=dot c=green interpol=join;
    symbol4 i=none w=1.25 h=1.25 v=dot c=red interpol=join;

    axis1 label=NONE order=(&minPlot to &maxPlot by &yincrement) major=none minor=none; 
    axis2 label=NONE value=(height=0.65);
    axis3 label=NONE order=(&minPlot to &maxPlot by &yincrement) value=none major=none minor=none;
    axis4 label=NONE value=(height=0.65);                                     

    legend1 label=NONE shape=symbol(15,1) frame;

    plot &varname.*batchn = datastatus / vaxis=axis1 haxis=axis2 frame
                                         vref=&minMeanSpec &maxMeanSpec &minSpec &maxSpec &overallavg
                                         lvref=(3 3 2 2 1)
                                         cvref=(green,green,blue,blue,purple)
                                         NOlegend
                                         ;

    plot2 avg&varname.*batchn = datastatus / vaxis=axis3 haxis=axis4 frame                              
                                             vref=&minMeanSpec &maxMeanSpec &minSpec &maxSpec &overallavg
                                             lvref=(3 3 2 2 1)
                                             cvref=(green,green,blue,blue,purple)
                                             legend=legend1
                                             ; 

    format batchn $batch.;
  run;
  quit;
%mend Unapproved;


 /* Start 120 dose */

/**************************************************************************************************************************************/
 /*      varname              ,duration  , dateText    , dose, strength,minSpec,maxSpec,minMeanSpec,maxMeanSpec,outFileName */
%plotter(FP_CI_0to2           , all      , Manufacturing , 120, 45-21  , -99   , 7      , -99  , 7    , FP_CI_02_LOW_120_);
%plotter(FP_CI_0to2           , all      , Test          , 120, 45-21  , -99   , 7      , -99  , 7    , FP_CI_02_LOW_120_);
%plotter(FP_CI_0to2           , one year , Manufacturing , 120, 45-21  , -99   , 7      , -99  , 7    , FP_CI_02_LOW_year_120_);
%plotter(FP_CI_0to2           , one year , Test          , 120, 45-21  , -99   , 7      , -99  , 7    , FP_CI_02_LOW_year_120_);

%plotter(FP_CI_3to5           , all      , Manufacturing , 120, 45-21  , 15    , 27     , 16   , 26   , FP_CI_35_LOW_120_);
%plotter(FP_CI_3to5           , all      , Test          , 120, 45-21  , 15    , 27     , 16   , 26   , FP_CI_35_LOW_120_);
%plotter(FP_CI_3to5           , one year , Manufacturing , 120, 45-21  , 15    , 27     , 16   , 26   , FP_CI_35_LOW_year_120_);
%plotter(FP_CI_3to5           , one year , Test          , 120, 45-21  , 15    , 27     , 16   , 26   , FP_CI_35_LOW_year_120_);

%plotter(FP_CI_6toF           , all      , Manufacturing , 120, 45-21  , -99   , 2      , -99  , 2    , FP_CI_6F_LOW_120_);
%plotter(FP_CI_6toF           , all      , Test          , 120, 45-21  , -99   , 2      , -99  , 2    , FP_CI_6F_LOW_120_);
%plotter(FP_CI_6toF           , one year , Manufacturing , 120, 45-21  , -99   , 2      , -99  , 2    , FP_CI_6F_LOW_year_120_);
%plotter(FP_CI_6toF           , one year , Test          , 120, 45-21  , -99   , 2      , -99  , 2    , FP_CI_6F_LOW_year_120_);

%plotter(FP_CI_Throat         , all      , Manufacturing , 120, 45-21  , 11    , 22     , 12   , 21   , FP_CI_Throat_LOW_120_);
%plotter(FP_CI_Throat         , all      , Test          , 120, 45-21  , 11    , 22     , 12   , 21   , FP_CI_Throat_LOW_120_);
%plotter(FP_CI_Throat         , one year , Test          , 120, 45-21  , 11    , 22     , 12   , 21   , FP_CI_Throat_LOW_year_120_);
%plotter(FP_CI_Throat         , one year , Manufacturing , 120, 45-21  , 11    , 22     , 12   , 21   , FP_CI_Throat_LOW_year_120_);

%plotter(FP_CI_Total_ExDevice , all      , Manufacturing , 120, 45-21  , -99   , -99   , -99  , -99   , FP_CI_Total_ExDevice_LOW_120_);
%plotter(FP_CI_Total_ExDevice , all      , Test          , 120, 45-21  , -99   , -99   , -99  , -99   , FP_CI_Total_ExDevice_LOW_120_);
%plotter(FP_CI_Total_ExDevice , one year , Manufacturing , 120, 45-21  , -99   , -99   , -99  , -99   , FP_CI_Total_ExDevice_LOW_year_120_);
%plotter(FP_CI_Total_ExDevice , one year , Test          , 120, 45-21  , -99   , -99   , -99  , -99   , FP_CI_Total_ExDevice_LOW_year_120_);

%plotter(FP_DTU_BEG           , all      , Manufacturing , 120, 45-21  , 31.5  , 58.5   , 36   , 54   , FP_DTU_beg_LOW_120_);
%plotter(FP_DTU_BEG           , all      , Test          , 120, 45-21  , 31.5  , 58.5   , 36   , 54   , FP_DTU_beg_LOW_120_);
%plotter(FP_DTU_BEG           , one year , Manufacturing , 120, 45-21  , 31.5  , 58.5   , 36   , 54   , FP_DTU_beg_LOW_year_120_);
%plotter(FP_DTU_BEG           , one year , Test          , 120, 45-21  , 31.5  , 58.5   , 36   , 54   , FP_DTU_beg_LOW_year_120_);

%plotter(FP_DTU_DIFF          , all      , Manufacturing , 120, 45-21  , -99   , -99    , -99  , -99  , FP_DTU_diff_LOW_120_);
%plotter(FP_DTU_DIFF          , all      , Test          , 120, 45-21  , -99   , -99    , -99  , -99  , FP_DTU_diff_LOW_120_);
%plotter(FP_DTU_DIFF          , one year , Manufacturing , 120, 45-21  , -99   , -99    , -99  , -99  , FP_DTU_diff_LOW_year_120_);
%plotter(FP_DTU_DIFF          , one year , Test          , 120, 45-21  , -99   , -99    , -99  , -99  , FP_DTU_diff_LOW_year_120_);

%plotter(FP_DTU_END           , all      , Manufacturing , 120, 45-21  , 31.5  , 58.5   , 36   , 54   , FP_DTU_end_LOW_120_);
%plotter(FP_DTU_END           , all      , Test          , 120, 45-21  , 31.5  , 58.5   , 36   , 54   , FP_DTU_end_LOW_120_);
%plotter(FP_DTU_END           , one year , Manufacturing , 120, 45-21  , 31.5  , 58.5   , 36   , 54   , FP_DTU_end_LOW_year_120_);
%plotter(FP_DTU_END           , one year , Test          , 120, 45-21  , 31.5  , 58.5   , 36   , 54   , FP_DTU_end_LOW_year_120_);

%plotter(FP_TDC_can_wall      , all      , Manufacturing , 120, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_can_wall_LOW_120_);
%plotter(FP_TDC_can_wall      , all      , Test          , 120, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_can_wall_LOW_120_);
%plotter(FP_TDC_can_wall      , one year , Manufacturing , 120, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_can_wall_LOW_year_120_);
%plotter(FP_TDC_can_wall      , one year , Test          , 120, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_can_wall_LOW_year_120_);

%plotter(FP_TDC_concentration , all      , Manufacturing , 120, 45-21  , 0.586 , 0.716  , 0.6  , 0.7  , FP_TDC_conc_LOW_120_);
%plotter(FP_TDC_concentration , all      , Test          , 120, 45-21  , 0.586 , 0.716  , 0.6  , 0.7  , FP_TDC_conc_LOW_120_);
%plotter(FP_TDC_concentration , one year , Manufacturing , 120, 45-21  , 0.586 , 0.716  , 0.6  , 0.7  , FP_TDC_conc_LOW_year_120_);
%plotter(FP_TDC_concentration , one year , Test          , 120, 45-21  , 0.586 , 0.716  , 0.6  , 0.7  , FP_TDC_conc_LOW_year_120_);

%plotter(FP_TDC_suspension    , all      , Manufacturing , 120, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_suspension_LOW_120_);
%plotter(FP_TDC_suspension    , all      , Test          , 120, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_suspension_LOW_120_);
%plotter(FP_TDC_suspension    , one year , Manufacturing , 120, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_suspension_LOW_year_120_);
%plotter(FP_TDC_suspension    , one year , Test          , 120, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_suspension_LOW_year_120_);

%plotter(FP_TDC_total_mass    , all      , Manufacturing , 120, 45-21  , 7.48  , 9.15   , 7.6  , 9.0  , FP_TDC_total_mass_LOW_120_);
%plotter(FP_TDC_total_mass    , all      , Test          , 120, 45-21  , 7.48  , 9.15   , 7.6  , 9.0  , FP_TDC_total_mass_LOW_120_);
%plotter(FP_TDC_total_mass    , one year , Manufacturing , 120, 45-21  , 7.48  , 9.15   , 7.6  , 9.0  , FP_TDC_total_mass_LOW_year_120_);
%plotter(FP_TDC_total_mass    , one year , Test          , 120, 45-21  , 7.48  , 9.15   , 7.6  , 9.0  , FP_TDC_total_mass_LOW_year_120_);

%plotter(FP_TDC_valve         , all      , Manufacturing , 120, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_valve_LOW_120_);
%plotter(FP_TDC_valve         , all      , Test          , 120, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_valve_LOW_120_);
%plotter(FP_TDC_valve         , one year , Manufacturing , 120, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_valve_LOW_year_120_);
%plotter(FP_TDC_valve         , one year , Test          , 120, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_valve_LOW_year_120_);

%plotter(Leak                 , all      , Manufacturing , 120, 45-21  , -99   , 500    , -99  , 440  , LEAK_LOW_120_);
%plotter(Leak                 , all      , Test          , 120, 45-21  , -99   , 500    , -99  , 440  , LEAK_LOW_120_);
%plotter(Leak                 , one year , Manufacturing , 120, 45-21  , -99   , 500    , -99  , 440  , LEAK_LOW_year_120_);
%plotter(Leak                 , one year , Test          , 120, 45-21  , -99   , 500    , -99  , 440  , LEAK_LOW_year_120_);

%plotter(SX_CI_0to2           , all      , Manufacturing , 120, 45-21  , -99   , 5      , -99  , 4    , SX_CI_02_LOW_120_);
%plotter(SX_CI_0to2           , all      , Test          , 120, 45-21  , -99   , 5      , -99  , 4    , SX_CI_02_LOW_120_);
%plotter(SX_CI_0to2           , one year , Manufacturing , 120, 45-21  , -99   , 5      , -99  , 4    , SX_CI_02_LOW_year_120_);
%plotter(SX_CI_0to2           , one year , Test          , 120, 45-21  , -99   , 5      , -99  , 4    , SX_CI_02_LOW_year_120_);

%plotter(SX_CI_3to5           , all      , Manufacturing , 120, 45-21  , 7     , 13     , 7    , 12   , SX_CI_35_LOW_120_);
%plotter(SX_CI_3to5           , all      , Test          , 120, 45-21  , 7     , 13     , 7    , 12   , SX_CI_35_LOW_120_);
%plotter(SX_CI_3to5           , one year , Manufacturing , 120, 45-21  , 7     , 13     , 7    , 12   , SX_CI_35_LOW_year_120_);
%plotter(SX_CI_3to5           , one year , Test          , 120, 45-21  , 7     , 13     , 7    , 12   , SX_CI_35_LOW_year_120_);

%plotter(SX_CI_6toF           , all      , Manufacturing , 120, 45-21  , -99   , 1      , -99  , 1    , SX_CI_6F_LOW_120_);
%plotter(SX_CI_6toF           , all      , Test          , 120, 45-21  , -99   , 1      , -99  , 1    , SX_CI_6F_LOW_120_);
%plotter(SX_CI_6toF           , one year , Manufacturing , 120, 45-21  , -99   , 1      , -99  , 1    , SX_CI_6F_LOW_year_120_);
%plotter(SX_CI_6toF           , one year , Test          , 120, 45-21  , -99   , 1      , -99  , 1    , SX_CI_6F_LOW_year_120_);

%plotter(SX_CI_Throat         , all      , Manufacturing , 120, 45-21  , 2     , 10     , 3    , 9    , SX_CI_Throat_LOW_120_);
%plotter(SX_CI_Throat         , all      , Test          , 120, 45-21  , 2     , 10     , 3    , 9    , SX_CI_Throat_LOW_120_);
%plotter(SX_CI_Throat         , one year , Manufacturing , 120, 45-21  , 2     , 10     , 3    , 9    , SX_CI_Throat_LOW_year_120_);
%plotter(SX_CI_Throat         , one year , Test          , 120, 45-21  , 2     , 10     , 3    , 9    , SX_CI_Throat_LOW_year_120_);

/***%plotter(SX_CI_Total_ExDevice , all      , Manufacturing , 120, 45-21  , 16.8  , 23.1   , -99  , -99  , SX_CI_Total_ExDevice_LOW_120_);***/
/***%plotter(SX_CI_Total_ExDevice , all      , Test          , 120, 45-21  , 16.8  , 23.1   , -99  , -99  , SX_CI_Total_ExDevice_LOW_120_);***/
/***%plotter(SX_CI_Total_ExDevice , one year , Manufacturing , 120, 45-21  , 16.8  , 23.1   , -99  , -99  , SX_CI_Total_ExDevice_LOW_year_120_);***/
/***%plotter(SX_CI_Total_ExDevice , one year , Test          , 120, 45-21  , 16.8  , 23.1   , -99  , -99  , SX_CI_Total_ExDevice_LOW_year_120_);***/
%plotter(SX_CI_Total_ExDevice , all      , Manufacturing , 120, 45-21  , -99   , -99    , -99  , -99  , SX_CI_Total_ExDevice_LOW_120_);
%plotter(SX_CI_Total_ExDevice , all      , Test          , 120, 45-21  , -99   , -99    , -99  , -99  , SX_CI_Total_ExDevice_LOW_120_);
%plotter(SX_CI_Total_ExDevice , one year , Manufacturing , 120, 45-21  , -99   , -99    , -99  , -99  , SX_CI_Total_ExDevice_LOW_year_120_);
%plotter(SX_CI_Total_ExDevice , one year , Test          , 120, 45-21  , -99   , -99    , -99  , -99  , SX_CI_Total_ExDevice_LOW_year_120_);

%plotter(SX_DTU_BEG           , all      , Manufacturing , 120, 45-21  , 14.7  , 27.3   , 16.8 , 25.2 , SX_DTU_beg_LOW_120_);
%plotter(SX_DTU_BEG           , all      , Test          , 120, 45-21  , 14.7  , 27.3   , 16.8 , 25.2 , SX_DTU_beg_LOW_120_);
%plotter(SX_DTU_BEG           , one year , Manufacturing , 120, 45-21  , 14.7  , 27.3   , 16.8 , 25.2 , SX_DTU_beg_LOW_year_120_);
%plotter(SX_DTU_BEG           , one year , Test          , 120, 45-21  , 14.7  , 27.3   , 16.8 , 25.2 , SX_DTU_beg_LOW_year_120_);

%plotter(SX_DTU_DIFF          , all      , Manufacturing , 120, 45-21  , -99   , -99    , -99  , -99  , SX_DTU_diff_LOW_120_);
%plotter(SX_DTU_DIFF          , all      , Test          , 120, 45-21  , -99   , -99    , -99  , -99  , SX_DTU_diff_LOW_120_);
%plotter(SX_DTU_DIFF          , one year , Manufacturing , 120, 45-21  , -99   , -99    , -99  , -99  , SX_DTU_diff_LOW_year_120_);
%plotter(SX_DTU_DIFF          , one year , Test          , 120, 45-21  , -99   , -99    , -99  , -99  , SX_DTU_diff_LOW_year_120_);

%plotter(SX_DTU_END           , all      , Manufacturing , 120, 45-21  , 14.7  , 27.3   , 16.8 , 25.2 , SX_DTU_end_LOW_120_);
%plotter(SX_DTU_END           , all      , Test          , 120, 45-21  , 14.7  , 27.3   , 16.8 , 25.2 , SX_DTU_end_LOW_120_);
%plotter(SX_DTU_END           , one year , Manufacturing , 120, 45-21  , 14.7  , 27.3   , 16.8 , 25.2 , SX_DTU_end_LOW_year_120_);
%plotter(SX_DTU_END           , one year , Test          , 120, 45-21  , 14.7  , 27.3   , 16.8 , 25.2 , SX_DTU_end_LOW_year_120_);

%plotter(SX_TDC_can_wall      , all      , Manufacturing , 120, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_can_wall_LOW_120_);
%plotter(SX_TDC_can_wall      , all      , Test          , 120, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_can_wall_LOW_120_);
%plotter(SX_TDC_can_wall      , one year , Manufacturing , 120, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_can_wall_LOW_year_120_);
%plotter(SX_TDC_can_wall      , one year , Test          , 120, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_can_wall_LOW_year_120_);

%plotter(SX_TDC_concentration , all      , Manufacturing , 120, 45-21  , 0.287 , 0.350  , 0.29 , 0.34 , SX_TDC_conc_LOW_120_);
%plotter(SX_TDC_concentration , all      , Test          , 120, 45-21  , 0.287 , 0.350  , 0.29 , 0.34 , SX_TDC_conc_LOW_120_);
%plotter(SX_TDC_concentration , one year , Manufacturing , 120, 45-21  , 0.287 , 0.350  , 0.29 , 0.34 , SX_TDC_conc_LOW_year_120_);
%plotter(SX_TDC_concentration , one year , Test          , 120, 45-21  , 0.287 , 0.350  , 0.29 , 0.34 , SX_TDC_conc_LOW_year_120_);

%plotter(SX_TDC_suspension    , all      , Manufacturing , 120, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_suspension_LOW_120_);
%plotter(SX_TDC_suspension    , all      , Test          , 120, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_suspension_LOW_120_);
%plotter(SX_TDC_suspension    , one year , Manufacturing , 120, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_suspension_LOW_year_120_);
%plotter(SX_TDC_suspension    , one year , Test          , 120, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_suspension_LOW_year_120_);

%plotter(SX_TDC_total_mass    , all      , Manufacturing , 120, 45-21  , 3.65  , 4.46   , 3.7  , 4.4  , SX_TDC_total_mass_LOW_120_);
%plotter(SX_TDC_total_mass    , all      , Test          , 120, 45-21  , 3.65  , 4.46   , 3.7  , 4.4  , SX_TDC_total_mass_LOW_120_);
%plotter(SX_TDC_total_mass    , one year , Manufacturing , 120, 45-21  , 3.65  , 4.46   , 3.7  , 4.4  , SX_TDC_total_mass_LOW_year_120_);
%plotter(SX_TDC_total_mass    , one year , Test          , 120, 45-21  , 3.65  , 4.46   , 3.7  , 4.4  , SX_TDC_total_mass_LOW_year_120_);

%plotter(SX_TDC_valve         , all      , Manufacturing , 120, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_valve_LOW_120_);
%plotter(SX_TDC_valve         , all      , Test          , 120, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_valve_LOW_120_);
%plotter(SX_TDC_valve         , one year , Manufacturing , 120, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_valve_LOW_year_120_);
%plotter(SX_TDC_valve         , one year , Test          , 120, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_valve_LOW_year_120_);

%plotter(content_weight       , all      , Manufacturing , 120, 45-21  , 10.8  , 12.3   , 11.1 , 12.3 , CONTENT_WEIGHT_LOW_120_);
%plotter(content_weight       , all      , Test          , 120, 45-21  , 10.8  , 12.3   , 11.1 , 12.3 , CONTENT_WEIGHT_LOW_120_);
%plotter(content_weight       , one year , Manufacturing , 120, 45-21  , 10.8  , 12.3   , 11.1 , 12.3 , CONTENT_WEIGHT_LOW_year_120_);
%plotter(content_weight       , one year , Test          , 120, 45-21  , 10.8  , 12.3   , 11.1 , 12.3 , CONTENT_WEIGHT_LOW_year_120_);

%plotter(moisture             , all      , Manufacturing , 120, 45-21  , -99   , 175    , -99  , 150  , MOISTURE_LOW_120_);
%plotter(moisture             , all      , Test          , 120, 45-21  , -99   , 175    , -99  , 150  , MOISTURE_LOW_120_);
%plotter(moisture             , one year , Manufacturing , 120, 45-21  , -99   , 175    , -99  , 150  , MOISTURE_LOW_year_120_);
%plotter(moisture             , one year , Test          , 120, 45-21  , -99   , 175    , -99  , 150  , MOISTURE_LOW_year_120_);

%plotter(shot_weight          , all      , Manufacturing , 120, 45-21  , 63    , 85     , 67   , 81   , SHOT_WEIGHT_LOW_120_);
%plotter(shot_weight          , all      , Test          , 120, 45-21  , 63    , 85     , 67   , 81   , SHOT_WEIGHT_LOW_120_);
%plotter(shot_weight          , one year , Manufacturing , 120, 45-21  , 63    , 85     , 67   , 81   , SHOT_WEIGHT_LOW_year_120_);
%plotter(shot_weight          , one year , Test          , 120, 45-21  , 63    , 85     , 67   , 81   , SHOT_WEIGHT_LOW_year_120_);

%plotter(total_imp_max        , all      , Test          , 120, 45-21  , -99   , 2.1    , -99  , 2.1  , TOTAL_IMPURITIES_LOW_120_);
%plotter(total_imp_max        , all      , Manufacturing , 120, 45-21  , -99   , 2.1    , -99  , 2.1  , TOTAL_IMPURITIES_LOW_120_);
%plotter(total_imp_max        , one year , Manufacturing , 120, 45-21  , -99   , 2.1    , -99  , 2.1  , TOTAL_IMPURITIES_LOW_year_120_);
%plotter(total_imp_max        , one year , Test          , 120, 45-21  , -99   , 2.1    , -99  , 2.1  , TOTAL_IMPURITIES_LOW_year_120_);
/**********************************************************************/

/**********************************************************************/
%plotter(FP_CI_0to2           , all      , Manufacturing , 120 , 115-21 , -99   , 25     , -99  , 22  , FP_CI_02_MID_120_);
%plotter(FP_CI_0to2           , all      , Test          , 120 , 115-21 , -99   , 25     , -99  , 22  , FP_CI_02_MID_120_);
%plotter(FP_CI_0to2           , one year , Manufacturing , 120 , 115-21 , -99   , 25     , -99  , 22  , FP_CI_02_MID_year_120_);
%plotter(FP_CI_0to2           , one year , Test          , 120 , 115-21 , -99   , 25     , -99  , 22  , FP_CI_02_MID_year_120_);

%plotter(FP_CI_3to5           , all      , Manufacturing , 120 , 115-21 , 39    , 67     , 41   , 65  , FP_CI_35_MID_120_);
%plotter(FP_CI_3to5           , all      , Test          , 120 , 115-21 , 39    , 67     , 41   , 65  , FP_CI_35_MID_120_);
%plotter(FP_CI_3to5           , one year , Manufacturing , 120 , 115-21 , 39    , 67     , 41   , 65  , FP_CI_35_MID_year_120_);
%plotter(FP_CI_3to5           , one year , Test          , 120 , 115-21 , 39    , 67     , 41   , 65  , FP_CI_35_MID_year_120_);

%plotter(FP_CI_6toF           , all      , Manufacturing , 120 , 115-21 , -99   , 3      , -99  , 3   , FP_CI_6F_MID_120_);
%plotter(FP_CI_6toF           , all      , Test          , 120 , 115-21 , -99   , 3      , -99  , 3   , FP_CI_6F_MID_120_);
%plotter(FP_CI_6toF           , one year , Manufacturing , 120 , 115-21 , -99   , 3      , -99  , 3   , FP_CI_6F_MID_year_120_);
%plotter(FP_CI_6toF           , one year , Test          , 120 , 115-21 , -99   , 3      , -99  , 3   , FP_CI_6F_MID_year_120_);

%plotter(FP_CI_Throat         , all      , Manufacturing , 120 , 115-21 , 25    , 54     , 26   , 52  , FP_CI_Throat_MID_120_);
%plotter(FP_CI_Throat         , all      , Test          , 120 , 115-21 , 24    , 54     , 26   , 52  , FP_CI_Throat_MID_120_);
%plotter(FP_CI_Throat         , one year , Manufacturing , 120 , 115-21 , 24    , 54     , 26   , 52  , FP_CI_Throat_MID_year_120_);
%plotter(FP_CI_Throat         , one year , Test          , 120 , 115-21 , 24    , 54     , 26   , 52  , FP_CI_Throat_MID_year_120_);

/***%plotter(FP_CI_Total_ExDevice , all      , Manufacturing , 120 , 115-21 , 93    , 128    , -99  , -99 , FP_CI_Total_ExDevice_MID_120_);***/
/***%plotter(FP_CI_Total_ExDevice , all      , Test          , 120 , 115-21 , 93    , 128    , -99  , -99 , FP_CI_Total_ExDevice_MID_120_);***/
/***%plotter(FP_CI_Total_ExDevice , one year , Manufacturing , 120 , 115-21 , 93    , 128    , -99  , -99 , FP_CI_Total_ExDevice_MID_year_120_);***/
/***%plotter(FP_CI_Total_ExDevice , one year , Test          , 120 , 115-21 , 93    , 128    , -99  , -99 , FP_CI_Total_ExDevice_MID_year_120_);***/
%plotter(FP_CI_Total_ExDevice , all      , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_CI_Total_ExDevice_MID_120_);
%plotter(FP_CI_Total_ExDevice , all      , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_CI_Total_ExDevice_MID_120_);
%plotter(FP_CI_Total_ExDevice , one year , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_CI_Total_ExDevice_MID_year_120_);
%plotter(FP_CI_Total_ExDevice , one year , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_CI_Total_ExDevice_MID_year_120_);

%plotter(FP_DTU_BEG           , all      , Manufacturing , 120 , 115-21 , 86.25 , 143.75 , 92   , 138 , FP_DTU_beg_MID_120_);
%plotter(FP_DTU_BEG           , all      , Test          , 120 , 115-21 , 86.25 , 143.75 , 92   , 138 , FP_DTU_beg_MID_120_);
%plotter(FP_DTU_BEG           , one year , Manufacturing , 120 , 115-21 , 86.25 , 143.75 , 92   , 138 , FP_DTU_beg_MID_year_120_);
%plotter(FP_DTU_BEG           , one year , Test          , 120 , 115-21 , 86.25 , 143.75 , 92   , 138 , FP_DTU_beg_MID_year_120_);

%plotter(FP_DTU_DIFF          , all      , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_DTU_diff_MID_120_);
%plotter(FP_DTU_DIFF          , all      , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_DTU_diff_MID_120_);
%plotter(FP_DTU_DIFF          , one year , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_DTU_diff_MID_year_120_);
%plotter(FP_DTU_DIFF          , one year , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_DTU_diff_MID_year_120_);

%plotter(FP_DTU_END           , all      , Manufacturing , 120 , 115-21 , 86.25 , 143.75 , 92   , 138 , FP_DTU_end_MID_120_);
%plotter(FP_DTU_END           , all      , Test          , 120 , 115-21 , 86.25 , 143.75 , 92   , 138 , FP_DTU_end_MID_120_);
%plotter(FP_DTU_END           , one year , Manufacturing , 120 , 115-21 , 86.25 , 143.75 , 92   , 138 , FP_DTU_end_MID_year_120_);
%plotter(FP_DTU_END           , one year , Test          , 120 , 115-21 , 86.25 , 143.75 , 92   , 138 , FP_DTU_end_MID_year_120_);

%plotter(FP_TDC_can_wall      , all      , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_TDC_can_wall_MID_120_);
%plotter(FP_TDC_can_wall      , all      , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_TDC_can_wall_MID_120_);
%plotter(FP_TDC_can_wall      , one year , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_TDC_can_wall_MID_year_120_);
%plotter(FP_TDC_can_wall      , one year , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_TDC_can_wall_MID_year_120_);

%plotter(FP_TDC_concentration , all      , Manufacturing , 120 , 115-21 , 1.48  , 1.809  , 1.51 , 1.78, FP_TDC_conc_MID_120_);
%plotter(FP_TDC_concentration , all      , Test          , 120 , 115-21 , 1.48  , 1.809  , 1.51 , 1.78, FP_TDC_conc_MID_120_);
%plotter(FP_TDC_concentration , one year , Manufacturing , 120 , 115-21 , 1.48  , 1.809  , 1.51 , 1.78, FP_TDC_conc_MID_year_120_);
%plotter(FP_TDC_concentration , one year , Test          , 120 , 115-21 , 1.48  , 1.809  , 1.51 , 1.78, FP_TDC_conc_MID_year_120_);

%plotter(FP_TDC_suspension    , all      , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_TDC_suspension_MID_120_);
%plotter(FP_TDC_suspension    , all      , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_TDC_suspension_MID_120_);
%plotter(FP_TDC_suspension    , one year , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_TDC_suspension_MID_year_120_);
%plotter(FP_TDC_suspension    , one year , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_TDC_suspension_MID_year_120_);

%plotter(FP_TDC_total_mass    , all      , Manufacturing , 120 , 115-21 , 18.61 , 22.74  , 19.0 , 22.3, FP_TDC_total_mass_MID_120_);
%plotter(FP_TDC_total_mass    , all      , Test          , 120 , 115-21 , 18.61 , 22.74  , 19.0 , 22.3, FP_TDC_total_mass_MID_120_);
%plotter(FP_TDC_total_mass    , one year , Manufacturing , 120 , 115-21 , 18.61 , 22.74  , 19.0 , 22.3, FP_TDC_total_mass_MID_year_120_);
%plotter(FP_TDC_total_mass    , one year , Test          , 120 , 115-21 , 18.61 , 22.74  , 19.0 , 22.3, FP_TDC_total_mass_MID_year_120_);

%plotter(FP_TDC_valve         , all      , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_TDC_valve_MID_120_);
%plotter(FP_TDC_valve         , all      , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_TDC_valve_MID_120_);
%plotter(FP_TDC_valve         , one year , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_TDC_valve_MID_year_120_);
%plotter(FP_TDC_valve         , one year , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , FP_TDC_valve_MID_year_120_);

%plotter(Leak                 , all      , Manufacturing , 120 , 115-21 , -99   , 500    , -99  , 440 , LEAK_MID_120_);
%plotter(Leak                 , all      , Test          , 120 , 115-21 , -99   , 500    , -99  , 440 , LEAK_MID_120_);
%plotter(Leak                 , one year , Manufacturing , 120 , 115-21 , -99   , 500    , -99  , 440 , LEAK_MID_year_120_);
%plotter(Leak                 , one year , Test          , 120 , 115-21 , -99   , 500    , -99  , 440 , LEAK_MID_year_120_);

%plotter(SX_CI_0to2           , all      , Manufacturing , 120 , 115-21 , -99   , 6      , -99  , 5   , SX_CI_02_MID_120_);
%plotter(SX_CI_0to2           , all      , Test          , 120 , 115-21 , -99   , 6      , -99  , 5   , SX_CI_02_MID_120_);
%plotter(SX_CI_0to2           , one year , Manufacturing , 120 , 115-21 , -99   , 6      , -99  , 5   , SX_CI_02_MID_year_120_);
%plotter(SX_CI_0to2           , one year , Test          , 120 , 115-21 , -99   , 6      , -99  , 5   , SX_CI_02_MID_year_120_);

%plotter(SX_CI_3to5           , all      , Manufacturing , 120 , 115-21 , 7     , 13     , 7    , 12  , SX_CI_35_MID_120_);
%plotter(SX_CI_3to5           , all      , Test          , 120 , 115-21 , 7     , 13     , 7    , 12  , SX_CI_35_MID_120_);
%plotter(SX_CI_3to5           , one year , Manufacturing , 120 , 115-21 , 7     , 13     , 7    , 12  , SX_CI_35_MID_year_120_);
%plotter(SX_CI_3to5           , one year , Test          , 120 , 115-21 , 7     , 13     , 7    , 12  , SX_CI_35_MID_year_120_);

%plotter(SX_CI_6toF           , all      , Manufacturing , 120 , 115-21 , -99   , 1      , -99  , 1   , SX_CI_6F_MID_120_);
%plotter(SX_CI_6toF           , all      , Test          , 120 , 115-21 , -99   , 1      , -99  , 1   , SX_CI_6F_MID_120_);
%plotter(SX_CI_6toF           , one year , Manufacturing , 120 , 115-21 , -99   , 1      , -99  , 1   , SX_CI_6F_MID_year_120_);
%plotter(SX_CI_6toF           , one year , Test          , 120 , 115-21 , -99   , 1      , -99  , 1   , SX_CI_6F_MID_year_120_);

%plotter(SX_CI_Throat         , all      , Manufacturing , 120 , 115-21 , 3     , 11     , 4    , 10  , SX_CI_Throat_MID_120_);
%plotter(SX_CI_Throat         , all      , Test          , 120 , 115-21 , 3     , 11     , 4    , 10  , SX_CI_Throat_MID_120_);
%plotter(SX_CI_Throat         , one year , Manufacturing , 120 , 115-21 , 3     , 11     , 4    , 10  , SX_CI_Throat_MID_year_120_);
%plotter(SX_CI_Throat         , one year , Test          , 120 , 115-21 , 3     , 11     , 4    , 10  , SX_CI_Throat_MID_year_120_);

/***%plotter(SX_CI_Total_ExDevice , all      , Manufacturing , 120 , 115-21 , 17.4  , 23.7   , -99  , -99 , SX_CI_Total_ExDevice_MID_120_);***/
/***%plotter(SX_CI_Total_ExDevice , all      , Test          , 120 , 115-21 , 17.4  , 23.7   , -99  , -99 , SX_CI_Total_ExDevice_MID_120_);***/
/***%plotter(SX_CI_Total_ExDevice , one year , Manufacturing , 120 , 115-21 , 17.4  , 23.7   , -99  , -99 , SX_CI_Total_ExDevice_MID_year_120_);***/
/***%plotter(SX_CI_Total_ExDevice , one year , Test          , 120 , 115-21 , 17.4  , 23.7   , -99  , -99 , SX_CI_Total_ExDevice_MID_year_120_);***/
%plotter(SX_CI_Total_ExDevice , all      , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_CI_Total_ExDevice_MID_120_);
%plotter(SX_CI_Total_ExDevice , all      , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_CI_Total_ExDevice_MID_120_);
%plotter(SX_CI_Total_ExDevice , one year , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_CI_Total_ExDevice_MID_year_120_);
%plotter(SX_CI_Total_ExDevice , one year , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_CI_Total_ExDevice_MID_year_120_);

%plotter(SX_DTU_BEG           , all      , Manufacturing , 120 , 115-21 , 14.7  , 27.3   , 16.8 , 25.2, SX_DTU_beg_MID_120_);
%plotter(SX_DTU_BEG           , all      , Test          , 120 , 115-21 , 14.7  , 27.3   , 16.8 , 25.2, SX_DTU_beg_MID_120_);
%plotter(SX_DTU_BEG           , one year , Manufacturing , 120 , 115-21 , 14.7  , 27.3   , 16.8 , 25.2, SX_DTU_beg_MID_year_120_);
%plotter(SX_DTU_BEG           , one year , Test          , 120 , 115-21 , 14.7  , 27.3   , 16.8 , 25.2, SX_DTU_beg_MID_year_120_);

%plotter(SX_DTU_DIFF          , all      , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_DTU_diff_MID_120_);
%plotter(SX_DTU_DIFF          , all      , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_DTU_diff_MID_120_);
%plotter(SX_DTU_DIFF          , one year , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_DTU_diff_MID_year_120_);
%plotter(SX_DTU_DIFF          , one year , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_DTU_diff_MID_year_120_);

%plotter(SX_DTU_END           , all      , Manufacturing , 120 , 115-21 , 14.7  , 27.3   , 16.8 , 25.2, SX_DTU_end_MID_120_);
%plotter(SX_DTU_END           , all      , Test          , 120 , 115-21 , 14.7  , 27.3   , 16.8 , 25.2, SX_DTU_end_MID_120_);
%plotter(SX_DTU_END           , one year , Manufacturing , 120 , 115-21 , 14.7  , 27.3   , 16.8 , 25.2, SX_DTU_end_MID_year_120_);
%plotter(SX_DTU_END           , one year , Test          , 120 , 115-21 , 14.7  , 27.3   , 16.8 , 25.2, SX_DTU_end_MID_year_120_);

%plotter(SX_TDC_can_wall      , all      , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_TDC_can_wall_MID_120_);
%plotter(SX_TDC_can_wall      , all      , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_TDC_can_wall_MID_120_);
%plotter(SX_TDC_can_wall      , one year , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_TDC_can_wall_MID_year_120_);
%plotter(SX_TDC_can_wall      , one year , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_TDC_can_wall_MID_year_120_);

%plotter(SX_TDC_concentration , all      , Manufacturing , 120 , 115-21 , 0.288 , 0.352  , 0.29 , 0.35, SX_TDC_conc_MID_120_);
%plotter(SX_TDC_concentration , all      , Test          , 120 , 115-21 , 0.288 , 0.352  , 0.29 , 0.35, SX_TDC_conc_MID_120_);
%plotter(SX_TDC_concentration , one year , Manufacturing , 120 , 115-21 , 0.288 , 0.352  , 0.29 , 0.35, SX_TDC_conc_MID_year_120_);
%plotter(SX_TDC_concentration , one year , Test          , 120 , 115-21 , 0.288 , 0.352  , 0.29 , 0.35, SX_TDC_conc_MID_year_120_);

%plotter(SX_TDC_suspension    , all      , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_TDC_suspension_MID_120_);
%plotter(SX_TDC_suspension    , all      , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_TDC_suspension_MID_120_);
%plotter(SX_TDC_suspension    , one year , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_TDC_suspension_MID_year_120_);
%plotter(SX_TDC_suspension    , one year , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_TDC_suspension_MID_year_120_);

%plotter(SX_TDC_total_mass    , all      , Manufacturing , 120 , 115-21 , 3.61  , 4.41   , 3.7  , 4.3 , SX_TDC_total_mass_MID_120_);
%plotter(SX_TDC_total_mass    , all      , Test          , 120 , 115-21 , 3.61  , 4.41   , 3.7  , 4.3 , SX_TDC_total_mass_MID_120_);
%plotter(SX_TDC_total_mass    , one year , Manufacturing , 120 , 115-21 , 3.61  , 4.41   , 3.7  , 4.3 , SX_TDC_total_mass_MID_year_120_);
%plotter(SX_TDC_total_mass    , one year , Test          , 120 , 115-21 , 3.61  , 4.41   , 3.7  , 4.3 , SX_TDC_total_mass_MID_year_120_);

%plotter(SX_TDC_valve         , all      , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_TDC_valve_MID_120_);
%plotter(SX_TDC_valve         , all      , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_TDC_valve_MID_120_);
%plotter(SX_TDC_valve         , one year , Manufacturing , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_TDC_valve_MID_year_120_);
%plotter(SX_TDC_valve         , one year , Test          , 120 , 115-21 , -99   , -99    , -99  , -99 , SX_TDC_valve_MID_year_120_);

%plotter(content_weight       , all      , Manufacturing , 120 , 115-21 , 10.8  , 12.3   , 11.1 , 12.3, CONTENT_WEIGHT_MID_120_);
%plotter(content_weight       , all      , Test          , 120 , 115-21 , 10.8  , 12.3   , 11.1 , 12.3, CONTENT_WEIGHT_MID_120_);
%plotter(content_weight       , one year , Manufacturing , 120 , 115-21 , 10.8  , 12.3   , 11.1 , 12.3, CONTENT_WEIGHT_MID_year_120_);
%plotter(content_weight       , one year , Test          , 120 , 115-21 , 10.8  , 12.3   , 11.1 , 12.3, CONTENT_WEIGHT_MID_year_120_);

%plotter(moisture             , all      , Manufacturing , 120 , 115-21 , -99   , 175    , -99  , 150 , MOISTURE_MID_120_);
%plotter(moisture             , all      , Test          , 120 , 115-21 , -99   , 175    , -99  , 150 , MOISTURE_MID_120_);
%plotter(moisture             , one year , Manufacturing , 120 , 115-21 , -99   , 175    , -99  , 150 , MOISTURE_MID_year_120_);
%plotter(moisture             , one year , Test          , 120 , 115-21 , -99   , 175    , -99  , 150 , MOISTURE_MID_year_120_);

%plotter(shot_weight          , all      , Manufacturing , 120 , 115-21 , 63    , 85     , 67   , 81  , SHOT_WEIGHT_MID_120_);
%plotter(shot_weight          , all      , Test          , 120 , 115-21 , 63    , 85     , 67   , 81  , SHOT_WEIGHT_MID_120_);
%plotter(shot_weight          , one year , Manufacturing , 120 , 115-21 , 63    , 85     , 67   , 81  , SHOT_WEIGHT_MID_year_120_);
%plotter(shot_weight          , one year , Test          , 120 , 115-21 , 63    , 85     , 67   , 81  , SHOT_WEIGHT_MID_year_120_);

%plotter(total_imp_max        , all      , Manufacturing , 120 , 115-21 , -99   , 2.1    , -99  , 2.1 , TOTAL_IMPURITIES_MID_120_);
%plotter(total_imp_max        , all      , Test          , 120 , 115-21 , -99   , 2.1    , -99  , 2.1 , TOTAL_IMPURITIES_MID_120_);
%plotter(total_imp_max        , one year , Manufacturing , 120 , 115-21 , -99   , 2.1    , -99  , 2.1 , TOTAL_IMPURITIES_MID_year_120_);
%plotter(total_imp_max        , one year , Test          , 120 , 115-21 , -99   , 2.1    , -99  , 2.1 , TOTAL_IMPURITIES_MID_year_120_);
/**********************************************************************/

/**********************************************************************/
%plotter(FP_CI_0to2           , all      , Manufacturing , 120 , 230-21 , -99   , 59    , -99  , 52   , FP_CI_02_HIGH_120_);
%plotter(FP_CI_0to2           , all      , Test          , 120 , 230-21 , -99   , 59    , -99  , 52   , FP_CI_02_HIGH_120_);
%plotter(FP_CI_0to2           , one year , Manufacturing , 120 , 230-21 , -99   , 59    , -99  , 52   , FP_CI_02_HIGH_year_120_);
%plotter(FP_CI_0to2           , one year , Test          , 120 , 230-21 , -99   , 59    , -99  , 52   , FP_CI_02_HIGH_year_120_);

%plotter(FP_CI_3to5           , all      , Manufacturing , 120 , 230-21 , 77    , 124   , 81   , 120  , FP_CI_35_HIGH_120_);
%plotter(FP_CI_3to5           , all      , Test          , 120 , 230-21 , 77    , 124   , 81   , 120  , FP_CI_35_HIGH_120_);
%plotter(FP_CI_3to5           , one year , Manufacturing , 120 , 230-21 , 77    , 124   , 81   , 120  , FP_CI_35_HIGH_year_120_);
%plotter(FP_CI_3to5           , one year , Test          , 120 , 230-21 , 77    , 124   , 81   , 120  , FP_CI_35_HIGH_year_120_);

%plotter(FP_CI_6toF           , all      , Manufacturing , 120 , 230-21 , -99   , 4     , -99  , 4    , FP_CI_6F_HIGH_120_);
%plotter(FP_CI_6toF           , all      , Test          , 120 , 230-21 , -99   , 4     , -99  , 4    , FP_CI_6F_HIGH_120_);
%plotter(FP_CI_6toF           , one year , Manufacturing , 120 , 230-21 , -99   , 4     , -99  , 4    , FP_CI_6F_HIGH_year_120_);
%plotter(FP_CI_6toF           , one year , Test          , 120 , 230-21 , -99   , 4     , -99  , 4    , FP_CI_6F_HIGH_year_120_);

%plotter(FP_CI_Throat         , all      , Manufacturing , 120 , 230-21 , 59    , 109   , 64   , 104  , FP_CI_Throat_HIGH_120_);
%plotter(FP_CI_Throat         , all      , Test          , 120 , 230-21 , 59    , 109   , 64   , 104  , FP_CI_Throat_HIGH_120_);
%plotter(FP_CI_Throat         , one year , Manufacturing , 120 , 230-21 , 59    , 109   , 64   , 104  , FP_CI_Throat_HIGH_year_120_);
%plotter(FP_CI_Throat         , one year , Test          , 120 , 230-21 , 59    , 109   , 64   , 104  , FP_CI_Throat_HIGH_year_120_);

/***%plotter(FP_CI_Total_ExDevice , all      , Manufacturing , 120 , 230-21 , 193   , 262   , -99  , -99  , FP_CI_Total_ExDevice_HIGH_120_);***/
/***%plotter(FP_CI_Total_ExDevice , all      , Test          , 120 , 230-21 , 193   , 262   , -99  , -99  , FP_CI_Total_ExDevice_HIGH_120_);***/
/***%plotter(FP_CI_Total_ExDevice , one year , Manufacturing , 120 , 230-21 , 193   , 262   , -99  , -99  , FP_CI_Total_ExDevice_HIGH_year_120_);***/
/***%plotter(FP_CI_Total_ExDevice , one year , Test          , 120 , 230-21 , 193   , 262   , -99  , -99  , FP_CI_Total_ExDevice_HIGH_year_120_);***/
%plotter(FP_CI_Total_ExDevice , all      , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_CI_Total_ExDevice_HIGH_120_);
%plotter(FP_CI_Total_ExDevice , all      , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_CI_Total_ExDevice_HIGH_120_);
%plotter(FP_CI_Total_ExDevice , one year , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_CI_Total_ExDevice_HIGH_year_120_);
%plotter(FP_CI_Total_ExDevice , one year , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_CI_Total_ExDevice_HIGH_year_120_);

%plotter(FP_DTU_BEG           , all      , Manufacturing , 120 , 230-21 , 172.5 , 287.5 , 184  , 276  , FP_DTU_beg_HIGH_120_);
%plotter(FP_DTU_BEG           , all      , Test          , 120 , 230-21 , 172.5 , 287.5 , 184  , 276  , FP_DTU_beg_HIGH_120_);
%plotter(FP_DTU_BEG           , one year , Manufacturing , 120 , 230-21 , 172.5 , 287.5 , 184  , 276  , FP_DTU_beg_HIGH_year_120_);
%plotter(FP_DTU_BEG           , one year , Test          , 120 , 230-21 , 172.5 , 287.5 , 184  , 276  , FP_DTU_beg_HIGH_year_120_);

%plotter(FP_DTU_DIFF          , all      , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_DTU_diff_HIGH_120_);
%plotter(FP_DTU_DIFF          , all      , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_DTU_diff_HIGH_120_);
%plotter(FP_DTU_DIFF          , one year , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_DTU_diff_HIGH_year_120_);
%plotter(FP_DTU_DIFF          , one year , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_DTU_diff_HIGH_year_120_);

%plotter(FP_DTU_END           , all      , Manufacturing , 120 , 230-21 , 172.5 , 287.5 , 184  , 276  , FP_DTU_end_HIGH_120_);
%plotter(FP_DTU_END           , all      , Test          , 120 , 230-21 , 172.5 , 287.5 , 184  , 276  , FP_DTU_end_HIGH_120_);
%plotter(FP_DTU_END           , one year , Manufacturing , 120 , 230-21 , 172.5 , 287.5 , 184  , 276  , FP_DTU_end_HIGH_year_120_);
%plotter(FP_DTU_END           , one year , Test          , 120 , 230-21 , 172.5 , 287.5 , 184  , 276  , FP_DTU_end_HIGH_year_120_);

%plotter(FP_TDC_can_wall      , all      , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_TDC_can_wall_HIGH_120_);
%plotter(FP_TDC_can_wall      , all      , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_TDC_can_wall_HIGH_120_);
%plotter(FP_TDC_can_wall      , one year , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_TDC_can_wall_HIGH_year_120_);
%plotter(FP_TDC_can_wall      , one year , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_TDC_can_wall_HIGH_year_120_);

%plotter(FP_TDC_concentration , all      , Manufacturing , 120 , 230-21 , 2.939 , 3.592 , 3.0  , 3.53 , FP_TDC_conc_HIGH_120_);
%plotter(FP_TDC_concentration , all      , Test          , 120 , 230-21 , 2.939 , 3.592 , 3.0  , 3.53 , FP_TDC_conc_HIGH_120_);
%plotter(FP_TDC_concentration , one year , Manufacturing , 120 , 230-21 , 2.939 , 3.592 , 3.0  , 3.53 , FP_TDC_conc_HIGH_year_120_);
%plotter(FP_TDC_concentration , one year , Test          , 120 , 230-21 , 2.939 , 3.592 , 3.0  , 3.53 , FP_TDC_conc_HIGH_year_120_);

%plotter(FP_TDC_suspension    , all      , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_TDC_suspension_HIGH_120_);
%plotter(FP_TDC_suspension    , all      , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_TDC_suspension_HIGH_120_);
%plotter(FP_TDC_suspension    , one year , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_TDC_suspension_HIGH_year_120_);
%plotter(FP_TDC_suspension    , one year , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_TDC_suspension_HIGH_year_120_);

%plotter(FP_TDC_total_mass    , all      , Manufacturing , 120 , 230-21 , 36.65 , 44.79 , 37.5 , 44.0 , FP_TDC_total_mass_HIGH_120_);
%plotter(FP_TDC_total_mass    , all      , Test          , 120 , 230-21 , 36.65 , 44.79 , 37.5 , 44.0 , FP_TDC_total_mass_HIGH_120_);
%plotter(FP_TDC_total_mass    , one year , Manufacturing , 120 , 230-21 , 36.65 , 44.79 , 37.5 , 44.0 , FP_TDC_total_mass_HIGH_year_120_);
%plotter(FP_TDC_total_mass    , one year , Test          , 120 , 230-21 , 36.65 , 44.79 , 37.5 , 44.0 , FP_TDC_total_mass_HIGH_year_120_);

%plotter(FP_TDC_valve         , all      , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_TDC_valve_HIGH_120_);
%plotter(FP_TDC_valve         , all      , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_TDC_valve_HIGH_120_);
%plotter(FP_TDC_valve         , one year , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_TDC_valve_HIGH_year_120_);
%plotter(FP_TDC_valve         , one year , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , FP_TDC_valve_HIGH_year_120_);

%plotter(Leak                 , all      , Manufacturing , 120 , 230-21 , -99   , 500   , -99  , 440  , LEAK_HIGH_120_);
%plotter(Leak                 , all      , Test          , 120 , 230-21 , -99   , 500   , -99  , 440  , LEAK_HIGH_120_);
%plotter(Leak                 , one year , Manufacturing , 120 , 230-21 , -99   , 500   , -99  , 440  , LEAK_HIGH_year_120_);
%plotter(Leak                 , one year , Test          , 120 , 230-21 , -99   , 500   , -99  , 440  , LEAK_HIGH_year_120_);

%plotter(SX_CI_0to2           , all      , Manufacturing , 120 , 230-21 , -99   , 7     , -99  , 6    , SX_CI_02_HIGH_120_);
%plotter(SX_CI_0to2           , all      , Test          , 120 , 230-21 , -99   , 7     , -99  , 6    , SX_CI_02_HIGH_120_);
%plotter(SX_CI_0to2           , one year , Manufacturing , 120 , 230-21 , -99   , 7     , -99  , 6    , SX_CI_02_HIGH_year_120_);
%plotter(SX_CI_0to2           , one year , Test          , 120 , 230-21 , -99   , 7     , -99  , 6    , SX_CI_02_HIGH_year_120_);

%plotter(SX_CI_3to5           , all      , Manufacturing , 120 , 230-21 , 7     , 13    , 7    , 12   , SX_CI_35_HIGH_120_);
%plotter(SX_CI_3to5           , all      , Test          , 120 , 230-21 , 7     , 13    , 7    , 12   , SX_CI_35_HIGH_120_);
%plotter(SX_CI_3to5           , one year , Manufacturing , 120 , 230-21 , 7     , 13    , 7    , 12   , SX_CI_35_HIGH_year_120_);
%plotter(SX_CI_3to5           , one year , Test          , 120 , 230-21 , 7     , 13    , 7    , 12   , SX_CI_35_HIGH_year_120_);

%plotter(SX_CI_6toF           , all      , Manufacturing , 120 , 230-21 , -99   , 1     , -99  , 1    , SX_CI_6F_HIGH_120_);
%plotter(SX_CI_6toF           , all      , Test          , 120 , 230-21 , -99   , 1     , -99  , 1    , SX_CI_6F_HIGH_120_);
%plotter(SX_CI_6toF           , one year , Manufacturing , 120 , 230-21 , -99   , 1     , -99  , 1    , SX_CI_6F_HIGH_year_120_);
%plotter(SX_CI_6toF           , one year , Test          , 120 , 230-21 , -99   , 1     , -99  , 1    , SX_CI_6F_HIGH_year_120_);

%plotter(SX_CI_Throat         , all      , Manufacturing , 120 , 230-21 , 4     , 12    , 5    , 11   , SX_CI_Throat_HIGH_120_);
%plotter(SX_CI_Throat         , all      , Test          , 120 , 230-21 , 4     , 12    , 5    , 11   , SX_CI_Throat_HIGH_120_);
%plotter(SX_CI_Throat         , one year , Manufacturing , 120 , 230-21 , 4     , 12    , 5    , 11   , SX_CI_Throat_HIGH_year_120_);
%plotter(SX_CI_Throat         , one year , Test          , 120 , 230-21 , 4     , 12    , 5    , 11   , SX_CI_Throat_HIGH_year_120_);

/***%plotter(SX_CI_Total_ExDevice , all      , Manufacturing , 120 , 230-21 , 17.9  , 24.2  , -99  , -99  , SX_CI_Total_ExDevice_HIGH_120_);***/
/***%plotter(SX_CI_Total_ExDevice , all      , Test          , 120 , 230-21 , 17.9  , 24.2  , -99  , -99  , SX_CI_Total_ExDevice_HIGH_120_);***/
/***%plotter(SX_CI_Total_ExDevice , one year , Manufacturing , 120 , 230-21 , 17.9  , 24.2  , -99  , -99  , SX_CI_Total_ExDevice_HIGH_year_120_);***/
/***%plotter(SX_CI_Total_ExDevice , one year , Test          , 120 , 230-21 , 17.9  , 24.2  , -99  , -99  , SX_CI_Total_ExDevice_HIGH_year_120_);***/
%plotter(SX_CI_Total_ExDevice , all      , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_CI_Total_ExDevice_HIGH_120_);
%plotter(SX_CI_Total_ExDevice , all      , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_CI_Total_ExDevice_HIGH_120_);
%plotter(SX_CI_Total_ExDevice , one year , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_CI_Total_ExDevice_HIGH_year_120_);
%plotter(SX_CI_Total_ExDevice , one year , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_CI_Total_ExDevice_HIGH_year_120_);

%plotter(SX_DTU_BEG           , all      , Manufacturing , 120 , 230-21 , 14.7  , 27.3  , 16.8 , 25.2 , SX_DTU_beg_HIGH_120_);
%plotter(SX_DTU_BEG           , all      , Test          , 120 , 230-21 , 14.7  , 27.3  , 16.8 , 25.2 , SX_DTU_beg_HIGH_120_);
%plotter(SX_DTU_BEG           , one year , Manufacturing , 120 , 230-21 , 14.7  , 27.3  , 16.8 , 25.2 , SX_DTU_beg_HIGH_year_120_);
%plotter(SX_DTU_BEG           , one year , Test          , 120 , 230-21 , 14.7  , 27.3  , 16.8 , 25.2 , SX_DTU_beg_HIGH_year_120_);

%plotter(SX_DTU_DIFF          , all      , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_DTU_diff_HIGH_120_);
%plotter(SX_DTU_DIFF          , all      , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_DTU_diff_HIGH_120_);
%plotter(SX_DTU_DIFF          , one year , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_DTU_diff_HIGH_year_120_);
%plotter(SX_DTU_DIFF          , one year , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_DTU_diff_HIGH_year_120_);

%plotter(SX_DTU_END           , all      , Manufacturing , 120 , 230-21 , 14.7  , 27.3  , 16.8 , 25.2 , SX_DTU_end_HIGH_120_);
%plotter(SX_DTU_END           , all      , Test          , 120 , 230-21 , 14.7  , 27.3  , 16.8 , 25.2 , SX_DTU_end_HIGH_120_);
%plotter(SX_DTU_END           , one year , Manufacturing , 120 , 230-21 , 14.7  , 27.3  , 16.8 , 25.2 , SX_DTU_end_HIGH_year_120_);
%plotter(SX_DTU_END           , one year , Test          , 120 , 230-21 , 14.7  , 27.3  , 16.8 , 25.2 , SX_DTU_end_HIGH_year_120_);

%plotter(SX_TDC_can_wall      , all      , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_TDC_can_wall_HIGH_120_);
%plotter(SX_TDC_can_wall      , all      , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_TDC_can_wall_HIGH_120_);
%plotter(SX_TDC_can_wall      , one year , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_TDC_can_wall_HIGH_year_120_);
%plotter(SX_TDC_can_wall      , one year , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_TDC_can_wall_HIGH_year_120_);

%plotter(SX_TDC_concentration , all      , Manufacturing , 120 , 230-21 , 0.279 , 0.341 , 0.29 , 0.34 , SX_TDC_conc_HIGH_120_);
%plotter(SX_TDC_concentration , all      , Test          , 120 , 230-21 , 0.279 , 0.341 , 0.29 , 0.34 , SX_TDC_conc_HIGH_120_);
%plotter(SX_TDC_concentration , one year , Manufacturing , 120 , 230-21 , 0.279 , 0.341 , 0.29 , 0.34 , SX_TDC_conc_HIGH_year_120_);
%plotter(SX_TDC_concentration , one year , Test          , 120 , 230-21 , 0.279 , 0.341 , 0.29 , 0.34 , SX_TDC_conc_HIGH_year_120_);

%plotter(SX_TDC_suspension    , all      , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_TDC_suspension_HIGH_120_);
%plotter(SX_TDC_suspension    , all      , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_TDC_suspension_HIGH_120_);
%plotter(SX_TDC_suspension    , one year , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_TDC_suspension_HIGH_year_120_);
%plotter(SX_TDC_suspension    , one year , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_TDC_suspension_HIGH_year_120_);

%plotter(SX_TDC_total_mass    , all      , Manufacturing , 120 , 230-21 , 3.48  , 4.25  , 3.6  , 4.2  , SX_TDC_total_mass_HIGH_120_);
%plotter(SX_TDC_total_mass    , all      , Test          , 120 , 230-21 , 3.48  , 4.25  , 3.6  , 4.2  , SX_TDC_total_mass_HIGH_120_);
%plotter(SX_TDC_total_mass    , one year , Manufacturing , 120 , 230-21 , 3.48  , 4.25  , 3.6  , 4.2  , SX_TDC_total_mass_HIGH_year_120_);
%plotter(SX_TDC_total_mass    , one year , Test          , 120 , 230-21 , 3.48  , 4.25  , 3.6  , 4.2  , SX_TDC_total_mass_HIGH_year_120_);

%plotter(SX_TDC_valve         , all      , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_TDC_valve_HIGH_120_);
%plotter(SX_TDC_valve         , all      , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_TDC_valve_HIGH_120_);
%plotter(SX_TDC_valve         , one year , Manufacturing , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_TDC_valve_HIGH_year_120_);
%plotter(SX_TDC_valve         , one year , Test          , 120 , 230-21 , -99   , -99   , -99  , -99  , SX_TDC_valve_HIGH_year_120_);

%plotter(content_weight       , all      , Manufacturing , 120 , 230-21 , 10.8  , 12.3  , 11.1 , 12.3 , CONTENT_WEIGHT_HIGH_120_);
%plotter(content_weight       , all      , Test          , 120 , 230-21 , 10.8  , 12.3  , 11.1 , 12.3 , CONTENT_WEIGHT_HIGH_120_);
%plotter(content_weight       , one year , Manufacturing , 120 , 230-21 , 10.8  , 12.3  , 11.1 , 12.3 , CONTENT_WEIGHT_HIGH_year_120_);
%plotter(content_weight       , one year , Test          , 120 , 230-21 , 10.8  , 12.3  , 11.1 , 12.3 , CONTENT_WEIGHT_HIGH_year_120_);

%plotter(moisture             , all      , Manufacturing , 120 , 230-21 , -99   , 175   , -99  , 150  , MOISTURE_HIGH_120_);
%plotter(moisture             , all      , Test          , 120 , 230-21 , -99   , 175   , -99  , 150  , MOISTURE_HIGH_120_);
%plotter(moisture             , one year , Manufacturing , 120 , 230-21 , -99   , 175   , -99  , 150  , MOISTURE_HIGH_year_120_);
%plotter(moisture             , one year , Test          , 120 , 230-21 , -99   , 175   , -99  , 150  , MOISTURE_HIGH_year_120_);

%plotter(shot_weight          , all      , Manufacturing , 120 , 230-21 , 63    , 85    , 67   , 81   , SHOT_WEIGHT_HIGH_120_);
%plotter(shot_weight          , all      , Test          , 120 , 230-21 , 63    , 85    , 67   , 81   , SHOT_WEIGHT_HIGH_120_);
%plotter(shot_weight          , one year , Manufacturing , 120 , 230-21 , 63    , 85    , 67   , 81   , SHOT_WEIGHT_HIGH_year_120_);
%plotter(shot_weight          , one year , Test          , 120 , 230-21 , 63    , 85    , 67   , 81   , SHOT_WEIGHT_HIGH_year_120_);

%plotter(total_imp_max        , all      , Manufacturing , 120 , 230-21 , -99   , 2.1   , -99  , 2.1  , TOTAL_IMPURITIES_HIGH_120_);
%plotter(total_imp_max        , all      , Test          , 120 , 230-21 , -99   , 2.1   , -99  , 2.1  , TOTAL_IMPURITIES_HIGH_120_);
%plotter(total_imp_max        , one year , Manufacturing , 120 , 230-21 , -99   , 2.1   , -99  , 2.1  , TOTAL_IMPURITIES_HIGH_year_120_);
%plotter(total_imp_max        , one year , Test          , 120 , 230-21 , -99   , 2.1   , -99  , 2.1  , TOTAL_IMPURITIES_HIGH_year_120_);

/**********************************************************************/


 /* Start 60 dose */

/**********************************************************************/
/* PRS02116                                                               ind spec        mean spec                             */
/*                                                                     _______________   ___________                            */
%plotter(FP_CI_0to2           , all      , Manufacturing , 60, 45-21  , -99   , 8      , -99  , 7    , FP_CI_02_LOW_60_);
%plotter(FP_CI_0to2           , all      , Test          , 60, 45-21  , -99   , 8      , -99  , 7    , FP_CI_02_LOW_60_);
%plotter(FP_CI_0to2           , one year , Manufacturing , 60, 45-21  , -99   , 8      , -99  , 7    , FP_CI_02_LOW_year_60_);
%plotter(FP_CI_0to2           , one year , Test          , 60, 45-21  , -99   , 8      , -99  , 7    , FP_CI_02_LOW_year_60_);

%plotter(FP_CI_3to5           , all      , Manufacturing , 60, 45-21  , 15    , 27     , 16   , 26   , FP_CI_35_LOW_60_);
%plotter(FP_CI_3to5           , all      , Test          , 60, 45-21  , 15    , 27     , 16   , 26   , FP_CI_35_LOW_60_);
%plotter(FP_CI_3to5           , one year , Manufacturing , 60, 45-21  , 15    , 27     , 16   , 26   , FP_CI_35_LOW_year_60_);
%plotter(FP_CI_3to5           , one year , Test          , 60, 45-21  , 15    , 27     , 16   , 26   , FP_CI_35_LOW_year_60_);

%plotter(FP_CI_6toF           , all      , Manufacturing , 60, 45-21  , -99   , 2      , -99  , 2    , FP_CI_6F_LOW_60_);
%plotter(FP_CI_6toF           , all      , Test          , 60, 45-21  , -99   , 2      , -99  , 2    , FP_CI_6F_LOW_60_);
%plotter(FP_CI_6toF           , one year , Manufacturing , 60, 45-21  , -99   , 2      , -99  , 2    , FP_CI_6F_LOW_year_60_);
%plotter(FP_CI_6toF           , one year , Test          , 60, 45-21  , -99   , 2      , -99  , 2    , FP_CI_6F_LOW_year_60_);

%plotter(FP_CI_Throat         , all      , Manufacturing , 60, 45-21  , 10    , 21     , 11   , 20   , FP_CI_Throat_LOW_60_);
%plotter(FP_CI_Throat         , all      , Test          , 60, 45-21  , 10    , 21     , 11   , 20   , FP_CI_Throat_LOW_60_);
%plotter(FP_CI_Throat         , one year , Test          , 60, 45-21  , 10    , 21     , 11   , 20   , FP_CI_Throat_LOW_year_60_);
%plotter(FP_CI_Throat         , one year , Manufacturing , 60, 45-21  , 10    , 21     , 11   , 20   , FP_CI_Throat_LOW_year_60_);

%plotter(FP_CI_Total_ExDevice , all      , Manufacturing , 60, 45-21  ,  -99  ,    -99 , -99  , -99  , FP_CI_Total_ExDevice_LOW_60_);
%plotter(FP_CI_Total_ExDevice , all      , Test          , 60, 45-21  ,  -99  ,    -99 , -99  , -99  , FP_CI_Total_ExDevice_LOW_60_);
%plotter(FP_CI_Total_ExDevice , one year , Manufacturing , 60, 45-21  ,  -99  ,    -99 , -99  , -99  , FP_CI_Total_ExDevice_LOW_year_60_);
%plotter(FP_CI_Total_ExDevice , one year , Test          , 60, 45-21  ,  -99  ,    -99 , -99  , -99  , FP_CI_Total_ExDevice_LOW_year_60_);

/* "Mean Drug Content per Dose (mcg)" - individual specs come from 30% footnote */
%plotter(FP_DTU_BEG           , all      , Manufacturing , 60, 45-21  , 31.5  , 58.5   , 36   , 54   , FP_DTU_beg_LOW_60_);
%plotter(FP_DTU_BEG           , all      , Test          , 60, 45-21  , 31.5  , 58.5   , 36   , 54   , FP_DTU_beg_LOW_60_);
%plotter(FP_DTU_BEG           , one year , Manufacturing , 60, 45-21  , 31.5  , 58.5   , 36   , 54   , FP_DTU_beg_LOW_year_60_);
%plotter(FP_DTU_BEG           , one year , Test          , 60, 45-21  , 31.5  , 58.5   , 36   , 54   , FP_DTU_beg_LOW_year_60_);

%plotter(FP_DTU_DIFF          , all      , Manufacturing , 60, 45-21  , -99   , -99    , -99  , -99  , FP_DTU_diff_LOW_60_);
%plotter(FP_DTU_DIFF          , all      , Test          , 60, 45-21  , -99   , -99    , -99  , -99  , FP_DTU_diff_LOW_60_);
%plotter(FP_DTU_DIFF          , one year , Manufacturing , 60, 45-21  , -99   , -99    , -99  , -99  , FP_DTU_diff_LOW_year_60_);
%plotter(FP_DTU_DIFF          , one year , Test          , 60, 45-21  , -99   , -99    , -99  , -99  , FP_DTU_diff_LOW_year_60_);

/* "Mean Drug Content per Dose (mcg)" - individual specs come from 30% footnote */
%plotter(FP_DTU_END           , all      , Manufacturing , 60, 45-21  , 31.5  , 58.5   , 36   , 54   , FP_DTU_end_LOW_60_);
%plotter(FP_DTU_END           , all      , Test          , 60, 45-21  , 31.5  , 58.5   , 36   , 54   , FP_DTU_end_LOW_60_);
%plotter(FP_DTU_END           , one year , Manufacturing , 60, 45-21  , 31.5  , 58.5   , 36   , 54   , FP_DTU_end_LOW_year_60_);
%plotter(FP_DTU_END           , one year , Test          , 60, 45-21  , 31.5  , 58.5   , 36   , 54   , FP_DTU_end_LOW_year_60_);

%plotter(FP_TDC_can_wall      , all      , Manufacturing , 60, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_can_wall_LOW_60_);
%plotter(FP_TDC_can_wall      , all      , Test          , 60, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_can_wall_LOW_60_);
%plotter(FP_TDC_can_wall      , one year , Manufacturing , 60, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_can_wall_LOW_year_60_);
%plotter(FP_TDC_can_wall      , one year , Test          , 60, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_can_wall_LOW_year_60_);

/* "Free Suspension Concentration per Canister (mg/g)" */
%plotter(FP_TDC_concentration , all      , Manufacturing , 60, 45-21  , 0.611 , 0.747  , 0.62 , 0.73 , FP_TDC_conc_LOW_60_);
%plotter(FP_TDC_concentration , all      , Test          , 60, 45-21  , 0.611 , 0.747  , 0.62 , 0.73 , FP_TDC_conc_LOW_60_);
%plotter(FP_TDC_concentration , one year , Manufacturing , 60, 45-21  , 0.611 , 0.747  , 0.62 , 0.73 , FP_TDC_conc_LOW_year_60_);
%plotter(FP_TDC_concentration , one year , Test          , 60, 45-21  , 0.611 , 0.747  , 0.62 , 0.73 , FP_TDC_conc_LOW_year_60_);

/* not sure where tdc_susp specs come from */
%plotter(FP_TDC_suspension    , all      , Manufacturing , 60, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_suspension_LOW_60_);
%plotter(FP_TDC_suspension    , all      , Test          , 60, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_suspension_LOW_60_);
%plotter(FP_TDC_suspension    , one year , Manufacturing , 60, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_suspension_LOW_year_60_);
%plotter(FP_TDC_suspension    , one year , Test          , 60, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_suspension_LOW_year_60_);

/* "Drug Content per Canister (mg)" */
%plotter(FP_TDC_total_mass    , all      , Manufacturing , 60, 45-21  , 4.98  , 6.74   , 5.2  , 6.6  , FP_TDC_total_mass_LOW_60_);
%plotter(FP_TDC_total_mass    , all      , Test          , 60, 45-21  , 4.98  , 6.74   , 5.2  , 6.6  , FP_TDC_total_mass_LOW_60_);
%plotter(FP_TDC_total_mass    , one year , Manufacturing , 60, 45-21  , 4.98  , 6.74   , 5.2  , 6.6  , FP_TDC_total_mass_LOW_year_60_);
%plotter(FP_TDC_total_mass    , one year , Test          , 60, 45-21  , 4.98  , 6.74   , 5.2  , 6.6  , FP_TDC_total_mass_LOW_year_60_);

%plotter(FP_TDC_valve         , all      , Manufacturing , 60, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_valve_LOW_60_);
%plotter(FP_TDC_valve         , all      , Test          , 60, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_valve_LOW_60_);
%plotter(FP_TDC_valve         , one year , Manufacturing , 60, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_valve_LOW_year_60_);
%plotter(FP_TDC_valve         , one year , Test          , 60, 45-21  , -99   , -99    , -99  , -99  , FP_TDC_valve_LOW_year_60_);

%plotter(Leak                 , all      , Manufacturing , 60, 45-21  , -99   , 500    , -99  , 440  , LEAK_LOW_60_);
%plotter(Leak                 , all      , Test          , 60, 45-21  , -99   , 500    , -99  , 440  , LEAK_LOW_60_);
%plotter(Leak                 , one year , Manufacturing , 60, 45-21  , -99   , 500    , -99  , 440  , LEAK_LOW_year_60_);
%plotter(Leak                 , one year , Test          , 60, 45-21  , -99   , 500    , -99  , 440  , LEAK_LOW_year_60_);

%plotter(SX_CI_0to2           , all      , Manufacturing , 60, 45-21  , -99   , 5      , -99  , 4    , SX_CI_02_LOW_60_);
%plotter(SX_CI_0to2           , all      , Test          , 60, 45-21  , -99   , 5      , -99  , 4    , SX_CI_02_LOW_60_);
%plotter(SX_CI_0to2           , one year , Manufacturing , 60, 45-21  , -99   , 5      , -99  , 4    , SX_CI_02_LOW_year_60_);
%plotter(SX_CI_0to2           , one year , Test          , 60, 45-21  , -99   , 5      , -99  , 4    , SX_CI_02_LOW_year_60_);

%plotter(SX_CI_3to5           , all      , Manufacturing , 60, 45-21  , 7     , 13     , 7    , 12   , SX_CI_35_LOW_60_);
%plotter(SX_CI_3to5           , all      , Test          , 60, 45-21  , 7     , 13     , 7    , 12   , SX_CI_35_LOW_60_);
%plotter(SX_CI_3to5           , one year , Manufacturing , 60, 45-21  , 7     , 13     , 7    , 12   , SX_CI_35_LOW_year_60_);
%plotter(SX_CI_3to5           , one year , Test          , 60, 45-21  , 7     , 13     , 7    , 12   , SX_CI_35_LOW_year_60_);

%plotter(SX_CI_6toF           , all      , Manufacturing , 60, 45-21  , -99   , 1      , -99  , 1    , SX_CI_6F_LOW_60_);
%plotter(SX_CI_6toF           , all      , Test          , 60, 45-21  , -99   , 1      , -99  , 1    , SX_CI_6F_LOW_60_);
%plotter(SX_CI_6toF           , one year , Manufacturing , 60, 45-21  , -99   , 1      , -99  , 1    , SX_CI_6F_LOW_year_60_);
%plotter(SX_CI_6toF           , one year , Test          , 60, 45-21  , -99   , 1      , -99  , 1    , SX_CI_6F_LOW_year_60_);

%plotter(SX_CI_Throat         , all      , Manufacturing , 60, 45-21  , 2     , 10     , 3    , 9    , SX_CI_Throat_LOW_60_);
%plotter(SX_CI_Throat         , all      , Test          , 60, 45-21  , 2     , 10     , 3    , 9    , SX_CI_Throat_LOW_60_);
%plotter(SX_CI_Throat         , one year , Manufacturing , 60, 45-21  , 2     , 10     , 3    , 9    , SX_CI_Throat_LOW_year_60_);
%plotter(SX_CI_Throat         , one year , Test          , 60, 45-21  , 2     , 10     , 3    , 9    , SX_CI_Throat_LOW_year_60_);

/* not sure where exdevice specs come from, may be wrong */
%plotter(SX_CI_Total_ExDevice , all      , Manufacturing , 60, 45-21  , 16.8  , 23.1   , -99  , -99  , SX_CI_Total_ExDevice_LOW_60_);
%plotter(SX_CI_Total_ExDevice , all      , Test          , 60, 45-21  , 16.8  , 23.1   , -99  , -99  , SX_CI_Total_ExDevice_LOW_60_);
%plotter(SX_CI_Total_ExDevice , one year , Manufacturing , 60, 45-21  , 16.8  , 23.1   , -99  , -99  , SX_CI_Total_ExDevice_LOW_year_60_);
%plotter(SX_CI_Total_ExDevice , one year , Test          , 60, 45-21  , 16.8  , 23.1   , -99  , -99  , SX_CI_Total_ExDevice_LOW_year_60_);

/* "Mean Drug Content per Dose (mcg)" - individual specs come from 30% footnote */
%plotter(SX_DTU_BEG           , all      , Manufacturing , 60, 45-21  , 14.7  , 27.3   , 16.8 , 25.2 , SX_DTU_beg_LOW_60_);
%plotter(SX_DTU_BEG           , all      , Test          , 60, 45-21  , 14.7  , 27.3   , 16.8 , 25.2 , SX_DTU_beg_LOW_60_);
%plotter(SX_DTU_BEG           , one year , Manufacturing , 60, 45-21  , 14.7  , 27.3   , 16.8 , 25.2 , SX_DTU_beg_LOW_year_60_);
%plotter(SX_DTU_BEG           , one year , Test          , 60, 45-21  , 14.7  , 27.3   , 16.8 , 25.2 , SX_DTU_beg_LOW_year_60_);

%plotter(SX_DTU_DIFF          , all      , Manufacturing , 60, 45-21  , -99   , -99    , -99  , -99  , SX_DTU_diff_LOW_60_);
%plotter(SX_DTU_DIFF          , all      , Test          , 60, 45-21  , -99   , -99    , -99  , -99  , SX_DTU_diff_LOW_60_);
%plotter(SX_DTU_DIFF          , one year , Manufacturing , 60, 45-21  , -99   , -99    , -99  , -99  , SX_DTU_diff_LOW_year_60_);
%plotter(SX_DTU_DIFF          , one year , Test          , 60, 45-21  , -99   , -99    , -99  , -99  , SX_DTU_diff_LOW_year_60_);

/* "Mean Drug Content per Dose (mcg)" - individual specs come from 30% footnote */
%plotter(SX_DTU_END           , all      , Manufacturing , 60, 45-21  , 14.7  , 27.3   , 16.8 , 25.2 , SX_DTU_end_LOW_60_);
%plotter(SX_DTU_END           , all      , Test          , 60, 45-21  , 14.7  , 27.3   , 16.8 , 25.2 , SX_DTU_end_LOW_60_);
%plotter(SX_DTU_END           , one year , Manufacturing , 60, 45-21  , 14.7  , 27.3   , 16.8 , 25.2 , SX_DTU_end_LOW_year_60_);
%plotter(SX_DTU_END           , one year , Test          , 60, 45-21  , 14.7  , 27.3   , 16.8 , 25.2 , SX_DTU_end_LOW_year_60_);

%plotter(SX_TDC_can_wall      , all      , Manufacturing , 60, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_can_wall_LOW_60_);
%plotter(SX_TDC_can_wall      , all      , Test          , 60, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_can_wall_LOW_60_);
%plotter(SX_TDC_can_wall      , one year , Manufacturing , 60, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_can_wall_LOW_year_60_);
%plotter(SX_TDC_can_wall      , one year , Test          , 60, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_can_wall_LOW_year_60_);

/* "Free Suspension Concentration per Canister (mg/g)" */
%plotter(SX_TDC_concentration , all      , Manufacturing , 60, 45-21  , 0.288 , 0.352  , 0.29 , 0.35 , SX_TDC_conc_LOW_60_);
%plotter(SX_TDC_concentration , all      , Test          , 60, 45-21  , 0.288 , 0.352  , 0.29 , 0.35 , SX_TDC_conc_LOW_60_);
%plotter(SX_TDC_concentration , one year , Manufacturing , 60, 45-21  , 0.288 , 0.352  , 0.29 , 0.35 , SX_TDC_conc_LOW_year_60_);
%plotter(SX_TDC_concentration , one year , Test          , 60, 45-21  , 0.288 , 0.352  , 0.29 , 0.35 , SX_TDC_conc_LOW_year_60_);

%plotter(SX_TDC_suspension    , all      , Manufacturing , 60, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_suspension_LOW_60_);
%plotter(SX_TDC_suspension    , all      , Test          , 60, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_suspension_LOW_60_);
%plotter(SX_TDC_suspension    , one year , Manufacturing , 60, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_suspension_LOW_year_60_);
%plotter(SX_TDC_suspension    , one year , Test          , 60, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_suspension_LOW_year_60_);

/* "Drug Content per Canister (mg)" */
%plotter(SX_TDC_total_mass    , all      , Manufacturing , 60, 45-21  , 2.34  , 3.16   , 2.4  , 3.1  , SX_TDC_total_mass_LOW_60_);
%plotter(SX_TDC_total_mass    , all      , Test          , 60, 45-21  , 2.34  , 3.16   , 2.4  , 3.1  , SX_TDC_total_mass_LOW_60_);
%plotter(SX_TDC_total_mass    , one year , Manufacturing , 60, 45-21  , 2.34  , 3.16   , 2.4  , 3.1  , SX_TDC_total_mass_LOW_year_60_);
%plotter(SX_TDC_total_mass    , one year , Test          , 60, 45-21  , 2.34  , 3.16   , 2.4  , 3.1  , SX_TDC_total_mass_LOW_year_60_);

%plotter(SX_TDC_valve         , all      , Manufacturing , 60, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_valve_LOW_60_);
%plotter(SX_TDC_valve         , all      , Test          , 60, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_valve_LOW_60_);
%plotter(SX_TDC_valve         , one year , Manufacturing , 60, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_valve_LOW_year_60_);
%plotter(SX_TDC_valve         , one year , Test          , 60, 45-21  , -99   , -99    , -99  , -99  , SX_TDC_valve_LOW_year_60_);

/* "Weight of Canister Contents (g)" */
%plotter(content_weight       , all      , Manufacturing , 60, 45-21  , 6.8   , 8.3    , 7.1  ,  8.3 , CONTENT_WEIGHT_LOW_60_);
%plotter(content_weight       , all      , Test          , 60, 45-21  , 6.8   , 8.3    , 7.1  ,  8.3 , CONTENT_WEIGHT_LOW_60_);
%plotter(content_weight       , one year , Manufacturing , 60, 45-21  , 6.8   , 8.3    , 7.1  ,  8.3 , CONTENT_WEIGHT_LOW_year_60_);
%plotter(content_weight       , one year , Test          , 60, 45-21  , 6.8   , 8.3    , 7.1  ,  8.3 , CONTENT_WEIGHT_LOW_year_60_);

%plotter(moisture             , all      , Manufacturing , 60, 45-21  , -99   , 175    , -99  , 150  , MOISTURE_LOW_60_);
%plotter(moisture             , all      , Test          , 60, 45-21  , -99   , 175    , -99  , 150  , MOISTURE_LOW_60_);
%plotter(moisture             , one year , Manufacturing , 60, 45-21  , -99   , 175    , -99  , 150  , MOISTURE_LOW_year_60_);
%plotter(moisture             , one year , Test          , 60, 45-21  , -99   , 175    , -99  , 150  , MOISTURE_LOW_year_60_);

/* not sure where SHOT_WEIGHT specs come from, may be wrong */
%plotter(shot_weight          , all      , Manufacturing , 60, 45-21  , 63    , 85     , 67   , 81   , SHOT_WEIGHT_LOW_60_);
%plotter(shot_weight          , all      , Test          , 60, 45-21  , 63    , 85     , 67   , 81   , SHOT_WEIGHT_LOW_60_);
%plotter(shot_weight          , one year , Manufacturing , 60, 45-21  , 63    , 85     , 67   , 81   , SHOT_WEIGHT_LOW_year_60_);
%plotter(shot_weight          , one year , Test          , 60, 45-21  , 63    , 85     , 67   , 81   , SHOT_WEIGHT_LOW_year_60_);

%plotter(total_imp_max        , all      , Test          , 60, 45-21  , -99   , 2.1    , -99  , 2.1  , TOTAL_IMPURITIES_LOW_60_);
%plotter(total_imp_max        , all      , Manufacturing , 60, 45-21  , -99   , 2.1    , -99  , 2.1  , TOTAL_IMPURITIES_LOW_60_);
%plotter(total_imp_max        , one year , Manufacturing , 60, 45-21  , -99   , 2.1    , -99  , 2.1  , TOTAL_IMPURITIES_LOW_year_60_);
%plotter(total_imp_max        , one year , Test          , 60, 45-21  , -99   , 2.1    , -99  , 2.1  , TOTAL_IMPURITIES_LOW_year_60_);
/**********************************************************************/

/**********************************************************************/
/* PRS02115 */
%plotter(FP_CI_0to2           , all      , Manufacturing , 60, 115-21  , -99   , 25      , -99  , 22  , FP_CI_02_MID_60_);
%plotter(FP_CI_0to2           , all      , Test          , 60, 115-21  , -99   , 25      , -99  , 22  , FP_CI_02_MID_60_);
%plotter(FP_CI_0to2           , one year , Manufacturing , 60, 115-21  , -99   , 25      , -99  , 22  , FP_CI_02_MID_year_60_);
%plotter(FP_CI_0to2           , one year , Test          , 60, 115-21  , -99   , 25      , -99  , 22  , FP_CI_02_MID_year_60_);

%plotter(FP_CI_3to5           , all      , Manufacturing , 60, 115-21  , 39    , 67     , 41   , 65   , FP_CI_35_MID_60_);
%plotter(FP_CI_3to5           , all      , Test          , 60, 115-21  , 39    , 67     , 41   , 65   , FP_CI_35_MID_60_);
%plotter(FP_CI_3to5           , one year , Manufacturing , 60, 115-21  , 39    , 67     , 41   , 65   , FP_CI_35_MID_year_60_);
%plotter(FP_CI_3to5           , one year , Test          , 60, 115-21  , 39    , 67     , 41   , 65   , FP_CI_35_MID_year_60_);

%plotter(FP_CI_6toF           , all      , Manufacturing , 60, 115-21  , -99   , 3      , -99  , 3    , FP_CI_6F_MID_60_);
%plotter(FP_CI_6toF           , all      , Test          , 60, 115-21  , -99   , 3      , -99  , 3    , FP_CI_6F_MID_60_);
%plotter(FP_CI_6toF           , one year , Manufacturing , 60, 115-21  , -99   , 3      , -99  , 3    , FP_CI_6F_MID_year_60_);
%plotter(FP_CI_6toF           , one year , Test          , 60, 115-21  , -99   , 3      , -99  , 3    , FP_CI_6F_MID_year_60_);

%plotter(FP_CI_Throat         , all      , Manufacturing , 60, 115-21  , 24    , 54     , 26   , 52   , FP_CI_Throat_MID_60_);
%plotter(FP_CI_Throat         , all      , Test          , 60, 115-21  , 24    , 54     , 26   , 52   , FP_CI_Throat_MID_60_);
%plotter(FP_CI_Throat         , one year , Test          , 60, 115-21  , 24    , 54     , 26   , 52   , FP_CI_Throat_MID_year_60_);
%plotter(FP_CI_Throat         , one year , Manufacturing , 60, 115-21  , 24    , 54     , 26   , 52   , FP_CI_Throat_MID_year_60_);

%plotter(FP_CI_Total_ExDevice , all      , Manufacturing , 60, 115-21  , -99   ,  -99   , -99  , -99  , FP_CI_Total_ExDevice_MID_60_);
%plotter(FP_CI_Total_ExDevice , all      , Test          , 60, 115-21  , -99   ,  -99   , -99  , -99  , FP_CI_Total_ExDevice_MID_60_);
%plotter(FP_CI_Total_ExDevice , one year , Manufacturing , 60, 115-21  , -99   ,  -99   , -99  , -99  , FP_CI_Total_ExDevice_MID_year_60_);
%plotter(FP_CI_Total_ExDevice , one year , Test          , 60, 115-21  , -99   ,  -99   , -99  , -99  , FP_CI_Total_ExDevice_MID_year_60_);

/*                                                  "Content Uniformity" 25% footnote   and "Mean Drugper Dose" */
%plotter(FP_DTU_BEG           , all      , Manufacturing , 60, 115-21  , 92    , 138   , 86    , 144  , FP_DTU_beg_MID_60_);
%plotter(FP_DTU_BEG           , all      , Test          , 60, 115-21  , 92    , 138   , 86    , 144  , FP_DTU_beg_MID_60_);
%plotter(FP_DTU_BEG           , one year , Manufacturing , 60, 115-21  , 92    , 138   , 86    , 144  , FP_DTU_beg_MID_year_60_);
%plotter(FP_DTU_BEG           , one year , Test          , 60, 115-21  , 92    , 138   , 86    , 144  , FP_DTU_beg_MID_year_60_);

%plotter(FP_DTU_DIFF          , all      , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , FP_DTU_diff_MID_60_);
%plotter(FP_DTU_DIFF          , all      , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , FP_DTU_diff_MID_60_);
%plotter(FP_DTU_DIFF          , one year , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , FP_DTU_diff_MID_year_60_);
%plotter(FP_DTU_DIFF          , one year , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , FP_DTU_diff_MID_year_60_);

%plotter(FP_DTU_END           , all      , Manufacturing , 60, 115-21  , 92    , 138    , 92   , 138  , FP_DTU_end_MID_60_);
%plotter(FP_DTU_END           , all      , Test          , 60, 115-21  , 92    , 138    , 92   , 138  , FP_DTU_end_MID_60_);
%plotter(FP_DTU_END           , one year , Manufacturing , 60, 115-21  , 92    , 138    , 92   , 138  , FP_DTU_end_MID_year_60_);
%plotter(FP_DTU_END           , one year , Test          , 60, 115-21  , 92    , 138    , 92   , 138  , FP_DTU_end_MID_year_60_);

%plotter(FP_TDC_can_wall      , all      , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , FP_TDC_can_wall_MID_60_);
%plotter(FP_TDC_can_wall      , all      , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , FP_TDC_can_wall_MID_60_);
%plotter(FP_TDC_can_wall      , one year , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , FP_TDC_can_wall_MID_year_60_);
%plotter(FP_TDC_can_wall      , one year , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , FP_TDC_can_wall_MID_year_60_);

/* "Free Suspension Concentration per Canister" */
%plotter(FP_TDC_concentration , all      , Manufacturing , 60, 115-21  , 1.546 , 1.890  , 1.58 , 1.86 , FP_TDC_conc_MID_60_);
%plotter(FP_TDC_concentration , all      , Test          , 60, 115-21  , 1.546 , 1.890  , 1.58 , 1.86 , FP_TDC_conc_MID_60_);
%plotter(FP_TDC_concentration , one year , Manufacturing , 60, 115-21  , 1.546 , 1.890  , 1.58 , 1.86 , FP_TDC_conc_MID_year_60_);
%plotter(FP_TDC_concentration , one year , Test          , 60, 115-21  , 1.546 , 1.890  , 1.58 , 1.86 , FP_TDC_conc_MID_year_60_);

%plotter(FP_TDC_suspension    , all      , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , FP_TDC_suspension_MID_60_);
%plotter(FP_TDC_suspension    , all      , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , FP_TDC_suspension_MID_60_);
%plotter(FP_TDC_suspension    , one year , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , FP_TDC_suspension_MID_year_60_);
%plotter(FP_TDC_suspension    , one year , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , FP_TDC_suspension_MID_year_60_);

/* "Total Drug Content per Canister" */
%plotter(FP_TDC_total_mass    , all      , Manufacturing , 60, 115-21  , 12.43 , 16.82  , 12.9 , 16.4 , FP_TDC_total_mass_MID_60_);
%plotter(FP_TDC_total_mass    , all      , Test          , 60, 115-21  , 12.43 , 16.82  , 12.9 , 16.4 , FP_TDC_total_mass_MID_60_);
%plotter(FP_TDC_total_mass    , one year , Manufacturing , 60, 115-21  , 12.43 , 16.82  , 12.9 , 16.4 , FP_TDC_total_mass_MID_year_60_);
%plotter(FP_TDC_total_mass    , one year , Test          , 60, 115-21  , 12.43 , 16.82  , 12.9 , 16.4 , FP_TDC_total_mass_MID_year_60_);

%plotter(FP_TDC_valve         , all      , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , FP_TDC_valve_MID_60_);
%plotter(FP_TDC_valve         , all      , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , FP_TDC_valve_MID_60_);
%plotter(FP_TDC_valve         , one year , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , FP_TDC_valve_MID_year_60_);
%plotter(FP_TDC_valve         , one year , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , FP_TDC_valve_MID_year_60_);

%plotter(Leak                 , all      , Manufacturing , 60, 115-21  , -99   , 500    , -99  , 440  , LEAK_MID_60_);
%plotter(Leak                 , all      , Test          , 60, 115-21  , -99   , 500    , -99  , 440  , LEAK_MID_60_);
%plotter(Leak                 , one year , Manufacturing , 60, 115-21  , -99   , 500    , -99  , 440  , LEAK_MID_year_60_);
%plotter(Leak                 , one year , Test          , 60, 115-21  , -99   , 500    , -99  , 440  , LEAK_MID_year_60_);

%plotter(SX_CI_0to2           , all      , Manufacturing , 60, 115-21  , -99   , 6      , -99  , 5    , SX_CI_02_MID_60_);
%plotter(SX_CI_0to2           , all      , Test          , 60, 115-21  , -99   , 6      , -99  , 5    , SX_CI_02_MID_60_);
%plotter(SX_CI_0to2           , one year , Manufacturing , 60, 115-21  , -99   , 6      , -99  , 5    , SX_CI_02_MID_year_60_);
%plotter(SX_CI_0to2           , one year , Test          , 60, 115-21  , -99   , 6      , -99  , 5    , SX_CI_02_MID_year_60_);

%plotter(SX_CI_3to5           , all      , Manufacturing , 60, 115-21  , 7     , 13     , 7    , 12   , SX_CI_35_MID_60_);
%plotter(SX_CI_3to5           , all      , Test          , 60, 115-21  , 7     , 13     , 7    , 12   , SX_CI_35_MID_60_);
%plotter(SX_CI_3to5           , one year , Manufacturing , 60, 115-21  , 7     , 13     , 7    , 12   , SX_CI_35_MID_year_60_);
%plotter(SX_CI_3to5           , one year , Test          , 60, 115-21  , 7     , 13     , 7    , 12   , SX_CI_35_MID_year_60_);

%plotter(SX_CI_6toF           , all      , Manufacturing , 60, 115-21  , -99   , 1      , -99  , 1    , SX_CI_6F_MID_60_);
%plotter(SX_CI_6toF           , all      , Test          , 60, 115-21  , -99   , 1      , -99  , 1    , SX_CI_6F_MID_60_);
%plotter(SX_CI_6toF           , one year , Manufacturing , 60, 115-21  , -99   , 1      , -99  , 1    , SX_CI_6F_MID_year_60_);
%plotter(SX_CI_6toF           , one year , Test          , 60, 115-21  , -99   , 1      , -99  , 1    , SX_CI_6F_MID_year_60_);

%plotter(SX_CI_Throat         , all      , Manufacturing , 60, 115-21  , 3     , 11     , 4    , 10   , SX_CI_Throat_MID_60_);
%plotter(SX_CI_Throat         , all      , Test          , 60, 115-21  , 3     , 11     , 4    , 10   , SX_CI_Throat_MID_60_);
%plotter(SX_CI_Throat         , one year , Manufacturing , 60, 115-21  , 3     , 11     , 4    , 10   , SX_CI_Throat_MID_year_60_);
%plotter(SX_CI_Throat         , one year , Test          , 60, 115-21  , 3     , 11     , 4    , 10   , SX_CI_Throat_MID_year_60_);

%plotter(SX_CI_Total_ExDevice , all      , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , SX_CI_Total_ExDevice_MID_60_);
%plotter(SX_CI_Total_ExDevice , all      , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , SX_CI_Total_ExDevice_MID_60_);
%plotter(SX_CI_Total_ExDevice , one year , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , SX_CI_Total_ExDevice_MID_year_60_);
%plotter(SX_CI_Total_ExDevice , one year , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , SX_CI_Total_ExDevice_MID_year_60_);

/*                                                  "Content Uniformity" 25% footnote   and "Mean Drug Content per Dose" */
%plotter(SX_DTU_BEG           , all      , Manufacturing , 60, 115-21  , 15.8  , 26.3   , 16.8 , 25.2 , SX_DTU_beg_MID_60_);
%plotter(SX_DTU_BEG           , all      , Test          , 60, 115-21  , 15.8  , 26.3   , 16.8 , 25.2 , SX_DTU_beg_MID_60_);
%plotter(SX_DTU_BEG           , one year , Manufacturing , 60, 115-21  , 15.8  , 26.3   , 16.8 , 25.2 , SX_DTU_beg_MID_year_60_);
%plotter(SX_DTU_BEG           , one year , Test          , 60, 115-21  , 15.8  , 26.3   , 16.8 , 25.2 , SX_DTU_beg_MID_year_60_);

%plotter(SX_DTU_DIFF          , all      , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , SX_DTU_diff_MID_60_);
%plotter(SX_DTU_DIFF          , all      , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , SX_DTU_diff_MID_60_);
%plotter(SX_DTU_DIFF          , one year , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , SX_DTU_diff_MID_year_60_);
%plotter(SX_DTU_DIFF          , one year , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , SX_DTU_diff_MID_year_60_);

%plotter(SX_DTU_END           , all      , Manufacturing , 60, 115-21  , 15.8  , 26.3   , 16.8 , 25.2 , SX_DTU_end_MID_60_);
%plotter(SX_DTU_END           , all      , Test          , 60, 115-21  , 15.8  , 26.3   , 16.8 , 25.2 , SX_DTU_end_MID_60_);
%plotter(SX_DTU_END           , one year , Manufacturing , 60, 115-21  , 15.8  , 26.3   , 16.8 , 25.2 , SX_DTU_end_MID_year_60_);
%plotter(SX_DTU_END           , one year , Test          , 60, 115-21  , 15.8  , 26.3   , 16.8 , 25.2 , SX_DTU_end_MID_year_60_);

%plotter(SX_TDC_can_wall      , all      , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , SX_TDC_can_wall_MID_60_);
%plotter(SX_TDC_can_wall      , all      , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , SX_TDC_can_wall_MID_60_);
%plotter(SX_TDC_can_wall      , one year , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , SX_TDC_can_wall_MID_year_60_);
%plotter(SX_TDC_can_wall      , one year , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , SX_TDC_can_wall_MID_year_60_);

/* "Free Suspension Concentration per Canister (mg/g)" */
%plotter(SX_TDC_concentration , all      , Manufacturing , 60, 115-21  , 0.288 , 0.352  , 0.29 , 0.35 , SX_TDC_conc_MID_60_);
%plotter(SX_TDC_concentration , all      , Test          , 60, 115-21  , 0.288 , 0.352  , 0.29 , 0.35 , SX_TDC_conc_MID_60_);
%plotter(SX_TDC_concentration , one year , Manufacturing , 60, 115-21  , 0.288 , 0.352  , 0.29 , 0.35 , SX_TDC_conc_MID_year_60_);
%plotter(SX_TDC_concentration , one year , Test          , 60, 115-21  , 0.288 , 0.352  , 0.29 , 0.35 , SX_TDC_conc_MID_year_60_);

%plotter(SX_TDC_suspension    , all      , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , SX_TDC_suspension_MID_60_);
%plotter(SX_TDC_suspension    , all      , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , SX_TDC_suspension_MID_60_);
%plotter(SX_TDC_suspension    , one year , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , SX_TDC_suspension_MID_year_60_);
%plotter(SX_TDC_suspension    , one year , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , SX_TDC_suspension_MID_year_60_);

/* "Drug Content per Canister (mg)" */
%plotter(SX_TDC_total_mass    , all      , Manufacturing , 60, 115-21  , 2.31  , 3.12   , 2.4  , 3.0  , SX_TDC_total_mass_MID_60_);
%plotter(SX_TDC_total_mass    , all      , Test          , 60, 115-21  , 2.31  , 3.12   , 2.4  , 3.0  , SX_TDC_total_mass_MID_60_);
%plotter(SX_TDC_total_mass    , one year , Manufacturing , 60, 115-21  , 2.31  , 3.12   , 2.4  , 3.0  , SX_TDC_total_mass_MID_year_60_);
%plotter(SX_TDC_total_mass    , one year , Test          , 60, 115-21  , 2.31  , 3.12   , 2.4  , 3.0  , SX_TDC_total_mass_MID_year_60_);

%plotter(SX_TDC_valve         , all      , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , SX_TDC_valve_MID_60_);
%plotter(SX_TDC_valve         , all      , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , SX_TDC_valve_MID_60_);
%plotter(SX_TDC_valve         , one year , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , SX_TDC_valve_MID_year_60_);
%plotter(SX_TDC_valve         , one year , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , SX_TDC_valve_MID_year_60_);

/* "Weight of Canister Contents (g)" */
%plotter(content_weight       , all      , Manufacturing , 60, 115-21  ,  6.8  ,  8.3   , 7.1 ,  8.3  , CONTENT_WEIGHT_MID_60_);
%plotter(content_weight       , all      , Test          , 60, 115-21  ,  6.8  ,  8.3   , 7.1 ,  8.3  , CONTENT_WEIGHT_MID_60_);
%plotter(content_weight       , one year , Manufacturing , 60, 115-21  ,  6.8  ,  8.3   , 7.1 ,  8.3  , CONTENT_WEIGHT_MID_year_60_);
%plotter(content_weight       , one year , Test          , 60, 115-21  ,  6.8  ,  8.3   , 7.1 ,  8.3  , CONTENT_WEIGHT_MID_year_60_);

%plotter(moisture             , all      , Manufacturing , 60, 115-21  , -99   , 175    , -99  , 150  , MOISTURE_MID_60_);
%plotter(moisture             , all      , Test          , 60, 115-21  , -99   , 175    , -99  , 150  , MOISTURE_MID_60_);
%plotter(moisture             , one year , Manufacturing , 60, 115-21  , -99   , 175    , -99  , 150  , MOISTURE_MID_year_60_);
%plotter(moisture             , one year , Test          , 60, 115-21  , -99   , 175    , -99  , 150  , MOISTURE_MID_year_60_);

%plotter(shot_weight          , all      , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , SHOT_WEIGHT_MID_60_);
%plotter(shot_weight          , all      , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , SHOT_WEIGHT_MID_60_);
%plotter(shot_weight          , one year , Manufacturing , 60, 115-21  , -99   , -99    , -99  , -99  , SHOT_WEIGHT_MID_year_60_);
%plotter(shot_weight          , one year , Test          , 60, 115-21  , -99   , -99    , -99  , -99  , SHOT_WEIGHT_MID_year_60_);

%plotter(total_imp_max        , all      , Test          , 60, 115-21  , -99   , 2.1    , -99  , 2.1  , TOTAL_IMPURITIES_MID_60_);
%plotter(total_imp_max        , all      , Manufacturing , 60, 115-21  , -99   , 2.1    , -99  , 2.1  , TOTAL_IMPURITIES_MID_60_);
%plotter(total_imp_max        , one year , Manufacturing , 60, 115-21  , -99   , 2.1    , -99  , 2.1  , TOTAL_IMPURITIES_MID_year_60_);
%plotter(total_imp_max        , one year , Test          , 60, 115-21  , -99   , 2.1    , -99  , 2.1  , TOTAL_IMPURITIES_MID_year_60_);
/**********************************************************************/

/**********************************************************************/
/* PRS02114 */
%plotter(FP_CI_0to2           , all      , Manufacturing , 60, 230-21  , -99   , 59     , -99  , 52   , FP_CI_02_HIGH_60_);
%plotter(FP_CI_0to2           , all      , Test          , 60, 230-21  , -99   , 59     , -99  , 52   , FP_CI_02_HIGH_60_);
%plotter(FP_CI_0to2           , one year , Manufacturing , 60, 230-21  , -99   , 59     , -99  , 52   , FP_CI_02_HIGH_year_60_);
%plotter(FP_CI_0to2           , one year , Test          , 60, 230-21  , -99   , 59     , -99  , 52   , FP_CI_02_HIGH_year_60_);

%plotter(FP_CI_3to5           , all      , Manufacturing , 60, 230-21  , 77    , 124    , 81   , 120  , FP_CI_35_HIGH_60_);
%plotter(FP_CI_3to5           , all      , Test          , 60, 230-21  , 77    , 124    , 81   , 120  , FP_CI_35_HIGH_60_);
%plotter(FP_CI_3to5           , one year , Manufacturing , 60, 230-21  , 77    , 124    , 81   , 120  , FP_CI_35_HIGH_year_60_);
%plotter(FP_CI_3to5           , one year , Test          , 60, 230-21  , 77    , 124    , 81   , 120  , FP_CI_35_HIGH_year_60_);

%plotter(FP_CI_6toF           , all      , Manufacturing , 60, 230-21  , -99   , 4      , -99  , 4    , FP_CI_6F_HIGH_60_);
%plotter(FP_CI_6toF           , all      , Test          , 60, 230-21  , -99   , 4      , -99  , 4    , FP_CI_6F_HIGH_60_);
%plotter(FP_CI_6toF           , one year , Manufacturing , 60, 230-21  , -99   , 4      , -99  , 4    , FP_CI_6F_HIGH_year_60_);
%plotter(FP_CI_6toF           , one year , Test          , 60, 230-21  , -99   , 4      , -99  , 4    , FP_CI_6F_HIGH_year_60_);

%plotter(FP_CI_Throat         , all      , Manufacturing , 60, 230-21  , 59    , 109    , 64   , 104  , FP_CI_Throat_HIGH_60_);
%plotter(FP_CI_Throat         , all      , Test          , 60, 230-21  , 59    , 109    , 64   , 104  , FP_CI_Throat_HIGH_60_);
%plotter(FP_CI_Throat         , one year , Test          , 60, 230-21  , 59    , 109    , 64   , 104  , FP_CI_Throat_HIGH_year_60_);
%plotter(FP_CI_Throat         , one year , Manufacturing , 60, 230-21  , 59    , 109    , 64   , 104  , FP_CI_Throat_HIGH_year_60_);

%plotter(FP_CI_Total_ExDevice , all      , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , FP_CI_Total_ExDevice_HIGH_60_);
%plotter(FP_CI_Total_ExDevice , all      , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , FP_CI_Total_ExDevice_HIGH_60_);
%plotter(FP_CI_Total_ExDevice , one year , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , FP_CI_Total_ExDevice_HIGH_year_60_);
%plotter(FP_CI_Total_ExDevice , one year , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , FP_CI_Total_ExDevice_HIGH_year_60_);

/*                                                  "Content Uniformity" 25% footnote   and "Mean Drug Content per Dose" */
%plotter(FP_DTU_BEG           , all      , Manufacturing , 60, 230-21  , 173   , 288    , 184  , 276  , FP_DTU_beg_HIGH_60_);
%plotter(FP_DTU_BEG           , all      , Test          , 60, 230-21  , 173   , 288    , 184  , 276  , FP_DTU_beg_HIGH_60_);
%plotter(FP_DTU_BEG           , one year , Manufacturing , 60, 230-21  , 173   , 288    , 184  , 276  , FP_DTU_beg_HIGH_year_60_);
%plotter(FP_DTU_BEG           , one year , Test          , 60, 230-21  , 173   , 288    , 184  , 276  , FP_DTU_beg_HIGH_year_60_);

%plotter(FP_DTU_DIFF          , all      , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , FP_DTU_diff_HIGH_60_);
%plotter(FP_DTU_DIFF          , all      , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , FP_DTU_diff_HIGH_60_);
%plotter(FP_DTU_DIFF          , one year , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , FP_DTU_diff_HIGH_year_60_);
%plotter(FP_DTU_DIFF          , one year , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , FP_DTU_diff_HIGH_year_60_);

%plotter(FP_DTU_END           , all      , Manufacturing , 60, 230-21  , 173   , 288    , 184  , 276  , FP_DTU_end_HIGH_60_);
%plotter(FP_DTU_END           , all      , Test          , 60, 230-21  , 173   , 288    , 184  , 276  , FP_DTU_end_HIGH_60_);
%plotter(FP_DTU_END           , one year , Manufacturing , 60, 230-21  , 173   , 288    , 184  , 276  , FP_DTU_end_HIGH_year_60_);
%plotter(FP_DTU_END           , one year , Test          , 60, 230-21  , 173   , 288    , 184  , 276  , FP_DTU_end_HIGH_year_60_);

%plotter(FP_TDC_can_wall      , all      , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , FP_TDC_can_wall_HIGH_60_);
%plotter(FP_TDC_can_wall      , all      , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , FP_TDC_can_wall_HIGH_60_);
%plotter(FP_TDC_can_wall      , one year , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , FP_TDC_can_wall_HIGH_year_60_);
%plotter(FP_TDC_can_wall      , one year , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , FP_TDC_can_wall_HIGH_year_60_);

/* "Free Suspension Concentration per Canister (mg/g)" */
%plotter(FP_TDC_concentration , all      , Manufacturing , 60, 230-21  , 2.926 , 3.576  , 2.99 , 3.51 , FP_TDC_conc_HIGH_60_);
%plotter(FP_TDC_concentration , all      , Test          , 60, 230-21  , 2.926 , 3.576  , 2.99 , 3.51 , FP_TDC_conc_HIGH_60_);
%plotter(FP_TDC_concentration , one year , Manufacturing , 60, 230-21  , 2.926 , 3.576  , 2.99 , 3.51 , FP_TDC_conc_HIGH_year_60_);
%plotter(FP_TDC_concentration , one year , Test          , 60, 230-21  , 2.926 , 3.576  , 2.99 , 3.51 , FP_TDC_conc_HIGH_year_60_);

%plotter(FP_TDC_suspension    , all      , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , FP_TDC_suspension_HIGH_60_);
%plotter(FP_TDC_suspension    , all      , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , FP_TDC_suspension_HIGH_60_);
%plotter(FP_TDC_suspension    , one year , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , FP_TDC_suspension_HIGH_year_60_);
%plotter(FP_TDC_suspension    , one year , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , FP_TDC_suspension_HIGH_year_60_);

/* "Drug Content per Canister (mg)" */
%plotter(FP_TDC_total_mass    , all      , Manufacturing , 60, 230-21  , 23.5  , 31.8   , 24.3 , 31.0 , FP_TDC_total_mass_HIGH_60_);
%plotter(FP_TDC_total_mass    , all      , Test          , 60, 230-21  , 23.5  , 31.8   , 24.3 , 31.0 , FP_TDC_total_mass_HIGH_60_);
%plotter(FP_TDC_total_mass    , one year , Manufacturing , 60, 230-21  , 23.5  , 31.8   , 24.3 , 31.0 , FP_TDC_total_mass_HIGH_year_60_);
%plotter(FP_TDC_total_mass    , one year , Test          , 60, 230-21  , 23.5  , 31.8   , 24.3 , 31.0 , FP_TDC_total_mass_HIGH_year_60_);

%plotter(FP_TDC_valve         , all      , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , FP_TDC_valve_HIGH_60_);
%plotter(FP_TDC_valve         , all      , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , FP_TDC_valve_HIGH_60_);
%plotter(FP_TDC_valve         , one year , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , FP_TDC_valve_HIGH_year_60_);
%plotter(FP_TDC_valve         , one year , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , FP_TDC_valve_HIGH_year_60_);

%plotter(Leak                 , all      , Manufacturing , 60, 230-21  , -99   , 500    , -99  , 440  , LEAK_HIGH_60_);
%plotter(Leak                 , all      , Test          , 60, 230-21  , -99   , 500    , -99  , 440  , LEAK_HIGH_60_);
%plotter(Leak                 , one year , Manufacturing , 60, 230-21  , -99   , 500    , -99  , 440  , LEAK_HIGH_year_60_);
%plotter(Leak                 , one year , Test          , 60, 230-21  , -99   , 500    , -99  , 440  , LEAK_HIGH_year_60_);

%plotter(SX_CI_0to2           , all      , Manufacturing , 60, 230-21  , -99   , 7      , -99  , 6    , SX_CI_02_HIGH_60_);
%plotter(SX_CI_0to2           , all      , Test          , 60, 230-21  , -99   , 7      , -99  , 6    , SX_CI_02_HIGH_60_);
%plotter(SX_CI_0to2           , one year , Manufacturing , 60, 230-21  , -99   , 7      , -99  , 6    , SX_CI_02_HIGH_year_60_);
%plotter(SX_CI_0to2           , one year , Test          , 60, 230-21  , -99   , 7      , -99  , 6    , SX_CI_02_HIGH_year_60_);

%plotter(SX_CI_3to5           , all      , Manufacturing , 60, 230-21  , 7     , 13     , 7    , 12   , SX_CI_35_HIGH_60_);
%plotter(SX_CI_3to5           , all      , Test          , 60, 230-21  , 7     , 13     , 7    , 12   , SX_CI_35_HIGH_60_);
%plotter(SX_CI_3to5           , one year , Manufacturing , 60, 230-21  , 7     , 13     , 7    , 12   , SX_CI_35_HIGH_year_60_);
%plotter(SX_CI_3to5           , one year , Test          , 60, 230-21  , 7     , 13     , 7    , 12   , SX_CI_35_HIGH_year_60_);

%plotter(SX_CI_6toF           , all      , Manufacturing , 60, 230-21  , -99   , 1      , -99  , 1    , SX_CI_6F_HIGH_60_);
%plotter(SX_CI_6toF           , all      , Test          , 60, 230-21  , -99   , 1      , -99  , 1    , SX_CI_6F_HIGH_60_);
%plotter(SX_CI_6toF           , one year , Manufacturing , 60, 230-21  , -99   , 1      , -99  , 1    , SX_CI_6F_HIGH_year_60_);
%plotter(SX_CI_6toF           , one year , Test          , 60, 230-21  , -99   , 1      , -99  , 1    , SX_CI_6F_HIGH_year_60_);

%plotter(SX_CI_Throat         , all      , Manufacturing , 60, 230-21  , 4     , 12     , 5    , 11   , SX_CI_Throat_HIGH_60_);
%plotter(SX_CI_Throat         , all      , Test          , 60, 230-21  , 4     , 12     , 5    , 11   , SX_CI_Throat_HIGH_60_);
%plotter(SX_CI_Throat         , one year , Manufacturing , 60, 230-21  , 4     , 12     , 5    , 11   , SX_CI_Throat_HIGH_year_60_);
%plotter(SX_CI_Throat         , one year , Test          , 60, 230-21  , 4     , 12     , 5    , 11   , SX_CI_Throat_HIGH_year_60_);

%plotter(SX_CI_Total_ExDevice , all      , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , SX_CI_Total_ExDevice_HIGH_60_);
%plotter(SX_CI_Total_ExDevice , all      , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , SX_CI_Total_ExDevice_HIGH_60_);
%plotter(SX_CI_Total_ExDevice , one year , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , SX_CI_Total_ExDevice_HIGH_year_60_);
%plotter(SX_CI_Total_ExDevice , one year , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , SX_CI_Total_ExDevice_HIGH_year_60_);

/*                                                  "Content Uniformity" 25% footnote   and "Mean Drug Content per Dose" */
%plotter(SX_DTU_BEG           , all      , Manufacturing , 60, 230-21  , 15.8  , 26.3   , 16.8 , 25.2 , SX_DTU_beg_HIGH_60_);
%plotter(SX_DTU_BEG           , all      , Test          , 60, 230-21  , 15.8  , 26.3   , 16.8 , 25.2 , SX_DTU_beg_HIGH_60_);
%plotter(SX_DTU_BEG           , one year , Manufacturing , 60, 230-21  , 15.8  , 26.3   , 16.8 , 25.2 , SX_DTU_beg_HIGH_year_60_);
%plotter(SX_DTU_BEG           , one year , Test          , 60, 230-21  , 15.8  , 26.3   , 16.8 , 25.2 , SX_DTU_beg_HIGH_year_60_);

%plotter(SX_DTU_DIFF          , all      , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , SX_DTU_diff_HIGH_60_);
%plotter(SX_DTU_DIFF          , all      , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , SX_DTU_diff_HIGH_60_);
%plotter(SX_DTU_DIFF          , one year , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , SX_DTU_diff_HIGH_year_60_);
%plotter(SX_DTU_DIFF          , one year , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , SX_DTU_diff_HIGH_year_60_);

%plotter(SX_DTU_END           , all      , Manufacturing , 60, 230-21  , 15.8  , 26.3   , 16.8 , 25.2 , SX_DTU_end_HIGH_60_);
%plotter(SX_DTU_END           , all      , Test          , 60, 230-21  , 15.8  , 26.3   , 16.8 , 25.2 , SX_DTU_end_HIGH_60_);
%plotter(SX_DTU_END           , one year , Manufacturing , 60, 230-21  , 15.8  , 26.3   , 16.8 , 25.2 , SX_DTU_end_HIGH_year_60_);
%plotter(SX_DTU_END           , one year , Test          , 60, 230-21  , 15.8  , 26.3   , 16.8 , 25.2 , SX_DTU_end_HIGH_year_60_);

%plotter(SX_TDC_can_wall      , all      , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , SX_TDC_can_wall_HIGH_60_);
%plotter(SX_TDC_can_wall      , all      , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , SX_TDC_can_wall_HIGH_60_);
%plotter(SX_TDC_can_wall      , one year , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , SX_TDC_can_wall_HIGH_year_60_);
%plotter(SX_TDC_can_wall      , one year , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , SX_TDC_can_wall_HIGH_year_60_);

/* "Free Suspension Concentration per Canister (mg/g)" */
%plotter(SX_TDC_concentration , all      , Manufacturing , 60, 230-21  , 0.273 , 0.33   , 0.28 , 0.33 , SX_TDC_conc_HIGH_60_);
%plotter(SX_TDC_concentration , all      , Test          , 60, 230-21  , 0.273 , 0.33   , 0.28 , 0.33 , SX_TDC_conc_HIGH_60_);
%plotter(SX_TDC_concentration , one year , Manufacturing , 60, 230-21  , 0.273 , 0.33   , 0.28 , 0.33 , SX_TDC_conc_HIGH_year_60_);
%plotter(SX_TDC_concentration , one year , Test          , 60, 230-21  , 0.273 , 0.33   , 0.28 , 0.33 , SX_TDC_conc_HIGH_year_60_);

%plotter(SX_TDC_suspension    , all      , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , SX_TDC_suspension_HIGH_60_);
%plotter(SX_TDC_suspension    , all      , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , SX_TDC_suspension_HIGH_60_);
%plotter(SX_TDC_suspension    , one year , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , SX_TDC_suspension_HIGH_year_60_);
%plotter(SX_TDC_suspension    , one year , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , SX_TDC_suspension_HIGH_year_60_);

/* "Total Drug Content per Canister (mg)" */
%plotter(SX_TDC_total_mass    , all      , Manufacturing , 60, 230-21  , 2.19  , 2.96   , 2.3   , 2.9 , SX_TDC_total_mass_HIGH_60_);
%plotter(SX_TDC_total_mass    , all      , Test          , 60, 230-21  , 2.19  , 2.96   , 2.3   , 2.9 , SX_TDC_total_mass_HIGH_60_);
%plotter(SX_TDC_total_mass    , one year , Manufacturing , 60, 230-21  , 2.19  , 2.96   , 2.3   , 2.9 , SX_TDC_total_mass_HIGH_year_60_);
%plotter(SX_TDC_total_mass    , one year , Test          , 60, 230-21  , 2.19  , 2.96   , 2.3   , 2.9 , SX_TDC_total_mass_HIGH_year_60_);

%plotter(SX_TDC_valve         , all      , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , SX_TDC_valve_HIGH_60_);
%plotter(SX_TDC_valve         , all      , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , SX_TDC_valve_HIGH_60_);
%plotter(SX_TDC_valve         , one year , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , SX_TDC_valve_HIGH_year_60_);
%plotter(SX_TDC_valve         , one year , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , SX_TDC_valve_HIGH_year_60_);

/* "Weight of Canister Contents (g)" */
%plotter(content_weight       , all      , Manufacturing , 60, 230-21  ,  6.8  ,  8.3   ,  7.1 ,  8.3 , CONTENT_WEIGHT_HIGH_60_);
%plotter(content_weight       , all      , Test          , 60, 230-21  ,  6.8  ,  8.3   ,  7.1 ,  8.3 , CONTENT_WEIGHT_HIGH_60_);
%plotter(content_weight       , one year , Manufacturing , 60, 230-21  ,  6.8  ,  8.3   ,  7.1 ,  8.3 , CONTENT_WEIGHT_HIGH_year_60_);
%plotter(content_weight       , one year , Test          , 60, 230-21  ,  6.8  ,  8.3   ,  7.1 ,  8.3 , CONTENT_WEIGHT_HIGH_year_60_);

%plotter(moisture             , all      , Manufacturing , 60, 230-21  , -99   , 175    , -99  , 150  , MOISTURE_HIGH_60_);
%plotter(moisture             , all      , Test          , 60, 230-21  , -99   , 175    , -99  , 150  , MOISTURE_HIGH_60_);
%plotter(moisture             , one year , Manufacturing , 60, 230-21  , -99   , 175    , -99  , 150  , MOISTURE_HIGH_year_60_);
%plotter(moisture             , one year , Test          , 60, 230-21  , -99   , 175    , -99  , 150  , MOISTURE_HIGH_year_60_);

%plotter(shot_weight          , all      , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , SHOT_WEIGHT_HIGH_60_);
%plotter(shot_weight          , all      , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , SHOT_WEIGHT_HIGH_60_);
%plotter(shot_weight          , one year , Manufacturing , 60, 230-21  , -99   , -99    , -99  , -99  , SHOT_WEIGHT_HIGH_year_60_);
%plotter(shot_weight          , one year , Test          , 60, 230-21  , -99   , -99    , -99  , -99  , SHOT_WEIGHT_HIGH_year_60_);

%plotter(total_imp_max        , all      , Test          , 60, 230-21  , -99   , 2.1    , -99  , 2.1  , TOTAL_IMPURITIES_HIGH_60_);
%plotter(total_imp_max        , all      , Manufacturing , 60, 230-21  , -99   , 2.1    , -99  , 2.1  , TOTAL_IMPURITIES_HIGH_60_);
%plotter(total_imp_max        , one year , Manufacturing , 60, 230-21  , -99   , 2.1    , -99  , 2.1  , TOTAL_IMPURITIES_HIGH_year_60_);
%plotter(total_imp_max        , one year , Test          , 60, 230-21  , -99   , 2.1    , -99  , 2.1  , TOTAL_IMPURITIES_HIGH_year_60_);
/**********************************************************************/
