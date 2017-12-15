proc sql noprint;
  create table dict(keep=type) as
  select *
  from DICTIONARY.columns
  where libname eq 'WORK' 
        and memtype eq 'DATA' 
        and memname eq 'DATAPOST_DATASET'  /* upcased ds name */
        and name eq 'result'  /* normally a number, sometimes 42,666 */
  ;
quit;
data _NULL_; set dict(obs=10); put '!!!dbg'(_all_)(=);run;

data DataPost_Dataset; set DataPost_Dataset; dummy=1; run;
data dict; set dict; dummy=1; run;

data DataPost_Dataset(drop=dummy);
  merge DataPost_Dataset dict;
  by dummy;
run;

data DataPost_Dataset(drop=type);
  set DataPost_Dataset(rename=(TMPresult=result));
  if type eq 'num' then do;
    TMPresult=result;
  end;
  else do;
    TMPresult=input(result, ?? COMMA9.);
  end;
  drop result;
run;
data _NULL_; set DataPost_Dataset; put '!!!dbg'(_all_)(=);run;



 /* To go the other way, normally a character result: */

proc sql noprint;
  create table dict(keep=type) as
  select *
  from DICTIONARY.columns
  where libname eq 'WORK' and memtype eq 'DATA' and memname eq 'IND' and name eq 'result'
  ;
quit;
data _NULL_; set dict; put '!!!dbg'(_all_)(=);run;

data &sumonly_or_ind; set &sumonly_or_ind; dummy=1; run;
data dict; set dict; dummy=1; run;
data &sumonly_or_ind(drop=dummy);
  merge &sumonly_or_ind dict;
  by dummy;
run;

data &sumonly_or_ind(rename=(TMPresult=result));
  set &sumonly_or_ind;
  if type eq 'num' then do;
    TMPresult = put(result, F8.);
  end;
  else do;
    TMPresult = result;
  end;
  drop result;
run;
