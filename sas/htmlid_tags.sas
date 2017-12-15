 /* SAS IntrNet 2003-12-16 */

proc template;
  define style styles.bob;
    parent=styles.minimal;
    /* Insert HTML ID tags for the HTML2CSV JavaScript function. */
    style table from table / htmlid="bob";
    /* Insert JavaScript */
    replace StartupFunction /
            tagattr="window.status='NCHS Confidential Data'";
  end;
run;

 /* Then */
ods html body=_WEBOUT style=styles.bob rs=none
  headtext='<SCRIPT LANGUAGE=JavaScript TYPE=text/javascript SRC="/sasweb/nchs/html2csv.html"></SCRIPt>';
 
  ...

ods html close;
