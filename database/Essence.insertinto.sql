
--         Existing empty db file from CREATE statements in Essence.createtable.sql
--         __________
-- sqlite3 Essence.db
-- .read /cygdrive/u/code/misccode/Essence.insertinto.sql

-- To query:
-- sqlite> .read Essence.insertinto.sql

-- DDL

BEGIN TRANSACTION;
--                  ______optional_______
INSERT INTO "course"(cno, title, credits) VALUES('CS112','Accounting' ,5);
INSERT INTO "course"(cno, title, credits) VALUES('CS114','Math',10);
INSERT INTO "course"(cno, title, credits) VALUES('CS116','Science',12);
INSERT INTO "course"(cno, title, credits) VALUES('CX123','Chemistry',1);
INSERT INTO "course"(cno, title, credits) VALUES('DD123','Programming',12);
INSERT INTO "course"(cno, title, credits) VALUES('DD456','Basketweaving',10);
INSERT INTO "course"(cno, title, credits) VALUES('DD789','Dummyclass',5);
INSERT INTO professor VALUES('Fnamer','Addefourteen','IS','Tenured',9000,53);
INSERT INTO professor VALUES('Loncs','Dontteachit','IS','Tenured',50000,60);
INSERT INTO professor VALUES('Liamteach','Ialso','HIS','Tenured',60000,59);
INSERT INTO professor VALUES('Joe','Iteachit','MUS','Fired',70000,58);
INSERT INTO professor VALUES('Charles','Metoorich','MUS','Fired',80000,93);
INSERT INTO professor VALUES('Nulllquirk','Nullf','FOO','Fired',10000,'');
INSERT INTO professor VALUES('Prof','Rich','BAR','Tenured',201000,51);
INSERT INTO professor VALUES('Bo','Whydontshow','IS','Lazy',39000,62);
INSERT INTO "student" VALUES('1','studnA',30);
INSERT INTO "student" VALUES('2','studnB',98);
INSERT INTO "student" VALUES('3','studnC',98);
INSERT INTO "student" VALUES('4','studnD',22);
INSERT INTO "student" VALUES('5','studnE',18);
INSERT INTO "student" VALUES('32','takeemall',39);
INSERT INTO "student" VALUES('88','studnfnoclass',18);
INSERT INTO "student" VALUES('99','gretzky',38);
INSERT INTO "take" VALUES('1','CS112',2);
INSERT INTO "take" VALUES('1','CS114',4);
INSERT INTO "take" VALUES('2','CS112',3);
INSERT INTO "take" VALUES('3','CX123',1);
INSERT INTO "take" VALUES('4','CS114',2);
INSERT INTO "take" VALUES('4','CS116',4);
INSERT INTO "take" VALUES('5','DD123',1);
INSERT INTO "take" VALUES('5','DD456',2);
INSERT INTO "take" VALUES('5','DD789',3);
INSERT INTO "take" VALUES('32','CS112',4);
INSERT INTO "take" VALUES('32','CS114',0);
INSERT INTO "take" VALUES('32','CS116',0);
INSERT INTO "take" VALUES('32','CX123',0);
INSERT INTO "take" VALUES('32','DD123',0);
INSERT INTO "take" VALUES('32','DD456',0);
INSERT INTO "take" VALUES('32','DD789',0);
INSERT INTO "take" VALUES('99','CS112','D');
INSERT INTO "teach" VALUES('Liamteach','Ialso','CS112');
INSERT INTO "teach" VALUES('Joe','Iteachit','CS112');
INSERT INTO "teach" VALUES('Joe','Iteachit','CX000');
INSERT INTO "teach" VALUES('Charles','Metoorich','CS112');
INSERT INTO "teach" VALUES('Prof','Rich','CX000');
COMMIT;
