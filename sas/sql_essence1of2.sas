 /*---------------------------------------------------------------------------
  *    Name: sql_essence1of2.sas
  *
  * Summary: Read in exported Access tables and build SAS datasets to be
  *          used by sql2of2.sas
  *
  *          !! Run this prior to running sql_essence2of2.sas !!
  *
  * Created: Thu, 18 Nov 1999 11:55:31 (Bob Heckel)
  * Modified: Fri 24 Mar 2006 12:08:30 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options linesize=82 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        ;

libname BOBH '~/tmp';

data BOBH.course;
  /* Exported from sql_essence.mdb */
  /* This informat not required: */
  ***informat cno $4. title $10. credit;
  /* dsd -- consecutive delims indicate missing values (also strips " ) */
  infile "$HOME/code/sas/Course.txt" DSD DELIMITER='|';
  input cno $  title $  credits;
run;

data BOBH.professor;
  /* Required on this one since lnames can be > 8 chars */
  informat fname $12.  lname $12.  dept  rank $10.  salary  age;
  /* MISSOVER required -- missing value causes SAS "to go to a new line when
   * input statement reached past the end of a line"  The line after the one
   * with the null was skipped until I used MISSOVER.
   */
  infile "$HOME/code/sas/Professor.txt" DSD DELIMITER='|' MISSOVER;
  input fname $  lname $  dept  rank $  salary  age;
run;

data BOBH.room;
  informat rno  length  width;
  /* DSD not needed. */
  infile "$HOME/code/sas/Room.txt" dlm='|';
  input rno  length  width; 
run;
  
data BOBH.student;
  informat sno  sname $25.  age;
  infile "$HOME/code/sas/Student.txt" dsd delimiter='|';
  input sno  sname $  age;
run;

data BOBH.take;
  informat sno  cno $10.  grade;
  infile "$HOME/code/sas/Take.txt" dsd delimiter='|';
  input sno  cno $  grade; 
run;

data BOBH.teach;
  informat fname $10.  lname $15.  cno $5.;
  infile "$HOME/code/sas/Teach.txt" dsd delimiter='|';
  list;
  input fname $  lname $  cno $;
run;


/* See sql_essence2of2.sas for queries... */
