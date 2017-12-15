options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: basename.sas
  *
  *  Summary: Extract short filename from a fully qualified path.
  *
  *  Created: Wed 14 May 2008 08:56:51 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%macro FullyQualifiedToFileNameOnly;
  %let fq = c:\cygwin\home\bheckel\VALTREX_Caplets\CODE\log\Valtrex_Caplets.log;

  %let fq = %sysfunc(reverse(&fq));

  %let basename = %sysfunc(reverse(%scan(&fq, 1, '\')));

  %put _all_;
%mend; %FullyQualifiedToFileNameOnly
