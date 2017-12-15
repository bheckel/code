 /* Adapted from NCHS SAS User Group attachment 2003-12-01 */

 /* Write values of 3 variables separated by a space */
put x y z; 

 /* Write the text 'name=' followed by the value of name, and then 'phone='
  * followed by the value of phone. 
  */
put name= phone=; 

 /* Write each element of my_array in the form variable=value */
put my_array(*)=; /* same */ put my_array[*]=; 

 /* Write text followed by hexadecimal 09 which is a tab character (in ASCII) */
put 'hello' '09'x; 

 /* Write 132 underscores */
put 132*'_';

 /* Write value of text at line 2 */
put #2 text; 

 /* Write value of cost out beginning at line 3 column 44 */
put #3 @44 cost;

 /* Write value of text at line specified in variable line */
put #line text; 

 /* Write value of text at line calculated by value of line multiplied by 3 */
put #(line*3) text; 

 /* Write value of line1, then go to a new line and write value of line2 */
put line1 / line2; 

 /* Write the value of myvar out into the columns from column 1 to column 5 */
put myvar 1-5; 

 /* Write the value of cost out using the DOLLAR12.2 format */
put cost DOLLAR12.2; 

 /* Write the value of a out using a 1. format, then a comma, then the value
  * of b using a $3. format 
  */
put (a b) (1. ',' $3.); 

 /* Write values of variables a, b & c out, separated by spaces & keep line
  * 'open' so that next put statement will continue on. If we reach end of
  * data step iteration then line is 'closed' 
  */
put a b c @; 

 /* Write values of variables d & e out, separated by spaces & keep line
  * 'open', even if we reach end of ds iteration.
  */
put d e @@; 

 /* Write value of 'a' followed by a number of spaces calculated by value of
  * gap multiplied by 2, and then value of 'b' 
  */
put a +(2*gap) b; 

 /*  Write out the current input buffer, as read by the last input statement */
put _infile_;

 /* Write out the values of all variables, including _error_ and _n_ */
put _all_;
put "foo" _all_;

 /* Write out the default or previously defined variables to the ODS
  * destination 
  */
put _ods_; 

 /* Ensure that a totally blank page is produced. This means that if we had
  * written even 1 character on a page, then that page will be written as well
  * as another totally blank page. 
  */
put _blankpage_; 

 /* This finishes the current page, causing the next thing we write out to be
  * on a new page. 
  */
put _page_; 

 /* Repeat character x number of times */
put 78 * '~';
put 40 * '-' / myvar;
