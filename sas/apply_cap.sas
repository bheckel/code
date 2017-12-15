
  /* Apply caps */
  proc sort data=output_add; by storeid; run;

  data output_add_med output_add_hi;
    set output_add;
    if priority eq 0 then output output_add_med;
    else if priority eq 30 then output output_add_hi;
    else put 'ERROR: unknown priority: ' priority=;
  run;

  data output_add_med;
    set output_add_med;
    by storeid;

    if first.storeid then do;
      seq=1;
      output;
    end;
    else do;
      seq+1;
      if seq<=10 then output;
    end;

    drop seq;
  run;
