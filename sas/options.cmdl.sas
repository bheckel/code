options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: options.cmdl.sas
  *
  *  Summary: Get a definition and current value of a specific SAS option.
  *
  *           E.g. sr options.cmdl.sas center
  *
  *  Created: Fri 13 Jun 2003 09:21:48 (Bob Heckel)
  * Modified: Thu 22 May 2008 14:45:37 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source ls=78;

proc options option=&SYSPARM define value;
run;
