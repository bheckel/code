options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ods_crownjewels.sas
  *
  *  Summary: Demo of customized PDF using SAS 9.4 ODS.  SAS Enterprise Reporting.
  *
  *  Adapted: Fri 27 May 2016 10:40:43 (Bob Heckel -- http://support.sas.com/resources/papers/proceedings13/015-2013.pdf)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

title; footnote;
 /* If you tried changing the margins to 0in the value would be ignored
  * (because it means to use the printer’s default margins). This will allow
  * the entire page to be filled with the background color.
  */
options papersize = (8.5in 8in)
  orientation = portrait
  leftmargin = .001in
  rightmargin = .001in
  topmargin = .001in
  bottommargin = .001in
  nodate
  nonumber
  ;

 /* Set page bgcolor */
proc template;
  define style Oakwood;
    parent = Styles.printer;
    class Body / backgroundcolor=cxc4daa1;
  end;
run;


ods pdf file="/Drugs/Personnel/bob/Example1.pdf" notoc style=Oakwood; 

 /* Left/right margins of the full page width */
ods layout gridded x=.1in y=.1in columns=2;

   /* Row 1 Left side column */
  ods region width=25%;

   /* Use Report Writing Interface to build Row 1 Left side column (a nested 2x2) */
  data _null_;
    dcl odsout obj();

    obj.layout_gridded(rows: 2, columns: 2, column_gutter: "0in", row_gutter: "0in"); 

      /* Image on left.  Fills both rows. */
      obj.region();
  /***    obj.image(file: "/Drugs/Personnel/bob/CCEdiagram17March2016.png", width: "100%");***/
      obj.image(file: "/Drugs/Personnel/bob/CCEdiagram17March2016.png", width: ".5in", height: ".6in");

      /* Text on right.  One line of text on each of the 2 rows. */
      obj.region();
      obj.format_text(data: "Oakwood", style_attr: "color=cx405218 font_weight=Bold font_size=20pt");
      obj.format_text(data: "Text on 2nd row", style_attr: "color=cx405218 font_weight=Bold font_size=20pt");

    obj.layout_end();
  run;


   /* Use ods text to build Row 1 Right side column.
    * ODS LAYOUT moves to the next available region in the grid when an ODS REGION;
    * statement is encountered unless ADVANCE=EXPLICIT, =PROC, =OUTPUT,
    * or =BYGROUP is specified.
    */
  ods region width=75% style={backgroundcolor=cxafbd91};
  title "Quote of the Day";
  ods text="";
  ods text='(*ESC*){style SystemTitle [color=cxC92C6B]"Lorem ipsum dolor sit amet consectetuer adipiscing elit"}'; 


   /* Use Report Writing Interface to build Row 2 */
  ods region column_span=1;
  data _null_;
    dcl odsout obj();
    
    obj.image(file: "/Drugs/Personnel/bob/sasgraph.png", width: "100%",height: "45%");
  run;

  ods region column_span=1;
  data _null_;
    dcl odsout obj();
    
    obj.image(file: "/Drugs/Personnel/bob/t.png", width: "100%",height: "45%");
  run;

  /* Use regular ODS PDF to build doublewide Row 3 */
/***  ods region column_span=2 style={backgroundcolor=cxcccccc};***/
/***  title "&SYSDSN";proc print data=sashelp.cars(obs=2) width=minimum heading=H;run;title;***/

  /* Use RWI to build doublewide Row 3 */
  ods region column_span=2 style={backgroundcolor=cxcccccc};
  data _null_;
    set sashelp.shoes(obs=5) end=end;
    by region;
    if _n_ eq 1 then dcl odsout obj();

    if first.region then do;
      obj.format_text(data: subsidiary, style_elem: "Systemtitle", style_attr: " background=cxc4d4a1");
      obj.table_start(style_attr: 'frame=void rules=none backgroundcolor=_undef_');
    end;

    obj.row_start();
      obj.format_cell(data: subsidiary || ' ' || product || ' long text here to fill out the double wide row..........................................'); 
    obj.row_end();

    if last.region then do;
      obj.table_end();
    end;
  run;


  /* Use proc odstext to build doublewide Row 4 */
  ods region;
    title "This exquisite selection of 5 bottles is available in limited quantities. So place your order before we run out!";
    proc odstext;
      p "$299" / style={font_size=9pt color=red};
      p "Free Shipping and handling." / style={font_size=8pt font_weight=bold};
    run; 
ods layout end;


 /* Place an overlay image on same page */
ods layout  gridded x=6in y=5in;
  data _null_;
    dcl odsout obj();
    obj.image(file: "/Drugs/Personnel/bob/SGPlot.png", width: "10%",height: "10%");
  run;
ods layout end;


ods _all_ close; 
