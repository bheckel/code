 /*----------------------------------------------------------------------------
  *     Name: multlines_onepdv.sas
  *
  *  Summary: Allow multiple lines per record that makes up the program
  *           data vector (PDV).  Uses line pointer control slash '/'
  *           The slash says to move to column 1 of the next line of data
  *           before reading the next variable.
  *
  *  Created: Tue Apr 20 1999 13:44:09 (Bob Heckel)
  * Modified: Tue 03 Jun 2003 16:07:31 (Bob Heckel)
  *----------------------------------------------------------------------------
  */
 
data work.address;
  input name $ 1-20  /
        street $ 1-20
        #4 city $ 1-10  state $ 11-12  zip $ 14-18;
  cards;
Farr, Sue
15 Greenwood St
Info you do not want from line number three
Anaheim   CA 90066
Cox, Kathy B
1623 N. Ackron St
Info you do not want from line number three
Pasadena  CA 90063
  ;
run;
proc print; run;
