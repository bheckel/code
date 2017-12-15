/*----------------------------------------------------------------------------
 * Program Name:  bubblesort
 *
 *      Summary: Demo of the bubblesort sorting algorithm.
 *
 *    Generated:  Wed 10/21/98 02:56:09 (Bob Heckel)
 * Modified: Tue 27 May 2003 15:48:42 (Bob Heckel)
 *----------------------------------------------------------------------------
 */

data _NULL_;
  array arr[*] $ arr1-arr4;
  /* One, not zero-based! */
  arr[1] = 'c';
  arr[2] = 'a';
  arr[3] = 'd';
  arr[4] = 'b';
  nelems = dim(arr);
  put nelems=;

  /* Outer loop causes pgm to pass over the array 3 times -- one fewer than
   * the number of elements in the array (theoretical num of passes needed to
   * put the array in order).  Inner loop examines each consecutive pair of
   * elements in the array, exchanging them where indicated.
   */
  do i = 1 to nelems-1;
    do j = 2 to nelems;
      if arr(j-1) > arr(j) then 
        do;
          swaptmp = arr(j-1);
          arr(j-1) = arr(j);
          arr(j) = swaptmp;
        end;
      end;
    end;

   do k = 1 to nelems; 
     put arr{k}=; 
   end; 
run;
