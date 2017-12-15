options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: build_if_statment.sas
  *
  *  Summary: Demo of splitting a pipe delimited string then building an 
  *           IF statement out of the non-blank pieces.
  *
  *  Adapted: Wed 12 Mar 2003 10:38:00 (Bob Heckel -- usenet post
  *                                     Howard_Schreier@ITA.DOC.GOV)
  *---------------------------------------------------------------------------
  */
options source;

%global s;
%let s=||02||04|||07|08|;
  

 /* Force spaces on consecutive pipes since %scan can't handle
  * consecutive delimiters. 
  */
data _NULL_;
  %global spaces_added;
  /* Nested tranwrd() required to handle multiple runs of empty. */
  like_dsd = tranwrd(tranwrd("&s",'||','| |'), '||','| |');
  call symput('spaces_added', like_dsd);
run;

 /* Gets ugly b/c don't want leading or trailing commas in the IN stmt. */
%macro BuildIfStatement(checked, elems, myvar);
  %global ifstmt;
  %local i field elems myvar checked;
  %do i = 1 %to &elems;
    %let field = %scan(&checked, &i, '|');
    /* If the element is not blank, e.g. first elem *is* missing in &s above. */
    %if &field ne  %then
      %do;
        /* Avoid a trailing comma in the list of elements. */
        /* If the previous element exists (avoid leading comma). */
        %if &ifstmt ne   %then
          %let field = ,&field;
        %else
          %let field = &field;
      %end;
    %let ifstmt = &ifstmt &field;
  %end;
  %let ifstmt = IF &myvar IN(&ifstmt)%str(;);
%mend BuildIfStatement;
%BuildIfStatement(&spaces_added, 8, race)

%put !!! &ifstmt;

