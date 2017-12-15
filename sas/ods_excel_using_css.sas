
ods excel file="~/bob/t.xlsx"
          options(embedded_titles="yes" sheet_name="CSS class selectors" start_at="B2")
          cssstyle="~/code/sas/ods_using_css0.css"
          /* DOM option prints ODS DOM html to Log so you can determine which CSS tags to use .css e.g. .systemtitle */
          DOM
          ;

  title 'Profit Summary for Company ABC';
  proc print data=sashelp.orsales(obs=3) noobs;
    format profit dollar.;
    var Year Product_group quantity Profit;
    sum quantity profit;
  run;

ods excel close; 


 /* Advanced CSS selectors */
ods excel file="~/bob/t2.xlsx" 
          cssstyle="./ods_excel_using_css.css" 
          options(sheet_interval="none")
          DOM
          ;

  proc print data=sashelp.class(obs=5); run;
  proc print data=sashelp.class(obs=5) NOobs; sum height; run;

ods excel close;
