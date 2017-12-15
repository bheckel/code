options nosource;
 /*---------------------------------------------------------------------------
  *     Name: wordwrap.sas
  *
  *  Summary: Demo of wrapping long lines.  This version works backwards on a
  *           string.
  *
  *  Adapted: Mon Oct 28 17:38:57 2002 (Bob Heckel -- Professional SAS
  *                                     Programming Shortcuts - Rick Aster)
  *---------------------------------------------------------------------------
  */
options source;

data _NULL_;
  retain text "Early in the 21st century, the Tyrell Corporation advanced robot evolution";

  /* Declarations. */
  length linelen 3 ;       /* max line length */
  length c 3;              /* character start position */
  length len $ 8;          /* actual length of vari text */
  array textline{4} $ 25;  /* holds 4 lines of shortened text */
  length start 3;          /* first non-whitespace letter */
  length fragment $ 3;     /* contains 3 chars to be considered for break */

  linelen = 25;
  c = 1;   /* default */
  len = length(text);

  * Find lines of text. ;
  do i = 1 to dim(textline);
    textline{i} = '';
    if c >= len then
       continue;

    * Skip spaces to find start of line. ;
    do while(substr(text, c, 1) = ' ');
      c + 1;
    end;
    start = c;
    * Find end of line at space, hyphen, or dash. ;
    endline = 0;
    if start + linelen <= len then
      do c = start + linelen - 1 to start by -1 until (endline);
        fragment = substr(text, c);
        if substr(fragment, 2, 1) = ' ' or substr(fragment, 2, 2) = '--' or
          (substr(fragment, 1, 1) = '-' and substr(fragment, 2, 1) ne '-') then 
            endline = c;
      end;
    if endline then 
      do;
        textline{i} = substr(text, start, endline-start+1);
        c = endline + 1;
      end;
    else 
      do;
        textline{i} = substr(text, start);
        c = start + linelen;
      end;

  end;

  * Show results. ;
  do i = 1 to dim(textline);
    if textline{i} ne '' then 
      put textline{i};
  end;
run;
