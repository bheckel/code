 /* Editable via vim ~/bob/temp.xls */
 /* ods_excel.sas may be a better option */
ods html file='~/bob/temp.xls';
proc report data=sashelp.class(obs=5) nowd
  style(report)={rules=none}
  style(column)={background=white htmlstyle='border:none'}
  style(header)={htmlstyle="mso-rotate:45; height:50pt; border:none" background=_undef_};

  col name age sex height weight;

  compute after;
    name="Total";
  endcomp;

  rbreak after / summarize style={font_weight=bold htmlstyle="border-bottom:5px double red; border-left:none; border-right:none; border-top:5px dashed red"};
run;
ods html close;
