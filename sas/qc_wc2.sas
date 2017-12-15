%macro qc_wc2(dsin=, varin=, fmtin=, lblin=);
  proc sql;
    select min(&varin) format=&fmtin.. label="Min &lblin",
           int(mean(&varin)) format=&fmtin.. label="Mean &lblin",
           max(&varin) format=&fmtin.. label="Max &lblin" from &dsin;
    quit;
%mend;
