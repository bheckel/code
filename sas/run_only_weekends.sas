data _NULL_;
  set xtransform;

  %let i=1;
  %do %until (%qscan(&vnms, &i)=  );
    %let f=%qscan(&vnms, &i);
      call symput("&f",left(trim(&f)));
    %let i=%eval(&i+1);
  %end;

  if weekday(today()) in(2, 3, 4, 5, 6) then
    isWeekday=1;
  else
    isWeekday=0;

  if executefrequency eq 'daily' and isWeekday then
    dateok=1;
  else if executefrequency eq 'weekly' and not isWeekday then
    dateok=1;
  else
    dateok=0;

  if transformenabled eq 1 and dateok eq 1 then do;
    s1='%'||executemacro;
    put '!!! running: ' s1=;
    call execute(s1);  /* 2010-08-06 SAS v8.2 unable to suppress incorrect SAS Log WARNING 32-169 */
  end;
  else do;
    put '!!! skipping: ' executemacro= transformenabled= dateok=;
  end;
run;
