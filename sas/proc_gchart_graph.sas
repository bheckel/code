options NOsource NOxwait;
 /*---------------------------------------------------------------------------
  *     Name: proc_gchart.sas
  *
  *  Summary: Demo of limiting small values and proc gchart.
  *
  *  Created: Fri 31 Oct 2003 15:08:50 (Bob Heckel --
  *       http://homepage.ntlworld.com/philipmason/Tips%20Newsletter/60.htm)
  *---------------------------------------------------------------------------
  */
options source;

* Limit ... values less that this percentage are combined;
* class1 ... 1st classification variable;
* class2 ... 2nd classification variable;
* anal ... analysis variable;
* more ... value to use for values that are combined;
%macro limit(limit=0.01, class1=a, class2=b, anal=x, more=., in=in, out=out);
  proc sql;
    create table &out as
      select &class1, &class2, sum(&anal) as &anal
      from (select &class1, case when(&anal/sum(&anal)<&limit) then 
                              &more
                            else &class2
                   end as &class2,
              &anal
            from &in
            group by &class1
           )
      group by &class1, &class2;
  quit;
%mend limit;
 
 /* Create test data. */
data in;
  do a=1 to 10;
    do b=1 to 100;
      x=ranuni(1)*100;
      output;
    end;
  end;
run;
 
filename graph 'junk.png';
goptions device=png gsfname=graph;
proc gchart data=in;
  vbar a / subgroup=b sumvar=x discrete;
run;
 
 /*  Use limit macro to avoid large confusing legends and imperceptibly tiny
  *  bar segments. 
  */
%limit(limit=0.02);
 
filename graph 'junk2.png';
proc gchart data=out;
  vbar a / subgroup=b sumvar=x discrete;
run; 

data _NULL_;
  x 'start /B junk.png';
  x 'start /B junk2.png';
run;
