
CREATE TABLE t AS SELECT * FROM salesgroup@rion_test;

      SELECT UTC.COLUMN_NAME, UTC.DATA_LENGTH, UTC.DATA_TYPE
        FROM USER_TAB_COLS UTC
       WHERE UTC.TABLE_NAME = UPPER('t')
         AND UTC.USER_GENERATED = 'YES'
         AND HIDDEN_COLUMN = 'NO'
         AND VIRTUAL_COLUMN = 'NO'
         AND DATA_TYPE LIKE '%CHAR%'
         ;--AND COLUMN_NAME != 'SDM_BUSINESS_KEY';
         
  create or replace PROCEDURE change_lengths(in_table_name VARCHAR2) IS
    v_count      NUMBER := 0;
    v_max_length NUMBER;

    CURSOR colCursor IS
      SELECT UTC.COLUMN_NAME, UTC.DATA_LENGTH, UTC.DATA_TYPE
        FROM USER_TAB_COLS UTC
       WHERE UTC.TABLE_NAME = UPPER(in_table_name)
         AND UTC.USER_GENERATED = 'YES'
         AND HIDDEN_COLUMN = 'NO'
         AND VIRTUAL_COLUMN = 'NO'
         AND DATA_TYPE LIKE '%CHAR%'
         ;--AND COLUMN_NAME != 'SDM_BUSINESS_KEY';

  BEGIN
    FOR colRec IN colCursor LOOP
      v_count := v_count + 1;

      EXECUTE IMMEDIATE 'CREATE INDEX ' || in_table_name || 'IX' || v_count ||
                        ' on ' || in_table_name || ' (lengthb(' ||
                        colRec.column_name || ')) PARALLEL 16 NOLOGGING';

      EXECUTE IMMEDIATE 'ALTER INDEX ' || in_table_name || 'IX' || v_count ||
                        ' NOPARALLEL LOGGING';

      EXECUTE IMMEDIATE 'select max(lengthb(' || colRec.column_name ||
                        ')) from ' || in_table_name
        INTO v_max_length;

      EXECUTE IMMEDIATE 'DROP INDEX ' || in_table_name || 'IX' || v_count;

      IF (v_max_length < colRec.data_length) THEN
        EXECUTE IMMEDIATE 'ALTER TABLE ' || in_table_name || ' MODIFY ' ||
                          colRec.column_name || ' ' || colRec.data_type || '(' ||
                          v_max_length || ')';
      END IF;
    END LOOP;
  END ;

exec change_lengths('t');

drop table t;

---


CREATE TABLE t AS SELECT salesgroup FROM salesgroup;
create materialized view tmv as select * from t;
desc t
desc tmv

alter table t modify salesgroup varchar2(10);
alter materialized view tmv modify salesgroup varchar2(10);
desc t
desc tmv

exec change_lengths_1667('t');
exec change_lengths_1667('tmv');
desc t
desc tmv

drop table t;
drop materialized view tmv;
