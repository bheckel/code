data _NULL_;
  /* Use Standard Print File keyword PRINT to redirect away from LOG into the
   * LIST for the duration of this step. 
   */
  file PRINT;
  put 'Here are automatic variables: ' _ALL_;
run;

data _NULL_;
  put 'back to Log by default';
run;
