/* Adapted: Fri, Nov 30, 2018  3:57:25 PM (Bob Heckel--devgym.oracle.com) */ 

/* Pipelined table functions are something of an oddity in PL/SQL: they pass
 * data back to the calling query, even before the function is completed; they
 * don't pass back anything but control with the RETURN statement.
 *
 * Fast: a PTF returns a row to its invoker (a query) with the PIPE ROW statement and
 * then continues to process rows.
 *
 * Efficient: since we no longer declare and populate a nested table to be returned by the
 * function, the amount of PGA needed to run this function goes down
 * dramatically.
 *
 * Only downside: you cannot call a PTF from within PL/SQL itself, it must be in
 * the FROM clause of a SELECT (only normal table functions can be called in PL/SQL) 
 */

/* A PTF can use a schema-level collection type as its return type, as long as
 * it is a nested table or varray.  Associative arrays (INDEX-BY) are not allowed to be
 * used as the return type.
 */
CREATE OR REPLACE TYPE strings_t IS TABLE OF VARCHAR2(100);
/

/* A pipelined table function returns a row to its invoker (a query) with the PIPE ROW statement and then continues to process rows */
CREATE OR REPLACE FUNCTION strings 
   RETURN strings_t
   PIPELINED
   AUTHID DEFINER
IS
BEGIN
   /* Use PIPE ROW to send the data back to the calling SELECT, instead of adding the data to a local collection */
   PIPE ROW ('abc');
   RETURN;  /* return nothing (no data) but control */
END;
/

SELECT COLUMN_VALUE my_string FROM TABLE (strings())
/

/* ERROR: non-pipelined table functions can be invoked natively in PL/SQL, since
 * they follow the standard model in PL/SQL: execute all code until hitting the
 * RETURN statement or an exception is raised. But when you go with PIPELINED, you
 * give up the ability to call the function in PL/SQL
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
