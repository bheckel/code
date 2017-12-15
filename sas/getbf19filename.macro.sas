%macro GetBF19FileName(e, s, y);
  %global FN;

  proc sql NOPRINT;
    select mergefile into :FN
    from "/u/dwj2/register/&e/&y/register"
    where stabbrev eq "&s"
    ;
  quit;
%mend GetBF19FileName;
%GetBF19FileName(&EVT, &STABBR, &YEAR)
