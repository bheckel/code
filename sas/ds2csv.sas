options nosource;
 /*---------------------------------------------------------------------
  *     Name: ds2csv.sas (compare with dswrite.sas)
  *
  *  Summary: Convert a SAS dataset to a CSV output text file.
  *
  *           Better:
  *
  * libname l '.'; proc export data=l.advair OUTFILE='advair.csv' DBMS=CSV REPLACE; run;
  *
  *  Adapted: Sun 20 Oct 2002 11:55:49 (Bob Heckel -- Rick Aster
  *                  http://www.globalstatements.com/shortcuts/12c.html)
  *---------------------------------------------------------------------
  */
options linesize=72 pagesize=32767 nocenter date nonumber replace
        source source2 notes obs=max errors=5 datastmtchk=allkeywords 
        symbolgen mprint mlogic merror serror
        ;

data work.sample1;
  input fname $1-10  lname $15-25  @30 storeno 3.;
  datalines;
mario         lemieux        123
ron           francis        123
jerry         garcia         123
larry         wall           345
richard       dawkins        345
richard       feynman        678
  ;
run;


***data _NULL_ / DEBUG;
data _NULL_;
  length type $1  fmt $32;
  * Labels, character values, and fields are limited to these maximum lengths;
  length lbl $40  cval  field $256;
  * Output text file;
  file OUT dlm='09'x lrecl=8192;
  * Input sas dataset;
  dsid = open('work.sample1');
  * Write labels of variables;
  nvars = attrn(dsid, 'nvars');
  if _N_ = 1 then 
    do n = 1 to nvars;
      lbl = varlabel(dsid, n);
      if lbl = '' then 
        lbl = varname(dsid, n);
      put lbl @;
    end;
  put;
  * Read and write data;
  nobs = attrn(dsid, 'nlobs');
  do i = 1 to nobs;
    rc = fetch(dsid);
    if rc then 
      leave;
    do n = 1 to nvars;
      type = vartype(dsid, n);
      fmt = varfmt(dsid, n);
      len = varlen(dsid, n);
      select (type);
        when ('C') 
          do;
             if fmt = '' then 
               fmt = '$char' || trim(left(put(len, F5.))) || '.';
             cval = getvarc(dsid, n);
             field = putc(cval, fmt);
           end;
        when ('N') 
          do;
             if fmt = '' then 
               fmt = 'best12.';
             nval = getvarn(dsid, n);
             field = putn(nval, fmt);
          end;
        otherwise
          do;
            /* Must switch filehandles or we'll write to out.dat */
            file LOG;
            put "impossible error";
            file OUT;
          end;
      end;
    put field @;
  end;
  put;
  end;  /* TODO why is this needed? */
  rc = close(dsid);
  stop;
run;
