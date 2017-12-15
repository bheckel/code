
%macro do_over_list(list);
  %let i=1;
  %do %until (%qscan(&list, &i)=  );
    %put %qscan(&list, &i);
    %let i=%eval(&i+1);
  %end;
%mend;
%do_over_list(aa bb cc);


%macro date_loop(start,end);
  %let start=%sysfunc(inputn(&start,anydtdte9.));
  %let end=%sysfunc(inputn(&end,anydtdte9.));

  %let dif=%sysfunc(intck(month,&start,&end));

  %do i=0 %to &dif;
    %let date=%sysfunc(putn(%sysfunc(intnx(month,&start,&i,b)),date9.));
    %put &date;
  %end;
%mend;
%date_loop(01jun2008,01aug2008)
