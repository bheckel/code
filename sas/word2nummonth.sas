%macro Word2NumMonth(m);
  %global mondigit;

  %if %upcase(&m) eq JAN or %upcase(&m eq JANUARY) %then
    %let m = 01;
  /* TODO finish */
  %else %if %upcase(&m) eq OCT or %upcase(&m eq OCTOBER) %then
    %let m = 10;
  %else
    %put !!! ERROR: unknown month name;

  %let mondigit = &m;
%mend Word2NumMonth;


