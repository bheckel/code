
 /* Insert something into the middle of a string */
data _null_;
  x='Tracheo-esophageal Fistula/Esophageal Atresia';
  l=length(x);
  if l gt 38 then
    do;
      x=trim(substr(x,1,2))||'XXX'||trim(substr(x,3));
      put x=;
    end;
run;
