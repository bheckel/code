
%let DPSVR = \\rtpsawnv0312;
/* DEBUG */
***%let DIRROOT = c:\cygwin\home\bheckel\projects\datapost\tmp\VALTREX_Caplets;
%let DIRROOT = &DPSVR\pucc\VALTREX_Caplets;
%let INDIVS = &DIRROOT\OUTPUT_COMPILED_DATA;
%let OUTP = &DIRROOT\Other;


/*DM 'clear log'; DM 'clear output'; options ls=155 ps=90;*/
options symbolgen mlogic mprint;
libname OUTDIR "&INDIVS";

data release_individuals(drop=sixmonthsago);
  set OUTDIR.valtrex_analytical_individuals;
  sixmonthsago = "&SYSDATE"d - 180;
  if study eq 'Release' and test_date gt sixmonthsago;
run;


/* TODO loop foreach */
 /* Separate data by Test */
data HPLC_Assay Disso_Percent_Rel LOD_Percent;
  /* Full Disso_Percent_Released varname makes a dataset name >32 char */
  length HPLC_Assay Disso_Percent_Rel LOD_Percent 8.;
  set release_individuals;

  if test eq 'HPLC_Assay' and result ne 'Conforms' then do;
    numres = result; 
    HPLC_Assay = numres;
    keep test_date mfg_batch material strength status HPLC_Assay;
    output HPLC_Assay;
  end;
  else if test='Disso_Percent_Released' then do;
    numres = result;
    Disso_Percent_Rel = numres;
    keep test_date mfg_batch material strength Disso_Percent_Rel;
    output Disso_Percent_Rel;
  end;
  else if test='LOD_Percent' then do;
    numres = result;
    LOD_Percent = numres;
    keep test_date mfg_batch material strength LOD_Percent;
    output LOD_Percent;
  end;
run;


%macro plotter(varname, strength, minSpec, maxSpec, minChart, maxChart, increment, outFileName, title);
  data individ&varname;
    set &varname;
    if strength eq "&strength";
  run;

  /* Mean by mfg_batch and date */
  proc sort data=individ&varname;
    by mfg_batch test_date;
  run;
  proc means data=individ&varname noprint;
    by mfg_batch test_date;
    var &varname;
    output out=means&varname(drop= _TYPE_ _FREQ_) mean=avg&varname /*min=min&varname max=max&varname*/;
  run;

  /* Combine means with individual values */
  data meanMerge&varname;
    merge individ&varname means&varname;
    by mfg_batch test_date;
  run;

  /* Add batch counter by date */
  proc sort data=meanMerge&varname.;
    by test_date mfg_batch;
  run;
  data plot&varname;
    retain BATCHOBS 0; 
    format BATCHN $10.; 
    set meanMerge&varname.;

    by test_date mfg_batch;

    if first.mfg_batch then batchobs+1; 

    /* Make the batch counter (batchobs) into sortable by alphanumeric: '1' = '01' */
    if batchobs <10 then batchN="0"||left(trim(substr(left(batchobs),1)))||"0";
    else if batchobs>99 then batchN="99"||left(trim(substr(left(batchobs),1)));
    else batchN=left(trim(substr(left(BATCHOBS),1)))||"0";

    keep batchn test_date mfg_batch test_date &varname avg&varname strength;
  run;

  /* Create format for sorting by test_date instead of mfg_batch */
  data formatdata;
    length START $10.
           LABEL $20.
           FMTNAME $15.
           ;
    set plot&varname;

    retain FMTNAME;
    FMTNAME = '$batch';

    if _N_ eq 1 then do;	
      HLO = 'O'; LABEL = ''; START = ' '; OUTPUT; HLO = ' '; 
    end;
    START = batchN;
    LABEL = mfg_batch;
    keep START LABEL HLO FMTNAME;
    output;
  run;

  proc sort NODUPKEY data=formatdata;
    by FMTNAME START HLO;
  run;

  proc format CNTLIN=formatdata; run;
/***  proc format library=work FMTLIB; run;***/


  %let stren = %scan(&strength, 1);
  goptions reset=goptions dev=cgmmw6c rotate=landscape hsize=0 vsize=0 gsfname=gsf2 gsfmode=replace;
  filename gsf2 "&OUTP\plots\test_date\&outFileName.&stren..cgm";
    
  symbol1 interpol=hilob color=blue bwidth=1;
  symbol2 interpol=none value=dot color=green;

  axis1 label=none;
  axis2 offset=(0,0) minor=none label=(a=-90 r=90) order=(&minChart to &maxChart by &increment);


  title "Valtrex Caplets &strength.: &title";
  title2 'Release batches 6 months old and newer';
  title3;
  footnote;
  footnote2 "Green dot indicates average.  Plot created on &SYSDATE";

  proc gplot data=plot&varname;
    plot &varname.*batchn avg&varname.*batchn avg&varname.*batchn / overlay haxis=axis1 vaxis=axis2 vref=&minSpec &maxSpec lvref=2;
    format batchn $batch.;
  run;
%mend plotter;



 /* %macro plotter(varname, strength, minSpec, maxSpec, minChart, maxChart, increment, outFileName, title); */
%plotter(HPLC_Assay, 500 mg, 90, 110, 85, 115, 1, HPLC_Assay_, Assay);
%plotter(Disso_Percent_Rel, 500 mg, 80, 0, 70, 110, 1, Disso_Percent_Release_, Dissolution Percent Released);
%plotter(LOD_Percent, 500 mg, 0, 4.5, 0, 6, 0.5, LOD_Percent_, Loss on Drying Percent);

%plotter(HPLC_Assay, 1000 mg, 90, 110, 85, 115, 1, HPLC_Assay_, Assay);
%plotter(Disso_Percent_Rel, 1000 mg, 80, 0, 70, 110, 1, Disso_Percent_Release_, Dissolution Percent Released);
%plotter(LOD_Percent, 1000 mg, 0, 4.5, 0, 6, 0.5, LOD_Percent_, Loss on Drying Percent);


%put _all_;
