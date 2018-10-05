---

http://zetcode.com/db/sqlite/introduction/

---

-- Paste or save statements below a t.sql then:
$ sqlite3
sqlite> .read t.sql
sqlite> .tables  --verify success

-- Or start existing:
$ sqlite3 /home/rsh86800/code/misccode/essenceofSQL.db

-- Or start new:
$ sqlite3 movies.db

-- Or from commandline:
$ sqlite3 rating.db <ratingINSERTs.sql
$ sqlite3 <ratingCreateInsertAndQueries.sql
$ sqlite3 -header <ratingCreateInsertAndQueries.sql

-----------------------------------------------
-- Save this as t.sql then .read t.sql

BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS Actors(AId integer primary key autoincrement, Name text);
INSERT INTO Actors VALUES(1,'Philip Seymour Hofman');
INSERT INTO Actors VALUES(2,'Kate Shindle');
INSERT INTO Actors VALUES(3,'Kelci Stephenson');
INSERT INTO Actors VALUES(4,'Al Pacino');
INSERT INTO Actors VALUES(5,'Gabrielle Anwar');
INSERT INTO Actors VALUES(6,'Patricia Arquette');
INSERT INTO Actors VALUES(7,'Gabriel Byrne');
INSERT INTO Actors VALUES(8,'Max von Sydow');
INSERT INTO Actors VALUES(9,'Ellen Burstyn');
INSERT INTO Actors VALUES(10,'Jason Miller');
COMMIT;

BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS Movies(MId integer primary key autoincrement, Title text);
INSERT INTO Movies VALUES(1,'Capote');
INSERT INTO Movies VALUES(2,'Scent of a woman');
INSERT INTO Movies VALUES(3,'Stigmata');
INSERT INTO Movies VALUES(4,'Exorcist');
INSERT INTO Movies VALUES(5,'Hamsun');
COMMIT;

BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS ActorsMovies(Id integer primary key autoincrement, 
                          AId integer, MId integer);
INSERT INTO ActorsMovies VALUES(1,1,1);
INSERT INTO ActorsMovies VALUES(2,2,1);
INSERT INTO ActorsMovies VALUES(3,3,1);
INSERT INTO ActorsMovies VALUES(4,4,2);
INSERT INTO ActorsMovies VALUES(5,5,2);
INSERT INTO ActorsMovies VALUES(6,6,3);
INSERT INTO ActorsMovies VALUES(7,7,3);
INSERT INTO ActorsMovies VALUES(8,8,4);
INSERT INTO ActorsMovies VALUES(9,9,4);
INSERT INTO ActorsMovies VALUES(10,10,4);
INSERT INTO ActorsMovies VALUES(11,8,5);
COMMIT;

create table dummy as select * from movies LIMIT 4;
alter table dummy rename to dummy2;
alter table dummy2 add column email text;
-----------------------------------------------

Poke around the schema:

sqlite> .show -- current settings
sqlite> .databases
sqlite> .tables
sqlite> .schema  -- view CREATE TABLEs
sqlite> .dump
sqlite> .dump movie
select * from friend limit 10;  -- like Oracle ROWNUM
sqlite> .separator
sqlite> .exit  -- quit
sqlite> .ex  -- quit
sqlite> .q  -- quit

-- This is maybe better stored in ~/.sqliterc:
sqlite> .separator :
sqlite> .mode column  -- switch from delimiter-separted print to screen
sqlite> .headers on
sqlite> .width 22, 18  -- e.g. a 2 column output

-- Save structure & data of a db to file (if not using BEGIN TRANSACTION; ... COMMIT;):
sqlite> .output mysaveddb.sql
sqlite> .dump mytbl  -- these CREATEs and INSERTs are written to the .sql file
-- Come back later and run to restore entire db:
sqlite> .read mysaveddb.sql

-- SELECTs will now produce HTML output:
$ sqlite3 -html test.db

$ tail ~/.sqlite_history

sqlite> SELECT 'wolf' || 'hound';  -- wolfhound
sqlite> SELECT 'Tom' IN ('Tom', 'Frank', 'Jane');  -- 1
sqlite> DELETE FROM Books2 WHERE Id=1;
-- Range subset rows 3 thru 6
sqlite> SELECT * FROM Cars LIMIT 2, 4;
-- Same, start at 3, go thru 6
sqlite> SELECT * FROM Cars LIMIT 4 OFFSET 2;

-- All 3 INNER joins are the same:
sqlite> SELECT Name, Day FROM Cust, Reser WHERE Cust.CustId=Reser.CustId;
sqlite> SELECT Name, Day FROM Cust AS C JOIN Reser AS R ON C.CustId=R.CustId;
-- Caution: if no matching columns, you get a CROSS JOIN
sqlite> SELECT Name, Day FROM Cust NATURAL JOIN Reser;

-- Functions:
sqlite> SELECT random() AS Random;
sqlite> SELECT date('now', '-55 days');
sqlite> SELECT strftime('%d-%m-%Y');
-- First Thursday in November of current year:
sqlite> SELECT date('now', 'start of year', '10 months', 'weekday 4');

sqlite> CREATE VIEW CheapCars AS SELECT Name FROM Cars WHERE Cost < 30000;
sqlite> DROP VIEW CheapCars;

sqlite> CREATE TABLE Log(Id INTEGER PRIMARY KEY, OldName TEXT, NewName TEXT, Date TEXT);
CREATE TRIGGER mytrigger UPDATE OF Name ON Friends
BEGIN;
  INSERT INTO Log(OldName, NewName, Date) VALUES (old.Name, new.Name, datetime('now'));
END;
-- Trigger pulled, Log inserts 'Franken' 'Frank' '2013-01-09 23:38:29':
sqlite> UPDATE Friends SET Name='Frank' WHERE Id=3;

---

ex1.sql:
~~~~~~~~~~~~~~~~~~~~~~~~
CREATE TABLE person (
    id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    age INTEGER
);
CREATE TABLE person_pet (
    person_id INTEGER,
    pet_id INTEGER
);
CREATE TABLE pet (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT,
    age INTEGER,
    dead INTEGER
);

INSERT INTO person (id, first_name, last_name, age) VALUES (0, "Zed", "Shaw", 37);
INSERT INTO pet (id, name, breed, age, dead)VALUES (0, "Fluffy", "Unicorn", 1000, 0);
INSERT INTO pet VALUES (1, "Gigantor", "Robot", 1, 1);
INSERT INTO person_pet (person_id, pet_id) VALUES (0, 0);
INSERT INTO person_pet VALUES (0, 1);
~~~~~~~~~~~~~~~~~~~~~~~~

sqlite> select * from person where first_name != 'Zed';
sqlite> DELETE FROM pet WHERE dead = 1;
sqlite> UPDATE person SET first_name = "Hilarious Guy" WHERE first_name = "Zed";

---

-- Transactions:

$ sqlite3 rating  -- rating.db doesn't exist yet
sqlite> BEGIN;  -- start a transaction
sqlite> .read ratingINSERTs.sql
sqlite> ROLLBACK;  -- if failures occurred, or just .q 
sqlite> COMMIT;  -- if success
sqlite> .exit

---

-- Import load readin delimited file to a temporary db:

$ sqlite3
sqlite> create table teach (fname text, lname text, cno text);
sqlite> .separator |
sqlite> .import Teach.txt teach  -- automatic INSERT INTOs written
sqlite> .q  -- All Is Lost

---

$ vi cfg.txt
80000000089319
80000000089323
80000000099999
$ vi gdm.txt
80000000089319
80000000089323

$ sqlite3
create table cfg (mat);
.import cfg.txt cfg
create table gdm (mat);
.import gdm.txt gdm
select * from cfg a left join gdm b on a.mat=b.mat;
.q

---

-- Specific to the user, dropped at db connection close. It's a static copy.
create TEMP table foo as select * from course where cno='CS112';
-- It's fully dynamic, regenerated each time it's queried.
create TEMP view foo as select * from course where cno='CS112';

delete from course;  -- fast truncation of table
delete from course where 1;  -- row by row deletions

SELECT 1+1, 5*32, 'abc'||'def', 1>2;  -- test out expressions
