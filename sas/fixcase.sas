/*----------------------------------------------------------------------------
 * Program Name: fixcase.sas
 *
 *      Summary: Force proper upper and lower case  lowercase on names.
 *               From Semicolon Oct 1998.
 *
 *               Also good example of ifthenelseif.
 *
 *               See also rightcase_string.sas
 *
 *      Created: Wed, 10 Nov 1999 15:00:21 (Bob Heckel)
 *----------------------------------------------------------------------------
 */
options linesize=80 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace;

title; footnote;

data work.fixnames;
  input @1 oldname $40.;
  lowname = lowcase(oldname);
  /* Define max of 5 possible name 'pieces'. */
  length word1-word5 $25.;
  array words{5} $ word1-word5;
  do i = 1 to 5;
    words{i} = scan(lowname, i, ' ');
    substr(words{i}, 1, 1) = upcase(substr(words{i}, 1, 1));
    /* Ck for name like McIntyre. */
    if ( substr(words{i}, 2, 1) = 'c' ) then
      substr(words{i}, 3, 1) = upcase(substr(words{i}, 3, 1));
    /* Ck for name like D'Angelo. */
    if ( substr(words{i}, 2, 1) = "'" ) then
      substr(words{i}, 3, 1) = upcase(substr(words{i}, 3, 1));
    /* Ck for names with abbreviations like Rn changed to RN, Md to MD. */
    if ( words{i} in ('Rn', 'Rn.') ) then
      substr(words{i}, 2, 1) = 'N';
    else if ( words{i} in ('Md', 'Md.') ) then
      substr(words{i}, 2, 1) = 'D';
    else if ( words{i} in ('Phd', 'Phd.') ) then
      substr(words{i}, 3, 1) = 'D';
  end;
  /* New, corrected name. */
  length fullname $40.;
  do i = 1 to 5;
    /* Add each word (piece) to the end of the previous one with a blank in
     * between.
     */
     fullname = trim(fullname) !! ' ' !! words{i};
  end;
  /* Output ds only needs this vari. */
  keep fullname;
  cards;
MS. JANE L. SMILEY
BEN SPOCK, MD
MIKE D'ANGELO PHD
MRS. PAT Q. MCINTYRYE, RN
;
run;

proc print; run;

