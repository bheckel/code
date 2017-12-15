 /* VALTREX 500MG CAPLETS (Fielder-CANADA) */
t1 = index(Product, '(');
t2 = index(Product, ')');
t3 = t2-t1;
if t1+t2 gt 0 then do;
  granulator = substr(Product, t1+1, t3-1);
  /* Don't want  Fielder-CANADA */
  granulator = scan(granulator, 1, '-');
end;
