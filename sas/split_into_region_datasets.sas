options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: split_into_region_datasets.sas
  *
  *  Summary: From a single dataset create one for each unique batch.
  *
  *           See also DataPost code splitFreeWeighBatches.sas which
  *           splits an unknown-at-runtime number of batches into 
  *           separate datasets.
  *
  *  Created: Tue 13 May 2008 13:57:44 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%macro ParseRegionToRegionDataset;
  %local c n i j;

  proc sql NOPRINT;
    select count(distinct region) into :c
    from sashelp.shoes
    /* Be sure the regions do not have weird characters! */
    where region in ('Africa', 'Canada')
    ;
  quit;

  %let c = %sysfunc(compress(&c));

  proc sql NOPRINT;
    select distinct region into :region1 thru :region&c
    from sashelp.shoes
    where region in ('Africa', 'Canada')
    ;
  quit;
  %let n = &SQLOBS;

  proc sort data=sashelp.shoes out=t; by region; run;

  data %do i=1 %to &n; OUT&&region&i %end; ;
    set t;
    %do j=1 %to &n;
      if region eq "&&region&j" then output OUT&&region&j;
    %end;
  run;
  %put _all_;
%mend; 
%ParseRegionToRegionDataset
