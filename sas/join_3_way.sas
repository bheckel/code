 /*---------------------------------------------------------------------------
  *     Name: join_3way.sas
  *
  *  Summary: Demo of a 3 way SQL join.
  *
  *  Adapted: Sat Jun 01 14:11:15 2002 (Bob Heckel -- SUGI27 Kirk Lafler)
  * Modified: Tue 07 Jul 2015 08:25:24 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options linesize=72 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace datastmtchk=allkeywords;

*************************;
data work.customers;
  infile cards;
  input @1 custno 3. @6 name $char10. @25 city $char20. state $char2.;
  cards;
113  Ron Francis        Raleigh             NC
114  Arturs Irbe        Latvia              UK
115  Nick Wallin        Raleigh             NC
117  Sandis Ozone       Raleigh             NC
  ;
run;

data work.movies;
  infile cards;
  input @1 custno 3. @6 movieno 10. @25 rating $char5. @32 category $char10.;
  cards;
113  12345              R      Adventure
114  24680              PG-13  Comedy
115  67890              G      Drama
113  24680              G      Drama
  ;
run;

data work.actors;
  infile cards;
  input @1 movieno 6. @8 leadactor $char10.;
  cards;
12345  Franka Potenka
67890  Kyle McLaughlin
24680  Charlton Heston
39000  Andie McDowell
  ;
run;
*************************;

 /* Link c to a then m to a */

 /* Alternative A */
proc sql;
  select c.custno,
         m.movieno,
         m.rating,
         m.category,
         a.leadactor
  from customers c,
       movies m,
       actors a
  where c.custno=m.custno and
        m.movieno=a.movieno
        ;
quit;

 /* Alternative B */
proc sql;
  select c.custno, m.movieno, m.rating, m.category, a.leadactor
  from (customers c join movies m ON c.custno=m.custno) join actors a ON m.movieno=a.movieno
  /*                                 ^^^^^^^^^^^^^^^^^                   ^^^^^^^^^^^^^^^^^^^ */
  ;
quit;
endsas;
Same but with LEFT join:
A.

             custno   movieno  rating  category    leadactor
           --------------------------------------------------
                113     12345  R       Adventure   Franka Pot
                114     24680  PG-13   Comedy      Charlton H
                115     67890  G       Drama       Kyle McLau
                113     24680  G       Drama       Charlton H
                                                                       2
B.
             custno   movieno  rating  category    leadactor
           --------------------------------------------------
                117         .                                
                113     12345  R       Adventure   Franka Pot
                114     24680  PG-13   Comedy      Charlton H
                113     24680  G       Drama       Charlton H
                115     67890  G       Drama       Kyle McLau

