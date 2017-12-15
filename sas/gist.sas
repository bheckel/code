
%macro gist(product, basepath);
  %local giststart vhfaselect vhfaconstraint ahfaselect;
  %let giststart = %sysfunc(time());

%macro bobh1901094220; /* {{{ */
  filename CTRL "&basepath\gist.&product..ctrl";
  /* TODO filexist check or abort */
  data commadelim;
    /* File contains comments and headers on the 1st 2 lines */
    infile CTRL DLM=',' DSD MISSOVER firstobs=3;
    input fid :$80. fname :$80.;
  run;

  filename INI "&basepath\gist_database.ini";
  /* TODO filexist check or abort */
  data _null_;
    infile INI DLM='=' MISSOVER;
    input key :$40. val :$40.;
    call symput(key, compress(val));
  run;

  /* User wants these fields (we bring them in as numbers) */
  proc sql NOprint;
    select distinct fid into :FLDIDS separated by ','
    from commadelim
    ;
  quit;
  %put _all_;
%mend bobh1901094220; /* }}} */
  %let dbusr=gist2_stat; %let dbpw=stab09stat; %let dbname=usprd117; 

  %let sq=%str(%');

  %if &product eq VENTOLIN HFA %then %do;
    %let vhfaselect=%str(, study_grp,'Ventolin HFA' as descrip, bch_no, lot_no, stat);
    %let vhfaconstraint=%str(and stat = 'A');
  %end;
  %else %if &product eq ADVAIR HFA %then %do;
    %let ahfaselect=%str(as STABILITYID, bch_no as BATCHID);
  %end;

  proc sql FEEDBACK;
    connect to oracle(USER=&dbusr ORAPW=&dbpw PATH=&dbname);
      CREATE TABLE pullgist AS SELECT * FROM CONNECTION TO ORACLE (
        /* GIST's DESCRIP holds control chars and is not used by jamiepost so we're hacking it here to avoid problems */
        SELECT study_no &ahfaselect &vhfaselect
        FROM gist2_c.study
        /* Must use A for VHFA or get dups */
        WHERE UPPER(descrip) like &sq.&product.%&sq &vhfaconstraint
      );
    disconnect from oracle;
  quit;
  /* TODO count obs then abort if low */
  %put &SQLXMSG;
  %put &SQLXRC;

  %if &product eq ADVAIR HFA %then %do;
    proc export data=pullgist OUTFILE='StabilityToBatchID.csv' DBMS=CSV REPLACE; run;
  %end;
  %else %do;
    proc export data=pullgist OUTFILE='updated_batchTOstabilityID.csv' DBMS=CSV REPLACE; run;
  %end;

%macro bobh1901091159; /* {{{ */
  proc sql NOprint;
    select distinct request_id into :REQIDS separated by ','
    from pullgist
    where field_name eq 'Product:' and upcase(field_value) like "%upcase(&product)%"
    ;
  quit;

  data pullgist(keep=request_id fieldnm2 field_value);
    set pullgist;
    length fieldnm1 $28;
    length fieldnm2 $32;

    if request_id in (&REQIDS);
    field_name = compress(field_name, '#.:%;()- ');
    fieldnm1 = field_name;
    /* Must disambiguate identically named fields */
    fieldnm2 = left(trim(fieldnm1)) || left(trim(field_id));
  run;

  proc transpose data=pullgist out=gist&product;
    by request_id;
    id fieldnm2;
    var field_value;
  run;

  data l.gist&product;
    set gist&product(drop= _NAME_ _LABEL_);
    source = "gist &dbname";
  run;

  /* TODO output CSV */

%mend bobh1901091159; /* }}} */
  skip 5;
  %put !!! (&SYSMACRONAME..sas SYSCC: &SYSCC) Elapsed minutes: %sysevalf((%sysfunc(time())-&giststart)/60);
  skip 5;
%mend;
 /* The first parameter must be the prod name for SQL LIKE searching.
  *
  * The second parameter is the path to the control file and initialization file.
  */
%gist(ADVAIR HFA, .);
%gist(VENTOLIN HFA, .);


endsas;
options noxwait noxsync;
***x 'C:\PROGRA~1\MICROS~2\Office10\excel.EXE';  /* you might need to specify the entire pathname */
x 'C:\cygwin\home\bheckel\projects\datapost\tmp\Gist\StabilityToBatchID.csv';
/* Sleep for 5 seconds to give  Excel time to come up */
data _null_;
   x=sleep(5);
run;
filename cmds dde 'excel|system';
data _null_;
   file cmds;
   ***put '[SELECT("R1C1:R20C3")]';
   ***put '[SORT(1,"R1C1",1)]';
   ***put '[SAVE()]';
   ***put '[QUIT()]';
   ***put '[Workbooks.Open Filename:="C:\cygwin\home\bheckel\projects\datapost\tmp\Gist\StabilityToBatchID.xls"]';
   put '[SaveAs("C:\cygwin\home\bheckel\projects\datapost\tmp\Gist\StabilityToBatchID.xls",xlExcel9795)]';
run;

