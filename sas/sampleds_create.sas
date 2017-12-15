options nosource;
 /*---------------------------------------------------------------------------
  *     Name: sampleds_create.sas (see also sampleds_tmplt.sas for an :r version)
  *
  *  Summary: Create a sample dummy dataset for testing
  *
  *  Created: Thu, 04 Nov 1999 14:27:13 (Bob Heckel)
  * Modified: Mon 29 Jul 2013 15:07:44 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%macro sample3;
  /* Numeric sample dataset */
  data x;
    do x = 1 to 5;
      do y = 8 to 9;
        output;
      end;
    end;
  run;
%mend sample3;
%sample3;
proc print data=_LAST_(obs=5) width=minimum; run;


%macro sample4;
   /* Best? */
  data randnums (drop= n i);
   do a = 1 to 3;
     do b = 1 to 3;
       do c = 1 to 3;
         n = int(6*ranuni(1));
         do i=1 to n;
           y = a+b+rannor(1);
           output;
         end;
       end;
     end;
   end;
run;
%mend sample4;
%sample4;
proc print data=_LAST_(obs=5) width=minimum; run;


%macro sample5;
   /* Shortest? */
  data w ;
    do id = 1 to 100 ; r = ranuni ( 16854830 ) ; output ; end ;
  run ;
%mend sample5;
%sample5;
proc print data=_LAST_(obs=5) width=minimum; run;


%macro sample7;
  data testdata1;
    do id=1 to 100;
      x = ceil(ranuni(0) * 100);
      charx = put(x,Z2. -L);
      output;
    end;
  run;
%mend sample7;
%sample7;
proc print data=_LAST_(obs=5) width=minimum; run;
