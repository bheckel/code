/********************************************************************************
*  SAVED AS:                build_long_in_list.sas
*                                                                         
*  CODED ON:                15-Feb-16 by Bob Heckel
*                                                                         
*  DESCRIPTION:             Enable long parameter lists in IN() statements, etc.
*                           which would normally overflow macrovariable max length 
*                           limits
*                                                                           
*  PARAMETERS:              Input dataset, field, data type
*
*  MACROS CALLED:           NONE
*                                                                         
*  INPUT GLOBAL VARIABLES:  NONE
*                                                                         
*  OUTPUT GLOBAL VARIABLES: %long_in_list &nitems
*                                                                         
*
* Sample usage:
*
* %build_long_in_list(ds=sashelp.shoes, var=region, type=char);
* proc sql;
*   select * from sashelp.shoes where region in ( %long_in_list );
* quit;
* 
*
*  LAST REVISED:                                                          
*   15-Feb-16   Initial version
********************************************************************************/

%macro build_long_in_list(ds=, var=, type=);
  %global nitems;
  %local i;

  proc sql NOprint;
    select left(put(count(distinct &var),8.)) into :nitems
    from &ds
    ;
  quit;

  %do i=1 %to &nitems;
    %global itm&i.;
  %end;

  proc sql NOprint;
    %if &type eq char %then %do;
      select distinct cats("'", left(trim(&var)), "'") into :itm1 - :itm&nitems
    %end;
    %else %do;
      select distinct &var into :itm1 - :itm&nitems
    %end;
    from &ds
    ;
  quit;

  %macro long_in_list;
    %local j;
&itm1
    %do j=2 %to &nitems;
,&&itm&j
    %end;
  %mend;
%mend;
