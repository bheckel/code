
%macro m;
  proc sql NOprint;
    select left(put(count(distinct region),8.)) into :nreg
    from sashelp.shoes
    where region like 'A%'
    ;
  quit;

  proc sql NOprint;
/***    select distinct cats("'", left(trim(region)), "'") into :reg1 - :reg&nreg***/
/***    select distinct quote(region, "'") into :reg1 - :reg&nreg***/
/***    select distinct quote(left(trim(region)), "'") into :reg1 - :reg&nreg***/
    select distinct quote(cats(region), "'") into :reg1 - :reg&nreg
    from sashelp.shoes
    ;
  quit;

  %macro reglist;
&reg1
    %do j=2 %to &nreg;
,&&reg&j
    %end;
  %mend;

  %put _user_;

  proc sql;
    select * from sashelp.shoes where region in ( %reglist );
  quit;

  %put %reglist;
%mend; %m;
