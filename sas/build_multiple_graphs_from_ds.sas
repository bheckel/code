
/* Create a series of simple graphs */
symbol1 interpol=join value=none;
axis1 label=none value=none major=none minor=none style=0;

%macro rungraphs;
   %do yr=1980 %to 1985;
      filename gsasfile "c:\&yr..png";
      goptions device=png gsfname=gsasfile xmax=1 in ymax=1 in;

      proc gplot data=sashelp.retail;
         where year=&yr;
         plot sales*month / vaxis=axis1 haxis=axis1;
      run;
      quit;
   %end;
%mend;

%rungraphs
