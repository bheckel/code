options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_gplot.small_screen.sas
  *
  *  Summary: Demo of simple, small smartphone oriented graphs.  Uses 
  *           reference lines.
  *
  *  Adapted: Tue 24 Mar 2009 14:45:01 (Bob Heckel -- LeRoy Bessler SUGI 034-2008)
  *---------------------------------------------------------------------------
  */
options source NOcenter NOmlogic NOsgen;

data DOW19901991;
  drop snydjcm;
  retain FirstTradingDayIn1991Found 'N' TradingDay 0;
  length MonthAbbrev $ 1;
  set SASHELP.citiday(keep= date snydjcm where=(snydjcm ne .));
  Year = year(date);
  if Year in (1990 1991);
  if Year eq 1990 or FirstTradingDayIn1991Found eq 'Y' then
    TradingDay = TradingDay + 1;
  else do;
    TradingDay = 1;
    FirstTradingDayIn1991Found = 'Y';
  end;
  Dow=round(snydjcm,1);
  Month = month(date);
  MonthAbbrev=substr(left(put(date,monname3.)),1,1);
run;



%macro CommonPreliminaryCode(PathToGraph=,FigureNumber=,BackgroundColor=CXFFFF00);
  goptions reset=all;
  goptions device=GIF;
/***  goptions ypixels=129 xpixels=172;***/
  goptions ypixels=320 xpixels=320;
  goptions border;
  goptions cback=&BackgroundColor;
  goptions gsfmode=replace gsfname=anyname;
  filename anyname "&PathToGraph.\Figure&FigureNumber..GIF";
%mend;


%macro GetHtickmarkValues;
  %do i = 1 %to &NumberOfTickMarks %by 1;
    "&&htickvalue&i"
  %end;
%mend GetHtickmarkValues;


%macro CreateTradeDayHtickmarkValues(data=,filter=);
  /* Maximum number of trading days in a year is 263.  Possible extra GLOBAL
   * statements are harmless.
   */
  %do i = 1 %to 262 %by 1;
    %global htickvalue&i;
  %end;

  /* For the actual number of trading days found: */
  %global NumberOfTickMarks;

  data Selected;
    set &data;
    %if %length(&filter) ne 0 %then %do;
      where &filter;
    %end;
  run;

  data _null_;
    retain DayInMonth 0;
    set Selected end=LastOne;
    by Month;
    if first.Month then
      DayInMonth = 1;
    else
      DayInMonth = DayInMonth+1;
    /* The monthly average number of trading days is 22.  Want to put the month
     * abbrev label at the mid-month.
     */
    if DayInMonth eq 11 then
      call symput('htickvalue'||trim(left(_N_)),MonthAbbrev);
    else
      call symput('htickvalue'||trim(left(_N_)),'');
    if LastOne;
    call symput('NumberOfTickMarks',trim(left(_N_)));
  run;
%mend CreateTradeDayHtickmarkValues;


%macro IdentifyXdatesForCriticalPoints(data=,yVar=,xDateVar=);
  %global LocateMinAndOrMaxWhenUnique;
  data _null_;
    length MinLoc MaxLoc $ 11;
    retain HowManyXfoundForMinY HowManyXfoundForMaxY 0;
    retain xForMinY . xForMaxY .;
    set &data end=LastOne;
    if &Yvar EQ &yAxisStartTickMarkValue then do;
      if HowManyXfoundForMinY eq 0 then do;
        HowManyXfoundForMinY = 1;
        xForMinY = &xDateVar;
      end;
      else
        HowManyXfoundForMinY + 1;
      end;
    else
      if &Yvar EQ &yAxisEndTickMarkValue then do;
        if HowManyXfoundForMaxY eq 0 then do;
          HowManyXfoundForMaxY = 1;
          xForMaxY = &xDateVar;
        end;
        else HowManyXfoundForMaxY + 1;
      end;

    if LastOne;

    put HowManyXfoundForMinY= HowManyXfoundForMaxY= xForMinY= xForMaxY=;

    if HowManyXfoundForMinY eq 1 then
      MinLoc = "Min:" || trim(left(put(xForMinY,date7.)));
    else
      MinLoc = " ";

    if HowManyXfoundForMaxY eq 1 then
      MaxLoc = "Max:" || trim(left(put(xForMaxY,date7.)));
    else
      MaxLoc = " ";

    call symput('LocateMinAndOrMaxWhenUnique',trim(left(MinLoc)) || " " || trim(left(MaxLoc)));
  run;
%mend IdentifyXdatesForCriticalPoints;


%macro IdentifyYaxisCriticalPoints(data=,filter=,yVar=,yVarFormat=);
  %global yVarStart yVarEnd;
  data Selected;
    set &data;
    %if %length(&filter) ne 0 %then %do;
    where &filter;
    %end;
  run;

  data _null_;
    set Selected end=LastOne;
    if _N_ eq 1 then
      call symput('yVarStart',trim(left(put(&yVar,&yVarFormat))));
    else
    if LastOne then
      call symput('yVarEnd' ,trim(left(put(&yVar,&yVarFormat))));
  run;

  proc means data=Selected min max range noprint;
    var &Yvar;
    output out=MinMaxRange min=yMin max=yMax range=yMaxMinDiff;
  run;

  %global yAxisStartTickMarkValue yAxisStartTickMarkDisplay yAxisEndTickMarkValue yAxisEndTickMarkDisplay yAxisIncrement;

  data _null_;
    set MinMaxRange;
    call symput('yAxisStartTickMarkValue' ,trim(left(yMin)));
    call symput('yAxisStartTickMarkDisplay',trim(left(put(yMin,&yVarFormat))));
    call symput('yAxisEndTickMarkValue' ,trim(left(yMax)));
    call symput('yAxisEndTickMarkDisplay' ,trim(left(put(yMax,&yVarFormat))));
    call symput('yAxisIncrement',trim(left(yMaxMinDiff)));
  run;

  data _null_;
    set Selected;

    if &yVar LT &yAxisStartTickMarkValue then
      put &yVar= " is below yAxis Start &yAxisStartTickMarkValue";

    if &yVar GT &yAxisEndTickMarkValue then
      put &yVar= " is above yAxis End &yAxisEndTickMarkValue";
  run;
%mend IdentifyYaxisCriticalPoints;


%CommonPreliminaryCode(PathToGraph=c:/temp,FigureNumber=11);
footnote1 angle=+90 font=none height=1 ' ';
footnote2 angle=-90 font=none height=1 ' ';
/* For multi-line plots, presence of legend creates extra white space at bottom. */
footnote3; /* turn off white space at bottom. */
title1 font=none height=1 ' ';
goptions htext=9pt ftext='Verdana';
 /* 1990 and 1991 had 262 and 263 trading days. On a two-line plot, use 263 invisible tick marks. */
%CreateTradeDayHtickmarkValues(data=DOW19901991,filter=%str(Year eq 1991));
axis1 label=none major=none minor=none style=0 order=1 to &NumberOfTickMarks by 1 value=(%GetHtickmarkValues);
%IdentifyYaxisCriticalPoints(data=DOW19901991,yVar=Dow,yVarFormat=4.);
axis2 label=none major=none minor=none style=0 order=&yAxisStartTickMarkValue to &yAxisEndTickMarkValue by &yAxisIncrement value=("&yAxisStartTickMarkDisplay" "&yAxisEndTickMarkDisplay");
title2 font='Verdana' justify=CENTER height=9pt "Dow Index 1990-1991" justify=CENTER "Start=&yVarStart, End=&yVarEnd";
%IdentifyXdatesForCriticalPoints(data=DOW19901991,yVar=DOW,xDateVar=date);
title3 font='Verdana' height=9pt "&LocateMinAndOrMaxWhenUnique";
symbol1 color=CXFF0000 interpol=join v=none w=1;
symbol2 color=CX0000FF interpol=join v=none w=1;
legend1 label=none shape=symbol(15,1);

proc gplot data=DOW19901991;
  /* dark gray dotted reference lines at top and bottom of vaxis range */
  plot Dow*TradingDay=Year / haxis=axis1 vaxis=axis2 legend=legend1 vref=&yAxisStartTickMarkValue &yAxisEndTickMarkValue cvref=CX333333 lvref=35;
run; quit;

