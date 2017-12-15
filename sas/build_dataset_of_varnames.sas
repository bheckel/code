options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: build_dataset_of_varnames.sas
  *
  *  Summary: Demo of converting varnames in one dataset into observations in 
  *           a new dataset.
  *
  *           See also proc_contents.sas
  *
  *  Adapted: Wed 24 Sep 2008 09:55:27 (Bob Heckel - SAS Docs)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data shoeDSfieldnames(keep=fieldname);
   set sashelp.shoes;

   /* All character variables in shoes */ 
   array ch{*} _character_;   

   /* All numeric variables in shoes */ 
   array nu{*} _numeric_;     

   /* Make sure var 'fieldname' is not in either array */
   length fieldname $32;             

   do i=1 to dim(ch);
      /* get name of character variable */
/***      call vname(ch{i},fieldname); ***/
      /* same (better?) */
      fieldname = vname(ch{i});
      /* write fieldname to an observation */
      output;                  
   end;

   do j=1 to dim(nu);
         /* get fieldname of numeric variable */
      call vname(nu{j},fieldname); 
         /* write fieldname to an observation */
      output;                  
   end;

   /* Read only a single obs to gather varnames */
   stop;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* For comparison */
proc contents data=sashelp.shoes out=contentsapproach;run;
proc print data=_LAST_(obs=max) width=minimum; run;
