%macro report_writer(type=, ds=, title=, nvars=, vars=, vartypes=, labels=, formats=);
  /********************************************************************************
  *  SAVED AS:                report_writer.sas
  *                                                                         
  *  CODED ON:                23-Apr-16 by Bob Heckel
  *                                                                         
  *  DESCRIPTION:             Generate a native Excel document from dataset(s)
  *                           using SAS' 9.4+ Report Writer Interface (RWI).
  * 
  *  SAMPLE USAGE:
  *
  *   data t;
  *     c='a'; n=1; d=9000; p=0.1; output;
  *     c='b'; n=2; d=8999; p=0.2; output;
  *     c='c'; n=1; d=9001; p=0.3; output;
  *   run;
  *
  *   %let style=style_&SYSMACRONAME._&SYSPROCESSID;
  *   proc template;
  *     define style &style;
  *       parent=styles.printer;
  *       style body / background=white fontfamily=Arial;
  *       style TitleCells from body / fontweight=bold font_style=italic just=center;
  *       style HeaderCells from body / borderstyle=solid background=cxE9F0F2 font_style=italic;
  *       style TextCells from body / borderstyle=solid just=left;
  *       style DataCells from body / borderstyle=solid just=right;
  *     end;
  *   run;
  *
  *   ods excel file="/Drugs/Personnel/bob/t.xlsx" style=style options(sheet_name="My Sheet" sheet_interval="none" absolute_column_width="20");
  *
  *   %report_writer(type=excel,
  *                  ds=t,
  *                  title='Number of Acute Patients By Month',
  *                  nvars=4,
  *                  vars=%str(c,n,d,p),
  *                  vartypes=%str(char,num,date,pct),
  *                  labels=%str(My Char,MyNum,My Date,My Pct),
  *                  formats=%str(.,.,YYMMDD10.,PERCENT9.2)
  *                 );
  *
  *  Multiple calls write to the same worksheet.  To add new worksheet use
  *  something like:
  *    ods excel (sheet_name="Next Tab");
  *  prior to the next %report_writer call.
  *                                                                           
  *  PARAMETERS: vartypes can be 'char', 'num', 'date' or 'pct'.  formats parameter is optional.
  *
  *  MACROS CALLED:           NONE
  *                                                                         
  *  INPUT GLOBAL VARIABLES:  NONE
  *                                                                         
  *  OUTPUT GLOBAL VARIABLES: NONE  
  *                                                                         
  *  LAST REVISED:                                                          
  *   28-Apr-16   Initial version
  *   13-Jun-16   Cleaned up example code
  ********************************************************************************/
  %if %upcase(&type) eq EXCEL %then %do;
    data _null_;
      set &ds end=done;
      if _n_ eq 1 then do;
        declare odsout o();
        o.table_start();

          o.row_start();
            o.format_cell(text:&title., style:"TitleCells", colspan:&nvars, width:"1.5in");
          o.row_end();

          o.row_start();
            %do i=1 %to &nvars;
              %let label=%scan(%bquote(&labels), &i, ',');
              o.format_cell(text:"&label", style:"HeaderCells");
            %end;
          o.row_end();
      end;

          o.row_start();
            %do i=1 %to &nvars;
              %let var=%scan(%bquote(&vars), &i, ',');
              %let vartype=%scan(%bquote(&vartypes), &i, ',');
              %let format=%scan(%bquote(&formats), &i, ',');

              %if %upcase(&vartype) eq CHAR %then %do;
                o.format_cell(text:&var, style:"TextCells", width:"1in" );
              %end;
              %else %if %upcase(&vartype) eq NUM %then %do;
                o.format_cell(data:&var, style:"DataCells");
              %end;
              %else %if (%upcase(&vartype) eq DATE or %upcase(&vartype) eq PCT) %then %do;
                o.format_cell(data:&var, style:"DataCells", format:"&format");
              %end;
            %end;
          o.row_end();

        if done then do;
          o.row_start();
            o.format_cell(text:"", colspan:&nvars, overrides:"background=white borderstyle=none");
          o.row_end();
          o.table_end();
        end;
    run;
  %end;
  %else %do;
    %put ERROR: &=type not yet implemented;
  %end;
%mend report_writer;
