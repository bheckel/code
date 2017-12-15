options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: embed_image_pdf.sas
  *
  *  Summary: Embed image files inside a PDF
  *
  *           See also build_multiple_graphs_from_ds.sas to create images
  *
  *  Adapted: Mon 24 Sep 2012 12:50:39 (Bob Heckel--sas.com)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

/* One record per year to create the format */
proc sort data=SASHELP.retail(where=(year < 1986)) out=retail nodupkey; 
  by year;
run;

data myfmt;
  set retail;
  fmtname = "Mypng";
  START = year;
  LABEL = "C:\cygwin\home\rsh86800\tmp\1348498689_24Sep12\"||put(year,4.)||".png";
run;

/* Create the format containing the links to the images */
proc format cntlin=myfmt; run;

/* Create a format to blank out values in the column that will contain the image. */
proc format;
  value Blank OTHER=" ";
run;

 /* DEBUG */
proc format library= WORK FMTLIB; run;

ODS listing close;
/***ods rtf file='t.rtf';***/
ODS pdf file='t.pdf' NOTOC;
/***ods html file='t.html' style=sasweb;***/
proc report data=retail nowd;
  column year image;

  define year / group 'Year';
  define image / 'Graph' computed style(column)=[postimage=Mypng. just=l cellwidth=1.5in ] format=Blank.;

  /* Set the computed variable equal to the variable value that matches the
   * value in the $Mypng. format
   */
  compute image;
    image = year;
  endcomp;    
run;
ODS _all_ close;
