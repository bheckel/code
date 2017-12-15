
goptions reset=all ftext=swissl device=png cback=white border htitle=12pt
         ctext=gray gsfname=outpng gsfmode=replace
         ;

%macro m(var);
  filename outpng "&var..png";

  title1 h=1.1 'Zebulon DataPost IP21 MDI Line8 Filler';
  title2 h=0.75 "&var";

  proc sql;
    select min(&var) as min, floor((min(&var)*0.90)) as minref,
           max(&var) as max, ceil((max(&var)*1.10)) as maxref,
           ceil(std(&var)) as std
           into :MIN, :MINREF, :MAX, :MAXREF, :STD
    from l.ip21_0002t_line8filler
    ;
  quit;

  symbol i=join v=dot c=vibg h=0.1;

   /* Y */
  axis1 order=(&minref to &maxref by &std) minor=none 
        reflabel=(j=c h=9pt '' '') label=NONE/*(height=0.65)*/ value=(height=0.75);
   /* X */
  axis2 label=(height=0.65 '') value=(height=0.75) ;

   /* Produce the graph */
  proc gplot data=l.ip21_0002t_line8filler(keep= TS &var);
    format ts DATETIME7.;
  /***  where ts lt '12NOV2010:00:00:00'dt;***/
    plot &var*ts / vaxis=axis1 haxis=axis2 /*vref=&MIN &MAX*/ lvref=(3 3 2 2) NOLEGEND;
  run;
%mend;
%m(_23034794_FILL_RM_HUM_PV);
%m(_23034794_RECIR_PRES_PV);
%m(_23034794_GROSS_WEIGHT_PV);
%m(_23034794_MIX_RM_TEMP_PV);
