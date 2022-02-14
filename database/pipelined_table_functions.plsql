-- Adapted: Fri, Nov 30, 2018  3:57:25 PM (Bob Heckel--devgym.oracle.com)
-- Modified: 10-Feb-2022 (Bob Heckel)
/* See also pass_cursor.plsql table_function.plsql */
/* https://docs.oracle.com/database/121/LNPLS/tuning.htm#LNPLS918 */

/* Pipelined table functions are something of an oddity in PL/SQL: they pass
 * data back to the calling query, even before the function is completed; they
 * don't pass back anything but control with the RETURN statement.
 *
 * Fast: a PTF returns a row to its invoker (a query) with the PIPE ROW statement and
 * then continues to process rows.
 *
 * Efficient: since we no longer declare and populate a nested table to be returned by the
 * function, the amount of PGA needed to run this function goes down dramatically.
 *
 * Only downside: you cannot call a PTF from within PL/SQL itself, it must be in
 * the FROM clause of a SELECT (only normal table functions can be called in PL/SQL) 
 *
 * We could have used a regular table function instead of pipelined – then we would have had to build 
 * the entire output collection before returning it. But if a table function is meant to be used 
 * strictly from SQL and never from PL/SQL, it is almost always a good idea to make it pipelined.
 * We get the ability to quit processing if the client SQL stops fetching rows from the function.
 */

---

CREATE OR REPLACE TYPE num_tab_typ AS TABLE OF NUMBER;
/
CREATE OR REPLACE FUNCTION piped_func(factor IN NUMBER)
  RETURN num_tab_typ PIPELINED
AS
BEGIN
  FOR counter IN 1..1000 LOOP
    PIPE ROW (counter*factor);
  END LOOP;
  RETURN;
END piped_func;
/
SELECT COLUMN_VALUE 
  FROM TABLE(piped_func(2))
 WHERE rownum < 5;

---

 /*
 * A PTF can use a schema-level collection type as its return type, as long as
 * it is a nested table or varray.  Associative arrays (INDEX-BY) are not allowed to be
 * used as the return type.
 */
CREATE OR REPLACE TYPE strings_t IS TABLE OF VARCHAR2(100);
/

/* A pipelined table function returns a row to its invoker (a query) with the PIPE ROW statement 
 * and then continues to process rows
 */
CREATE OR REPLACE FUNCTION strings 
   RETURN strings_t
   PIPELINED
   AUTHID DEFINER
IS
BEGIN
   /* Use PIPE ROW to send the data back to the calling SELECT, instead of adding the data to a local collection
    * (pretend this is in a 1M record fetch loop that populates an object on each iteration).
    */
   PIPE ROW ('abc');
   RETURN;  /* an unqualified RETURN returns nothing but control (no data) */
END;
/

SELECT COLUMN_VALUE my_string FROM TABLE(strings()) WHERE rownum < 9;  -- will be done before the PLSQL looping finishes
/

/* ERROR: non-pipelined table functions can be invoked natively in PL/SQL because
 * they follow the standard model in PL/SQL: execute all code until hitting the
 * RETURN statement or an exception is raised. But when you go with PIPELINED, you
 * give up the ability to call the function in PL/SQL.
 */
DECLARE
   l_strings strings_t := strings_t();
BEGIN
   l_strings := strings();
END;
/

---

-- See also streaming_table_functions.plsql

/******************* Setup *******************/
/* This can be avoided for pipelined table functions https://livesql.oracle.com/apex/livesql/file/tutorial_GS1U5KY647O601AZ0CGDQTKJX.html */
CREATE OR REPLACE PACKAGE stock_mgr AUTHID DEFINER IS
   TYPE stocks_rc_type IS REF CURSOR RETURN stocks%ROWTYPE;
END stock_mgr;
/

CREATE TABLE stocks
(
   ticker        VARCHAR2 (20),
   trade_date    DATE,
   open_price    NUMBER,
   close_price   NUMBER
)
/

/* Load up 10000 rows - when running in your own database, you might want to
   use a higher volume of data here, to see a more dramatic difference in the
   elapsed time and memory utilization 
*/
INSERT INTO stocks
       SELECT 'STK' || LEVEL,
              SYSDATE,
              LEVEL,
              LEVEL + 15
         FROM DUAL
   CONNECT BY LEVEL <= 10000
/   

CREATE TABLE tickers
(
   ticker      VARCHAR2 (20),
   pricedate   DATE,
   pricetype   VARCHAR2 (1),
   price       NUMBER
)
/

CREATE TYPE ticker_ot AS OBJECT
(
   ticker VARCHAR2 (20),
   pricedate DATE,
   pricetype VARCHAR2 (1),
   price NUMBER
);
/

CREATE TYPE tickers_nt AS TABLE OF ticker_ot;
/


/******************* Function *******************/
-- Fetch a row from a cursor variable
-- Apply a transformation to each row
-- Return when done

-- At least one parameter to streaming table functions must be a strong cursor variable.
CREATE OR REPLACE FUNCTION doubled_pl(rows_in stock_mgr.stocks_rc_type)
   RETURN tickers_nt
   PIPELINED
   AUTHID DEFINER
IS
   TYPE stocks_aat IS TABLE OF stocks%ROWTYPE INDEX BY PLS_INTEGER;
   l_stocks   stocks_aat;

   -- Not needed for pipelining, no assignment to a nested table
   --l_doubled   tickers_nt := tickers_nt();
BEGIN
   LOOP
      FETCH rows_in BULK COLLECT INTO l_stocks LIMIT 100;
      EXIT WHEN l_stocks.COUNT = 0;

      FOR l_row IN 1 .. l_stocks.COUNT LOOP
         PIPE ROW (ticker_ot(l_stocks (l_row).ticker,
                             l_stocks (l_row).trade_date,
                             'O',
                             l_stocks (l_row).open_price));

         PIPE ROW (ticker_ot(l_stocks (l_row).ticker,
                             l_stocks (l_row).trade_date,
                             'C',
                             l_stocks (l_row).close_price));
      END LOOP;
   END LOOP;

   RETURN;  -- nothing but control (to the query) is returned
END;
/

/******************* Stream *********************/
INSERT INTO tickers
   SELECT * 
     FROM TABLE (doubled_pl(CURSOR (SELECT * FROM stocks)))
/

SELECT * FROM tickers
 WHERE ROWNUM < 20
/

---

CREATE TABLE stocks2
(
   ticker        VARCHAR2 (20),
   trade_date    DATE,
   open_price    NUMBER,
   close_price   NUMBER
)
/

CREATE OR REPLACE PACKAGE pkg
   AUTHID DEFINER
AS
   TYPE stocks_nt IS TABLE OF stocks2%ROWTYPE;

   FUNCTION stock_rows
      RETURN stocks_nt
      PIPELINED;
END;
/

CREATE OR REPLACE PACKAGE BODY pkg
AS
   FUNCTION stock_rows
      RETURN stocks_nt
      PIPELINED
   IS
      l_stock   stocks2%ROWTYPE;
   BEGIN
      l_stock.ticker := 'ORCL';
      l_stock.open_price := 100;
      PIPE ROW (l_stock);
      RETURN;
   END;
END;
/

SELECT ticker, open_price FROM TABLE (pkg.stock_rows ())
/

-- This is more convenient, but behind the scenes, Oracle Database is creating types implicitly for you, as can see below.
SELECT object_name, object_type
  FROM user_objects
 WHERE object_type IN ('TYPE', 'PACKAGE', 'PACKAGE BODY')
/

---

FUNCTION get_employee_data(in_sql VARCHAR2 DEFAULT 'SELECT * FROM EMPLOYEE_BASE@SEP') RETURN QUOTA_MODELING_TYPES.T_EMPLOYEE_TABLE
	PIPELINED IS
	v_employee_table QUOTA_MODELING_TYPES.T_EMPLOYEE_TABLE;
BEGIN
	EXECUTE IMMEDIATE in_sql BULK COLLECT
		INTO v_employee_table;

	FOR i IN 1 .. v_employee_table.COUNT LOOP
		PIPE ROW (v_employee_table(i));
	END LOOP;

	RETURN;
END;

... CURSOR v_geoSecurityCursor(in_qm_geo_id NUMBER) IS
	SELECT T.*, EB.FIRST_NAME || ' ' || EB.LAST_NAME AS name
		FROM QM_GEO_SECURITY T, table(get_employee_data()) EB
	 WHERE T.EMPLOYEE_ID = EB.EMPLOYEE_ID
...

---

-- Won't work in a package
create or REPLACE function f_search_view (par_string in varchar2)
    return sys.odcivarchar2list
    pipelined
  is
  begin
    for cur_r in (select view_name, text 
                  from all_views
                  where text_length < 32767)
    loop
      if instr(cur_r.text, par_string) > 0 then
         pipe row (cur_r.view_name);
      end if;
    end loop;

    return;
  end;

select * from table(f_search_view('CAE'));

DROP FUNCTION f_search_view

---

CREATE OR REPLACE PACKAGE SCHEDULER_PERC_ALERTS_TYPES AUTHID DEFINER IS
  TYPE rt_perc_alert IS RECORD (
    job_name             VARCHAR(32767),
    job_action           VARCHAR(32767),
    status               VARCHAR(32767),
    last_run_duration    INTERVAL DAY(9) TO SECOND(6),
    time_since_last_run  INTERVAL DAY(9) TO SECOND(6),
    last_start_date      TIMESTAMP(6) WITH TIME ZONE,
    next_run_date        TIMESTAMP(6) WITH TIME ZONE
  );

  TYPE t_perc_alert1 IS TABLE OF rt_perc_alert;
END;
/
CREATE OR REPLACE PACKAGE BODY SCHEDULER_PERC_ALERTS_TYPES IS
END;
/
CREATE OR REPLACE PACKAGE SCHEDULER_PERC_ALERTS AUTHID DEFINER IS
  /* CreatedBy: bheck
   *   Created: 13-Nov-19
   *   Purpose: Leverage AUTHID DEFINER and pipelining to allow non-SETARS
   *            access to job scheduler views. This approach avoids permission
   *            failures generated when using views to access USER_SCHEDULER_JOBS
   *            instead of DBA_SCHEDULER_JOBS. But access to DBA_SCHEDULER_JOBS
   *            also won't work because SETARS lacks admin rights on that view
   *            too (RION-37368)
   *    Change: 16-Jul-20 bheck - View RION_PERC_ALERT1_V is invalid post-upgrade
   *            to 18c (RION-45894)
   */
  FUNCTION perc_alert1 RETURN SCHEDULER_PERC_ALERTS_TYPES.t_perc_alert1 PIPELINED;
END SCHEDULER_PERC_ALERTS;
/
CREATE OR REPLACE PACKAGE BODY SCHEDULER_PERC_ALERTS IS
  FUNCTION perc_alert1 RETURN SCHEDULER_PERC_ALERTS_TYPES.t_perc_alert1 PIPELINED AS
    CURSOR c1 IS
      SELECT job_name,
             job_action,
             CASE WHEN (state = 'SCHEDULED' AND last_run_duration IS NOT NULL) THEN 'CLEAR' ELSE 'ALERT' END AS status,
             last_run_duration,
             CAST(SYSDATE - last_start_date AS INTERVAL DAY(9) TO SECOND(6)) AS time_since_last_run,
             last_start_date,
             next_run_date
        FROM USER_SCHEDULER_JOBS 
       WHERE enabled = 'TRUE';

  BEGIN
    FOR r IN c1 LOOP
      PIPE ROW (r);
    END LOOP;
    RETURN;
  END;
END SCHEDULER_PERC_ALERTS;
/

select * from table(SCHEDULER_PERC_ALERTS.perc_alert1);

create or replace force view RION_PERC_ALERT1_V as  select * from table(SCHEDULER_PERC_ALERTS.perc_alert1);

---

-- Call function from a select statement 12c+
WITH FUNCTION fun_with_plsql(p_sal NUMBER) RETURN NUMBER IS
BEGIN
  RETURN (p_sal * 12);
END;

SELECT ename, deptno, fun_with_plsql(sal) "annual_sal" FROM emp

---

-- Comma separated list in column to rows
-- Adapted: 03-Apr-2020 (Bob Heckel -- Practical Oracle SQL Kim Berg Hansen)
create or replace package bob_pkg as
  type favorite_coll_type is table of integer;
end;

create or replace package body bob_pkg as
  function favorite_list_to_coll_type (
     p_favorite_list   in customer_favorites.favorite_list%type
  )
     return favorite_coll_type PIPELINED
  is
     v_from_pos  pls_integer;
     v_to_pos    pls_integer;
  begin
     if p_favorite_list is not null then
        v_from_pos := 1;
        loop
           v_to_pos := instr(p_favorite_list, ',', v_from_pos);
           PIPE ROW (to_number(
              substr(
                 p_favorite_list
               , v_from_pos
               , case v_to_pos
                    when 0 then length(p_favorite_list) + 1
                           else v_to_pos
                 end - v_from_pos
              )
           ));
           exit when v_to_pos = 0;
           v_from_pos := v_to_pos + 1;
        end loop;
     end if;
  end favorite_list_to_coll_type;
end;

-- as admin: grant create public SYNONYM to unit_test_repos
create public SYNONYM favorite_list_to_coll_type for  bob_pkg.favorite_list_to_coll_type

select
   cf.customer_id
   -- keyword
 , fl.COLUMN_VALUE as product_id
from customer_favorites cf
     -- Takes a collection (nested table) and turns the elements of the collection into rows
   , table(
        favorite_list_to_coll_type(cf.favorite_list)
     ) fl
order by cf.customer_id, fl.COLUMN_VALUE;

SELECT * FROM favorite_list_to_coll_type('1,2,3');
