options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: macro.array.sas
  *
  *  Summary: Turn a macrovar into an array and loop iterate it
  *
  *           See also foreach.sas
  *
  *  Adapted: Wed 18 May 2005 13:35:08 (Bob Heckel
  *                     http://support.sas.com/ctx/samples/index.jsp?sid=818)
  *---------------------------------------------------------------------------
  */
options source NOcenter;


%macro looparray; 
  %local varlist i elem; 

  %let varlist=Age Height Name Sex Weight;
  %let i=0; 

  %do %while (%scan(&varlist, &i+1, %str( )) ne %str( ));
    %let i=%eval(&i+1); 
    %let elem=%scan(&varlist, &i, %str( ));  
    /** ... do something with current element here ... **/
    /****************************************************/
    %put pseudo arr[&i] is &elem;
    /****************************************************/
  %end; 
%mend looparray; 
%looparray

