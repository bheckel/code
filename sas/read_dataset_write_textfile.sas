 /* Create delimited text file from a SAS data set.     */
 %macro dswrite(dsname=,    /* library.dataset */
                file=  ,    /* report file     */
                dlm=);      /* delimiter       */

   %put NOTE: *** Macro DSWRITE beginning execution ***;


    /* Assume zero records found */
   %let rptobs = 0;

    /* Create library and dataset name macro variables */
   %let lib = %upcase(%scan(%quote(&dsname), 1, %str(.)));
   %let dsn = %upcase(%scan(%quote(&dsname), 2, %str(.)));

    /* Get variable information for specific dataset */
   proc sql noprint;

      create view work.ds_dict as

       select *
          from dictionary.columns
             where libname = "&lib" and
                   memname = "&dsn"
       ;

   quit;

    /* Setup variables and formats for writing to file */
   data _null_;
        set work.ds_dict end=eof;

         /* Use variable name if label is blank */
        if label eq ' ' then
           label = name;

         /* Report run date */
        call symput('RUNDATE', put(today(), yymmdd10.));

         /* Get variable names, labels and formats */
        call symput('VAR'   !! left(put(_n_, 3.)), name);
        call symput('LABEL' !! left(put(_n_, 3.)), label);

        if upcase(type) eq 'CHAR' then
           call symput('FORMAT' !! left(put(_n_, 3.)), '$' !! put(length, 3.) !! '.');
        else
        if format ne ' ' then
           call symput('FORMAT' !! left(put(_n_, 3.)), format);
        else
           call symput('FORMAT' !! left(put(_n_, 3.)), 'best10.');

        if (eof) then
           call symput('NUMVAR', left(put(_n_, 3.)));
   run;

    /* Reset macro variable if records found */
   data _null_;
        set &dsname nobs=rptobs;
        call symput('RPTOBS', rptobs);
        stop;
   run;

   %if &rptobs ne 0 %then
   %do;  /* records found */

       /* Write data to file */
      data _null_;
           set &dsname;

            /* Character elements only */
           array chars _character_;

            /* File name */
           file "&file" lrecl=32750;

            /* Strip out any tab characters */
           do over chars;
              chars = compress(chars, '09'x);
           end;

           if _n_ eq 1 then
           do;  /* Report title and header */

               /* Write header */
              put
              %do i=1 %to &numvar;
                 "&&label&i" &dlm
              %end;
              ;

           end; /* Report title and header */

            /* Write data */
           put
           %do i=1 %to &numvar;
              &&var&i &&format&i &dlm
           %end;
           ;
      run;

   %end; /* Records found */

   %else
   %do;  /* No records found */

       /* Write message to file */
      data _null_;

            /* File name */
           file "&file" lrecl=32750;

            /* Write message */
           put 'No records found';

      run;

   %end; /* No records found */

 %mend dswrite;


/* MOVE THIS LINE BELOW CODE */
/*** %dswrite(dsname=work.tmp1, file=~bh1/outpt.txt, dlm='09'x);***/
