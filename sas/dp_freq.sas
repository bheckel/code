
%macro val;
  libname s '\\Rtpdsntp032\DataPostArchive\Valtrex_Caplets\OUTPUT_COMPILED_DATA';

  proc freq data=s.valtrex_analytical_summary;
    table mfg_batch study;
  run;

  proc freq data=s.valtrex_analytical_individuals;
    table mfg_batch study;
  run;
%mend;

%macro ven;
  libname s '\\Rtpdsntp032\DataPostArchive\Ventolin_HFA\OUTPUT_COMPILED_DATA';

  proc freq data=s.venhfa_analytical_summary;
    table mfg_batch studyID;
  run;

  proc freq data=s.venhfa_analytical_individuals;
    table mfg_batch studyID;
  run;
%mend;

***%val;
%ven;
