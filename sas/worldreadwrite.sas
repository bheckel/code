%macro worldreadwrite(file=, folder=, recurse=);
  /********************************************************************************
  *  SAVED AS:                worldreadwrite.sas
  *                                                                         
  *  CODED ON:                12-Jan-16 (bheckel)
  *                                                                         
  *  DESCRIPTION:             Open permissions on a file (or files) that you own
  *
  *  PARAMETERS:              File (or file name plus wildcard), or folder
  *
  *  MACROS CALLED:           NONE
  *                                                                         
  *  INPUT GLOBAL VARIABLES:  NONE
  *                                                                         
  *  OUTPUT GLOBAL VARIABLES: NONE 
  *
  *  SAMPLE CALLS:
  *    %worldreadwrite(file=/path/to/single/file.csv);
  *    %worldreadwrite(file=/path/to/multiple/file*);
  *    %worldreadwrite(folder=/path/to/entire/folder/);
  *    %worldreadwrite(folder=/path/to/entire/folder/, recurse=Y);
  *                                                                         
  *  LAST REVISED:                                                          
  *   12-Jan-16 (bheckel)  Initial version
  *   13-Jan-16 (bheckel)  Add recursion
  ********************************************************************************/
  data _null_;
    %if "&file" ne ""  %then %do;
      rc1=system("chmod 777 &file");
    %end;
    %else %if "&folder" ne "" %then %do;
      %if "&recurse" eq "Y" %then %do;
        rc1=system("chmod -R 777 &folder/");
      %end;
      %else %do;
        rc1=system("chmod 777 &folder/*");
      %end;
    %end;

    if (rc1 ne 0) then do;
      put 'ERR' 'OR: chmod failure: ' rc1=;
      sysuserid=symget('SYSUSERID');
      file=symget('file');
      put sysuserid= file=;
    end;
    else do;
      put 'permission changed';
    end;
  run;
%mend;
