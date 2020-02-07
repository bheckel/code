BEGIN;
ALTER TABLE dshbrd.dashboardclients ADD COLUMN deactivated boolean NOT NULL DEFAULT FALSE;
ALTER TABLE dshbrd.dashboardclients ADD COLUMN version integer;

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
-- Oracle
/* ALTER TABLE peoples ADD hatred NUMBER; */

/* Rename peoples back to person. */
ALTER TABLE peoples RENAME TO person;

.schema person



ALTER TABLE Customer DROP COLUMN Birth_Date;


-- No COMMIT required
