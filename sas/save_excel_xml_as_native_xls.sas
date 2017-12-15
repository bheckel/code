
ods tagsets.excelxp file="c:\temp\temp.xml";
  proc print data=sashelp.class; run;
ods tagsets.excelxp close;

options noxwait noxsync;
filename cmds dde 'excel|system';
data _null_;
  file cmds;
  X=SLEEP(10);
  put "[open(""C:\temp\temp.xml"")]";
  put '[ERROR("FALSE")]';
  put "[SAVE.AS(""C:\temp\temp.xls"",1)]";
  X=SLEEP(2);
  put '[close("false")]';
run;

