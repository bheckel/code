options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: mfile.sas
  *
  *  Summary: Write all (MPRINT) data to an external file.  Better than using
  *           vim with a :g!/^MPRIN/d b/c that misses mprint lines that wrap.
  *
  *  Created: Mon 09 Jan 2006 09:20:07 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

options mfile mprint;

 /*      keyword      */
filename MPRINT 'junk';

%macro mktitle(proc, data);
  title "%upcase(&proc) of %upcase(&data)";
%mend mktitle;
%mktitle(foo, bar)
