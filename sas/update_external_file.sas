options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: update_external_file.sas
  *
  *  Summary: Update an external file in-place.
  *
  *  Adapted: Tue 03 Jun 2003 10:18:08 (Bob Heckel --
  *                  file:///C:/bookshelf_sas/lgref/z0146932.htm#z0177221)
  *---------------------------------------------------------------------------
  */
options source;

data _NULL_;
  /* The INFILE and FILE statements must specify the same file. */
  /*             efficient              */
  infile 'junk' SHAREBUFFERS;
  file 'junk';
  input state $ 1-2  phone $ 5-16; 
  if state eq 'NC' and substr(phone, 5, 3) eq '333' then
    phone = '910-'||substr(phone, 5, 8);
  put phone 5-16;
run;

endsas;

junk contents:
NJ  201-232-6752
NC  919-333-0641
NS  123-456-7890
