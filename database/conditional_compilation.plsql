
ALTER SESSION SET plsql_optimize_level = 1
/

CREATE OR REPLACE PROCEDURE compute_intensive
IS
   PROCEDURE body_of_proc IS BEGIN NULL; END;
BEGIN
   $IF $$plsql_optimize_level < 2
   $THEN
      $ERROR 'compute_intensive must be compiled with maximum optimization!' $END
   $END
   body_of_proc;
END compute_intensive;
/
/*
Errors: PROCEDURE COMPUTE_INTENSIVE Line/Col: 7/7 PLS-00179: $ERROR: compute_intensive must be compiled with maximum optimization!
*/
