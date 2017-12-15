options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: rwi_excel_formatted.sas
  *
  *  Summary: Report Writer Interface demo
  *
  *  Adapted: Thu 04 Aug 2016 15:25:14 (Bob Heckel--http://support.sas.com/resources/papers/proceedings15/SAS1880-2015.pdf)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data t;
  input market :$10. value :comma10.2 change;
  cards;
S&P500 2,025.00 200
DOW 17,526.00 300
NASDAQ 4165.50 200
US_Dollar 92,751.00 500
Crude_Oil 47.52 -3
T-Notes 129,000.00 -5000
  ;
run; 
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;


ods escapechar="^";
ods excel file="~/bob/t.xlsx" options(embedded_titles="yes");

data _null_;
  set t end=done;

  if _N_ = 1 then do;
    declare odsout obj();

    obj.title(data:"%sysfunc(today(),worddate.)");
    /********** START TABLE **********/
    obj.table_start();
    /******* START HEADER ROW *******/
    obj.row_start();
    obj.format_cell(data:"Morning Markets",column_span:4, style_attr:"background=red color=yellow");
    obj.row_end();
    /******* END HEADER ROW *******/
  end;

  percent=(value/change)/100;

  /******* START OBS ROW *******/
  obj.row_start();
    /* Prepend up/down unicode arrows */
    if change > 0 then obj.format_cell(data: market,style_attr:"pretext='^{style[color=green] ^{unicode 2B06}}' background=#CCFFFF just=l");
    else obj.format_cell(data:market,style_attr: "pretext='^{style[color=red] ^{unicode 2B07}}' background=#CCFFFF just=l ");

    obj.format_cell(data: value, style_attr:" background=#CCFFFF");
    obj.format_cell(data: change,style_attr:" background=#CCFFFF");
    obj.format_cell(data: percent,style_attr:" background=#CCFFFF", format:"percent10.2");
  obj.row_end();

  if done then do;
    obj.row_start();
      obj.format_cell(data:"Data as of %sysfunc(time(),time.)",
      column_span: 4,style_attr: "backgroundcolor=red
      color=yellow");
    /******* END OBS ROW *******/
    obj.row_end();

    obj.table_end();
    /********** END TABLE **********/
  end;
run;

ods excel close 
