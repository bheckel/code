%macro m;
  ods _all_ close;

  %let reportlocation=/Drugs/Personnel/bob; %let filenm=junk.xml;  /* Excel warning thrown if use 'xls' */

  /* Options: http://support.sas.com/rnd/base/ods/odsmarkup/excelxp_help.html */
   /* Detail of all options */
/***  ODS tagsets.excelxp file="test.xml" options(doc="help");***/

  ods tagsets.excelxp path="&reportlocation" file="&filenm" style=printer /*minimal*/
    options(                                                     /* SAS will increment Census 2... if multiple worksheets */
      absolute_column_width="10,5,5" /*sheet_interval='none'*/ sheet_name='Census' autofit_height='YES' /*suppress_bylines='yes'*/
      orientation="Landscape" row_height_fudge='.5' embedded_titles='yes' skip_space='1,0,0,0,0' FitToPage='yes'
    );

  title color=blue 'testing';

  proc sql;
    select *
    from sashelp.shoes
    where monotonic() <9
    ;
  quit;

  /* Same sheet. By default, the ExcelXP tagset creates a new worksheet when a SAS procedure creates new tabular output but we're using
   * SHEET_INTERVAL='none' and SUPPRESS_BYLINES='YES'
   */
  proc report data=sashelp.class nowd;
    column name sex;
    define sex / display style(column)=[background=#BBBBBB];
  quit;

  ods tagsets.excelxp options(sheet_name='Censusx');
  proc sql;
    select *
    from sashelp.class
    where monotonic() <3
    ;
  quit;

  ods tagsets.excelxp close;
%mend;
%m;
