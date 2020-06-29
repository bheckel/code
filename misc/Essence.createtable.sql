
--         New file
--         __________
-- sqlite3 Essence.db
-- .read /cygdrive/u/code/misccode/Essence.createtable.sql

-- DDL

BEGIN TRANSACTION;
---CREATE TABLE course (cno TEXT PRIMARY KEY, title TEXT, credits INTEGER);
-- More secure but need e.g. DROP TABLE course if re-running:
CREATE TABLE IF NOT EXISTS course (cno TEXT PRIMARY KEY, title TEXT, credits INTEGER);
CREATE TABLE IF NOT EXISTS professor (fname TEXT, lname TEXT, dept TEXT, rank TEXT, salary INTEGER, age INTEGER);
CREATE TABLE IF NOT EXISTS student (sno TEXT, sname TEXT, age INTEGER);
CREATE TABLE IF NOT EXISTS take (sno TEXT, cno TEXT, grade INTEGER);
CREATE TABLE IF NOT EXISTS teach (fname TEXT, lname TEXT, cno TEXT);
CREATE TABLE IF NOT EXISTS seniors (sno TEXT, sname TEXT, credits INTEGER);
--CREATE UNIQUE INDEX Student_ndx ON Student(Sno);
COMMIT;
