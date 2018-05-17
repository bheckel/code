BEGIN;
ALTER TABLE dshbrd.dashboardclients ADD COLUMN deactivated boolean NOT NULL DEFAULT FALSE;
ALTER TABLE dshbrd.dashboardclients ADD COLUMN version integer;
COMMIT;



 /* http://sql.learncodethehardway.org/book/ex12.html */

/* Only drop table if it exists. */
DROP TABLE IF EXISTS person;

/* Create again to work with it. */
CREATE TABLE person (
    id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    age INTEGER
);

/* Rename the table to peoples. */
ALTER TABLE person RENAME TO peoples;

/* Add a hatred column to peoples. */
ALTER TABLE peoples ADD COLUMN hatred INTEGER;

/* Rename peoples back to person. */
ALTER TABLE peoples RENAME TO person;

.schema person



ALTER TABLE Customer DROP COLUMN Birth_Date;
