
proc sql FEEDBACK;
  CONNECT TO ORACLE(USER=gdm_dist_r ORAPW=slice45read PATH=ukprd613);
    CREATE TABLE foo AS SELECT * FROM CONNECTION TO ORACLE (
      SELECT 1 FROM dual
    );
  DISCONNECT FROM ORACLE;
quit;


/* or */
libname ORA oracle user=pks password=dev123dba path=usdev388;
