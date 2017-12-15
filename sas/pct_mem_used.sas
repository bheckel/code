%macro pct_mem_used(gopt=);
  data null;
    memsizechar=getoption("&gopt");
/***    put memsizechar;***/

    memsizenum = input(getoption("&gopt"), 20.);
/***    put memsizenum comma15.;***/

    memsize_kb = floor(memsizenum/1024);
/***    put memsize_kb comma15.;***/

    memsize_mb = floor(memsize_kb/1024);
/***    put memsize_mb comma15.;***/

    memsize_gb = floor(memsize_mb/1024);
/***    put memsize_gb comma15.;***/

    mb = memsize_mb || 'M';
    put mb;
  run;
%mend;
data t;
set
sashelp.shoes
sashelp.shoes
sashelp.shoes
sashelp.shoes
sashelp.shoes
sashelp.shoes
sashelp.shoes
sashelp.shoes
sashelp.shoes
sashelp.shoes
sashelp.shoes
;
run;
%pct_mem_used(gopt=memsize);
sasfile work.t open;
%pct_mem_used(gopt=xmrlmem);
