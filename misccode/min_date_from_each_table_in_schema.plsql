-- Created: 08-Aug-19 (Bob Heckel)
create or replace PACKAGE BODY RION39366 IS

  PROCEDURE do IS

    mindt DATE;

    CURSOR c1 IS
      SELECT table_name, low_value
        FROM user_tab_columns
       WHERE table_name IN(
         SELECT table_name
           FROM user_tables
          WHERE table_name NOT LIKE 'BDG%'
            AND table_name NOT LIKE '%CMK'
            AND table_name NOT LIKE '%\_OLD' ESCAPE '\'
            AND table_name NOT LIKE '%\_BKUP'  ESCAPE '\'
            AND NOT regexp_like(table_name, '.*\d+$')
            AND NOT regexp_like(table_name, '^S\d+')
        )
          AND column_name = 'CREATED'
        ORDER BY 1
      ;

    BEGIN

       FOR c1rec IN c1 LOOP
         dbms_stats.convert_raw_value(hextoraw(c1rec.LOW_VALUE), mindt);

         IF mindt < '01JAN1970' THEN
           dbms_output.put_line(c1rec.table_name || ' ' || to_char(mindt, 'DD-MON-YYYY'));
         END IF;
       END LOOP;

    END do;
END;
