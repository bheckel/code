
/*-------------------------------------------------------------------*/
/* Combining and Modifying SAS Data Sets: Examples                   */
/* Publication book code: 55219                                      */
/*                                                                   */
/* Each sample begins with a comment that states the example         */
/* number of the program shown. This file contains the program shown */
/* in the book as well as the DATA steps necessary to create the     */
/* input data sets used in each example.                             */
/*-------------------------------------------------------------------*/

/* Example 2.1                                                       */

options nodate nonumber ls=80;

data one;
   input id $ name $  dept $ project $;
   datalines;
000 Miguel A12 Document
111 Fred B45 Survey
222 Diana B45 Document
888 Monique A12 Document
999 Vien D03 Survey
;

data two;
   input id $ name $ projhrs;
   datalines;
111 Fred 35
222 Diana 40
777 Steve 0
888 Monique 37
999 Vien 42
;

data combine;
   length origin $ 4;
   merge one(in=in1) two(in=in2);
   by id;
   if in1 and in2 then origin='both';
   else if in1 then origin='one';
   else origin='two';
   if dept=' ' then dept='NEW';
   if project=' ' then project='NONE';
   if projhrs=. then projhrs=0;
run;

proc print data=combine;
   title 'COMBINE';
run;

/* Example 2.2                                                       */

options nodate nonumber ls=80;

data one;
     input time time5.  sample;
     format time datetime13.;
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
data two;
     input time time5.  sample;
     format time datetime13.;
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

      if onedone and twodone then stop;
   end;      /* ends the DO WHILE loop */
   return;

getone: if last1 then
           do;
              onedone=1;
              return;
           end;
        set one (rename=(time=tempt1 sample=temps1)) end=last1;
        return;

gettwo: if last2 then
           do;
              twodone=1;
              return;
           end;
        set two (rename=(time=tempt2 sample=temps2)) end=last2;
        return;
run;


proc print data=match1;
title 'MATCH1';
run;

/* Example 2.2: Related Technique                                   */

options nodate nonumber ls=80;

data one;
     input time time5.  sample;
     format time datetime13.;
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
data two;
     input time time5.  sample;
     format time datetime13.;
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

proc sql;
   create table match2 as
      select *
         from one(rename=(time=time1 sample=sample1)) full join
              two(rename=(time=time2 sample=sample2))
            on abs(time1-time2)<=5*60;
quit;

proc print data=match2;
   title 'MATCH2';
run;

/* Example 2.3                                                       */

options nodate nonumber ls=80;

data projects;
   input project $ stdate : mmddyy8. enddate : mmddyy8.;
   format stdate enddate mmddyy8.;
   datalines;
BASEMENT  01/09/95 01/27/95
FRAME     02/01/95 02/12/95
ROOFING   02/15/95 02/20/95
PLUMB     02/22/95 02/28/95
WIRE      03/02/95 03/05/95
BRICK     03/07/95 03/29/95
;

data bills;
   input workid compdate : mmddyy8. charge : 7.2;
   format compdate mmddyy8. charge dollar10.2;
   datalines;
1234        01/17/95   944.80
2225        02/18/95  1280.94
3879        03/04/95   888.90
8888        03/21/95  2280.87
;

data combine1(drop=found);
   set projects;
   found=0;
   do i=1 to n until (found);
      set bills point=i nobs=n;

      if stdate <= compdate <= enddate then
         do;
            found=1;
            output;
         end;
   end;
   if not found then put 'No bills exist for: ' project
      'with start date ' stdate 'and enddate ' enddate +(-1) '.';
run;

proc print data=combine1;
   title 'COMBINE1';
run;


/* Example 2.3: Related Technique                                    */

options nodate nonumber ls=80;

data projects;
   input project $ stdate : mmddyy8. enddate : mmddyy8.;
   format stdate enddate mmddyy8.;
   datalines;
BASEMENT  01/09/95 01/27/95
FRAME     02/01/95 02/12/95
ROOFING   02/15/95 02/20/95
PLUMB     02/22/95 02/28/95
WIRE      03/02/95 03/05/95
BRICK     03/07/95 03/29/95
;

data bills;
   input workid compdate : mmddyy8. charge : 7.2;
   format compdate mmddyy8. charge dollar10.2;
   datalines;
1234        01/17/95   944.80
2225        02/18/95  1280.94
3879        03/04/95   888.90
8888        03/21/95  2280.87
;
proc sql;
   create table combine2 as
      select *
         from projects, bills
         where compdate between stdate and enddate;
quit;

proc print data=combine2;
   title 'COMBINE2';
run;

/* Example 2.4                                                       */

options nodate nonumber ls=80;

data primary;
   input empnum salary comma7.;
   format salary dollar9.;
   datalines;
1234  55,000
3333  72,000
4876  32,000
5489  17,000
;

data lookup (index=(empnum));
   input empnum taxbrckt;
   datalines;
1111  .18
1234  .28
3333  .32
4222  .18
4876  .24
;
run;

data final1;
   set primary;
   set lookup key=empnum;
   select(_iorc_);
      when (%sysrc(_sok))
         do;
            net=salary*(1-taxbrckt);
         end;
      when (%sysrc(_dsenom))
         do;
            taxbrckt=.;
            put 'WARNING: No tax information for empnum ' empnum;
            _error_=0;
         end;
      otherwise
         do;
            put 'Unexpected ERROR:  _IORC_ =  ' _iorc_;
            stop;
         end;
   end;      /* ends the SELECT group */
run;

proc print data=final1;
   format net dollar9.;
   title 'FINAL1';
run;

/* Example 2.4: Related Technique                                    */

data primary;
   input empnum salary comma7.;
   format salary dollar9.;
   datalines;
1234  55,000
3333  72,000
4876  32,000
5489  17,00
;

data lookup (index=(empnum));
   input empnum taxbrckt;
   datalines;
1111  .18
1234  .28
3333  .32
4222  .18
4876  .24
;

proc sql;
   create table final2 as
      select primary.empnum,primary.salary,taxbrckt,
             salary*(1-taxbrckt) as net format=dollar7.
         from primary left join lookup
            on primary.empnum=lookup.empnum;
quit;

proc print data=final2;
   title 'FINAL2';
run;


/* Example 2.5                                                       */

options nodate nonumber ls=80;

data bteam;
input lname : $10. sex $ height weight type;
cards;
Adams M 67 160 2
Alexander M 69 115 1
Apple M 69 139 1
Arthur F 66 125 2
Avery M 66 152 2
Barefoot M 68 158 2
Baucom M 70 170 3
Blair M 69 133 1
Blalock M 68 148 2
Bostic F 74 170 3
;
data ideal;
input height small medium large;
cards;
66 126 138 149
67 130 141 154
68 134 145 158
69 138 149 162
70 142 153 167
71 146 157 172
72 150 161 177
73 154 165 181
74 158 169 185
75 162 173 189
;

data inshape outshape;
   keep lname height weight type;
   array wt(66:75,3) _temporary_;
   if _n_=1 then
      do i=1 to all;
         set ideal nobs=all;
         wt(height,1)=small;
         wt(height,2)=medium;
         wt(height,3)=large;
      end;
   set bteam;
   if sex='M'and 3 ge type ge 1 and 75 ge height ge 66;
   if wt(height,type)-5 le weight le wt(height,type)+5
      then output inshape;
   else output outshape;
run;

proc print data=inshape;
   title 'INSHAPE';
run;

proc print data=outshape;
   title 'OUTSHAPE';
run;

/* Example 2.6                                                       */

options nodate nonumber ls=80;

data engineer;
   input engineer $ availhrs;
   datalines;
Inge 33
Jane 100
Eduardo  12
Fred 16
Kia 130
Monique  44
Sofus 23
;

data projects;
   input projid $ hours;
   datalines;
Aero 31
Brandx 150
Chem 18
Contra 41
Eng2 6
Eng3 29
;

data engineer assign(keep=engineer projid);
   set projects;
   found=0;
   do i=1 to 1000 while (not found);
      x=ceil(ranuni(12345)*n);
      modify engineer point=x nobs=n;
      if availhrs>=hours then
         do;
            output assign;
            availhrs=availhrs-hours;
            replace engineer;
            found=1;
         end;
   end;      /* ends the iterative DO loop */
   if found=0 then do;
      engineer="NONE";
      output assign;
   end;
run;

proc print data=engineer;
   title 'ENGINEER';
run;

proc print data=assign;
   title 'ASSIGN';
run;

/* Example 2.7                                                       */

data one;
   input house $ x y;
   cards;
house1 1 1
house2 3 3
house3 2 3
house4 7 7
;

data two;
  input store $ x y;
  cards;
store1 6 1
store2 5 2
store3 3 5
store4 7 5
;

options nodate nonumber ls=80;

proc sql;
   create table final as
      select one.house, two.store label='Closest Store',
         sqrt((abs(two.x-one.x)**2)+(abs(two.y-one.y)**2)) as dist
            label='Distance' format=4.2
      from one,two
      group by house
      having calculated dist= min(dist);
quit;

proc print data=final label;
   title1 'FINAL';
run;

/* Example 3.1                                                       */

options nodate nonumber ls=80;

data dept_id;
   input store $2. dept $ ;
   cards;
13  VIDEO
;

data salesrep;
   input name $ month $ totsales;
   format totsales dollar8.;
   cards;
Harvey     Jan   25375
Lou        Jan   9950
Mary       Jan   27985
Sam        Jan   8795
;

data sales_id;
   if _n_=1 then set dept_id;
   set salesrep;
run;

proc print data=sales_id;
   title 'SALES_ID';
run;

/* Example 3.2                                                       */

options nodate nonumber ls=80;

data dept_id;
   input store $2. dept $ ;
   cards;
02  AUTO
07  HSEWARES
10  AUDIO
13  VIDEO
;

data salesrep;
   input name $ month $ totsales;
   format totsales dollar8.;
   cards;
Harvey     Jan   25375
Lou        Jan   9950
Mary       Jan   27985
Sam        Jan   8795
;

data sales_id;
   if _n_=1 then set dept_id point=last nobs=last;
   set salesrep;
run;

proc print data=sales_id;
   title 'SALES_ID';
run;

/* Example 3.3                                                       */

options nodate nonumber ls=80;

data one;
   input id name& $20.;
   datalines;
1 Nay Rong
2 Kelly Windsor
3 Julio Meraz
4 Richard Krabill
5 Rita Giuliano
;

data two;
   input id sale;
   format sale dollar10.;
   datalines;
1 28000
2 30000
2 40000
3 15000
3 20000
3 25000
4 35000
5 40000
;

data three;
   input id bonus;
   format bonus dollar10.;
   datalines;
1 2000
2 4000
3 3000
4 2500
5 2800
;

data final;
   merge one two three;
   by id;
run;

proc print data=final;
   title 'FINAL';
run;

/* Example 3.4                                                       */

options nodate nonumber ls=80;

data master;
   input itema itemb itemc;
   datalines;
1 2 0
1 3 99
1 4 88
1 5 77
2 1 66
2 2 55
3 4 44
;

data trans;
   input itema itemb itemc;
   datalines;
1 5 6
3 3 4
;

data final(drop=oldb oldc);
   merge master(rename=(itemb=oldb itemc=oldc)) trans(in=in2);
   by itema;
   if not in2 then
   do;
      itemb=oldb;
      itemc=oldc;
   end;
run;

proc print data=final;
   title 'FINAL';
run;

/* Example 3.5                                                       */

data trans;
input ssn $11. recdate;
cards;
243-09-8956 93
243-09-8956 92
243-09-8956 91
231-18-1345 93
231-18-1345 92
221-27-1234 92
221-27-1234 90
221-27-1234 89
215-15-0007 92
215-15-0007 90
215-15-0007 89
202-36-5566 89
;
data master;
input ssn $11. name $;
cards;
243-09-8956 Joe
231-18-1345 Susan
215-15-0007 David
221-27-1234 Jane
233-44-3215 Paula
;

proc sort data=master;
   by ssn;
run;

proc sort data=trans;
   by ssn;
run;

data trans(index=(ssn));
   set trans;
run;

data final1(drop=i recdate);
   array datefld(*) date1-date3;
   set master;
   i=0;
   do until (_iorc_ = %sysrc(_dsenom));
      set trans key=ssn;
      select(_iorc_);
         when(%sysrc(_sok)) do;
            i + 1;
            datefld(i) = recdate;
         end;
         when(%sysrc(_dsenom)) do;
            output;
            _error_ = 0;
         end;
         otherwise do;
            put 'Unexpected ERROR: _IORC_ =  ' _iorc_;
            stop;
         end;
      end;      /* ends SELECT group */
   end;         /* ends DO UNTIL loop */
run;

options nodate nonumber ls=80;

proc print data=final1;
   title 'FINAL1';
run;

/* Example 3.5: Related Technique                                    */

data trans;
input ssn $11. recdate;
cards;
243-09-8956 93
243-09-8956 92
243-09-8956 91
231-18-1345 93
231-18-1345 92
221-27-1234 92
221-27-1234 90
221-27-1234 89
215-15-0007 92
215-15-0007 90
215-15-0007 89
202-36-5566 89
;
data master;
input ssn $11. name $;
cards;
243-09-8956 Joe
231-18-1345 Susan
215-15-0007 David
221-27-1234 Jane
233-44-3215 Paula
;

proc sort data=master;
   by ssn;
run;

proc sort data=trans;
   by ssn;
run;

data trans(index=(ssn));
   set trans;
run;


data final2;
  array datefld(*) date1-date3;
  drop i recdate;
  set master;
  i = 0;
  do until (_iorc_ = %sysrc(_dsenom));
     set trans key=ssn;
     select(_iorc_);
        when(%sysrc(_sok)) do;
           i + 1;
           datefld(i) = recdate;
        end;
        when(%sysrc(_dsenom)) do;
           if i > 0 then output;
           _error_ = 0;
        end;
        otherwise do;
           put 'Unexpected ERROR: _IORC_ =  ' _iorc_;
           stop;
        end;
     end;
  end;

run;

options nodate nonumber ls=80;

proc print data=final2;
   title 'FINAL2';
run;

/* Example 3.6                                                       */

options nodate nonumber ls=80;

data master (index=(x));
   input x y;
   datalines;
1 2
1 3
2 4
3 5
1 2
;

data trans;
   input x y;
   datalines;
1 8
3 9
5 2
;

data master;
   do p = 1 to totobs;
      flag = 0;
      _iorc_ = 0;
      set trans(keep=x) point=p nobs=totobs;
      do while (_iorc_=%sysrc(_sok));
         modify master key=x;
         select (_iorc_);
            when (%sysrc(_sok)) do;
               set trans point=p;
               flag=1;
               replace;
            end;
            when (%sysrc(_dsenom)) do;
               if flag then
                  put 'NOTE: No more matches for KEY = ' x;
               else
                  put 'NOTE: No match for KEY = ' x;
               _error_ = 0;
            end;
            otherwise do;
               put 'ERROR: _IORC_ =  ' _iorc_ / 'Program halted.';
               _error_ = 0;
               stop;
            end;
         end;      /* ends SELECT group      */
      end;         /* ends DO WHILE loop     */
   end;            /* ends iterative DO loop */
   stop;
run;

proc print data=master;
   title 'MASTER';
run;

/* Example 3.7                                                       */

options nodate nonumber ls=80;

data master (index=(cust));
   input cust x;
   datalines;
1 1
1 2
1 3
2 2
2 2
2 2
2 2
3 3
3 3
4 2
;

data trans;
   input cust;
   datalines;
1
3
;

data master;
   set trans;
   flag=0;
   do until(flag);
      modify master key=cust;
      select (_iorc_);
         when (%sysrc(_sok)) remove;
         when (%sysrc(_dsenom))
            do;
               _error_=0;
               flag=1;
            end;
         otherwise
            do;
               put 'Unexpected ERROR: _iorc_= ' _iorc_;
               stop;
            end;
      end;      /* ends SELECT group  */
   end;         /* ends DO UNTIL loop */
run;

proc print data=MASTER;
   title 'MASTER';
run;

/* Example 3.7: Related Technique                                    */


options nodate nonumber ls=80;
data master (index=(cust));
   input cust x;
   datalines;
1 1
1 2
1 3
2 2
2 2
2 2
2 2
3 3
3 3
4 2
;

data trans;
   input cust;
   datalines;
1
3
;

proc sql;
   delete from master
      where cust in (select cust from trans);
quit;

proc print data=MASTER;
   title 'MASTER';
run;

/* Example 3.8                                                       */

options nodate nonumber ls=80;

data lookup;
   input partno $ desc $15.;
   datalines;
A401 tuning peg
A025 bridge
A203 nut
A220 neck
A810 pick guard
A063 pickup
A047 pot
A608 volume knob
A097 toggle switch
A498 body
;

data primary;
   input partno $ quantity;
   datalines;
A220 4
A498 4
A063 8
A810 4
A777 3
;

/* In order to test the error-handling code in this program,     */
/* the fifth dataline contains a value for PARTNO for which the  */
/* the LOOKUP data set will have no match. This record was       */
/* not shown in the book.                                        */

data report1(drop=pn found);
   set primary;
   found=0;
   do n=1 to numobs until (found);
      set lookup (rename=(partno=pn)) nobs=numobs point=n;
      if partno=pn then
         do;
            output;
            found=1;
         end;
   end;
   if not found then put 'No match for PARTNO=' partno 'in LOOKUP.'
      ' Observation not added to REPORT1 data set.';
run;

proc print data=report1;
   title 'REPORT1';
run;

/* Example 3.8: Related Technique                                    */

data lookup;
   input partno $ desc $15.;
   datalines;
A401 tuning peg
A025 bridge
A203 nut
A220 neck
A810 pick guard
A063 pickup
A047 pot
A608 volume knob
A097 toggle switch
A498 body
;

data primary;
   input partno $ quantity;
   datalines;
A220 4
A498 4
A063 8
A810 4
;

options nodate nonumber ls=80;

proc sql;
   create table report2 as
      select *
         from primary, lookup
         where primary.partno=lookup.partno;
quit;

proc print data=report2;
   title 'REPORT2';
run;

/* Example 3.9                                                       */

options nodate nonumber ls=80;

data lookup;
   input partno $ desc $15.;
   datalines;
A401 tuning peg
A025 bridge
A203 nut
A220 neck
A810 pick guard
A063 pickup
A047 pot
A608 volume knob
A097 toggle switch
A498 body
;

data primary;
   input partno $ quantity;
   datalines;
A220 4
A498 4
A063 8
A810 4
;

data formats;
   set lookup(rename=(partno=start desc=label));
   fmtname='$parts';
run;

proc format cntlin=formats;
run;

data report1;
   set primary;
   desc=put(partno,$parts.);
run;

proc print data=report1;
   title 'REPORT1';
run;

/* Example 3.9: Related Technique                                    */

options nodate nonumber ls=80;

proc sql;
   create table report2 as
      select *, put(partno,$parts.) as desc
         from primary;
quit;

proc print data=report2;
   title 'REPORT2';
run;

/* Example 3.10                                                      */

options nodate nonumber ls=80;

data primary;
 input store loc item $ amount;
 format amount dollar6.0;
 cards;
1 233 DEBIT 350
1 233 DEBIT 550
1 735 DEBIT 650
1 735 DEBIT 250
1 233 CREDIT 450
1 233 CREDIT 300
2 222 DEBIT 20
2 222 DEBIT 10
2 444 CREDIT 775
2 444 CREDIT 995
2 399 CREDIT 1000
2 399 CREDIT 2500
;

data lookup;
input store loc @7 storname $14. @22 city $15.;
cards;
1 233 Lynn's Finest  St Thomas
1 735 Lynn's Finest  San Diego
1 234 Lynn's Finest  Orlando
2 222 Just 4 You     San Francisco
2 444 Just 4 You     New York
2 399 Just 4 You     Boston
;

proc datasets ddname=work;
   modify lookup;
   index create storloc=(store loc);
run;

data report1(drop=store loc);
   set primary;
   set lookup key=storloc/unique;
   select (_iorc_);
      when (%sysrc(_SOK)) output;
      when (%sysrc(_dsenom))
         do;
            put 'WARNING!  New Location not in Table' store= loc=;
            _error_=0;
         end;
      otherwise
         do;
            put 'Unexpected ERROR:  _IORC_ =  ' _iorc_;
            _error_=0;
            stop;
         end;
   end;
run;

proc print data=report1;
   title 'REPORT1';
run;

/* Example 3.10: Related Technique                                   */

options nodate nonumber ls=80;

data primary;
 input store loc item $ amount;
 format amount dollar6.0;
 cards;
1 233 DEBIT 350
1 233 DEBIT 550
1 735 DEBIT 650
1 735 DEBIT 250
1 233 CREDIT 450
1 233 CREDIT 300
2 222 DEBIT 20
2 222 DEBIT 10
2 444 CREDIT 775
2 444 CREDIT 995
2 399 CREDIT 1000
2 399 CREDIT 2500
;

data lookup;
input store loc @7 storname $14. @22 city $15.;
cards;
1 233 Lynn's Finest  St Thomas
1 735 Lynn's Finest  San Diego
1 234 Lynn's Finest  Orlando
2 222 Just 4 You     San Francisco
2 444 Just 4 You     New York
2 399 Just 4 You     Boston
;

proc sql;
   create table report2 as
      select storname, city, item, amount
         from  primary p, lookup l
         where p.store=l.store and p.loc=l.loc;
quit;

proc print data=report2;
   title 'REPORT2';
run;

/* Example 3.11                                                      */

options nodate nonumber ls=80;

data lookup (index=(partno));
   input partno $ desc $15.;
   datalines;
A401 tuning peg
A025 bridge
A203 nut
A220 neck
A810 pick guard
A063 pickup
A047 pot
A608 volume knob
A097 toggle switch
A498 body
;

data primary;
   input partno $ quantity;
   datalines;
A220 4
A498 4
A063 8
A810 4
A777 3
;

proc sort data=primary;
   by partno;
run;

data report1;
   set primary;
   set lookup key=partno;
   select (_iorc_);
      when (%sysrc(_SOK)) output;
      when (%sysrc(_dsenom))
         do;
            put 'WARNING:  Part number ' partno 'is not in lookup table.';
            _error_=0;
         end;
      otherwise do;
         put 'Unexpected ERROR:  _IORC_ =  ' _iorc_;
         stop;
      end;
   end;
run;

proc print data=report1;
   title 'REPORT1';
run;

/* Example 3.11: Related Technique                                   */

options nodate nonumber ls=80;

data lookup (index=(partno));
   input partno $ desc $15.;
   datalines;
A401 tuning peg
A025 bridge
A203 nut
A220 neck
A810 pick guard
A063 pickup
A047 pot
A608 volume knob
A097 toggle switch
A498 body
;

data primary;
   input partno $ quantity;
   datalines;
A220 4
A498 4
A063 8
A810 4
A777 3
;

proc sql;
   create table report2 as
      select *
         from primary, lookup
         where primary.partno=lookup.partno;
quit;

proc print data=report2;
   title 'REPORT2';
run;

/* Example 4.1                                                       */

options nodate nonumber ls=80;

data master;
   input name $ Y;
   datalines;
John 1111
John 2222
John 3333
Mary 1111
;

data trans;
   input name $ Z;
   datalines;
John 89
John 94
John 83
Mary 77
Mary 88
Mary 99
;

data combined;
   inmast=0;
   merge master(in=inmast) trans;
   by name;
   if inmast;
run;

proc print data=combined;
   title 'COMBINED';
run;

/* Example 4.1: Related Technique                                    */

data master;
   input name $ Y;
   datalines;
John 1111
John 2222
John 3333
Mary 1111
;

data trans;
   input name $ Z;
   datalines;
John 89
John 94
John 83
Mary 77
Mary 88
Mary 99
;

data combine2;
   merge master(in=inmast) trans;
   by name;
   if inmast;
run;

proc print data=combine2;
   title 'COMBINE2';
run;

/* Example 4.2                                                       */

options nodate nonumber ls=80;

data master;
   input item $ price;
   format price dollar5.2;
   datalines;
apple  1.99
apple  2.89
apple  1.49
grapes 1.69
grapes 2.46
orange 2.29
orange 1.89
orange 2.19
;

data trans;
   input item $ price;
   format price dollar5.2;
   datalines;
banana 1.05
grapes 2.75
orange 1.49
orange   .
orange 2.39
;

data combine(drop=newprice);
   merge master trans(rename=(price=newprice));
   by item;
   if newprice ne . then price=newprice;
   format price dollar5.2;
run;

proc print data=combine;
   title 'COMBINE';
run;

/* Example 4.3                                                       */

data trips;
  input dest $15. travcode $;
  cards;
DETROIT        C751
SAN FRANCISCO  C288
ST THOMAS      A054
HAWAII         P003
BERMUDA        A059
;

data attends;
  input name $char15. level;
  cards;
Kreuger, John     1
Angler, Erica     2
Ng, Sebastian     1
Sook, Joy         3
Silverton, Lou    2
;

options nodate nonumber ls=80 ps=100;

proc sql;
   create table flights as
      select *
         from trips, attends;
quit;

proc print data=flights label;
   title1 'FLIGHTS';
run;

/* Example 4.4                                                       */

data roster;
input grade student $ ;
cards;
11 Jon
9 Rick
10 Amber
12 Susan
10 Cindy
11 Ginny
10 Denise
12 Lynn
11 Michael
12 Jake
;

data schedule;
input grade homeroom $ location $;
cards;
11 6 room4
10 3 room1
12 8 library
10 4 room2
11 5 room3
10 2 cafe
11 7 shop
9 1 gym
;

options nodate nonumber ls=80 ps=100;

proc sql;
   create table assign as
      select student, roster.grade, homeroom, location
         from roster, schedule
         where roster.grade=schedule.grade
         order by student;
quit;

proc print data=assign label;
   title1 'ASSIGN';
run;

/* Example 4.5                                                       */

options nodate nonumber ls=80;

data rooms;
     input @1 room $char4.  @6 demofac $char1.
           @8 capacity 3.;
     cards;
R100 N 10
R200 Y 15
R301 Y 30
R305 N 50
R400 Y 60
R420 Y 100
;

data meetings;
     input @1 numatt 3.
           @5 demo   $char1.
           @7 desc   $char40.;
     cards;
10  Y Operator Training
12  N Sales Meeting
40  Y Marketing Presentation
60  N Division Meeting
45  N Employee Orientation
;

data _null_;
   if 0 then set rooms nobs=nobs;
   call symput('num',left(put(nobs,8.)));
   stop;
run;

data rooms(keep = room demofac capacity)
     assign(keep = desc room numatt demo demofac capacity);
   array used(*) used1-used&num;
   retain used1-used&num 0;
   set meetings end=done;
   tempcap = 999;
   tempdemo = demo;
   tempobs = .;
   do i=1 to nobs;
      if used(i) ne 1 then
         do;
            set rooms point=i nobs=nobs;
            if capacity >= numatt and (demofac=demo or demo = 'N') then
               do;
                  if (capacity < tempcap) or
                     (demo = 'N' and tempdemo = 'Y') then
                     do;
                        tempcap = capacity;
                        tempdemo = demofac;
                        tempobs = i;
                     end;
               end;      /* ends a DO group           */
            if tempcap=numatt and tempdemo=demo then leave;
         end;            /* ends a DO group           */
   end;                  /* ends an iterative DO loop */
   if tempobs ne . then
      do;
         set rooms point=tempobs;
         output assign;
         used(tempobs)=1;
      end;
   else
      do;
         room = 'NONE';
         capacity = .;
         demofac = ' ';
         output assign;
      end;
   if done then
      do i=1 to dim(used);
         if not used(i) then
               do;
                  set rooms point=i;
                  output rooms;
               end;
      end;
run;

proc print data=assign;
   title1 'ASSIGN';
run;

proc print data=rooms;
   title1 'ROOMS';
run;

/* Example 4.6                                                       */

options nodate nonumber ls=80;

data sales;
input product salesrep $ ordernum $;
cards;
310 Polanski  RAL5447
310 Alvarez   CH1443
312 Corrigan  DUR5523
313 Corrigan  DUR5524
313 Polanski  RAL5498
;

data stock(index=(product));
input product prdtdesc $ 10-29 piece pcdesc $ 45-54;
cards;
310      oak pedestal table         310.01  tabletop
310      oak pedestal table         310.02  pedestal
310      oak pedestal table         310.03  2 leaves
312      brass floor lamp           312.01  lamp base
312      brass floor lamp           312.02  lamp shade
313      oak bookcase, short        313.01  bookcase
313      oak bookcase, short        313.02  2 shelves
;

data shiplist(drop=dummy);
   set sales;
   by product;
   dummy=0;
   do until(_iorc_=%sysrc(_dsenom));
      if dummy then product=99999;
      set stock key=product;
      select (_iorc_);
         when (%sysrc(_sok)) output;
         when (%sysrc(_dsenom))
            do;
               _error_=0;
               if not last.product and not dummy then
                  do;
                     dummy=1;
                     _iorc_=0;
                  end;
            end;
         otherwise
            do;
               put 'Unexpected ERROR: _IORC_ =  ' _iorc_;
               stop;
            end;
      end;      /* ends the SELECT group  */
   end;         /* ends the DO UNTIL loop */
run;

proc print data=shiplist;
   title 'SHIPLIST';
run;

proc printto;
run;

/* Example 4.6: Related Technique                                    */

data sales;
input product salesrep $ ordernum $;
cards;
310 Polanski  RAL5447
310 Alvarez   CH1443
312 Corrigan  DUR5523
313 Corrigan  DUR5524
313 Polanski  RAL5498
;

data stock(index=(product));
   input product prdtdesc $ 10-29 piece pcdesc $ 45-54;
   cards;
310      oak pedestal table         310.01  tabletop
310      oak pedestal table         310.02  pedestal
310      oak pedestal table         310.03  2 leaves
312      brass floor lamp           312.01  lamp base
312      brass floor lamp           312.02  lamp shade
313      oak bookcase, short        313.01  bookcase
313      oak bookcase, short        313.02  2 shelves
;

options nodate nonumber ls=80;

proc sql;
   create table shiplst as
      select *
         from sales as a, stock as b
            where a.product=b.product;
quit;

proc print data=shiplst;
   title 'SHIPLST';
run;


/* Example 4.7                                                       */

data employee;
   input id : $4. name & $14. emptype : $1. @25 location $20.;
cards;
341 Kreuger, John  H    Bldg A, Rm 1111
511 Olszweski, Joe  S   Bldg A, Rm 1234
5112 Nuhn, Len  S       Bldg A, Rm 2123
5132 Nguyen, Luan  S    Bldg B, Rm 5022
5151 Oveida, Susan  S   Bldg D, Rm 2013
3551 Sook, Joy    H     Bldg E, Rm 2533
3782 Comuzzi, James  S  Bldg E, Rm 1101
381 Smith, Ann  S       Bldg C, Rm 3321
;
data daily;
input idnum $4. itemno quantity;
cards;
341       101      2
341       103      1
511       101      1
511       103      1
5112      105      1
5132      105      1
3551      104      1
3551      105      2
3782      104      1
341       101      2
511       101      1
511       103      3
5112      105      1
5112      101      3
5132      105      2
3551      104      1
3551      105      2
3551      103      2
3782      104      1
3782      105      3
;
data prices;
input itemno price;
cards;
101      0.30
102      0.65
103      2.75
104      1.25
105      0.85
;

options nodate nonumber ls=80;

proc sql;
   create table charge as
   select id, name, location,
          sum(quantity*price) as total format=dollar8.2,
          case emptype
             when 'H' then 'cash charge'
             when 'S' then 'payroll deduction'
             else 'special'
          end as type
      from employee as e, daily as d, prices as p
      where p.itemno=d.itemno and id=idnum
      group by id, name, location, type;
quit;

proc print data=charge label;
   title1 'CHARGE';
run;

/* Example 4.8                                                       */

data one;
format date date7. depart time5.;
 input date:date7. flight depart:time5.;
cards;
01jan93 114 7:10
01jan93 202 10:43
01jan93 439 12:16
02jan93 114 7:10
02jan93 202 10:45
;

data two;
format date date7. depart time5.;
 input date:date7. flight depart:time5.;
cards;
01jan93 176 8:21
02jan93 176 9:10
03jan93 176 8:21
04jan93 176 9:31
05jan93 176 8:13
;

options nodate nonumber ls=80;

proc sql;
   create table schedule as
      select *
         from one
      outer union corr
      select *
         from two
      order by date, depart;
quit;

proc print data=schedule label;
   title1 'SCHEDULE';
run;

/* Example 4.8: Related Technique                                    */

data one;
format date date7. depart time5.;
 input date:date7. flight depart:time5.;
cards;
01jan93 114 7:10
01jan93 202 10:43
01jan93 439 12:16
02jan93 114 7:10
02jan93 202 10:45
;

data two;
format date date7. depart time5.;
 input date:date7. flight depart:time5.;
cards;
01jan93 176 8:21
02jan93 176 9:10
03jan93 176 8:21
04jan93 176 9:31
05jan93 176 8:13
;

options nodate nonumber ls=80;

data sched;
   set one two;     /* data sets must be sorted on the BY variables*/
   by date depart;
run;

proc print data=sched label;
   title1 'SCHED';
run;


/* Example 4.9: This code produces unexpected results.               */


options nodate nonumber ls=80;

data one_a;
input @1 common $1.
      @3 test $4.;
cards;
A AAAA
C CCCC
;

data two;
input @1 common $1.
      @3 switch $1.;
cards;
A N
A Y
A N
B N
B Y
B N
;

data combined;
   set one_a two(in=in2);
   by common;
   if in2 and switch = 'Y' then test = 'TRUE';
run;

proc print data=combined;
   title 'COMBINED';
run;



/* Example 4.9: This code produces expected results.                 */

data one_b;
input @1 common $1.;
cards;
A
C
;

data two;
input @1 common $1.
      @3 switch $1.;
cards;
A N
A Y
A N
B N
B Y
B N
;

data combined;
   set one_b two(in=in2);
   by common;
   if in2 and switch = 'Y' then test = 'TRUE';
run;

proc print data=combined;
   title 'COMBINED';
run;

/* Example 4.10                                                      */

data breakdwn;
 input brkdndt date7. +1 vehicle $char3.;
 format brkdndt date7.;
 cards;
2mar94  AAA
20may94 AAA
19jun94 AAA
29nov94 AAA
4jul94  BBB
31may94 CCC
24dec94 CCC
;

data maint;
 input mntdate date7.  +1 vehicle $char3.;
 format mntdate date7.;
 cards;
3jan94  AAA
5apr94  AAA
10aug94 AAA
28jan94 CCC
16may94 CCC
07oct94 CCC
24feb94 DDD
22jun94 DDD
19sep94 DDD
;

proc sort data=breakdwn; by vehicle;
run;

proc sort data=maint; by vehicle mntdate;
run;

options nodate nonumber ls=80;

data brkkey (keep = vehicle first1 last1);
   set breakdwn;
   by vehicle;
   retain first1;
   if first.vehicle then first1=_n_;
   if last.vehicle then
      do;
         last1=_n_;
         output;
      end;
run;

data maintkey (keep = vehicle first2 last2);
   set maint;
   by vehicle;
   retain first2;
   if first.vehicle then first2=_n_;
   if last.vehicle then
      do;
         last2=_n_;
         output;
      end;
run;

data keys;
   merge brkkey(in=in1) maintkey;
   by vehicle;
   if in1;
run;

data final1;
   drop first1 last1 first2 last2 mntdate;
   set keys;

   do i=first1 to last1;
      set breakdwn point=i;
      format lastmnt date7.;
      lastmnt=. ;

      if first2 ne . then
         do j=first2 to last2;
            set maint point=j;
            if mntdate gt lastmnt and mntdate le brkdndt
               then lastmnt=mntdate;
               else if mntdate gt brkdndt then leave;
         end;
      output;
   end;        /* ends the outer iterative DO loop */
run;

proc print data=final1;
   title 'FINAL1';
run;

/* Example 4.10: Related Technique                                   */


options nodate nonumber ls=80;

proc sql;
   create table final2 as
      select b.vehicle, b.brkdndt, m.mntdate as lastmnt
         from breakdwn b left join maint m
              on b.vehicle=m.vehicle and b.brkdndt >= m.mntdate
         group by b.vehicle, b.brkdndt
         having m.mntdate = max(m.mntdate);
quit;

proc print data=final2;
   title 'FINAL2';
run;

/* Example 5.1                                                       */

options nodate nonumber ls=80;

data newhires;
   input name $30. dept & $20. id;
   datalines;
Estefon, Emilio                Toys  54345
Wentworth, Guy                 Hardware  43454
Nay, Rong                      Automotive  23234
Harper, Chang                  Toys   45434
Smart, Matthew                 Toys   45412
Ochman, Andre                  Toys   45413
Welk, Liz Ann                  Hardware  32322
Jordan, Erica                  Linens   31012
;

data toydept;
   set newhires;
   where dept='Toys';
run;

proc print data=toydept;
   title 'TOYDEPT';
run;

/* Example 5.2                                                       */

options nodate nonumber ls=80;

data clasdata;
input id name $ class $ ;
cards;
3456    Amber     CHEM101
3456    Amber     MATH102
3456    Amber     MATH102
4567    Denise    ENGL201
4567    Denise    ENGL201
2345    Ginny     CHEM101
2345    Ginny     MATH102
2345    Ginny     ENGL201
1234    Lynn      CHEM101
1234    Lynn      CHEM101
1234    Lynn      MATH102
5678    Rick      CHEM101
5678    Rick      HIST300
5678    Rick      HIST300
;

proc sort data=clasdata;
   by name class;
run;

data dups nodups;
   set clasdata;
   by name class;
   if first.class and last.class then output nodups;
   else output dups;
run;

proc print data=dups;
   title 'DUPS';
run;

proc print data=nodups;
   title 'NODUPS';
run;

/* Example 5.3                                                       */

options nodate nonumber ls=80;

data sales;
input name $char15. daysales;
cards;
Ball, George           674
Lee, Chin             1800
Placa, Ace            2500
Leung, Ho             3000
Wagner, Willie         850
DuBois, Grace         2000
Jernigan, Alec         750
Tilldale, Jules       1000
Brown, Dick            555
Hammer, Danny          400
Wills, Wesley          800
Grant, Heber          3500
Mooney, Hal            400
;

data subset (drop=startobs endobs);
   if numobs > 10 then
      do;
         startobs=1;
         endobs=5;
         link getobs;
         startobs=numobs-4;
         endobs=numobs;
         link getobs;
      end;
   else
      do;
         startobs=1;
         endobs=numobs;
         link getobs;
      end;
   stop;

return;
getobs:
   do i=startobs to endobs;
      set sales point=i nobs=numobs;
      output;
   end;
return;
run;

proc print data=subset;
   title1 'SUBSET';
run;

/* Example 5.4                                                       */

data test1;
   input x y;
   cards;
1 2
2 4
3 6
4 8
5 10
;
options nodate nonumber ls=80;

data test1(drop=i);
   set test1 end=lastone;
   output;
   if lastone then do;
      do i=1 to 10;
         x=x+1;
         y=y+2;
         output;
      end;
   end;
run;

proc print data=test1;
   title 'TEST1';
run;

/* Example 5.4: Related Technique                                    */

data test1;
   input x y;
   cards;
1 2
2 4
3 6
4 8
5 10
;

options nodate nonumber ls=80;

data test2(drop=i);
     if _n_=1 then set test1 point=lastobs nobs=lastobs;
     do i = 1 to 10;
        x = x +1;
        y = y + 2;
        output;
     end;
     stop;
run;

proc append base=test1 data=test2;
run;

proc print data=test1;
   title 'TEST1';
run;

/* Example 5.5                                                       */

data tasks;
input days job $8.;
cards;
1 wiring
2 drywall
4 flooring
2 trimwork
3 painting
;

options nodate nonumber ls=80;

data tasks(drop=i testday);
   format date date9.;
   set tasks;
   if _n_=1 then date=today();
   do i=1 to days;
      testday=weekday(date);
      if testday=7 then date=date+2;
      if testday=1 then date=date+1;
      output;
      date+1;
   end;
run;

proc print data=tasks;
   title 'TASKS';
run;

/* Example 5.6                                                       */

options nodate nonumber ls=80;

data one;
   input x y;
cards;
5 1
5 2
10 1
2 1
2 2
19 1
;

data two;
   merge one one(firstobs=2 rename=(x=nextx) keep=x);
   if x=nextx then match='YES';
   else match='NO';
run;

proc print data=TWO;
   title 'TWO';
run;

/* Example 5.7                                                       */

options nodate nonumber ls=80;

data informs;
   input start end;
   cards;
1 2
1 1
1 3
1 4
1 10
1 5
3 1
3 3
3 2
3 4
3 5
2 1
2 2
;

proc sort data=informs;
   by start;
run;

data showlag(drop=i count);
   set informs;
   by start;
   array group (*) endlag1-endlag4;
   endlag1=lag1(end);
   endlag2=lag2(end);
   endlag3=lag3(end);
   endlag4=lag4(end);
   if first.start then count=1;
   do i=count to dim(group);
      group(i)=.;
   end;
   count + 1;
run;

proc print data=showlag;
   title1 'SHOWLAG';
run;

/* Example 5.8                                                       */

data grades;
  input name $ test1-test10;
  cards;
Betty    78 88 94 57 89 77 79 81 89 82
James    74 82 88 71 88 81 72 84 91 77
Fred     69 71 81 64 79 74 66 77 81 95
;

options nodate nonumber ls=80;

data curve(drop=i);
   retain test3 test5 test9;
   set grades;
   array alltest _numeric_;
   do i=4 to dim(alltest);
      alltest(i)+10;
      if alltest(i) > 100 then alltest(i) = 100;
  end;
run;

proc print data=curve;
   title1 'CURVE';
run;

/* Example 5.9                                                       */

options nodate nonumber ls=80;

data scores;
input id $ game1 game2 game3;
cards;
A 2 3 4
A 5 6 7
B 1 2 3
C 1 2 3
C 4 5 6
C 7 8 9
;
proc sort data=scores;
  by id;
run;

data grandtot(drop=temp1 temp2 temp3);
   set scores(rename= (game1=temp1 game2=temp2 game3=temp3));
   by id;
   if first.id then
      do;
         game1=0;
         game2=0;
         game3=0;
      end;
   game1 + temp1;
   game2 + temp2;
   game3 + temp3;
   if last.id then output;
run;

proc print data=grandtot;
   title1 'GRANDTOT';
run;

/* Example 5.9: Related Technique                                    */

options nodate nonumber ls=80;

data cumtot(drop=temp1 temp2 temp3);
   set scores(rename= (game1=temp1 game2=temp2 game3=temp3));
   by id;
   if first.id then
      do;
         game1=0;
         game2=0;
         game3=0;
      end;
   game1 + temp1;
   game2 + temp2;
   game3 + temp3;
run;

proc print data=cumtot;
   title1 'CUMTOT';
run;

/* Example 5.10                                                      */

options nodate nonumber ls=80;

data sales;
     input @1 region $char8.  @10 repid 4.  @15 amount 10. ;
     format amount dollar12.;
     cards;
NORTH    1001 1000000
NORTH    1002 1100000
NORTH    1003 1550000
NORTH    1008 1250000
NORTH    1005  900000
SOUTH    1007 2105000
SOUTH    1010  875000
SOUTH    1012 1655000
EAST     1051 2508000
EAST     1055 1805000
;
proc sort data=sales;
   by region;
run;

proc means data=sales noprint nway;
   var amount;
   by region;
   output out=regtot(keep=regtotal region) sum=regtotal;
run;

data percent1;
   merge sales regtot;
   by region;
   regpct = (amount / regtotal ) * 100;
   format regpct 6.2 amount regtotal dollar10.;
run;

proc print data=percent1;
   title1 'PERCENT1';
run;

/* Example 5.10: Related Technique                                   */

options nodate nonumber ls=80;

proc sql;
   create table percent2 as
      select *, sum(amount) as regtotal format=dollar10.,
             100*(amount/sum(amount)) as regpct format=6.2
         from sales
         group by region;
quit;

proc print data=percent2;
   title 'PERCENT2';
run;

/* Example 5.11                                                      */

data one;
  input id @5 name $15. @22 location $15. @40 hours;
  cards;
1   John Krueger      Tech Support     5
2   Joe Olszweski     Marketing        3
1   John Krueger      Tech Support     10
3   Len Nuhn          Sales            30
3   Len Nuhn          Sales            1
2   Joe Olszweski     Marketing        20
1   John Krueger      Tech Support     30
1   John Krueger      Tech Support     40
4   Luan Nguyen       Development      40
;

options nodate nonumber ls=80;

proc sql;
   create table final as
      select *, count(id) as count
      from one
      group by id;
quit;

proc print data=final label;
   title1 'FINAL';
run;

/* Example 5.12                                                      */

data employee;
 input name $ jobcode $ salary;
format salary dollar10.2;
cards;
Nikos A1 32456
Paul NA2 53798
Jody T2 25147
Olga T1 19810
Yao NA1 43433
Natasha A1 31987
Tom T2 23596
Kendrick NA1 41690
Kesha A1 33067
Klaus T1 20230
Kyle NA2 51081
Carla NA2 52270
Anne T2 24876
Gunner NA1 42345
Candice A1 34567
;
options nodate nonumber ls=80;

proc sql;
   create table final as
      select *, avg(salary) as average format=dollar10.2
         from employee
         group by jobcode
         having salary >calculated average;
quit;

proc print data=final label;
   title1 'FINAL';
run;

/* Example 5.13                                                      */

data amounts;
format amt1 amt2 10.7;
input amt1 amt2;
cards;
  .000054   .00005
  .000055   .00006
  .000056   .00006
  .999805   .99981
  .999806   .99981
17.999805 17.99981
17.999806 17.99981
18.999805 18.99981
18.999806 18.99981
18.999905 18.99991
18.999906 18.99991
;

options nodate nonumber ls=80;

%macro macround(var,unit,fuzz=1e-10);
   round ((&var+(sign(&var)*&fuzz)),&unit)
%mend;

data  macrnd;
   format amt1 amt2  m_round 10.6;
   set amounts;
   m_round=%macround(amt1,.00001);
  if amt2=m_round then match='yes';
  else match='no';
run;

proc print data=macrnd;
   title1 "MACRND";
run;

/* Example 5.13: A Closer Look                                       */

data regrnd;
   format amt1 amt2 r_round 10.6;
   set amounts;
   r_round=round(amt1,.00001);
   if amt2=r_round then match='yes';
   else match='no';
run;

proc print data=regrnd;
   title1 "REGRND";
run;

/* Example 5.14                                                      */

options nodate nonumber ls=80;

data students;
   input name:$ score;
   cards;
Deborah      89
Deborah      90
Deborah      95
Martin       90
Stefan       89
Stefan       76
;

data scores(keep=name score1-score3);
   retain name score1-score3;
   array scores(*) score1-score3;
   set students;
   by name;
   if first.name then do;
      i=1;
      do j=1 to 3;
         scores(j)=.;
      end;
   end;
   scores(i)=score;
   if last.name then output;
   i+1;
run;

proc print data=scores;
   title 'SCORES';
run;

/* Example 5.15                                                     */

data survey;
  input name $ cereal pastry bagel;
  cards;
John 10 9 8
Sam 2 8 4
Sally 5 7 6
;

options nodate nonumber ls=80;

data survey2(drop=cereal pastry bagel i);
   set survey;
   array num (*) cereal pastry bagel;
   length breakfst $ 8;
   do i=1 to dim(num);
      response=num[i];
      call vname(num[i],breakfst);
      output;
   end;
run;

proc print data=survey2;
   title1 'SURVEY2';
run;


/* Example 5.16                                                      */

options nodate nonumber ls=80;
proc printto log='/dept/pub/books/TW3185/logs/C5N14.log' new;

data one;
   input category rating;
   datalines;
1 6
1 9
1 8
1 9
1 8
1 10
1 10
2 7
2 8
2 8
2 10
2 9
2 8
2 10
3 6
3 9
3 9
3 9
3 8
3 9
3 9
;
proc transpose data=one
               out=interim(drop=_name_ category
                           rename=(col1=Ford col2=Nissan col3=Mazda
                                   col4=Saab col5=Saturn
                                   col6=Honda col7=Toyota));
   by category;
   var rating;
run;

proc transpose data=interim
               out=final(rename=(_name_=make col1=depend
                                 col2=appeal col3=perform));
run;

proc print data=interim;
   title 'INTERIM';
run;

proc print data=final;
   title 'FINAL';
run;


/* Example 6.1                                                       */

options nodate nonumber ls=80;

data one;
   input xchar $char8.;
   cards;
0123
12345
123456
123A45
;

data two;
   input ynum ;
   cards;
123
12345
999
 .
;

data char2num;
   set one;
   xnum = input(xchar,?? 8.);
run;

data num2char;
   set two;
   ychar1 = put(ynum,z6.);
   ychar2 = put(ynum, 6.);
   if ynum=. then ychar1=' ';
run;

proc print data=char2num;
   title 'CHAR2NUM';
run;

proc print data=num2char;
   title 'NUM2CHAR';
run;

proc printto;
run;

/* Example 6.1: Related Technique                                    */

data char2nm2(drop=x);
   set one(rename=(xchar=x));
   xchar = input(x,?? 8.);
run;

options nodate nonumber ls=80;

proc print data=char2nm2;
   title 'CHAR2NM2';
run;

/* Example 6.2                                                       */

options nodate nonumber ls=80;

data old;
   infile cards missover;
   input x $;
   cards;
1234
12E5

124ABC
124
ABCDEFGH
;

data new(drop=tempvar);
   length type $ 9.;
   set old;
   if x=' ' then
      do;
         type='Undefined';
         return;
      end;
  tempvar=input(x,?? 8.);
  if tempvar ne . then
     type = 'Numeric';
  else
     type = 'Character';
run;

proc print data=new;
   title 'NEW';
run;


/* Example 6.3                                                       */

data one;
   x_num=12345;
   y_char='12345';
run;

options nodate nonumber ls=80;

proc sql;
   select type into : vartype
      from dictionary.columns
      where libname='WORK' and
            memname='ONE' and
            name='X_NUM';
quit;

data num2char;
   set one;
   if "&vartype"="num" then charval=put(x_num,5.);
run;

proc print data=num2char ;
   title 'NUM2CHAR';
run;

proc sql;
   select type into : vartype
      from dictionary.columns
      where libname='WORK' and
            memname='ONE' and
            name='Y_CHAR';
quit;

data char2num;
   set one;
   if "&vartype"="char" then numval=input(y_char,5.);
run;

proc print data=char2num;
  title 'CHAR2NUM';
run;


/* Example 6.4                                                       */

data work.prices;
   crop='Wheat';
   market='Farmville';
   high=2.96;
   low=2.64;
   last=2.70;
   month='jul94';
run;

options nodate nonumber ls=80;

proc sql;
   describe table dictionary.columns;
   create table attr as
      select type, name, length
      from dictionary.columns
      where libname='WORK' and memname='PRICES'
      order by type;
quit;

proc print data=attr label;
   title1 'ATTR';
run;

/* Example 6.5                                                       */

options nodate nonumber ls=80;

data one;
   input code1-code6;
   cards;
3 1 5 4 6 2
9 8 6 5 7 4
3 2 1 9 0 7
8 2 6 4 0 1
5 7 4 3 8 2
;

data varsort(keep=code1-code6);
   array code(*) code1-code6;
   set one;
   do until (sorted);
      sorted=1;
      do i = 1 to dim(code)-1;
         if code(i) > code(i+1) then
            do;
               temp=code(i+1);
               code(i+1)=code(i);
               code(i)=temp;
               sorted=0;
            end;
      end;
   end;

proc print data=varsort;
   title 'VARSORT';
run;

/* Example 6.5: Related Technique                                    */

options nodate nonumber ls=80;

data one;
   input code1-code6;
   cards;
3 1 5 4 6 2
9 8 6 5 7 4
3 2 1 9 0 7
8 2 6 4 0 1
5 7 4 3 8 2
;

data varsort2(keep=code1-code6);
   array code(*) code1-code6;
   set one;
   hbnd = dim(code)-1;
   do until (sorted);
      sorted=1;
      do i = 1 to hbnd;
         if code(i) > code(i+1) then
            do;
               temp=code(i+1);
               code(i+1)=code(i);
               code(i)=temp;
               movehigh=i;
               sorted=0;
            end;
      end;
      hbnd=movehigh-1;
   end;
run;

proc print data=varsort2;
   title 'VARSORT2';
run;

/* Example 6.6                                                       */

options nodate nonumber ls=80;

data master;
   input name & $13.;
   cards;
NCSU
Clemson
Georgia Tech
Duke
Maryland
Virginia
Wake Forest
Florida State
UNC
;

data random;
   set master;
   x=ranuni(12345);
run;

proc sort data=random;
   by x;
run;

data one two three;
   set random;
   drop x class;
   class=mod(_N_,3);
   select (class);
      when (0) output one;
      when (1) output two;
      otherwise output three;
   end;
run;

proc print data=one;
title 'ONE';
run;

proc print data=two;
title 'TWO';
run;

proc print data=three;
title 'THREE';
run;

/* Example 6.6: Related Technique                                    */

data master;
   input name & $13.;
   cards;
NCSU
Clemson
Georgia Tech
Duke
Maryland
Virginia
Wake Forest
Florida State
UNC
;

data random;
   set master;
   x=ranuni(12345);
run;

proc sort data=random;
   by x;
run;

data simple(keep=name);
   set random(obs=5);
run;

proc print data=simple;
   title 'SIMPLE';
run;

/* Example 6.7                                                       */

options nodate nonumber ls=80;

data one;
input memname $15.;
cards;
_my_lib_my
_my_lib_My
mylibmylibmylib
my_libmylib_my
;

data two;
   set one;
   newmname=tranwrd(memname,'my','&');
   count=length(newmname)-length(compress(newmname,'&'));
run;

proc print data=two;
   title 'TWO';
run;

/* Example 6.8                                                       */

options nodate nonumber ls=80;

data survey;
   input comments $45.;
   cards;
The food was served in a timely manner.
The service was good!  Food was great!!
The waiter was very helpful and courteous.
My chicken is great, but service is slow!!!
I love the restaurant!!! Service is great!!
;

data new(keep=comments newcomnt);
   set survey;
   length newcomnt $ 20;
   nextchar=substr(comments,21,1);
   cutpt=substr(comments,20,1);
   if cutpt in (' ' ',' ';' '.' '?' '!') or
      nextchar in (' ' ',' ';' '.' '?' '!') then
         do;
            newcomnt=substr(comments,1,20);
         end;
   else do;
      do i=19 to 1 by -1 until (cutpt in (' ' ',' ';' '.' '?' '!'));
         cutpt=substr(comments,i,1);
      end;
      newcomnt=substr(comments,1,i);
   end;
run;

proc print data=new;
   title 'NEW';
run;


/* Example 6.9                                                       */

options nodate nonumber ls=80;

data one;
   input dateval mmddyy8. timeval time.;
   format dateval date9. timeval time.;
   cards;
07/19/94 16:00:00
12/25/94 14:22:58
01/01/95 23:01:00
01/09/95 09:35:19
;

data results(keep=datimval);
   set one;
   datimval=dhms(dateval,0,0,timeval);
   format datimval datetime.;
run;

proc print data=results;
   title 'RESULTS';
run;


/* Example 6.10                                                      */

options nodate nonumber ls=80;

data time1;
   input timechar $11.;
   cards;
33.49
1:13.69
13:00:00.33
1:13:43.45
;

proc format;
   picture tme other='99:99:99.99' ;
run;

data time2(drop=temp1 temp2);
   format sastime time11.2;
   set time1;
   temp1=compress(timechar,':');
   temp2=put(input(temp1,11.2),tme.);
   sastime=input(temp2,time11.);
run;

proc print data=time2;
   title 'TIME2';
run;


/* Example 6.11                                                      */

options nodate nonumber ls=80;

data birth;
   input name $ bday date9.;
   format bday worddate20.;
   cards;
Miguel 31dec1973
Joe 28feb1976
Rutger 29mar1976
Broguen 01mar1976
Susan 12dec1976
Michael 14feb1971
LeCe 09nov1967
Hans 02jul1955
Lou 30jul1960
;

data ages;
   set birth;
   current=today();
   format current worddate20.;
   age=int(intck('month',bday,current)/12);
   if month(bday)=month(current) then
      age=age-(day(bday)>day(current));
run;

proc print data=ages;
   title 'AGES';
run;

