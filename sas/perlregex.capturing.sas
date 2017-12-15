 /* v9 only ! */
data _null_;
  s='BF19.INX03012.FETMER';
  pattern_num = prxparse("/^[^.]*\.(\w\w)X(\d\d)(\d+)\..*MER$/"); 

  if prxmatch(pattern_num, s) then
    do;
      /* $1 */
      call prxposn(pattern_num, 1, pos, len);
      state = substr(s, pos, len);

      /* $2 */
      call prxposn(pattern_num, 2, pos, len);
      yr = substr(s, pos, len);

      /* $3 */
      call prxposn(pattern_num, 3, pos, len);
      ship = substr(s, pos, len);
    end;

  file PRINT; 
  put pattern_num= s= state= yr= ship=; 
run;
