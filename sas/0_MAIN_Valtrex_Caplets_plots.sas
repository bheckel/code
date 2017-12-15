/*******************************************************************************
 *                              PROGRAM HEADER                                
 *------------------------------------------------------------------------------
 *  PROGRAM NAME: 0_MAIN_Valtrex_Caplets_plots.sas
 *                                                                            
 *  CREATED BY: Bob Heckel (rsh86800)
 *                                                                            
 *  DATE CREATED: 15-Mar-10
 *                                                                            
 *  SAS VERSION: 8.2
 *                                                                            
 *  PURPOSE: Graph Valtrex data
 *                                                                           
 *  ASSUMPTIONS AND RESTRICTIONS: Input SAS dataset must exist and be in the 
 *                                expected location.
 *                                                                            
 *  DESCRIPTION OF OUTPUT: Analytical graphs for Valtrex Caplets
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
 *  15-Mar-10  |    1.0  | Bob Heckel         | Original.
 *-------------+---------+--------------------+---------------------------------
 *******************************************************************************
 */
%let PRODUCT = Valtrex Caplets;
%let DATASVR = \\Rtpdsntp032\DataPostArchive\Valtrex_Caplets\OUTPUT_COMPILED_DATA;
%let DATASET = valtrex_analytical_individuals;
%let PLOTSVR = \\rtpsawnv0312\pucc\plots\VALTREX_Caplets\OUTPUT;
%let DAYSPAST = 365;
%let DTRANGE = one year;


options symbolgen mlogic mprint;
libname DP "&DATASVR";

data release_individuals;
  set DP.&DATASET;
  if study eq 'Release' and test_date gt "&SYSDATE"d-&DAYSPAST;
run;


%macro separate_by_Test(test);
  data &test;
    /* Full Disso_Percent_Released varname makes a dataset name >32 char */
    length &test 8.;
    set release_individuals;

    if test eq "&test" and result ne 'Conforms' then do;
      numres = result; 
      &test = numres;
      keep &test test_date mfg_batch material strength status;
      output &test;
    end;
  run;
%mend separate_by_Test;
%separate_by_Test(HPLC_Assay);
%separate_by_Test(Disso_Percent_Released);
%separate_by_Test(LOD_Percent);


%macro plotter(varname, strength, minSpec, maxSpec, increment, outFileName, title);
  data individ&varname;
    set &varname;
    if strength eq "&strength";
  run;

  /* Mean by mfg_batch and date */
  proc sort data=individ&varname;
    by mfg_batch test_date;
  run;
  proc means data=individ&varname noprint;
    by mfg_batch test_date;
    var &varname;
    output out=means&varname(drop= _TYPE_ _FREQ_) mean=avg&varname /*min=min&varname max=max&varname*/;
  run;

  /* Combine means with individual values */
  data meanMerge&varname;
    merge individ&varname means&varname;
    by mfg_batch test_date;
  run;

  proc sort data=meanMerge&varname.;
    by test_date mfg_batch;
  run;
  data plot&varname;
    retain batchobs 0; 
    format batchN $10.; 
    set meanMerge&varname.;

    by test_date mfg_batch;

    if first.mfg_batch then batchobs+1; 

    /* Make the batch counter (batchobs) sortable by alphanumeric: '1' = '01' */
    if batchobs lt 10 then batchN='0'||left(trim(substr(left(batchobs),1)))||'0';
    else if batchobs gt 99 then batchN='99'||left(trim(substr(left(batchobs),1)));
    else batchN=left(trim(substr(left(batchobs),1)))||'0';

    keep batchN test_date mfg_batch test_date &varname avg&varname strength;
  run;

  /* Create format for sorting by test_date instead of mfg_batch */
  data formatdata;
    length START $10.
           LABEL $20.
           FMTNAME $15.
           ;
    set plot&varname;

    retain FMTNAME;
    FMTNAME = '$batch';

    if _N_ eq 1 then do;	
      HLO = 'O'; LABEL = ''; START = ' '; OUTPUT; HLO = ' '; 
    end;
    START = batchN;
    LABEL = mfg_batch;
    keep START LABEL HLO FMTNAME;
    output;
  run;

  proc sort NODUPKEY data=formatdata;
    by FMTNAME START HLO;
  run;

  proc format CNTLIN=formatdata; run;
  /* Debug only - view batch to test date map in .lst */
  proc format library=work FMTLIB; run;


  proc means data=plot&varname PRINT;
    var &varname.;
    output out=minmaxYaxis(drop= _TYPE_ _FREQ_) 
    min=min
    max=max
    ;
  run;

  data minmaxYaxis;
    set minmaxYaxis;

    if min lt &minSpec then 
      minVal = int(min-&increment)-1;  /* +/-1 is in case truncation rounds down */
    else
      minVal = int(&minSpec-&increment)-1;

    if max gt &maxSpec then
      maxVal = int(max+&increment)+1;
    else
      maxVal = int(&maxSpec+&increment)+1;

    if minVal lt 0 then minVal=0;

    call symput('minYaxis', minVal);
    call symput('maxYaxis', maxVal);
  run;


  %let stren = %scan(&strength, 1);
/***  goptions reset=goptions dev=cgmmw6c rotate=landscape hsize=0 vsize=0 gsfname=gsf2 gsfmode=replace;***/
  goptions reset=goptions dev=gif rotate=landscape gsfname=gsf2 gsfmode=replace xpixels=1150 ftext="arial/bo";
  filename gsf2 "&PLOTSVR\test_date\&outFileName.&stren..gif";
    
/***  symbol1 interpol=hilob color=blue;***/
/***  symbol2 interpol=none value=dot color=green;***/
  symbol1 i=none w=0.25 h=0.25 v=dot  c=blue;
  symbol2 i=none w=1.00 h=1.00 v=dot  c=green interpol=join;

  axis1 label=NONE;
  axis2 offset=(0,0) minor=none /*label=(a=-90 r=90)*/ label=NONE order=(&minYaxis to &maxYaxis by &increment);

  legend1 label=none shape=symbol(15,1);

  title "&PRODUCT &strength.: &title";
  title2 "Release batches - &DTRANGE";
  title3;
  footnote;
  footnote2 "Plot created on &SYSDATE";

  proc gplot data=plot&varname;
    plot &varname.*batchN avg&varname.*batchN / overlay haxis=axis1 vaxis=axis2 vref=&minSpec &maxSpec lvref=2 legend=legend1;
    format batchn $batch.;
  run;
%mend plotter;



 /* %macro plotter(varname      , strength , minSpec , maxSpec , increment , outFileName            , title);                        */
%plotter(HPLC_Assay             , 500 mg   , 90      , 110     , 2         , HPLC_Assay_            , Assay);
%plotter(Disso_Percent_Released , 500 mg   , 80      , 0       , 2         , Disso_Percent_Release_ , Dissolution Percent Released);
%plotter(LOD_Percent            , 500 mg   , 0       , 4.5     , 1         , LOD_Percent_           , Loss on Drying Percent);

%plotter(HPLC_Assay             , 1000 mg  , 90      , 110     , 2         , HPLC_Assay_            , Assay);
%plotter(Disso_Percent_Released , 1000 mg  , 80      , 0       , 2         , Disso_Percent_Release_ , Dissolution Percent Released);
%plotter(LOD_Percent            , 1000 mg  , 0       , 4.5     , 1         , LOD_Percent_           , Loss on Drying Percent);


%put _all_;
