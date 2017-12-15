options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ods_style_compare_print_report_tabulate.sas
  *
  *  Summary: ODS style comparison across the 3 major reporting procs
  *
  *  Adapted: Mon 06 Apr 2015 10:09:49 (Bob Heckel--http://support.sas.com/resources/papers/proceedings11/300-2011.pdf)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

ods html file='style08a.html';
ods rtf file='style08a.rtf';
ods pdf file='style08a.pdf';

 /* CX (e.g. CXff00ff) indicates SAS' RGB color specification */
PROC PRINT data=sashelp.class(obs=3)
  style(header)={background=cx0000ff foreground=cxffffff font_face=Arial}
  style(data)={background=yellow}
  style(obsheader)={background=green foreground=white}
  style(obs)={background=white foreground=green};
RUN;

PROC REPORT data=sashelp.class(obs=3) nowd style(header)={background=cx0000ff foreground=cxffffff font_face=Arial} style(column)={background=yellow};
  define name / 'Name' style(header)={background=green foreground=white} style(column)={background=white foreground=green font_weight=bold};
RUN;

PROC TABULATE data=sashelp.class
  style={background=yellow};
  class age sex / style={background=cx0000ff foreground=cxffffff font_face=Arial};
  classlev age / style={background=cyan};
  classlev sex / style={background=white foreground=blue};
  table sex all,
        age all={label='Count' style={background=white vjust=b}} * {style={background=purple foreground=white font_weight=bold}} / box={label='Box Area' style={vjust=b background=green foreground=white}};
  keylabel n='x'
  all='Tot';
  keyword all / style=Header{background=pink};
RUN;

ODS _all_ CLOSE;
