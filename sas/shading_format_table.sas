options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: shading_format_table.sas
  *
  *  Summary: Use shading gradient based on data.
  *
  *  Adapted: Mon 28 Jan 2008 12:43:58 (Bob Heckel - Phil Mason email)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%macro shade_tab_fmt(dset,var,fmtname);
  proc sql noprint;
    select min(&var), max(&var), range(&var) into :shade_min,
                                                  :shade_max,
                                                  :shade_range 
    from &dset
    ;
  quit;
  %put _all_;

  %* set each component of the color to produce a smooth range of colors when;
  %* mixed as RGB components;
  %let red=put(i/&shade_max*255,hex2.);
  %let green=put((&shade_max-i)/&shade_max*255,hex2.);
  %let blue=put(i/&shade_max*255,hex2.);

  * build a format, SHADE., to shade cells from one color to another;
  data _null_;
    call execute("proc format; value &fmtname");
    max=1;
    steps=64; * number of steps in color gradation;
    step=&shade_range/steps;

    do i=&shade_min to &shade_max by step;
      put i=;
      color='cx'||&red||&green||&blue;
      from=i-step/2;*((i-1)/&shade_max)*max;
      to=i+step/2; *(i/&shade_max)*max;
      call execute(put(from,best.)||'-'||put(to,best.)||'='||quote(color));
    end;

    call execute('.="gray" other="cxd0d0d0"; run;');
  run;
%mend shade_tab_fmt;
 
ods _all_ close; ods html file='c:\temp\percent_shade.html';
%shade_tab_fmt(sashelp.retail,sales,shade);
proc tabulate data=sashelp.retail style={background=SHADE.};
  class year month;
  var sales;
  table sales*sum,year,month;
run;
ods _all_ close; ods html close;
