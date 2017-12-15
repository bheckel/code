options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: whohas.sas
  *
  *  Summary: Determine the statistician and VSS assignments from the
  *           Register.
  *
  *           Data is used to populate the __DATA__ section of
  *           reviser-file-ck.pl on tstdev.
  *
  *  Created: Tue 07 Sep 2004 15:18:19 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Double loop (for each event and year) within this looping code. */
%macro ForEach(evtlist);
  %local i j e;

  %let i=1;
  %let e=%scan(&evtlist, &i, ' ');

  /* Using %bquote to protect against states like OR and NE. */
  %do %while ( %bquote(&e) ne  );
    %let i=%eval(&i+1);

    /* Only works for years 2000+ */
    %let j=3;
    %do %while ( &j lt 5  );
      libname THELIB "DWJ2.REGISTER.MOR200&j" DISP=SHR;

      data tmp;
        set THELIB.register;
        daebspec = lowcase(daebspec);
        daebstat = lowcase(daebstat);
        stabbrev = lowcase(stabbrev);
        yy = "0&j";
        if "&e" eq 'NAT' then
          evt = "nat";
        else
          evt = "dem";
      run;

      proc append base=tmpall data=tmp; run;
      %let j=%eval(&j+1);
    %end;

    %let e=%scan(&evtlist, &i, ' ');
  %end;
%mend ForEach;
%ForEach(NAT MOR)

proc print data=tmpall NOobs;
  var daebspec daebstat stabbrev evt yy;
run;
