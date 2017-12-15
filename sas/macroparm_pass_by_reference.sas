options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: macroparm_pass_by_reference.sas
  *
  *  Summary: Demo of optimizing macro parameter passing at the expense of
  *           code obfuscation.
  *
  *  Adapted: Wed 01 Apr 2009 13:28:18 (Bob Heckel -- SUGI 045-2008)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

/* In this case, SAS macro will store two copies of the exact same text value--
 * one in the global symbol table as &myVar and one in the local symbol table
 * as &var.
 */
%let myVar = a whole lot of text a whole lot of text a whole lot of text etc;
%macro passByValue(var);
  %if &var ne %str() %then 
   %put !!!&var;
%mend passByValue;
%passByValue(&myVar);


/* We can avoid copying and storing the large text value by passing
 * the name of the global variable and using multiple ampersands inside the
 * macro to force SAS macro to rescan it. That way the large text value is only
 * stored in one place. This could result in a substantial memory savings.
 */
%let myVar = a whole lot of text a whole lot of text a whole lot of text etc;
%macro passByRef(var);
  %if &&&var ne %str() %then
   %put !!!&&&var;
%mend passByRef;
%passByRef(myVar);
