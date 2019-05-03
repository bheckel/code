 /* Adapted: Tue 30 Apr 2019 09:44:59 (Bob Heckel) */
 /* https://blogs.oracle.com/oraclemagazine/controlling-the-flow-of-execution */
 /* Both the loop and the function have just ONE way out */
FUNCTION total_sales(start_year_in IN PLS_INTEGER, end_year_in IN PLS_INTEGER)
   RETURN PLS_INTEGER
IS
   l_current_year   PLS_INTEGER := start_year_in;
   l_return         PLS_INTEGER := 0;

BEGIN
   WHILE (l_current_year <= end_year_in AND total_sales_for_year(l_current_year) > 0)
   LOOP
      l_return := l_return + total_sales_for_year(l_current_year);
      l_current_year := l_current_year + 1;
   END LOOP;
   RETURN l_return;
END total_sales;
