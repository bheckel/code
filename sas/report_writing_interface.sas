options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: report_writing_interface.sas
  *
  *  Summary: Custom generation of complex reporting
  *
  *   ods listing;
  *   proc template;
  *      list styles;
  *   run;
  *
  *  https://support.sas.com/rnd/base/ods/scratch/styles-tips.pdf
  *
  *  Created: Wed 20 Apr 2016 08:38:34 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err mrecall;

 /* Occasionally needed if you have EG open */
/***ods path templat (update) sashelp.tmplmst (read);***/

proc template;
  define style mystyle;
    parent=styles.printer;
    style headercells from body / background=yellow fontweight=bold;
    style datacells from body / just=right rightmargin=4mm;
  end;
run;

 /*************************/

ods _ALL_ close;
ods pdf file='/Drugs/Personnel/bob/tmp/t.pdf' style=mystyle;
data _null_;
  dcl odsout o();
  o.layout_absolute();
    o.region(width:"8in", height:"1in", style_attr:"background=cxCCCCCC");
      o.format_text(data:"hello world", style_attr:"font_size=20pt font_style=italic");
run;

 /*************************/

ods _ALL_ close;
proc sql;
  create table numsex as
    select sex, count(*) as num
    from sashelp.class
    group by 1
    ;
  create table t as
    select c.*, num
    from sashelp.class c, numsex n
    where c.sex eq n.sex
    order by sex, name
    ;
quit;

proc format;
  value $Sex 'F' = 'Girls'
             'M' = 'Boys'
             ;
run;

/***ods pdf file='/Drugs/Personnel/bob/tmp/t.pdf' notoc style=mystyle;***/
ods excel file='/Drugs/Personnel/bob/tmp/t.xlsx' style=mystyle;
data _null_;
  set t end=done;
  by sex;
  if _n_ eq 1 then do;
    /* Header rows */
    declare odsout o();

    o.table_start();

      o.row_start();
        o.format_cell(colspan: 2);
        o.format_cell(text: 'Vital Stats', overrides: 'borderleftcolor=white fontweight=bold', colspan: 2);
      o.row_end();

      o.row_start();
        o.format_cell(text: 'Gender',style: 'HeaderCells', overrides: 'cellwidth=15mm');
        o.format_cell(text: 'Name',style: 'HeaderCells', overrides: 'cellwidth=30mm');
        o.format_cell(text: 'Height (ins)',style: 'HeaderCells', overrides: 'cellwidth=25mm');
        o.format_cell(text: 'Weight (lbs)',style: 'HeaderCells', overrides: 'cellwidth=25mm');
      o.row_end();
  end;

      /* Data rows */
      o.row_start();
        if first.sex then o.format_cell(text: put(Sex,$Sex.), overrides:'just=left fontweight=bold vjust=top', rowspan: num);
        o.format_cell(text: name,overrides: 'just=left');
        o.format_cell(text: height, style: 'DataCells');
        o.format_cell(text: weight, style: 'DataCells');
      o.row_end();

    if done then o.table_end();
run;

 /* Page/Tab 2 - use options(sheet_interval="none") to avoid new tab */
ods excel options(sheet_name="my second sheet");
data _null_;
  set t end=done;
  by sex;
  if _n_ eq 1 then do;
    /* Header rows */
    declare odsout o();

    o.table_start();

      o.row_start();
        o.format_cell(colspan: 2, style_attr: 'background=cx007DC3');
        o.format_cell(text: '2Vital Stats', overrides: 'borderleftcolor=white fontweight=bold', colspan: 2);
      o.row_end();

      o.row_start();
        o.format_cell(text: 'Gender',style: 'HeaderCells', overrides: 'cellwidth=15mm');
        o.format_cell(text: 'Name',style: 'HeaderCells', overrides: 'cellwidth=30mm');
        o.format_cell(text: 'Height (ins)',style: 'HeaderCells', overrides: 'cellwidth=25mm');
        o.format_cell(text: 'Weight (lbs)',style: 'HeaderCells', overrides: 'cellwidth=25mm');
      o.row_end();
  end;

      /* Data rows */
      o.row_start();
        if first.sex then o.format_cell(text: put(Sex,$Sex.), overrides:'just=left fontweight=bold vjust=top', rowspan: num);
        o.format_cell(text: name,overrides: 'just=left');
        o.format_cell(text: height, style: 'DataCells');
        o.format_cell(text: weight, style: 'DataCells');
      o.row_end();

    if done then o.table_end();
run;
ods _all_ close;

 /*************************/

