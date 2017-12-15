options noreplace mlogic sgen;
 /* debug toggle */
***options obs=5;
libname A 'c:/cygwin/home/bheckel/projects/alldatasets';

proc sql NOPRINT;
  select memname into :D separated by ' '
  from dictionary.members
  /* Limit to sumres datasets */
  where libname like 'A' and memname like 'SUM%'
  ;
quit;

%macro SetStmt(s);
  %local i f;

  %let i=1;

  %do %until (%qscan(&s, &i)=  );
    %let f=%qscan(&s, &i); 
    /*......................................................*/
    A.&f(IN=in&i)
    /*......................................................*/
    %let i=%eval(&i+1);
  %end;
%mend SetStmt;

%macro IfStmt(s);
  %local i f;

  %let i=1;

  %do %until (%qscan(&s, &i)=  );
    %let f=%qscan(&s, &i); 
    /*......................................................*/
    if in&i then frds="&f"%str(;);
    /*......................................................*/
    %let i=%eval(&i+1);
  %end;
%mend IfStmt;

data v / view=v;
  length frds $50;
  set %SetStmt(&D);
  %IfStmt(&D)
run;

options NOreplace ls=180;
libname ORA oracle user=pks password=pks path=usdev100;

proc sql;
  select distinct r.samp_id, r.resstrval format=$30., m.matl_nbr format=$30., m.batch_nbr format=$30.
  from v as r, ORA.samp as s, ORA.links_material as m
      where r.samp_id=s.samp_id and 
            s.matl_nbr=m.matl_nbr and s.batch_nbr=m.batch_nbr and
	    r.specname = 'ITEMCODE' and r.varname='PRODCODEDESC$' and
	    r.samp_id in(177987)
      ;
quit;
