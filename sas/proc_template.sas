options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_template.sas
  *
  *  Summary: Demo of leveraging existing ODS Style templates.
  *
  *           See ODSdefaultColors.html, odsmarkup.css,
  *           tagsets_template_8.sas, nonditherRGB.html
  *
  *           Use GUI Template Browser via SAS Explorer's Results tab,
  *           right-click Templates
  *
  *           FAQ:
  *           http://support.sas.com/rnd/base/topics/templateFAQ/Template.html
  *           http://support.sas.com/resources/papers/proceedings09/227-2009.pdf
  *
  *           TODO how to delete a custom style from SASUSER.TEMPLAT?
  *
  *  Adapted: Mon 09 Jun 2003 15:14:22 (Bob Heckel--Missing Semicolon 1/2001)
  * Modified: Mon 06 Apr 2015 13:17:05 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* List the default Template Store */
proc template; list; run;
 /* Print source code to Log */
proc template; source Styles.Default; run;
 /* Print source code to file */
proc template; source Styles.Default / file='t.src'; run;


 /* No need to worry about inheritance in 9.2+ */
ods path work.tmp(update) sasuser.templat(update) sashelp.tmplmst(read);
proc template;
  define style styles.purple;
    parent=styles.sasweb;
    class Header / background=purple foreground=white;
  end;
run;

ods html file='c:/temp/t.html' style=purple;
  title 'my ods test';
  proc print data=sashelp.shoes(obs=3); run;
ods html close;



endsas;
 /* Pre SAS 9.2 */
proc template;
   /* View available templates, etc. ("template item store"): */
  /* Toggle */
  list;
  ***list styles;
  ***list styles / store = sashelp.tmplmst;
  ***list stat / store = sashelp.tmplmst;

  /* Or assuming you already know the Style, print the whole style, same as
   * from SAS training JobAid: 
   */
  /* To Log: */
  ***source Styles.Default;
  /* To file: */
  ***source Styles.Default / store=SASHELP.tmplmst file='junk.sas';
  /* Same I think */
  source Styles.Default / file='junkstylesdefault.sas';
  /* Assuming this Style was created previously */
  ***source Styles.Bobhfont /  file='junk.sas';
  source Styles.Printer /  file='junkprinter.sas';
  source Styles.sasdocPrinter /  file='junksasdocprinter.sas';
run;


ods path show;


data sample;
   input density  crimerate  state $ 14-27  stabbrev $ 29-30;
   cards;
55.2 4271.2  Vermont        VT
9.1 2678.0   South Dakota   SD
120.4 4649.9 North Carolina NC
  ;
run;


libname BOBLIB 'c:/temp';
***ods path BOBLIB.bobstyle (write) sashelp.tmplmst (read);
 /* Better */
ods path BOBLIB.bobstylepath (update) sashelp.tmplmst (read);
ods path show;
%put !!! resetting to SAS defaults instead of BOBLIB...;
ods path reset;
ods path show;


 /* View names of style elements in browser via popups.  IE only!  Must have
  * run tagsets_template_8.sas to upgrade SAS 8.2 and use the css from class
  * which I've renamed odsmarkup.css.  It assumes the default ODS path is
  * being used.
  */
***ods markup file='junkmarkup.html' type=style_popup stylesheet='odsmarkup.css';
 /* Same */
ods markup file='junkmarkup.html' type=Tagsets.style_popup 
    stylesheet='odsmarkup.css'
    ;
***ods select VariablesAlpha;
ods select ALL;
  title 'ods markup test';
  /***   proc contents; run; ***/
ods markup close;
 /* Now use this webpage to figure out what SAS is calling the elements.
  * Click to get a popup of the style attribute definitions that you can
  * twiddle.
  */


proc template;
  ***define style myfont;
  /* Better for organization to use the word 'Styles' */
  define style Styles.Bobhstyle;
    notes 'This shows up in the stored style unlike normal SAS comments';
    /* Borrow (inherit) from an existing Style... */
    parent=Styles.Default;
      /* ...and override these HTML style elements: */
      /*    ___________                           */
      style SystemTitle "make titles arial light ital" /
        font_face="courier"
        font_weight=light
        font_style=italic
        font_size=1
        ;
      style Header /
        font_face="andale mono"
        font_weight=bold
        font_size=2
        foreground=cx00F000
        ;
      style Data "make data arial light with red font" /
        font_face="arial"
        font_weight=light
        foreground=cxFF0000
        ;
      /* Inheritance.  RowHeader is the row of Obs numbers. */
      style RowHeader from Header
        ;
      /* Inheritance with an exception on font size.  ProcTitle only matters
       * for procs like Contents, not Print 
       */
      style ProcTitle from SystemTitle /
        font_size=6
        ;
  end;
run;

ods listing close;
***ods html file='junk.html' style=BarrettsBlue;
***ods html file='junk.html' style=myfont;
ods html file='junk.html' style=bobhstyle;
  title 'my modified ods test -- Print';
  proc print; run;
ods html close;

 /* In this case, we want "The CONTENTS Procedure" to show */
 /* Toggle */
ods ptitle;  /* default is ptitle so don't really need this */
***ods NOptitle;
ods html file='junk2.html' style=myfont;
  title 'my modified ods test -- Contents';
  proc contents; run;
ods html close;
***ods listing;
***proc print; run;


 /* Add a logo image to the top of HTML report. */
proc template;
  ***define style mylogo;
  define style Styles.Bobhlogo;
    parent=Styles.default;
    replace Body from Document / preimage='missover.gif';
  end;
run;

ods html file='junk3.html' style=mylogo;
  title 'my logo bearing ods test';
  proc print; run;
ods html close;
