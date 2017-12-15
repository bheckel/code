
/* This code assumes that Excel       */
/* is installed on the current        */
/* drive in a directory called EXCEL. */

options noxwait noxsync;
x 'C:\PROGRA~1\MICROS~2\Office10\excel.EXE';  /* you might need to specify the entire pathname */

/* Sleep for 5 seconds to give */
/* Excel time to come up.       */
data _null_;
   x=sleep(5);
run;

/* The DDE link is established using   */
/* Microsoft Excel SHEET1, rows 1      */
/* through 20 and columns 1 through 3  */

filename data
   dde 'excel|sheet1!r1c1:r20c3';
data one;
   file data;
   do i=1 to 20;
      x=ranuni(i);
      y=x+10;
      z=x/2;
      put x y z;
   end;
run;

/* Microsoft defines the DDE topic */
/* SYSTEM to enable commands to be */
/* invoked within Excel.           */

filename cmds dde 'excel|system';

/* These PUT statements are       */
/* executing Excel macro commands */

data _null_;
   file cmds;
   put '[SELECT("R1C1:R20C3")]';
   put '[SORT(1,"R1C1",1)]';
   put '[SAVE()]';
   put '[QUIT()]';
run;

