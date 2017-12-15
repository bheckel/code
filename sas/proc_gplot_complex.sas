options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_gplot_complex.sas
  *
  *  Summary: Create a graph of multiple longitudinal variables in one graph
  *           to identify trends in the data otherwise masked by the
  *           complexity.
  *
  *  Adapted: Thu 10 Jul 2008 12:48:22 (Bob Heckel -- SUGI paper 2008 250-2008)
  *---------------------------------------------------------------------------
  */
options source NOcenter NObyline;

data sample; 
  ***infile datalines  LRECL=32767;  /* TODO doesn't work - is max CARDS 256 ? */
  input Cage Age BW TargetBW ADFI ADG EggWt @@; 
  agewk = age/7;
  datalines;
1 143 2068 2216 85.0 2.8 . 1 146 2132 2278 91.7 21.3 . 1 150 2234 2369 99.5 25.5 . 1 153 2335 2440 105.7 33.7 . 1 157 2426 2540 108.8 22.8 . 1 160 2495 2615 113.0 23.0 . 1 164 2581 2711 119.5 21.5 . 1
167 2672 2778 123.0 30.3 . 1 171 2787 2862 124.0 28.8 . 1 173 . . . . 50.1 1 174 2883 2921 124.0 32.0 52.3 1 176 . . . . 51.1 1 177 . . . . 53.3 1 178 2935 2997 124.0 13.0 53.1 1 179 . . . . 53.2 1 180
. . . . 52.1 1 181 2864 3052 124.7 -23.7 55.7 1 182 . . . . 54.5 1 183 . . . . 53.8 1 184 . . . . 53.5 1 185 2868 3119 128.8 1.0 53.5 1 186 . . . . 54.2 1 187 . . . . 56.1 1 188 2870 3165 133.3 0.7 54.2
1 189 . . . . 52.7 1 190 . . . . 54.5 1 191 . . . . 56.0 1 192 2918 3221 140.3 12.0 54.6 1 193 . . . . 54.1 1 194 . . . . 56.1 1 195 2951 3258 145.3 11.0 53.8 1 196 . . . . 52.4 1 198 . . . . 54.2 1 
199 3031 3302 149.3 20.0 56.6 1 200 . . . . 54.2 1 201 . . . . 55.4 1 202 3063 3331 150.7 10.7 55.1 1 203 . . . . 52.2 1 204 . . . . 54.4 1 205 . . . . 58.6 1 206 3042 3364 150.3 -5.3 57.0 1 207 . . .
. 56.8 1 208 . . . . 58.9 1 209 3079 3385 150.7 12.3 57.3 1 210 . . . . 56.9 1 211 . . . . 57.9 1 212 . . . . 58.7 1 213 3128 3400 151.0 12.3 58.9 1 214 . . . . 57.4 1 215 . . . . 57.8 1 216 3113 3408
149.7 -5.0 57.5 1 217 . . . . 57.9 1 218 . . . . 58.4 1 219 . . . . 57.5 1 220 3146 3418 149.8 8.3 58.3 1 221 . . . . 55.3 1 222 . . . . 56.9 1 223 3156 3427 148.0 3.3 56.1 1 224 . . . . 57.5
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


data ancillary;
  input cage strain $ treatment $ total_eggs breast_pct fat_pct prime_sequence average_eggwt total_eggwt;
  datalines;
1 Ross508 Standard 187 0.178 0.214 31 61.4 11.5 2 HiY Standard 158 0.173 0.241 17 52.1 9.8
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


/* Reset graphics options, set the default text height and font and direct SAS to create a collection of GIF images */ 
goptions reset=all htext=1.5 ftext="arial/bo" device=gif goutmode=append;

ODS LISTING close;
 /* Multiple graphs to one webpage */
ODS HTML path = "." body="BirdGraphs.htm";

/* Set up appropriate symbols and lines for each y-axis variable */ 
/*
                              Target                       Egg
Obs    Cage    Age     BW       BW       ADFI      ADG     Wt      agewk

  1      1     143    2068     2216      85.0      2.8      .     20.4286
  2      1     146    2132     2278      91.7     21.3      .     20.8571
 */
symbol1 v=dot  c=blue   i=none;           /* BW */
symbol2 v=none c=steel  i=join   line=1;  /* TargetBW */
symbol3 v=none c=salmon i=join   line=2;  /* ADFI */
symbol4 v=none c=red    i=join   line=3;  /* ADG */
symbol5 v=none c=green  i=needle line=1;  /* EggWt */
/* define horizontal and left and right vertical axes */ axis1 order=20 to 30 by 1 minor=none;
axis2 order=0 to 4000 by 500 label=(angle=90 "BW (g)") minor=none;
axis3 order=-50 to 175 by 25 label=(angle=90 "Weight (g)") minor=none;
/* define legends for left and right axes */ 
legend1 noframe position=(inside left) label=none value=(h=1) mode=protect offset=(5 pt,0 pt);
legend2 noframe position=(inside right) label=none value=(h=1) mode=protect offset=(-5 pt,0 pt);


%macro BuildGraph(begin, end);
  %do i=&begin %to &end;
    data _null_;
      set ancillary;
      where cage=&i;
      call symput('Strain', trim(Strain));
      call symput('Treatment', trim(Treatment));
      call symput('total', trim(put(Total_Eggs,3.0)));
      call symput('breast', put(breast_pct,percent7.1));
      call symput('pctfat', put(fat_pct,percent7.1));
      call symput('Prime', trim(put(Prime_Sequence,3.0)));
      call symput('eggwt', put(average_eggwt,4.1));
      call symput('eggmass', put(total_eggwt,4.1));
    run;
    %put _all_;

    /* Summary information is inserted into footnotes and the title */
    footnote1 j=c h=1.2 j=l "&breast. breast at 58 wk" j=r "&eggwt. g average egg wt";
    footnote2 j=left h=1.2 "&pctfat. carcass fat at 58 wk" j=c "&Prime. day prime sequence" j=right "Total: &eggmass. kg eggs";
    title1 j=l "Strain: &Strain." j=c "Cage &i" j=r "Treatment: &treatment.";

     /* Plot the five longitudinal variables simultaneously as a function of age */ 
    proc gplot data=sample;
      where cage eq &i;
/***      label Agewk = "Age (wk)" ADFI = "Feed intake (/d)" ADG = "Gain (/d)" Eggwt = "Egg wt" TargetBW = "Target BW";***/
      plot (BW TargetBW)*agewk     / overlay noframe haxis=axis1 vaxis=axis2 legend=legend1;
      plot2 (ADFI ADG EggWt)*agewk / overlay vaxis=axis3 legend=legend2 cvref=lig vref=52;
    run;
  %end;
%mend BuildGraph;

 /*         1 to N cages */
%BuildGraph(1, 1);
***%BuildGraph(1, 42);

ODS HTML close;
ODS LISTING;
