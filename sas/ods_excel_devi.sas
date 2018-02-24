options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ods_excel_devi.sas
  *
  *  Summary: Demo of combining Excel ODS and proc report
  *
  *  Adapted: Fri 12 Jan 2018 10:30:25 (Bob Heckel -- Devi Sekar SESUG2017_Paper-177)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data toc;
  length tab_name $10 tab_description $100;

  tab_name = "Report1a";
  tab_description = " List of Cars By Make, Type and Model (with profit pre-computed) ";
  output;

  tab_name = "Report1b";
  tab_description = " List of Cars By Make, Type and Model (with profit computed using Excel formulas)";
  output;

  tab_name = "Report2";
  tab_description = " Average MPG City, MPG Highway, MSRP, and Invoice Price by Type, Make, and Origin ";
  output;

  tab_name = "Report3";
  tab_description = " Average MSRP and Invoice Price By Type and across Make within Origin";
  output;
run;

ods excel file='~/bob/tmp/SESUG2017_Tables.xlsx' style=pearl options (embedded_titles = 'yes' embedded_footnotes = 'yes');
%let header_col_style = style(header)=[font_weight=bold font_size=11pt color=black bordertopstyle=solid bordertopwidth=0.1pt bordertopcolor=black borderbottomstyle=solid borderbottomwidth=0.1pt borderbottomcolor=black just=center] style(column)=[font_size=11pt];
ods excel options(sheet_name ='TOC' sheet_interval = 'Table' absolute_column_width='12,100' row_heights='30,20,20,20,20');
title j=left bold "List of Tables";


proc report data=toc &header_col_style;
  column tab_name tab_description;

  define tab_name / display format= $15. left "Table" style(column) = [textdecoration=underline foreground=blue];
  define tab_description / display format= $100. left "Report Description" style(column) = [foreground=blue];

  compute tab_name;
    urlstring = "#'" || strip(tab_name) || "'!A1";
    call define (_col_, 'url', urlstring);
  endcomp;
run;

proc format;
  value profcolr
    low - 0 = "red"
    0.01 - 2000 = "lightblue"
    2000.01 - 4000 = "violet"
    4000.01 - 5000 = "lightgreen"
    5000.01 - high = "darkgreen";
run;

ods excel options(sheet_name ='Report1a' absolute_column_width='12,15,45,20,20,20,20' row_heights='30,16,20,20,20' sheet_interval="Table" tab_color='green');
title1 j=left bold italic underlin=1 color=bib link="#'TOC'!A2" '(Click to return to the table of contents)';
title2 j=left "List of Cars By Make, Type and Model (with profit pre-computed) ";


proc report data=sashelp.cars split="*" &header_col_style;
  column make type model invoice msrp profit profit_pct p2;

  define make/order "Make" style(header)=[just=left] style(column) = [font_weight=bold];
  define type /order "Type" style(header)=[just=left] style(column) = [font_weight=bold];
  define model/order "Model" style(header)=[just=left];
  define msrp/format=dollar12. "MSRP" center;
  define invoice/format=dollar12. "Invoice*Price" center;
  define profit /computed "Profit" format=dollar12. center style=[background=profcolr.];  /* traffic light format */
  define profit_pct /computed "Percentage*Profit" format=percent8.2 center;
  define p2 /computed "Profit Using Excel" style={tagattr='formula:RC[-1]-RC[-2]'};

  compute profit;
    profit = msrp.sum-invoice.sum;
  endcomp;

  compute profit_pct;
    profit_pct = profit/invoice.sum;
  endcomp;

  compute p2;
    p2 = 0;
  endcomp;

  compute after make/style=[background=lightgrey];
    line ' ';
  endcomp;
run;


ods excel options(sheet_name ='Report2' sheet_interval='None' absolute_column_width='15,20,20,20,20,20,20' row_heights='30,16,20,20,20' tab_color='lightblue');
proc report data=sashelp.cars split="*" &header_col_style;
  column type make origin MPG_City MPG_Highway msrp Invoice;

  define type /group "Type" style(header)=[just=left] style(column) = [font_weight=bold];
  define make/order "Make" style(header)=[just=left];
  define origin/order "Origin" style(header)=[just=left];
  define MPG_City/analysis mean format=8.2 "MPG City*Mean" center;
  define MPG_Highway/analysis mean format=8.2 "MPG Highway*Mean" center;
  define msrp/ analysis mean format=dollar12. center "MSRP*Mean";
  define invoice/ analysis mean format=dollar12. center "Invoice Price*Mean";

  break after type/summarize;

  compute after type;
    make = "Mean:";
    if type = "Hybrid" then
      call define (_row_, 'style', 'style=[background=lightgreen]');
    else if type in ('SUV','Truck') then
      call define (_row_, 'style', 'style=[background=lightred]');
    else
      call define (_row_, 'style', 'style=[background=yellow]');
  endcomp;

  compute after/style= [bordertopstyle=solid bordertopwidth=0.1pt bordertopcolor=black];
    line ' ';
  endcomp;
run;

 /* Same worksheet */
proc report data=sashelp.cars split="*" &header_col_style;
  column type MPG_City MPG_Highway msrp Invoice;

  define type /group "Type" style(header)=[just=left] style(column) = [font_weight=bold];
  define MPG_City /analysis mean format=8.2 "MPG City*Mean" center;
  define MPG_Highway /analysis mean format=8.2 "MPG Highway*Mean" center;
  define msrp /mean format=dollar12. center "MSRP*Mean";
  define invoice/ mean format=dollar12. center "Invoice Price*Mean";

  compute after/style= [bordertopstyle=solid bordertopwidth=0.1pt bordertopcolor=black];
    line ' ';
  endcomp;
run;


ods excel options (sheet_name ='Report3' sheet_interval="Proc" absolute_column_width='16' row_heights='65,16,20,20,20' tab_color='lightpurple' frozen_rowheaders = '1');
title;
title1 j=left bold italic underlin=1 color=bib link="#'TOC'!A2" '(Click to return to the table of contents)';
title2 j=left bold height=11pt "Report3: Average MSRP and Invoice Price By Type and across Make (Origin: #Byval(Origin)) ";

proc sort data=sashelp.cars out=cars;
  by origin;
run;
options nobyline missing=" ";
proc report data=cars split="*" &header_col_style;
  by origin;  /* BY generates three tables, one for each origin value */
  column type make, (msrp invoice);
  define type/group "Type" style(header)=[just=l] style(column) = [font_weight=bold];
  define make/across "";
  define msrp/ mean analysis format=dollar12. center "Average*MSRP";
  define invoice/ mean analysis format=dollar12. center "Average*Invoice*Price";

  compute after/style= [bordertopstyle=solid bordertopwidth=0.1pt bordertopcolor=black];
    line ' ';
  endcomp;
run;
title;
options byline;
ods excel close;
