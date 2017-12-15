options nosource;
 /*----------------------------------------------------------------------------
  *    Name: sql_essence2of2.sas
  *
  * Summary: SQL statements from in the book "The Essence of SQL"
  *
  *          Make sure perm ds exist in $HOME/tmp (created via sql_essence1of2.sas)
  *
  *          !! Toggle each NOPRINT option to view !!
  *
  *          Use Vim's '[I' with cursor on 'title' to see all questions.
  *
  *          NUMBER option is used to keep track of the record when the records
  *          wrap.
  *
  *          These work with minor adaptations in sqlite3, see 
  *          Essence.createtable.sql and Essence.insertinto.sql which create
  *          Essence.db  
  *
  *          (S)o (F)ew (W)orkers (G)o (H)ome (O)n time
  *
  *  Created: Thu, 18 Nov 1999 11:55:31 (Bob Heckel)
  * Modified: Tue 17 May 2016 11:45:46 (Bob Heckel)
  *----------------------------------------------------------------------------
  */
options source linesize=110 pagesize=32767;

 /* We're assuming sql_essence1of2.sas has been run */
libname T '~/tmp';

 /*******************************************/
title 'Professor'; proc print data=T.Professor NOOBS; run; 
title 'Student'; proc print data=T.Student NOOBS; run; 
title 'Take'; proc print data=T.Take NOOBS; run; 
title 'Teach'; proc print data=T.Teach NOOBS; run; 
title;data; file PRINT; put '----------------------------------'; run;
 /*******************************************/


title 'Cartesian cross product e.g. 8 professors = 8*8 rows output';
proc sql NOPRINT;
  select *
  from T.professor, T.professor;
quit;

 /*******/


title 'E2 What are sno and sname of students who take CS112? Type 1.';
proc sql NOPRINT;
  select student.sno, student.sname
  from T.student, T.take
  where (student.sno=take.sno) and (take.cno="CS112");
quit;


 /*******/

title 'What is full name and age of profs teaching CS112?';
proc sql NOPRINT;
  select P.fname, P.lname, P.age
  from T.professor as P, T.teach as T
  where (P.fname=T.fname) and (P.lname=T.lname) and (T.cno="CS112");
quit;


 /*******/
title 'What are sno and sname of students who take CS112? (IN version)';
proc sql NOPRINT;
  select sno, sname
  from T.student
  where "CS112" IN(select cno
                   from T.take
                   where (sno=student.sno));
quit;

title 'What are sno and sname of students who take CS112? (EXISTS version)';
proc sql NOPRINT;
  select Sno, Sname
  from T.Student
  where EXISTS (select *
                from T.Take
                where (Sno=Student.Sno) AND (Cno="CS112"));
quit;

title 'What are sno and sname of students who take CS112? (JOIN version)';
proc sql NOPRINT;
  select a.*, b.*
  from T.Student a join T.Take b on a.sno=b.sno
  where b.cno='CS112'
  ;
quit;

 /*******/

title 'E3 Who takes either CS112 or CS114? Type 1.';
proc sql NOPRINT NUMBER;
  select DISTINCT Sno
  from T.Take
  where Cno IN("CS112", "CS114");
quit;

 /*******/

title 'E4 Who takes both CS112 and CS114? (CROSS JOIN self join). Both-And. Type 1.';
proc sql NOPRINT NUMBER;
  select X.Sno
  from T.Take as X, T.Take as Y
  where (X.Sno=Y.Sno)
    and (X.Cno="CS112") and (Y.Cno="CS114");
quit;

title 'E4_2 Who takes both CS112/DD123 and CS114/DD789? (CROSS JOIN self join). Both-And. Type 1.';
proc sql NOPRINT NUMBER;
  select distinct X.Sno
  from T.Take as X, T.Take as Y
  where (X.Sno=Y.Sno)
    and (X.Cno in("CS112","DD123")) and (Y.Cno in("CS114","DD789"));
quit;

 /*******/

title 'Who does not teach CS112? (aka who teaches *some* course that is '
      'different from CS112)';
 /*  Can't use  +  in SAS as can in Access. */
 /* TODO ??? gives wrong results, shows profs who do teach it...concat error??
  * Maybe try the next approach.
  */
proc sql NOPRINT NUMBER FEEDBACK;
  select Fname, Lname
  from T.Professor
  where ( Fname || Lname NOT IN (select Fname || Lname
                                 from T.Teach
                                 where (Cno="CS112")
                                )
        );
quit;

 /* Or (this one appears to work but the Book cautions against it for some
  * reason).
  */
proc sql NOPRINT;
  select Fname, Lname
  from T.Professor
  where ( (Fname NOT IN(select Fname
                        from T.Teach
                        where (Cno="CS112")
                        )
          )
  AND     (Lname NOT IN(select Lname
                        from T.Teach
                        where (Cno="CS112") 
                        )
          )
        );
quit;
 /*******/


 /*******/
title 'Who are students who do not take CS112? (including inactive students)';
proc sql NOPRINT NUMBER;
  select Sno
  from T.Student
  where NOT (Sno IN(select Sno 
                    from T.Take 
                    where (Cno="CS112")));
quit;



title 'Who takes some course but not CS112? (ignoring inactive students)';
proc sql NOPRINT;
  select DISTINCT Sno
  from T.Take
  where NOT (Sno IN(select Sno 
                    from T.Take 
                    where (Cno="CS112")));
quit;
 /*******/


 /*******/

title 'Who teaches CS112?';
proc sql NOPRINT NUMBER;
  select Fname, Lname
  from T.Professor
  where ("CS112" IN(select Cno
                    from T.Teach
                    where (Fname = Professor.Fname)
                      AND (Lname = Professor.Lname)));
quit;

 /*******/

title 'E6 Who takes a course that is not CS112? Type 1. Pseudo negation';
proc sql NOPRINT;
  select DISTINCT Sno
  from T.Take
  where Cno<>"CS112";
quit;

 /*******/
title 'E5 Who does not take CS112? Type 2. Real negation. Find those who DO take it then remove them.';
proc sql NOPRINT;
  select DISTINCT Sno
  from T.Student
  where NOT (sno in (select sno
                     from T.Take
                     where cno='CS112')
            )
  ;
quit;


 /* TODO wrong (a dup of previous query above */
title 'Who does not teach CS112? Type 2. Real negation. Find those who DO take it then remove them. Composite keys.';
proc sql NOPRINT;
  select fname, lname
  from T.Professor
  where (fname || lname NOT in(select fname || lname
                               from T.Teach
                               where cno = "CS112"));
quit;
 /*******/


 /*******/
title 'E7 Who takes at least 2 (i.e. different) courses [Type 1 self join version]?  Equality is transitive.';
proc sql NOPRINT;
  select DISTINCT X.Sno
  from T.Take as X, T.Take as Y
  where (X.Sno=Y.Sno)
    and (X.Cno<>Y.Cno);
quit;

 /* This does not always produce the same results as previous query - doesn't
  * take Cno into account so student 98 who took the same course twice is 
  * incorrectly counted twice
  */
title 'E7 Who takes at least 2 courses [Type 2 HAVING version]?';
proc sql NOPRINT;
  select DISTINCT Sno
  from T.Take
  group by Sno
  having count(*) >= 2;
quit;


title 'E7 Who takes at least 3 (i.e. different) courses? [Type 1 self join version]. Inequality is not transitive.';
proc sql NOPRINT;
  select DISTINCT X.Sno
  from T.Take as X, T.Take as Y, T.Take as Z
  where ((X.Sno=Y.Sno) and (Y.Sno=Z.Sno) 
     and (X.Cno<>Y.Cno) 
     and (Y.Cno<>Z.Cno) 
     and (X.Cno<>Z.Cno));
quit;

title 'Who takes at least 3 courses [Type 2 HAVING version]?';
proc sql NOPRINT;
  select Sno
  from T.Take
  group by Sno
  having count(*)>=3;
quit;


title 'Who takes at least 1 but at most 3 courses?';
proc sql NOPRINT;
  select Sno
  from T.Take
  group by Sno
  having count(*) <= 3;
quit;
 /*******/


title 'E114 Who takes some course (i.e. at least 1) but does NOT take CS112? Real negation.';
proc sql NOPRINT;
  select DISTINCT Sno
  from T.Take
  where NOT (sno in (select sno
                     from T.Take
                     where cno='CS112'))
  ;
quit;


 /*******/
title 'Which courses are taught by at least 2 profs? Composite keys.';
proc sql NOPRINT;
  select DISTINCT X.Cno
  from T.Teach as X, T.Teach as Y
  where (X.Cno=Y.Cno)
    and ((X.Fname<>Y.Fname) or (X.Lname<>Y.Lname));
quit;

title 'Which courses are taught by at least 3 profs? Composite keys. Inequality is not transitive.';
proc sql NOPRINT;
  select X.Cno
  from T.Teach as X, T.Teach as Y, T.Teach as z
  where (X.Cno=Y.Cno) and (Y.cno=Z.cno)
    and ((X.Fname<>Y.Fname) or (X.Lname<>Y.Lname))
    and ((y.Fname<>z.Fname) or (y.Lname<>z.Lname))
    and ((X.Fname<>z.Fname) or (X.Lname<>z.Lname))
    ;
quit;
 /*******/


 /*******/
title 'E8 Who takes at most 2 courses?. I.e. who does NOT take at least 3 courses? Could include students taking 0 courses.';
proc sql NOPRINT;
  select Sno
  from T.Student
  where NOT (Sno IN (select X.Sno
                     from T.Take as X, T.Take as Y, T.Take as Z
                     where ((X.Sno=Y.Sno) AND (Y.Sno=Z.Sno)
                        AND (X.Cno<>Y.Cno)
                        AND (Y.Cno<>Z.Cno)
                        AND (X.Cno<>Z.Cno))));
quit;

title 'Who takes at least 1 but at most 2 courses? Does NOT include students taking 0 courses';
proc sql NOPRINT;
  select Sno
  from T.Take
  group by Sno
  having count(*) <= 2;
quit;

title 'E115 Who takes at least 1 course but at most 2?. Does NOT include students taking 0 courses.';
proc sql NOPRINT;
  select DISTINCT Sno
  from T.Take
  where NOT (Sno IN (select X.Sno
                     from T.Take as X, T.Take as Y, T.Take as Z
                     where ((X.Sno=Y.Sno) AND (Y.Sno=Z.Sno)
                        AND (X.Cno<>Y.Cno)
                        AND (Y.Cno<>Z.Cno)
                        AND (X.Cno<>Z.Cno))));
quit;
 /*******/



 /*******/
title 'E9 Who takes exactly 2 courses? (IN version). I.e. who takes at least 2 courses and does NOT take at least 3 courses.';
proc sql NOPRINT;
  select X.Sno
  from T.Take as X, T.Take as Y
  where (X.Sno=Y.Sno)
         AND (X.Cno<Y.Cno)
         AND NOT (X.Sno IN
                         (select X.Sno
                          from T.Take as X, T.Take as Y, T.Take as Z
                          where (X.Sno=Y.Sno)
                                AND (Y.Sno=Z.Sno)
                                AND (X.Cno<Y.Cno)
                                AND (Y.Cno<Z.Cno)));
quit;

title 'Who takes exactly 2 courses (NOT EXISTS version)?';
proc sql NOPRINT;
  select X.Sno
  from T.Take as X, T.Take as Y
  where (X.Sno = Y.Sno)
        AND (X.Cno < Y.Cno)
        AND NOT EXISTS
                  (select *
                   from T.Take
                   where (Sno = X.Sno)
                         AND (Cno <> X.Cno)
                         AND (Cno <> Y.Cno));
quit;

title 'Who takes exactly 2 courses (HAVING version)?';
proc sql NOPRINT;
  select Sno
  from T.Take
  group by Sno
  having count(*)=2
  ;
quit;
 /*******/


 /*******/
title 'E10 Who takes only CS112? (version 1). I.e. who takes cs112 (E1) and does NOT take a course that is different from cs112 (E6)?';
proc sql NOPRINT;
select Sno           /* E1 */
from T.Take          /* E1 */
where (Cno="CS112")  /* E1 */
       AND NOT (Sno IN(select Sno               /* E6 */
                       from T.Take              /* E6 */
                       where (Cno<>"CS112")));  /* E6 */
quit;

title 'E10 Who takes only CS112? (version 2). I.e. who takes cs112 (E1) and does NOT take a course that is different from cs112 (E6)?';
proc sql NOPRINT;
  select Sno
  from T.Take
  where NOT (Sno IN(select Sno
                    from T.Take
                    where (Cno<>"CS112")));
quit;
 /*******/


title 'E11 Who takes either CS112 or CS114? I.e. who takes cs112 or 114 and does NOT take BOTH 112 AND 114? E3 NOT E4';
proc sql NOPRINT;
  select Sno                                /* E3 */
  from T.Take                               /* E3 */
  where ( (Cno="CS112") OR (Cno="CS114") )  /* E3 - parens are important here! */
    AND NOT (Sno IN                                 /* E4 BOTH-AND */
                    (select X.Sno
                     from T.Take as X, T.Take as Y  /* E4 BOTH-AND */
                     where (X.Sno=Y.Sno)            /* E4 BOTH-AND */
                           AND (X.Cno="CS112")      /* E4 BOTH-AND */
                           AND (Y.Cno="CS114")));   /* E4 BOTH-AND */
quit;


 /*******/
title 'E12 Who are the youngest students? (IN version). I.e. who are NOT among those students who are NOT youngest.';
proc sql NOPRINT;
  select Sno, Age
  from T.Student
  where NOT ( Age IN(select X.Age  /* replacing both Age with Sno would also work */
                     from T.Student as X, T.Student as Y
                     where (X.Age>Y.Age)) );  /* retrieves all ages except the smallest age */
quit;


title 'Who are the oldest students? I.e. who are NOT among those students who are NOT oldest.';
proc sql NOPRINT;
  select Sno, Age
  from T.Student
  where NOT ( Age IN(select X.Age
                     from T.Student as X, T.Student as Y
                     where (X.Age<Y.Age)) );
quit;


title 'E12 Who are the youngest students? (aggregate function version). I.e. who are NOT among those students who are NOT youngest.';
proc sql NOPRINT;
  select Sno
  from T.Student
  where ( Age = (select MIN(Age)
                 from T.Student) );
quit;

title 'E12 Who are the youngest students? (EXISTS version). I.e. who are NOT among those students who are NOT youngest.';
proc sql NOPRINT;
  select Sno
  from T.Student as S
  where NOT EXISTS
                 (select *
                  from T.Student
                  where (Age<S.Age));
quit;
 /*******/

 /*******/
title 'E13 Who takes every course? Cross product style. Type 2.';
proc sql NOPRINT;
  select Sno  /* 3 */
  from T.Student
  where Sno not in
                 (select Sno  /* 2 - those students for whom there IS a course they don't take */
                  /* cross product */
                  from T.Student, T.Course
                  where (Sno || Cno NOT IN  
                                (select Sno || Cno  /* 1 */
                                 from T.Take)));  
quit;

title 'E13 Who takes every course? NOT EXISTS style. Type 2 & 3';
proc sql NOPRINT;
  select Sno
  from T.Student
  where NOT EXISTS
                 (select *
                  from T.Course
                  where (Cno NOT IN
                                (select Cno
                                 from T.Take
                                 where (Sno = Student.Sno))));
quit;
 /*******/


title 'E14 What is avg salary of profs in depts with more than 3 profs';
title2 'who are older than 50?';
proc sql NOPRINT;
  select Dept, avg(Salary)  /* 4 */
  from T.Professor
  where Age>50  /* 1 */
  group by Dept  /* 2 */
  having (count(*)>3);  /* 3 takes a condition as an argument */
quit;



proc sql NOPRINT;
  select Dept, Rank, avg(Salary)
  from T.Professor
  where (Age>50)
  group by Dept, Rank
  having (count(*)>2);
quit;



title 'E15 What is GPA of each student?';
/* Won't run in SAS */
proc sql NOPRINT;
  /*                     carried out on individual values                       */
  /*                     _______________        _______                         */
  select Sno, round( sum(Grade * Credits) / sum(Credits) ) as 'Grade Point Avg'n
  /*                 ____________________   ____________                        */
  /*          ____________________________________________                      */
  /*          carried out after aggregations                                    */
  from T.Take, T.Course
  where Take.Cno=Course.Cno
  group by Sno;
quit;



title 'What is overall avg salary of profs older than 50?';
proc sql NOPRINT;
  select avg(Salary)
  from T.Professor
  where Age > 50;
quit;



title 'What is the avg salary by dept of professors older than 50?';
proc sql NOPRINT;
  select Dept, avg(Salary)
  from T.Professor
  where Age >50
  group by Dept;
quit;



 /*******/
title 'E17 Which profs salary is greater than overall avg?';
proc sql NOPRINT;
  select X.Fname, X.Lname
  from T.Professor as X, T.Professor as Y
  group by X.Fname, X.Lname, X.Salary
  having (X.Salary > avg(Y.Salary));
quit;

title 'E17 Which profs salary is greater than overall avg?';
proc sql NOPRINT;
  select X.Fname, X.Lname
  from T.Professor as X, T.Professor as Y
  group by X.Fname, X.Lname
  having min(X.Salary) > avg(Y.Salary);
quit;

title 'E17 Which profs salary is greater than overall avg?';
proc sql NOPRINT;
  select X.Fname, X.Lname
  from T.Professor as X, T.Professor as Y
  group by X.Fname, X.Lname
  having max(X.Salary) > avg(Y.Salary);
quit;

title 'E17 Which profs salary is greater than overall avg?';
proc sql NOPRINT;
  select Fname, Lname
  from T.Professor
  where (Salary >
                (select avg(Salary)
                 from T.Professor));
quit;
 /*******/


 /*******/
title "E18 Whose salary is greater than the avg within that prof's dept?";
proc sql NOPRINT;
  select X.Fname, X.Lname
  from T.Professor as X, T.Professor as Y
  where X.Dept=Y.Dept
  group by X.Fname, X.Lname, X.Salary
  having (X.Salary > avg(Y.Salary));
quit;

title "E18 Whose salary is greater than the avg within that prof's dept? Type 3.";
proc sql NOPRINT;
  select X.Fname, X.Lname
  from T.Professor as X
  where (Salary > (select avg(Salary)
                   from T.Professor
                   where (Dept=X.Dept)));
quit;
 /*******/


title 'Sort using 2 tables.';
proc sql NOPRINT;
  select Sname, Age
  from T.Student, T.Take
  where ((Student.Sno=Take.Sno)
    and (Cno="CS112"))
  order by 1 DESC , 2 DESC;
quit;



title 'Find where length is within 1% of width.';
proc sql NOPRINT;
  select Rno
  from T.Room
  where (abs(Length - Width) / Width) <= 0.01;
quit;



title "Find each student's highest grade achieved out of all classes ever taken";
proc sql NOPRINT;
  select Sno, max(Grade)
  from T.Take
  group by Sno;
quit;



 /* One of two. */
title "Student's highest grade achieved out of all classes ever taken";
 /* Create a temporary table to do complicated calculation. */
proc sql NOPRINT;
  create view work.fooview as 
    select Sno, max(Grade) as higrade
    from T.Take
    group by Sno;
quit;


 /* Two of two. */
 /* Meaningless output but could be useful? */
title "Student's highest grade achieved used in calculation of a new query";
proc sql NOPRINT;
  select a.sno, a.higrade, b.sno, b.Age, a.higrade*b.Age
  from work.fooview as a, T.student as b
  where a.sno=b.sno
  ;
quit;


title "Inserting a query result into a table (appends, does not replace)";
proc sql NOPRINT;
  select s.sno, sname, round(sum(grade*credits)/sum(credits),2)
  from T.student s, T.take t, T.course c
  where (s.sno=t.sno) and (t.cno=c.cno)
  group by s.sno, sname
  having sum(credits) > 9
  ;
quit;


endsas;
/* Keep only the records with the minimum age */
proc sql;
  create table t as
  select a.*
  from  l.rxfilldata_extra a left join l.rxfilldata_extra b on (a.storeid=b.storeid and a.pharmacypatientid=b.pharmacypatientid and a.age>b.age)
  where b.storeid is null and b.pharmacypatientid is null
  ;
quit;



title "Update";
proc sql NOPRINT;
  update T.Professor
  set salary=salary*1.1, Dept="IT"
  where dept="IS"
  ;
quit;

