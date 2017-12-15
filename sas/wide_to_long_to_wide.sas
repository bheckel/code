 /* wide to long aka "gathering" */

/* Wide

    Obs    rptrequirements    feb2016    mar2016    apr2016

     1      ATORVASTATIN       25729      27810      6856  
     2      CLOPIDOGREL        11884      12842      3246  
     3      Escitalopram        8706       9369      2210  
     4      METOPROLOL         12966      14053      3323  
     5      QUETIAPINE          4281       4627      1232  
     6      SINGULAIR          12736      14563      3539  
*/
title "&SYSDSN";proc print data=l.t(obs=10) width=minimum heading=H;run;title;

/* Long
  Obs    rptrequirements    i     moyr      num    value

    1     ATORVASTATIN      1    feb2016     1     25729
    2     ATORVASTATIN      2    mar2016     2     27810
    3     ATORVASTATIN      3    apr2016     3      6856
    4     CLOPIDOGREL       1    feb2016     1     11884
    5     CLOPIDOGREL       2    mar2016     2     12842
    6     CLOPIDOGREL       3    apr2016     3      3246
    7     Escitalopram      1    feb2016     1      8706
    8     Escitalopram      2    mar2016     2      9369
    9     Escitalopram      3    apr2016     3      2210
   10     METOPROLOL        1    feb2016     1     12966
 */
data t(drop= Feb2016 Mar2016 Apr2016);
  set l.t;
  array arr Feb2016 Mar2016 Apr2016;
  do i=1 to dim(arr);
    moyr=vlabel(arr(i));
    num=i;
    value=arr(i);
    if not missing(value) then output;
  end;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

proc sort; by rptrequirements moyr; run;
data tx(drop=moyr value i num j);
  set t;
  by rptrequirements moyr;
  retain Feb2016 Mar2016 Apr2016;
  array arr Feb2016 Mar2016 Apr2016;
  if first.moyr then do;
    do i=1 to dim(arr);
      arr(i)=.;
    end;
  end;

  do j=1 to dim(arr);
    if num=j then do;
      arr(j)=value;
    end;
  end;

  if last.moyr;
run;
data tx;
  update tx(obs=0) tx;
  by rptrequirements;
run;
/* Wide again aka "spreading" 

    Obs    rptrequirements    feb2016    mar2016    apr2016

     1      ATORVASTATIN       25729      27810      6856  
     2      CLOPIDOGREL        11884      12842      3246  
     3      Escitalopram        8706       9369      2210  
     4      METOPROLOL         12966      14053      3323  
     5      QUETIAPINE          4281       4627      1232  
     6      SINGULAIR          12736      14563      3539  
*/
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;
