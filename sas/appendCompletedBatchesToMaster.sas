
%macro appendCompletedBatchesToMaster(libnmIn, libnmOut);
  %local dsets i tmpds tmpfqds found;

  proc sql NOPRINT; 
    select memname into :dsets separated by ' ' 
    from dictionary.members 
    where libname like "&libnmIn"
    ; 
  quit;

  %let i = 1;
  %do %until (%qscan(&dsets, &i) =  );
    %let tmpds = %qscan(&dsets, &i); 
    %let tmpfqds = &libnmIn..%qscan(&dsets, &i); 
    %let found = 0;
    /*...........................................................*/
    proc sql NOPRINT;
      select byActivityCode into :found
      from &tmpfqds
      where byActivityCode eq '12'
      ;
    quit;

    %if &found eq 12 %then %do;
      proc append base=&libnmOut..valtrex_freeweigh_all data=&tmpfqds; run;
      proc datasets library=&libnmIn; delete &tmpds; run;
    %end;
    /*...........................................................*/
    %let i = %eval(&i+1);
  %end;
%mend;
