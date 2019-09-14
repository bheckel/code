/* Adapted: Thu, Nov 29, 2018  2:33:18 PM (Bob Heckel -- https://devgym.oracle.com) */

/* See also pipelined_table_functions.plsql */

/* drop table stocks; */
/* drop table tickers; */
/* drop type tickers_nt; */
/* drop type ticker_ot; */

/******************* Setup *******************/
CREATE TABLE stocks
(
   ticker        VARCHAR2 (20),
   trade_date    DATE,
   open_price    NUMBER,
   close_price   NUMBER
)
/

BEGIN
   FOR indx IN 1 .. 1000
   LOOP
      INSERT INTO stocks
           VALUES ('STK' || indx,
                   SYSDATE,
                   indx,
                   indx + 15);
   END LOOP;

   COMMIT;
END;
/

-- Transformation: for each row in the stock table, generate two rows for
-- the tickers table (one row each for the open and close prices):

CREATE TABLE tickers
(
   ticker      VARCHAR2 (20),
   pricedate   DATE,
   pricetype   VARCHAR2 (1),
   price       NUMBER
)
/

-- We want to move stock data to the tickers table, so we need an object type
-- that "looks like" the tickers table. Use object because we can't use PLSQL's foo%ROWTYPE
-- that SQL won't understand in SELECTs
CREATE TYPE ticker_ot AUTHID DEFINER IS OBJECT 
(
   ticker VARCHAR2 (20),
   pricedate DATE,
   pricetype VARCHAR2 (1),
   price NUMBER
);
/
CREATE TYPE tickers_nt AS TABLE OF ticker_ot;
/

-- Since we are going to use the table function in a streaming process, we will
-- also need to define a strong REF CURSOR type that will be used as the datatype
-- of the parameter accepting the dataset inside the SQL statement.

CREATE OR REPLACE PACKAGE stock_mgr AUTHID DEFINER IS
   TYPE stocks_rc_type IS REF CURSOR RETURN stocks%ROWTYPE;
   TYPE tickers_rc_type IS REF CURSOR RETURN tickers%ROWTYPE;
END stock_mgr;
/
/************************************************/

/******************* Function *******************/
-- Fetch a row from a cursor variable
-- Apply a transformation to each row
-- Put the transformed data into a collection
-- Return the collection when done

-- At least one parameter to streaming table functions must be a strong cursor variable.
CREATE OR REPLACE FUNCTION doubled(rows_in_cr stock_mgr.stocks_rc_type)
   RETURN tickers_nt  -- return an array, each of whose elements looks just like a row in the tickers table
   AUTHID DEFINER
IS
   -- Declare an associative array to hold rows fetched from the rows_in_cr cursor variable.
   TYPE stocks_aat IS TABLE OF stocks%ROWTYPE INDEX BY PLS_INTEGER;
   l_stocks    stocks_aat;

   l_doubled   tickers_nt := tickers_nt();
BEGIN
   LOOP
      FETCH rows_in_rc BULK COLLECT INTO l_stocks LIMIT 100;
      EXIT WHEN l_stocks.COUNT = 0;

      FOR l_row IN 1 .. l_stocks.COUNT LOOP
         l_doubled.EXTEND;
         l_doubled(l_doubled.LAST) :=
            ticker_ot(l_stocks (l_row).ticker,
                      l_stocks (l_row).trade_date,
                      'O',
                      l_stocks (l_row).open_price);

         l_doubled.EXTEND;
         l_doubled(l_doubled.LAST) :=
            ticker_ot(l_stocks (l_row).ticker,
                      l_stocks (l_row).trade_date,
                      'C',
                      l_stocks (l_row).close_price);
      END LOOP;
   END LOOP;
   CLOSE rows_in_cr;

   RETURN l_doubled;
END;
/
/************************************************/

/******************* Stream *********************/
INSERT INTO tickers
   SELECT * 
     FROM TABLE (doubled(CURSOR (SELECT * FROM stocks)))
/

select * from tickers;

/* When we add a "singled" fn then we can chain things like:

CREATE TABLE more_stocks
AS
   SELECT *
     FROM TABLE (
             singled(
                CURSOR (
                   SELECT * 
                     FROM TABLE (doubled(
                                   CURSOR (SELECT * FROM stocks))))))
/

*/
/************************************************/
