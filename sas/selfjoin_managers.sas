data t;
  input Name $ ID ManagerID;
  cards;
Bindependent 123 456
A_ceo 456  .
Cmiddlemgr 222 456
Dworkr1 777 222
Dworkr2 383 222
  ;
run;

proc sql;
  create table hierarchy as
  select a.*, b.Name as Manager
  from t as a left join t as b
  on a.ManagerID = b.ID
  order by Name
  ;
quit;

title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;
