
proc sql FEEDBACK;
  connect to oracle(USER=&dbusr ORAPW=&dbpw PATH=&dbname);
    CREATE TABLE eformsAll AS SELECT * FROM CONNECTION TO ORACLE (
      SELECT request_id, field_name, field_value, field_id, field_seq
      FROM eforms_extract.zebulon_request_detail
      WHERE field_id IN (&fldids) and request_id in (&reqids)
      ORDER BY request_id, field_seq
    );
  %if &SQLOBS eq 0 %then %do;
    %put _all_;
    data _NULL_; 
      put "ERROR: eforms_extract.zebulon_request_detail has &SQLOBS record count - aborting";
      abort abend 002;
    run;
  %end;
  %if &SQLXRC ne 0 %then %do;
    %put _all_;
    data _NULL_; 
      put "ERROR: eforms_extract.zebulon_request_detail has Oracle error &SQLXRC - aborting";
      abort abend 002;
    run;
  %end;
  disconnect from oracle;
quit;
