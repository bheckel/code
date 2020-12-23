-----------------------------------
-- Adapted: 23-Dec-2020 (Bob Heckel--https://oracle-base.com/articles/11g/dbms_comparison-identify-row-differences-between-objects)
-----------------------------------
set serveroutput on

BEGIN
  DBMS_COMPARISON.drop_comparison(
    comparison_name => 'test_cmp_1');
END;
/
DROP TABLE local_user.tab1 PURGE;
DROP TABLE remote_user.tab1 PURGE;
DROP USER local_user CASCADE;
DROP USER remote_user CASCADE;

-- Create schemas to compare
CREATE USER local_user IDENTIFIED BY Mypwoknowokok1 QUOTA UNLIMITED on data;
GRANT CREATE SESSION, CREATE VIEW, CREATE MATERIALIZED VIEW, CREATE SYNONYM TO local_user;
GRANT EXECUTE ON DBMS_COMPARISON TO local_user;

CREATE USER remote_user IDENTIFIED BY Mypwoknowokok1 QUOTA UNLIMITED on data;
GRANT CREATE SESSION, CREATE VIEW, CREATE MATERIALIZED VIEW, CREATE SYNONYM TO remote_user;


CREATE TABLE local_user.tab1 (
  id            NUMBER NOT NULL,
  description   VARCHAR2(50),
  created_date  DATE,
  CONSTRAINT tab1_pk PRIMARY KEY (id)
);

INSERT INTO local_user.tab1
SELECT level,
       'Description for ' || level,
       TRUNC(SYSDATE) - level
FROM   dual
CONNECT BY level <= 10;
COMMIT;


CREATE TABLE remote_user.tab1 (
  id            NUMBER NOT NULL,
  description   VARCHAR2(50),
  created_date  DATE,
  CONSTRAINT tab1_pk PRIMARY KEY (id)
);

INSERT INTO remote_user.tab1
SELECT level,
       'Description for ' || level,
       TRUNC(SYSDATE) - level
FROM   dual
CONNECT BY level <= 5;
COMMIT;

GRANT SELECT, INSERT, UPDATE, DELETE ON remote_user.tab1 TO local_user;

SELECT * FROM local_user.tab1;
SELECT * FROM remote_user.tab1;


BEGIN
  DBMS_COMPARISON.create_comparison (
    comparison_name    => 'test_cmp_1',
    schema_name        => 'local_user',
    object_name        => 'tab1',
    dblink_name        => NULL,
    remote_schema_name => 'remote_user',
    remote_object_name => 'tab1');
END;
/
DECLARE
  l_scan_info  DBMS_COMPARISON.comparison_type;
  l_result     BOOLEAN;
BEGIN
  l_result := DBMS_COMPARISON.compare (
                comparison_name => 'test_cmp_1',
                scan_info       => l_scan_info,
                perform_row_dif => TRUE
              );

  IF NOT l_result THEN
    DBMS_OUTPUT.put_line('Differences found. scan_id=' || l_scan_info.scan_id);
  ELSE
    DBMS_OUTPUT.put_line('No differences found.');
  END IF;
END;--scan_id=1 or next qry:
/
SELECT scan_id
FROM   user_comparison_scan
WHERE  comparison_name = 'TEST_CMP_1'
AND    parent_scan_id IS NULL;
/
SELECT comparison_name,
       scan_id,
       status,
       current_dif_count,
       count_rows
FROM   user_comparison_scan_summary
WHERE  scan_id = 9;--test_cmp_1
/
-- Confirm we looked at all the columns
SELECT comparison_name,
       column_position,
       column_name,
       index_column
FROM   user_comparison_columns
WHERE  comparison_name = 'TEST_CMP_1'
ORDER BY column_position;--column_name: id description created_date
/
-- Show the diff records
SELECT comparison_name,
       local_rowid,
       remote_rowid,
       status
FROM   user_comparison_row_dif
WHERE  comparison_name = 'TEST_CMP_1';--5rec
/
--SELECT * FROM local_user.tab1 where rowid='AAAiR5AAAAABAbcAAF';
-- Repair by making remote_user.tab1 look like  local_user.tab1:
DECLARE
  l_scan_info  DBMS_COMPARISON.comparison_type;
  l_result     BOOLEAN;
BEGIN
  DBMS_COMPARISON.converge (
    comparison_name  => 'test_cmp_1',
    scan_id          => 9,
    scan_info        => l_scan_info,
    converge_options => DBMS_COMPARISON.cmp_converge_local_wins, -- Default
    perform_commit   => FALSE  -- ?why commits?
  );

  DBMS_OUTPUT.put_line('scan_id          = ' || l_scan_info.scan_id);
  DBMS_OUTPUT.put_line('loc_rows_merged  = ' || l_scan_info.loc_rows_merged);
  DBMS_OUTPUT.put_line('rmt_rows_merged  = ' || l_scan_info.rmt_rows_merged);
  DBMS_OUTPUT.put_line('loc_rows_deleted = ' || l_scan_info.loc_rows_deleted);
  DBMS_OUTPUT.put_line('rmt_rows_deleted = ' || l_scan_info.rmt_rows_deleted);
END;
/
