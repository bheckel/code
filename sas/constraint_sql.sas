options nosource;
 /*---------------------------------------------------------------------------
  *     Name: constraint_sql.sas
  *
  *  Summary: Demo of using integrity constraints with proc sql.
  *
  *  Adapted: Tue 21 Jan 2003 16:38:48 (Bob Heckel --
  *                                     C:\bookshelf_sas\lrcon\z0403555.htm)
  *---------------------------------------------------------------------------
  */
options source;

proc sql;                       
  create table one (
    name   char(14),
    CONSTRAINT prim_key  primary key(name)
  );
quit;

proc sql;
  create table two (
   lname   char(14),
   CONSTRAINT for_key  foreign key(lname) references one on delete 
                                                restrict on update set null
  );
quit;

proc sql;
  insert into one values('Bob');
  insert into one values('Bobagain');
  insert into two values('Bob');
quit;
 
proc print data=one; run;
