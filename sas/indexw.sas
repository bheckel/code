
 /* Find a word in a string.  The substring pattern MUST begin and end on a
  * word boundary. 
  */
data _null_;
  /* 1234567890123 */
  s='asdf adog dog';
  ***f='dog';
  f='dog  ';  /* this one won't match if use index() */

  i=index(s, f);
  w=indexw(s, f);

  if i then
    put '!!! finds "dog" in "adog" at pos ' i;
  if w then
    put '!!! finds "dog" in "dog" at pos ' w;
run;

endsas;
data Prescribers;
  set Prescribers;
  badaddress2=compress(Address2, ',');
  if indexw(badaddress2, city) and indexw(badaddress2, state) and 
     indexw(badaddress2, zipcode) then
     address2 = '';
run;
