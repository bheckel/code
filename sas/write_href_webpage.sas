data t;
  set sashelp.shoes;
  rglnk = "<a href='http://example.com'>" || left(trim(region)) || "</a>";
run;

ods HTML body="t.html" style=Brick;
title "Consolidated Trends";
proc print data=t(obs=5); run;
ods HTML close;
