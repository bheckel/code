 /* Must break id num list into blocks to avoid overflowing SAS macro max
  * string length. 
  * 
  * loop_large_database_criteria_list.sas may be better
  */
data finalRetainList;
  retain list cnt loop;
  /* At least 500 x avg length of digits */
  format list: $9500.;
  set finalRetainList end=e;

  /* Break IN statement every 501 id nums */
  if _N_ eq 1 or cnt eq 501 then 
    do;
      cnt=0;
      loop+1;
    end;

  cnt+1;

  if cnt eq 1 then 
    do;
      list = trim(fnsh_prod_id_nbr);
    end;
  else if fnsh_prod_id_nbr ne . then 
    do;
      list = trim(left(list))||','||trim(left(fnsh_prod_id_nbr));
    end;

  if cnt=501 or e then 
    do;
      /* Build string for Oracle e.g. 'FNSH_PROD_ID_NBR IN (52499,52951...' */
      call symput('IDLIST'||compress(put(loop,5.)), 'FNSH_PROD_ID_NBR IN ('||trim(left(list))||')');
      call symput('NUMLOOPS', loop);
    end;
run;

proc sql;
  CONNECT TO ORACLE(USER=&oraid ORAPW=&orapw PATH=&orapath);
    EXECUTE (
      update retain.fnsh_prod 
      set prod_sel = 'Y', prod_sel_dt = TO_DATE(&ORANOW, 'DDMONYY:HH24:MI:SS')
      /* E.g. WHERE FNSH_PROD_ID_NBR IN (52499,52951...) OR FNSH_PROD_ID_NBR IN (9999,... */
      where &IDLIST1 %macro x; %DO Loop=2 %TO &NumLoops; OR &&IDLIST&Loop %END; %mend; %x
  ) BY ORACLE;
  DISCONNECT FROM ORACLE;
quit;
