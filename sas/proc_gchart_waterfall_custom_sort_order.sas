/*
                            Obs    obs    description                                              npats

                              1      1    Original Pull                                             3000
                              2      2    Remove Patients From Non-Pilot Stores                     2990
                              3      3    Remove Patients Under 18 Years Old                        2980
                              4      4    Remove Patients With Invalid Gender                       2970
                              5      5    Remove Patients With Invalid State                        2960
                              6      6    Remove Patients with Less than 3 Eligible Medications     1533
                              7      7    Remove Patients with None Overlapped Medications          1532
                              8      8    Remove Patient with No AtebpatientID                      1532
                              9      9    Remove TMM Enrolled, Opt Out or Unenrolled Patients        843
                             10     10    After Applying the Cap                                     801
*/

%macro waterfall_report;
  /* EDIT */
  %let data=/sasdata/TMMEligibility/Rexall/Imports/20170609;
  %let rpt=/sasreports/TMMEligImports/201706/Rexall/20170609;
  libname l "&data/Data";
  /* title "&SYSDSN";proc print data=l.wtf width=minimum heading=H;run;title; */

  data totals0;
    /* set l.wtf(keep=description npats); */
    set l.wtfx(keep=description npats);
  run;

  data totals0;
    set totals0;

    barorder = _n_;

    if _n_ eq 1 then do;
      call symput('MAX', npats+npats*0.10);
      /*TODO*/
      /* call symput('INCREMENT', round(npats*0.1,100)); */
      call symput('INCREMENT', 50000);
    end;
  run;
  %put _user_;

  data totals0;
    set totals0 end=e;
    put description=;
    /* description= prxchange("s/Remove( Patients)?( (From)?|(Under)?|(With)?) //i", -1, description); */
    /* description= prxchange("s/Remove( Patients)?|( prescriptions)? ( (From)?|(Under)?|(With)?) //i", -1, description); */
    description=strip(prxchange("s/Remove (Patients?)?|(prescriptions)?(with)?//i", -1, description));
    put 'aft' description=;
    output;
    if e then do;
      description='Total Targeted';
      barorder=barorder+1;
      output;
    end;
  run;
/* data totals0;set totals0; if _n_ > 4 then delete; */
  proc print data=totals0 width=minimum heading=H;run;title;

  data totals;
    set totals0;

    type = 'R';  /* whole bar length (blue) */
    prev = lag(npats);
    output;
    type = 'P';  /* partial bar length (invisible) */
    output;
  run;

  data totals;
    set totals;
    if prev eq . then prev = npats;
    diff = prev - npats;
    if type eq 'R' then P0 = npats+diff;
    else if type eq 'P' then P0 = prev-diff;
  run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;  
 
  proc sort data=totals; by description; run;
  proc transpose data=totals(keep=description type P0) out=totals;
    by description;
    id type;
  run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;  

  data totals;
    set totals;
    if missing(P) then p = 0;
    rr = r - p;
  run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;  

  data totals(rename=(rr=R));
    set totals(drop=r _name_);
  run;
  proc transpose data=totals out=totals(rename=(_NAME_=type COL1=npats));
    by description;
  run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;  

  /* Invert colors of first & last bars for cosmetic reasons (match business requirement sample) */
  data totals(drop=tmp:);
    set totals;

    retain tmp1;
    if description eq 'Original Pull' and type eq 'P' then do;
      tmp1 = npats;
      npats=0;
    end;
    else if description eq 'Original Pull' and type eq 'R' then do;
      npats = tmp1;
    end;

    retain tmp2;
    if description eq 'Total Targeted' and type eq 'P' then do;
      tmp2 = npats;
      npats=0;
    end;
    else if description eq 'Total Targeted' and type eq 'R' then do;
      npats = tmp2;
    end;
  run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;  

  proc sql;
    create table totals as
    select a.*, b.barorder
    from totals a join totals0 b on a.description=b.description
    ;
  quit;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;

  proc sql;
    create table fmt as
    select unique barorder as START, description as LABEL
    from totals
    ;
  quit;
  data control;
    set fmt;
    fmtname = 'barfmt';
    type = 'N';
    end = START;
  run;
  proc format lib=work cntlin=control; run;


  goptions ypixels=750 xpixels=850 ftext='Albany AMT' htext=0.80;

  title h=12pt 'Rexall Targeted Patient Waterfall';
  /* EDIT */
  title2 h=10pt 'Build Date 20170609';

  axis1 label=none
        split=' '
        value=(h=6pt)
        ;
  axis2 label=(a=90 '# of Patients')
        order=(0 to &MAX by &INCREMENT)
        value=(h=8pt)
        ;

  legend1 label=none cborder=none value=none;

  /* pattern1 c=gray; */
  pattern1 c=white;
  /* Rexall teal */
  pattern2 c=cx1DB1A8;

  options orientation=landscape leftmargin=0.5cm rightmargin=0.5cm bottommargin=0.5cm;
  /* EDIT */
  /* ods pdf file="&rpt/TMM-Rexall(clientid=1000000)-Waterfall-20170609.pdf" style=HtmlBlue NOTOC; */
  ods pdf file="~/bob/TMM-Rexall(clientid=1000000)-Waterfall-20170609.pdf" style=HtmlBlue NOTOC;
  /* ods excel file="~/bob/TMM-Rexall(clientid=1000000)-Waterfall-20170609.xlsx" style=HtmlBlue; */

    /* Generate vertical bar chart */
    proc gchart data=totals;
      format barorder barfmt.
             npats comma.
             ;

       /* vbar description / sumvar=npats */
       vbar barorder / 
            sumvar=npats
            discrete
            subgroup=type
            outside=sum
            /* width=6 */
            space=1
            maxis=axis1
            raxis=axis2
            coutline=white
            /* anno=anno */
            nolegend
            noframe
            ;
    run;
    
    data display;
      /* set l.wtf; */
      set l.wtfx;
      label obs='Restriction'
            description='Description'
            npats='Number of Patients'
            ;
    run;

    proc print data=display NOobs label; run;

  ods pdf close;
  /* ods excel close; */
%mend;
%waterfall_report;
