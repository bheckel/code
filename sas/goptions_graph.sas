
/* file:///C:/Bookshelf_SAS/gref/zonschap.htm#z0750291 */

goptions reset=global gunit=pct border
         ftext=swissb htitle=6 htext=3
         ctext=red cpattern=blue ctitle=green
         colors=(blue green red) hby=4;

/***proc goptions SHORT; run;***/
/* Display available options */
proc goptions; run;
