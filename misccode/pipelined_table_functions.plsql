/* Adapted: Fri, Nov 30, 2018  3:57:25 PM (Bob Heckel--devgym.oracle.com) */ 

CREATE OR REPLACE TYPE strings_t IS TABLE OF VARCHAR2 (100);
/

CREATE OR REPLACE FUNCTION strings 
   RETURN strings_t PIPELINED
   AUTHID DEFINER
IS
BEGIN
   /* Use PIPE ROW to send the data back to the calling SELECT, instead of adding the data to a local collection */
   PIPE ROW ('abc');
   /* RETURN nothing but control */
   RETURN;
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

CREATE OR REPLACE PACKAGE stock_mgr AUTHID DEFINER IS
   TYPE stocks_rc_type IS REF CURSOR RETURN stocks%ROWTYPE;
   TYPE tickers_rc_type IS REF CURSOR RETURN tickers%ROWTYPE;
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

CREATE OR REPLACE FUNCTION doubled_pl(rows_in stock_mgr.stocks_rc_type)
   RETURN tickers_nt
   PIPELINED
   AUTHID DEFINER
IS
   TYPE stocks_aat IS TABLE OF stocks%ROWTYPE INDEX BY PLS_INTEGER;
   l_stocks   stocks_aat;
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

   RETURN;
END;
/

SELECT COUNT(*) FROM tickers
/

/******************* Stream *********************/
INSERT INTO tickers
   SELECT * 
     FROM TABLE (doubled_pl(CURSOR (SELECT * FROM stocks)))
/

SELECT * FROM tickers
 WHERE ROWNUM < 20
/
