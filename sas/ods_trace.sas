options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ods_trace.sas
  *
  *  Summary: Demo of specifying only certain proc elements print to .lst.
  *           We're using PROC CONTENTS but it applies to other procs as well.
  *
  *  Created: Wed 02 Apr 2008 10:06:55 (Bob Heckel)
  * Modified: Fri 03 Apr 2015 14:25:32 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Suppress "The CONTENTS Procedure" */
***ods NOproctitle;

title '..............trace..............';
 /* Figure out the 3rd CONTENTS section's 'Name:' */
 /* Print ods details to .lst */
***ods trace on / listing;
 /* Print ods details to .log */
ods trace on / label;
  proc contents data=sashelp.shoes; 
  run;
ods trace off;
/*
Output Added:
-------------
Name:       Attributes <---1
Label:      Attributes
Template:   Base.Contents.Attributes
Path:       Contents.DataSet.Attributes
Label Path: 'The Contents Procedure'.'SASHELP.SHOES'.'Attributes'
-------------

Output Added:
-------------
Name:       EngineHost <---2
Label:      Engine/Host Information
Template:   Base.Contents.EngineHost
Path:       Contents.DataSet.EngineHost
Label Path: 'The Contents Procedure'.'SASHELP.SHOES'.'Engine/Host Information'
-------------

Output Added:
-------------
Name:       Variables <---3
Label:      Variables
Template:   Base.Contents.Variables
Path:       Contents.DataSet.Variables
Label Path: 'The Contents Procedure'.'SASHELP.SHOES'.'Variables'
-------------
*/

title '..............include..............';
 /* Then use only that 'Name:' All 3 approaches are the same. */
ods select Variables;
***ods select contents.dataset.VariablesAlpha;
***ods select 'The Contents Procedure'.'SASHELP.SHOES'.'Variables';
  proc contents data=sashelp.shoes; 
  run;
ods select off;

title '..............exclude..............';
 /* Or delete these 2 */
ods exclude EngineHost Variables;
  proc contents data=sashelp.shoes; 
  run;
ods select off;
