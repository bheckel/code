SELECT r.sampid
FROM Result R, Var V 
WHERE ( UPPER(R.ResStrVal)='SEREVENT DISKUS 50 MCG 60D EVAL/STRP'
        OR UPPER(R.ResStrVal)='SEREVENT DISKUS 50 MCG 60CT EVAL'
        OR UPPER(R.ResStrVal)='SEREVENT DISKUS 50MCG 60 DOSE'
        OR UPPER(R.ResStrVal)='SEREVENT INHALERS, 21 MCG - 60 ACT'
        or UPPER(R.ResStrVal)='SEREVENT'
      )
      AND R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODCODEDESC$' 
      and r.sampname like '9Z%'
      ;
quit;
