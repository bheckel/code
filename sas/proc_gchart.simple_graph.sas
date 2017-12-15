
data totals;
  length dept $ 7 site $ 8;
  input dept site quarter sales;
  datalines;
Parts   Sydney  1 7043.97
Parts   Atlanta 1 8225.26
Parts   Paris   1 5543.97
Tools   Sydney  4 1775.74
Tools   Atlanta 4 3424.19
Tools   Paris   4 6914.25
  ;
run;

goptions reset=global gunit=pct border cback=white
         colors=(blue green red) ctext=black
         ftitle=swissb ftext=swiss htitle=4 htext=3
         ;

legend1 cborder=black
        label=('Quarter:')
        position=(middle left outside)
        mode=protect
        across=1;

proc gchart data=totals;
   format quarter roman.;
   format sales dollar8.;
/***   label site='00'x dept='00'x;***/

   block site / sumvar=sales
                type=mean
                midpoints='Sydney' 'Atlanta'
                group=dept
                subgroup=quarter
                legend=legend1
                noheading
                coutline=black
                caxis=black
                ;
run;
