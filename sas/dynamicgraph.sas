/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  PROGRAM NAME:     DataPost_DynamicGraph.sas
 *
 *  CREATED BY:       Bob Heckel (rsh86800)
 *                                                                            
 *  DATE CREATED:     19-Apr-13
 *                                                                            
 *  SAS VERSION:      8.2
 *
 *  PURPOSE:          
 *
 *  INPUT:            XML configuration file
 *
 *  PROCESSING:       
 *
 *  OUTPUT:           
 *------------------------------------------------------------------------------
 *                     HISTORY OF CHANGE
 *-------------+---------+--------------------+---------------------------------
 *     Date    | Version | Modification By    | Nature of Modification
 *-------------+---------+--------------------+---------------------------------
 *  19-Apr-13  |    1.0  | Bob Heckel         | Original. CCF ?????.
 *-------------+---------+--------------------+---------------------------------
 *******************************************************************************
 */
%macro dg;
/***  %let DRIVEPATH=e:\datapost\data;***/
  %let DRIVEPATH=e:\datapostdemo\data;

  %if &_SRVNAME eq rtpsawn321 %then %do;
    %let URL=http://zdatapostd.gsk.com/DataPostDEMO/data;
  %end;
  %else %if &_SRVNAME eq kopsawn557 %then %do;
    %let URL=http://zdatapostd.gsk.com/DataPostDEMO/data;
  %end;
  %else %if &_SRVNAME eq rtpsawn323 %then %do;
    %let URL=http://zdatapostd.gsk.com/DataPostDEMO/data;
  %end;

  %let UNIQID=&SYSPROCESSID;
  %let TMPIMG=e:\datapostdemo\data\t_&UNIQID..gif;

  /*TODO*/
  libname TMPLIB 'e:/temp';

  filename GOUT "&TMPIMG";
  goptions reset=all htext=3 gunit=pct ctext=green device=gif gsfname=GOUT xpixels=1024 ypixels=768;

  %macro bobh2103134608; /* {{{ */
  libname DPDATA 'e:\DataPostDEMO\data\GSK\Zebulon\SolidDose\Bupropion';
  data t;
    set DPDATA.ols_0002t_bupropion;
    if mrp_batch_id in ('2ZM0211','2ZM2275');
    rename recorded_text=resultn1;
    rename mrp_batch_id=Batchn;
  run;
  %mend bobh2103134608; /* }}} */

  proc sort data=TMPLIB.xcondition out=xcondition; by columnname columnvalue; run;
  data _null_;
    set xcondition(where=(upcase(columnname) eq 'LONG_PRODUCT_NAME'));
    by columnname columnvalue;
    if first.columnvalue then do;
      i+1;
    end;
    call symput('xTHE_PROD'||compress(i), columnvalue);
    call symput('CNTPROD', i);
  /***  put '!!!wtf '(_all_)(=);run;  ***/
  run;

  proc sort data=TMPLIB.xcondition out=xcondition;
    by conditions_ordinal condition_ordinal columnname columnvalue;
  run;
  data t2;
    retain myprd;
    length myprd $80;
    set xcondition;
    by conditions_ordinal condition_ordinal columnname columnvalue;
    if first.conditions_ordinal then do;
      myprd = columnvalue;
    end;
  run;

  proc sort data=t2 NODUPKEY; by columnvalue; run;
  data t3;
    set t2(where=(upcase(columnname) eq 'LONG_TEST_NAME' and myprd eq: "&the_product"));
      i+1;
    call symput('xTHE_METH'||compress(i), columnvalue);
    call symput('CNTMETH', i);
  run;
/***data _null_; set t3; put (_all_)(=); run;***/

   /* grep -i 'LimitPattern_1_1 resolv' /cygdrive/z/Datapost/code/DataPost_Trend.log */
  %let i=1; %let Axis_X=mrp_batch_id; %let BatchCnt=2; %let NOCTL=; %let Title1=Bupropion SR 150 mg Purple Tablets;
  %let OutputTrendType_1_1=XsChart; %let PlotMessage1=Plot generated at; %let LimitPattern=1 2 3 4 5 6 7 8;
  %macro bobh2103134511; /* {{{ */
    proc shewhart data=DataPost_Data limits=xs_table;
        xchart resultn1*&Axis_X /tests= &LimitPattern testlabel=testindex
              test2run=8 test3run=7
                ctests=(1 red 2 purple 3 orange 4 brown 5 blue 6 green 7 cyan 8 magenta)						 
              cconnect=grey
              tableall(exceptions)
              npanelpos=850
              TURNHLABELS
              LIMITN=&BatchCnt 
              alln 
              NDECIMAL=3
              nmarkers
              &&NOCTL  ;
          ods output xchart=tempX;
        label &Axis_X='Batch Number (by Manufacture Date)'  resultn1='Mean';
  /***   		title &Title1 &Title2 &Title3; footnote j=l "&&OutputTrendType_&I._1 TrendId : %UPCASE(&TrendID) &&PlotMessage1 &&ExecutionStopTime&I &&PlotMessage2 &&PlotDateMIN &&PlotMessage3 &&PlotDateMAX";;***/
    run;
  %mend bobh2103134511; /* }}} */

  %if &the_type eq 42 %then %do;
    %put !!!!!%the_product;

    /*TODO*/
    libname TMPLIB2 'E:\DataPostDEMO\data\GSK\Zebulon\SolidDose\Bupropion';

    data DataPost_Data;
      set TMPLIB2.DataPost_Data;
/***put '!!!wtf '(_all_)(=);run;  ***/
    run;
/***    data xs_table;***/
/***      set TMPLIB.xs_table;***/
/***    run;***/

    proc gplot data=DataPost_Data;	
      plot resultn1*Batchn; 
      label BatchN="Batch Number (by Manufacture Date) &the_product" resultn1='Mean';
    /***  title "&Title1 &Title2 &Title3"; footnote j=l "&&OutputTrendType_&I._1 TrendId : %UPCASE(&TrendID) &&PlotMessage1 &&ExecutionStopTime&I &&PlotMessage2 &&PlotDateMIN &&PlotMessage3 &&PlotDateMAX";;***/
    /***	format BatchN $xbatch.;***/
      footnote j=l "&PlotMessage1 at &SYSDATE &SYSTIME";
      footnote2 j=l "&sel_method";
    run;
    ods html body=_WEBOUT (dynamic title='FINISHED') style=brick rs=none;
      data _null_;
        file _WEBOUT;
/***        put '<img src='; put "http://zdatapostd.gsk.com/datapostDEMO/data/t_&UNIQID..gif"; put '>';***/
/***        put '<img src='; put "&URL/t_&UNIQID..gif"; put '>';***/
        put "<img src='&URL/t_&UNIQID..gif'>";
      run;
    ods html close;
  %end;
  %else %if "&the_product" ne "" %then %do;
    ods html body=_WEBOUT (dynamic title='HAVEPROD') style=brick rs=none;
      data _null_;
        file _WEBOUT;
        put '<style type="text/css"> p {color:green; font-weight:bold; font-size:110%;} table,th,td {border:1px solid black; padding:15px;}</style>';
        put "<form action='http://&_SRVNAME/sasweb/cgi-bin/broker.exe' method='GET' name='the_form'>";
        put '<input type="hidden" name="_debug" value="131">';
        put '<input type="hidden" name="_service" value="default">';
        put '<input type="hidden" name="_program" value="dpdemo.dynamicgraph.sas">';
        put '<input type="hidden" name="the_type" value="42">';
        put "<input type='hidden' name='the_product' value='&the_product'>";
        put '<table><tr><td>';
        put '<p>Select Product:</p>';
        put '<select name="the_product" id="RQdata" style="width:350px;" DISABLED>';
        put "<option value="placeholder">&the_product</option>";
        put '</select>';
        put '<p><b>Select Method:</b></p>';
        put '<select name="sel_method" id="methodList" style="width:500px;">';
      %do i=1 %to &CNTMETH;
          put "<option value='&&xTHE_METH&i'> &&xTHE_METH&i </option>";
      %end;
        put '</select>';
        put '<p>Select Range:</p>';
        put '<input type="radio" name="the_radio" value="3">3 months';
        put '<input type="radio" name="the_radio" value="6" checked>6 months';
        put '<input type="radio" name="the_radio" value="9">9 months';
        put '<input type="radio" name="the_radio" value="12">12 months';
        put ' / OR Enter Number of Batches <input type="text" name="inptype" value=""><br><br>';
        put '<input name="the_submit" type="submit" value="Create Graph">';
        put '</td></tr></table>';
      run;
    ods html close;
  %end;
  %else %do;
    ods html body=_WEBOUT (dynamic title='HAVENOTHING') style=brick rs=none;
      data _null_;
        file _WEBOUT;
        put '<style type="text/css"> p {color:blue;} table,th,td {border:1px solid black; padding:15px;}</style>';
        put "<form action='http://&_SRVNAME/sasweb/cgi-bin/broker.exe' method='GET' name='the_form'>";
        put '<input type="hidden" name="_debug" value="131">';
        put '<input type="hidden" name="_service" value="default">';
        put '<input type="hidden" name="_program" value="dpdemo.dynamicgraph.sas">';
        put '<input type="hidden" name="the_type" value="41">';
        put '<table><tr><td>';
        put '<p><b>Select Product:</b></p>';
        put '<select name="the_product" id="RQdata" style="width:350px;">';
      %do i=1 %to &CNTPROD;
        put "<option value='&&xTHE_PROD&i'> &&xTHE_PROD&i </option>";
      %end;
        put '</select>     ';
        put '<p><input name="the_submit" type="submit" value="Next"></p>';
        put '</td></tr></table>';
      run;
    ods html close;
  %end;
  data _null_;
    rc=sleep(5);
    put rc=;
    %put !!!! &TMPIMG;
    rc2=system("del &TMPIMG");
    put rc2=;
  run;
%mend dg;
%dg;
