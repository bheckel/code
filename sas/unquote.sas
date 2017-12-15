/*
To unquote a value means to restore the significance of symbols in an item that
was previously masked by a macro quoting function.  Usually, after an item has
been masked by a macro quoting function, it RETAINS ITS SPECIAL STATUS until
one of the following occurs:

 You enclose the item with the %UNQUOTE function (see %UNQUOTE Function.)

 The item leaves the word scanner and is passed to the DATA step compiler, SAS
 procedures, SAS Macro Facility, or other parts of the SAS System.

 The item is returned as an unquoted result by the %SCAN, %SUBSTR, or %UPCASE
 function. (To retain a value's masked status during one of these operations,
 use the %QSCAN, %QSUBSTR, or %QUPCASE function. See Other Functions That
 Perform Macro Quoting for more details.)

As a rule, you do not need to unquote an item because it is automatically
unquoted when the item is passed from the word scanner to the rest of SAS.
Under two circumstances, however, you might need to use the %UNQUOTE function
to restore the original significance to a masked item:

 When you want to use a value with its restored meaning later in the same macro
 in which its value was previously masked by a macro quoting function.

 When, as in a few cases, masking text with a macro quoting function changes
 the way the word scanner tokenizes it, producing SAS statements that look
 correct but that the SAS compiler does not recognize.
 */

 /* Without the unquote() we get 'Expecting a = ' etc errors in Log */
data eforms(drop=TMP:);
  set eforms(rename=(
  /* Build e.g. rename=(DateofCompletion1008=TMPDateofCompletion1008 ...) */
  %local y; %let i=1; %let v=%qscan(&DATEVARS, &i, ' '); %let y=;
  %do %while ( &v ne  );
    /*...........................................................*/
    %let y=%bquote(&v.=TMP&v &y);
    /*...........................................................*/
    %let i=%eval(&i+1); %let v=%qscan(&DATEVARS, &i, ' '); 
  %end;
  %unquote(&y)
  ));

  /* Build e.g. DateofCompletion1008=input(TMPdtchar, MMDDYY10.); ... */
  %local z; %let i=1; %let v=%qscan(&DATEVARS, &i, ' '); %let z=;
  %do %while ( &v ne  );
    /*...........................................................*/
    %let z=%str(&v.=input(TMP&v., MMDDYY10.); &z);
    /*...........................................................*/
    %let i=%eval(&i+1); %let v=%qscan(&DATEVARS, &i, ' '); 
  %end;
  %unquote(&z);
run;
