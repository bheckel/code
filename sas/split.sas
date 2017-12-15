options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: split.sas
  *
  *  Summary: Hideous contortion required to count number of specific
  *           characters in a string then split and rebuild the string based
  *           on that number.  Hopefully there is a better way to do this.
  *
  *           Used by the SAS IntrNet Web Query System.
  *
  *  Created: Wed 25 Jun 2003 13:23:08 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* Accepts: a string, a delimiter.
  * "Returns": &numchunks, a count of delimiters, and macrovariables strings
  * &chunk1-N holding each delimited piece. 
  */
%macro Splitter(s, d);
  %global numchunks;
  %local i sl snodelm snodelml numdelims;

  %let sl=%length(&s);

  %let snodelm=%sysfunc(compress(&s, %str(&d)));
  %let snodelml=%length(&snodelm);

  %let numdelims=%eval(&sl-&snodelml);
  %let numchunks=%eval(&numdelims+1);

  %do i=1 %to &numchunks;
    %global chunk&i;
    %let chunk&i = %scan(%str(&s), &i, %str(&d)); 
  %end;
%mend Splitter;


 /* Accepts: a string, the input delimiter to split on, the output delimiter to
  * be inserted.
  * "Returns":  &parsed, a delimited string.  If &outdelim is "" it
  * automatically comma-delimits the returned parsed string.
  */
%macro DelimitIt(str, indelim, outdelim);
  %local i;
  /* Provides numchunks and chunk1-N */
  %Splitter(&str, &indelim)
  %global parsed;
  %do i=1 %to &numchunks;
    /* Have to wrap the string if quotes (TODO single quotes are trickier)
     * have been requested.
     */
    %if &outdelim eq %str("") %then
      /* Avoid leading comma. */
      %if &i eq 1 %then
        %let parsed = "&&chunk&i";
      %else
        %let parsed = &parsed,"&&chunk&i";
    %else %if &outdelim eq %str(()) %then
      %if &i eq 1 %then
        %let parsed = (&&chunk&i);
      %else
        %let parsed = &parsed,(&&chunk&i);
    %else
      %let parsed = &parsed &&chunk&i &outdelim;
  %end;

  %put _USER_;
%mend DelimitIt;
/*** %DelimitIt(abc_def_ghi_jkl, _, X) ***/
/*** %DelimitIt(abc_def_ghi_jkl, _, "") ***/
/*** %DelimitIt(%str(abc,def,ghi,jkl), %str(,), "")  ***/
 /* TODO why does this need %bquote on the IntrNet project? */
 /*        ____________                                     */
%DelimitIt(%str(1,2,3,4), %str(,), "");

%put !!! parsed string is: &parsed;
