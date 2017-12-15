/* SAS version of 99 bottles of beer        */
/* by Whitey (whitey@netcom.com) - 06/05/95 */

data _NULL_;
  do i = 99 to 1 by -1;
    put i 'bottles of beer on the wall,' i 'bottles of beer,';
    put 'take one down, pass it around,';
    j = i - 1;
    if j = 0 then
      put 'no more ' @;
    else
      put j @;
    put 'bottles of beer on the wall.';
  end;
run;
