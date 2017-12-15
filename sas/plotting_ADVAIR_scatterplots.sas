/*******************************************************************************
 *                              PROGRAM HEADER                                
 *------------------------------------------------------------------------------
 *  PROGRAM NAME: plotting_ADVAIR_scatterplots.sas
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
 *  09-Dec-09  |    2.0  | Bob Heckel         | Add AHFA 60s
 *-------------+---------+--------------------+---------------------------------
 *  17-Mar-10  |    8.0  | Bob Heckel         | Modify proc gplot for better
 *             |         |                    | readability
 *******************************************************************************
 */

 /* Allow this module to optionally run standalone */
/***%macro m;%if %superq(OUTP)=  %then %do; %global OUTP; %let OUTP=\\zebwd08D26987\Advair_HFA\Output_Compiled_Data;%end;%mend;%m;***/
%macro m;%if %superq(OUTP)=  %then %do; %global OUTP; %let OUTP=\\rtpsawnv0312\pucc\Advair_HFA\Output_Compiled_Data;%end;%mend;%m;

options symbolgen mlogic mprint;
libname outDir "&OUTP";

/*%plotter(CONTENT,  TDC,    avg_content_weight, avg_FP_TDC_total_mass,120,45-21,low,11.1, 12.3,        7.6,          9.0,          0,          0.125 );*/
%macro plotter(xindex, yindex, xvarname, yvarname, dose, Strength, strengthStr, xminMeanSpec, xmaxMeanSpec, yminMeanSpec, ymaxMeanSpec, xincrement, yincrement);
  data _null_;
		format today_date DATE9.;
		today_date = today();
		call symput('today_date', PUT(today_date, DATE9.)); 
  run;

  data release_summary;
	set outDir.analytical_summary;
	if storage_condition='Release';
  run;


  data release_summary;
     set release_summary;
     if Strength eq "&Strength" and dose eq "&dose"; 
  run;

  proc means data=release_summary noprint;
		var &xvarname. &yvarname.;
		output out=MinMax(drop= _type_ _freq_) 
			min=min&xvarname. min&yvarname.
			max=max&xvarname. max&yvarname.
		;
	run;

	data MinMax;
		set MinMax;
		if min&xvarname. < &xminMeanSpec. then minVal&xvarname. = min&xvarname.- &xincrement.;
			else minVal&xvarname.= &xminMeanSpec. - &xincrement.;

		if max&xvarname. > &xmaxMeanSpec. then maxVal&xvarname.= max&xvarname.+ &xincrement.;
			else maxVal&xvarname.= &xmaxMeanSpec. + &xincrement.;

        if minVal&xvarname. < 0 then  minVal&xvarname. = 0;

		call symput('xminPlot',minVal&xvarname.);
		call symput('xmaxPlot',maxVal&xvarname.);

		if min&yvarname.< &yminMeanSpec. then minVal&yvarname.=min&yvarname.- &yincrement.;
			else minVal&yvarname.= &yminMeanSpec. - &yincrement.;

		if max&yvarname. > &ymaxMeanSpec. then maxVal&yvarname.=max&yvarname.+ &yincrement.;
			else maxVal&yvarname.= &ymaxMeanSpec. + &yincrement.;
        
		if minVal&yvarname. < 0 then  minVal&yvarname. = 0;

		call symput('yminPlot',minVal&yvarname.);
		call symput('ymaxPlot',maxVal&yvarname.);
	run;

  data release_summary;
       format latest_testdate MMDDYY8.;
	 set release_summary;
	 if testdate_&xindex. > testdate_&yindex. then latest_testdate = testdate_&xindex.;
	 if testdate_&xindex. < testdate_&yindex. then latest_testdate = testdate_&yindex.;
  run;

  proc sort data = release_summary ;
	by descending latest_testdate;
  run;

  Data release_summary_first_1;
	format batch_ID $16.;
	set  release_summary (firstobs = 1 obs = 1);
	batch_ID = mfg_batch;
    index1 = mfg_batch;  
	call symput('index1',index1);
  run;

  Data release_summary_first_2;
	format batch_ID $16.;
	set  release_summary (firstobs = 2 obs = 2);
	batch_ID = mfg_batch; 
	index2 = mfg_batch; 
	call symput('index2',index2);
  run;

  Data release_summary_first_3;
	format batch_ID $16.;
	set  release_summary (firstobs = 3 obs = 3);
	batch_ID = mfg_batch; 
	index3 = mfg_batch; 
	call symput('index3',index3);
  run;

  Data release_summary_first_4;
	format batch_ID $16.;
	set  release_summary (firstobs = 4 obs = 4);
	batch_ID = mfg_batch; 
	index4 = mfg_batch;
    call symput('index4',index4); 
  run;

  Data release_summary_first_5;
	format batch_ID $16.;
	set  release_summary (firstobs = 5 obs = 5);
	batch_ID = mfg_batch;
    index5 = mfg_batch; 
    call symput('index5',index5); 
  run;

  Data release_summary_rest;
	format batch_ID $16.;
    set release_summary (firstobs = 6 obs = 110); 
    batch_ID = "previous";
	index6 = "previous"; 
	call symput('index6',index6);
  run;

  Data release_summary_batch_ID;
     set release_summary_first_1  release_summary_first_2 release_summary_first_3 
         release_summary_first_4 release_summary_first_5 release_summary_rest ;
  run;


  PROC SORT DATA = release_summary_batch_ID(keep = DATASTATUS) out = outfreq;
    by descending DATASTATUS;
  run;

  data outfreq;
	
	set outfreq(obs=1);
	App_status=DATASTATUS;
	call symput('App_status',App_status);
  run;

    
  * plot two dimension plots;
  goptions dev=cgmmw6c rotate=landscape htext=0.9 hsize=0 vsize=0 gsfname=gsf2 gsfmode=replace;
  filename gsf2 "&OUTP\PLOTs\scatterplots\&yvarname._BY_&xvarname._&strengthStr._&dose..cgm";

  %if &App_status = Approved %then %Approved;
  %else %Unapproved;
%mend plotter;

 /* v2 rsh86800 reorganized */
%macro Approved;
  proc gplot data=release_summary_batch_ID;
    title1 h=1.5 "Advair HFA &dose (&yvarname) by (&xvarname)";
    title2 ' ';
    title3 h=1.25 "Strength: &strength";

    footnote1 h=0.85 "Plot created &today_date";
    footnote2 ' ';

    axis1 label=(a=90 r=0 " &yvarname") order=(&yminPlot to &ymaxPlot by &yincrement);
    axis2 order=(&xminPlot to &xmaxPlot by &xincrement);

    symbol1 i=none w=1.75 h=1.75 v=dot c=brown;
    symbol2 i=none w=1.75 h=1.75 v=dot c=blue;
    symbol3 i=none w=1.75 h=1.75 v=dot c=gray;
    symbol4 i=none w=1.75 h=1.75 v=dot c=orange;
    symbol5 i=none w=1.75 h=1.75 v=dot c=black;
    symbol6 i=none w=0.625 h=0.625 v=dot c=green interpol=R;

    legend1 label=NONE frame;  /* suppress text 'batch_ID' */

    plot &yvarname*&xvarname=batch_ID / vaxis=axis1 haxis=axis2 frame 
                                        href= &xminMeanSpec &xmaxMeanSpec lhref=(3 3) chref=(green,green)
                                        vref= &yminMeanSpec &ymaxMeanSpec lvref=(3 3) cvref=(green,green)
                                        legend=legend1
                                        ;
  run;
  quit;
%mend;


 /* v2 rsh86800 reorganized */
%macro Unapproved;
  data average;/*{{{*/
     set release_summary_batch_ID;
	 keep &yvarname. &xvarname. datastatus batch_ID;
  run;

  data average;
     set average;
	 yvar = &yvarname. ;
	 xvar = &xvarname. ;
  run;

  data annoDataset;
     retain xsys ysys '2' hsys '3' when 'a' color 'blue' text 'dot' function 'symbol' size 2;
     set average release_summary_first_1  release_summary_first_2 release_summary_first_3 
         release_summary_first_4 release_summary_first_5 release_summary_rest;
     x=xvar;
	 y=yvar;

     if datastatus = 'Approved'  and batch_ID = &index1. then  do;
     color = 'brown';
     size = 3;
	 end;

	 if datastatus = 'Approved'  and batch_ID = &index2. then  do;
     color = 'blue';
     size = 3;
	 end;

	 if datastatus = 'Approved'  and batch_ID = &index3. then  do;
     color = 'gray';
     size = 3;
	 end;

	 if datastatus = 'Approved'  and batch_ID = &index4. then  do;
     color = 'orange';
     size = 3;
	 end;

     if datastatus = 'Approved'  and batch_ID = &index5. then  do;
     color = 'black';
     size = 3;
	 end;

	 if datastatus ^= 'Approved'  and batch_ID = &index1. then  do;
     color = 'red';
     size = 3;
	 end;

	 if datastatus ^= 'Approved'  and batch_ID = &index2. then  do;
     color = 'red';
     size = 3;
	 end;

	 if datastatus ^= 'Approved'  and batch_ID = &index3. then  do;
     color = 'red';
     size = 3;
	 end;

	 if datastatus ^= 'Approved'  and batch_ID = &index4. then  do;
     color = 'red';
     size = 3;
	 end;

     if datastatus ^= 'Approved'  and batch_ID = &index5. then  do;
     color = 'red';
     size = 3;
	 end;

     if datastatus = 'Approved'  and batch_ID = &index6. then  do;
     color = 'green';
     size = 1;
	 end;
     

	 if datastatus ^= 'Approved'  and batch_ID = &index6. then  do;
     color = 'red';
     size = 1;
	 end;
  run;/*}}}*/

  proc gplot data=annoDataset;
    title1 h=1.5 "Advair HFA &dose (&yvarname) by (&xvarname)";
    title2 ' ';
    title3 h=1.25 "Strength: &strength";

    footnote1 h=0.85 "Plot created &today_date";
    footnote2 ' ';

    axis1 label=(a=90 r=0 " &yvarname") order=(&yminPlot to &ymaxPlot by &yincrement);
    axis2 order=(&xminPlot to &xmaxPlot by &xincrement);

    legend1 label=NONE frame;

    plot &yvarname*&xvarname / anno=annoDataset
                               vaxis=axis1 haxis=axis2 frame 
                               href=&xminMeanSpec &xmaxMeanSpec lhref=(3 3) chref=(green,green)
                               vref=&yminMeanSpec &ymaxMeanSpec lvref=(3 3) cvref=(green,green)
                               legend=legend1
                               ;
  run;
  quit;
%mend Unapproved;


 /* Start 120 dose */

/*%macroplotter(xindex  ,yindex,              xvarname,                  yvarname,dose ,Strength,strengthStr,xminMeanSpec,xmaxMeanSpec,yminMeanSpec,ymaxMeanSpec,xincrement,yincrement);*/
/* "Total Drug Content per Canister (g)" by "Total Drug Content per Canister (mg)" */
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_TDC_total_mass    , 120 , 45-21  , low  , 11.1 , 12.3 , 7.6  , 9.0  , 1   , 0.125 );
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_TDC_total_mass    , 120 , 115-21 , mid  , 11.1 , 12.3 , 19.0 , 22.3 , 1   , 0.25);
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_TDC_total_mass    , 120 , 230-21 , high , 11.1 , 12.3 , 37.5 , 44.0 , 1   , 1);

/* "Total Drug Content per Canister (g)" by "Mean Drug Content per Dose (ug) footnote" */
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_DTU_BEG           , 120 , 45-21  , low  , 11.1 , 12.3 , 36   , 54   , 1   , 2 );
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_DTU_BEG           , 120 , 115-21 , mid  , 11.1 , 12.3 , 92   , 138  , 1   , 5);
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_DTU_BEG           , 120 , 230-21 , high , 11.1 , 12.3 , 184  , 276  , 1   , 10);

%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_DTU_END           , 120 , 45-21  , low  , 11.1 , 12.3 , 36   , 54   , 1   , 2 );
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_DTU_END           , 120 , 115-21 , mid  , 11.1 , 12.3 , 92   , 138  , 1   , 5);
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_DTU_END           , 120 , 230-21 , high , 11.1 , 12.3 , 184  , 276  , 1   , 10);

%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_CI_Total_ExDevice , 120 , 45-21  , low  , 11.1 , 12.3 , 36   , 48   , 1   , 1);
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_CI_Total_ExDevice , 120 , 115-21 , mid  , 11.1 , 12.3 , 98   , 120  , 1   , 2);
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_CI_Total_ExDevice , 120 , 230-21 , high , 11.1 , 12.3 , 175  , 240  , 1   , 4);

/* "Total Drug Content per Canister (mg)" by ? */
%plotter(TDC            , CI  , avg_FP_TDC_total_mass , avg_FP_CI_Total_ExDevice , 120 , 45-21  , low  , 7.6  , 9.0  , 36   , 48   , 0.1 , 1);
%plotter(TDC            , CI  , avg_FP_TDC_total_mass , avg_FP_CI_Total_ExDevice , 120 , 115-21 , mid  , 19.0 , 22.3 , 98   , 120  , 0.2 , 2);
%plotter(TDC            , CI  , avg_FP_TDC_total_mass , avg_FP_CI_Total_ExDevice , 120 , 230-21 , high , 37.5 , 44.0 , 175  , 240  , 1   , 5);

%plotter(DTU            , CI  , avg_FP_DTU_BEG        , avg_FP_CI_Total_ExDevice , 120 , 45-21  , low  , 36   , 54   , 36   , 48   , 1   , 2);
%plotter(DTU            , CI  , avg_FP_DTU_BEG        , avg_FP_CI_Total_ExDevice , 120 , 115-21 , mid  , 92   , 138  , 98   , 120  , 4   , 2);
%plotter(DTU            , CI  , avg_FP_DTU_BEG        , avg_FP_CI_Total_ExDevice , 120 , 230-21 , high , 184  , 276  , 175  , 240  , 6   , 6);

%plotter(DTU            , CI  , avg_FP_DTU_END        , avg_FP_CI_Total_ExDevice , 120 , 45-21  , low  , 36   , 54   , 36   , 48   , 1.5 , 1.5);
%plotter(DTU            , CI  , avg_FP_DTU_END        , avg_FP_CI_Total_ExDevice , 120 , 115-21 , mid  , 92   , 138  , 98   , 120  , 2   , 2);
%plotter(DTU            , CI  , avg_FP_DTU_END        , avg_FP_CI_Total_ExDevice , 120 , 230-21 , high , 184  , 276  , 175  , 240  , 5   , 5);


 /* Start 60 dose */

/* "Weight of Canister Contents Mean (g)" by "Drug Content per Canister Mean (mg)" */
/* PRS02116 */
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_TDC_total_mass    ,  60 , 45-21  , low  ,  7.1 ,  8.3 , 5.2  , 6.6  , 1   , 0.125 );
/* PRS02115 */
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_TDC_total_mass    ,  60 , 115-21 , mid  ,  7.1 ,  8.3 , 12.9 , 16.4 , 1   , 0.25);
/* PRS02114 */
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_TDC_total_mass    ,  60 , 230-21 , high ,  7.1 ,  8.3 , 24.3 , 31.0 , 1   , 1);

/* "Weight of Canister Contents Mean (g)" by "Mean Drug Content per Dose (mcg)" */
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_DTU_BEG           ,  60 , 45-21  , low  ,  7.1 ,  8.3 , 36   , 54   , 1   , 2 );
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_DTU_BEG           ,  60 , 115-21 , mid  ,  7.1 ,  8.3 , 92   , 138  , 1   , 5);
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_DTU_BEG           ,  60 , 230-21 , high ,  7.1 ,  8.3 , 184  , 276  , 1   , 10);

%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_DTU_END           ,  60 , 45-21  , low  ,  7.1 ,  8.3 , 36   , 54   , 1   , 2 );
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_DTU_END           ,  60 , 115-21 , mid  ,  7.1 ,  8.3 , 92   , 138  , 1   , 5);
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_DTU_END           ,  60 , 230-21 , high ,  7.1 ,  8.3 , 184  , 276  , 1   , 10);

/* "Weight of Canister Contents Mean (g)" by ??? */
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_CI_Total_ExDevice ,  60 , 45-21  , low  ,  7.1 ,  8.3 , 36   , 48   , 1   , 1);
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_CI_Total_ExDevice ,  60 , 115-21 , mid  ,  7.1 ,  8.3 , 98   , 120  , 1   , 2);
%plotter(CONTENT_WEIGHT , TDC , avg_content_weight    , avg_FP_CI_Total_ExDevice ,  60 , 230-21 , high ,  7.1 ,  8.3 , 175  , 240  , 1   , 4);

/* "Drug Content per Canister Mean (mg)" by ??? */
%plotter(TDC            , CI  , avg_FP_TDC_total_mass , avg_FP_CI_Total_ExDevice ,  60 , 45-21  , low  , 5.2  , 6.6  , 36   , 54   , 0.1 , 1);
%plotter(TDC            , CI  , avg_FP_TDC_total_mass , avg_FP_CI_Total_ExDevice ,  60 , 115-21 , mid  , 12.9 , 16.4 , 98   , 120  , 0.2 , 2);
%plotter(TDC            , CI  , avg_FP_TDC_total_mass , avg_FP_CI_Total_ExDevice ,  60 , 230-21 , high , 24.3 , 31.0 , 175  , 240  , 1   , 5);

/* "Mean Drug Content per Dose (mcg)" by ??? */
%plotter(DTU            , CI  , avg_FP_DTU_BEG        , avg_FP_CI_Total_ExDevice ,  60 , 45-21  , low  , 36   , 54   , 36   , 54   , 1   , 2);
%plotter(DTU            , CI  , avg_FP_DTU_BEG        , avg_FP_CI_Total_ExDevice ,  60 , 115-21 , mid  , 92   , 138  , 98   , 120  , 4   , 2);
%plotter(DTU            , CI  , avg_FP_DTU_BEG        , avg_FP_CI_Total_ExDevice ,  60 , 230-21 , high , 184  , 276  , 184  , 276  , 6   , 6);

/* "Mean Drug Content per Dose (mcg)" by ??? */
%plotter(DTU            , CI  , avg_FP_DTU_END        , avg_FP_CI_Total_ExDevice ,  60 , 45-21  , low  , 36   , 54   , 36   , 54   , 1.5 , 1.5);
%plotter(DTU            , CI  , avg_FP_DTU_END        , avg_FP_CI_Total_ExDevice ,  60 , 115-21 , mid  , 92   , 138  , 92   , 138  , 2   , 2);
%plotter(DTU            , CI  , avg_FP_DTU_END        , avg_FP_CI_Total_ExDevice ,  60 , 230-21 , high , 184  , 276  , 184  , 276  , 5   , 5);

