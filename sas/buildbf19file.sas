options NOsource;
 /*---------------------------------------------------------------------
  *     Name: NMGEOM
  *
  *  Summary: Create an NCHS formatted mainframe file based on a 
  *           textfile from Connie Gentry.  The input consists of 2
  *           columns - death certificate number and a geo code.
  *
  *           Will run (and write mf file) via Connect.
  *
  *  Created: Wed 07 Jul 2004 12:34:12 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options notes source NOcenter;

 /* Must be ff=unix and ncftp set to ASCII */
filename I  'BQH0.NMGEO.TXT';
filename O 'DWJ2.NMGEOM.D07JUL04' OLD;

data work.bf19;
  infile I;
  input cert geo $;
  /* Make sure input is clean. */
  if cert = "" then
    put '!!!!missing: ' cert=;
  if geo = "" then
    put '!!!!missing: ' geo=;
run;


data _NULL_;
  set work.bf19;
  /* We were asked to zero pad the certno and skip the trailing '1' */
  format cert Z6. geo $CHAR5.;
  file O LRECL=476 PAD;
  put @5 cert  @89 geo;
run;
