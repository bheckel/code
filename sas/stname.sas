
%macro GetFullStatename(s);
  %global statname;

  %if &s eq YC %then
    %let statname=NEW YORK CITY;
  %else
    %let statname = %sysfunc(stname(&s));
%mend GetFullStatename;
%GetFullStatename(WA);
%put &statname;
