options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: fuzzy_within_5minutes.sas
  *
  *  Summary: Approximate matching
  *
  *  Adapted: Thu 27 May 2010 16:00:15 (Bob Heckel--Combining and Modifying book)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data one;
  input time TIME5.  sample;
  format time DATETIME13.;
  time=dhms('23nov94'd,0,0,time);
  cards;
09:01   100
10:03   101
10:58   102
11:59   103
13:00   104
14:02   105
16:00   106
;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
data two;
  input time TIME5.  sample;
  format time DATETIME13.;
  time=dhms('23nov94'd,0,0,time);
  cards;
09:00   200
09:59   201
11:04   202
12:02   203
14:01   204
14:59   205
15:59   206
16:59   207
18:00   208
;
proc print data=_LAST_(obs=max) width=minimum; run;

data match1 (keep = time1 time2 sample1 sample2);
   link getone;
   link gettwo;

   format time1 time2 datetime13.;
   onedone=0;  twodone=0;

   do while (1=1);
      if abs(tempt1-tempt2) < 300 then
         do;
            time1=tempt1;
            time2=tempt2;
            sample1=temps1;
            sample2=temps2;
            output;
            link getone;
            link gettwo;
         end;


      else if (tempt1 > tempt2 and twodone=0) or onedone then
         do;
            time1=.;
            time2=tempt2;
            sample1=.;
            sample2=temps2;
            output;
            link gettwo;
         end;

      else if (tempt1 < tempt2 and onedone=0) or twodone then
         do;
            time1=tempt1;
            time2=.;
            sample1=temps1;
            sample2=.;
            output;
            link getone;
         end;

      put '!!! ' _all_;
      if onedone and twodone then stop;
   end;
   return;

getone: if last1 then
           do;
              onedone=1;
              return;
           end;
        set one (rename=(time=tempt1 sample=temps1)) end=last1;
        return;  /* sends program control to the statement immediately following the LINK statement */

gettwo: if last2 then
           do;
              twodone=1;
              return;
           end;
        set two (rename=(time=tempt2 sample=temps2)) end=last2;
        return;  /* sends program control to the statement immediately following the LINK statement */

  put 'never reached';
run;
title 'MATCH1 ds - matches within 300 seconds';
proc print data=match1; run;



title 'proc sql alternative';
proc sql;
  select *
  from one(rename=(time=time1 sample=sample1)) FULL JOIN two(rename=(time=time2 sample=sample2)) ON abs(time1-time2)<=300  /* FULL OUTER JOIN actually */
  ;
quit;
