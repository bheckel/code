
%let member1=Demog; 
%let member2=Adverse; 
%let Root=member;
%let Suffix=2; 

%put   &Root&Suffix;  /* member2 */
/* && resolves to & so we have &member2 which resolves down to... */
%put &&&Root&Suffix;  /* ...Adverse */

 /* Compare with double ampersand */
%let Root2=foo;
 /* && resolves to & so we have &Root2 which resolves down to... */
%put  &&Root&Suffix;  /* ...foo */



 /* http://support.sas.com/kb/42/101.html */

/* A long macro variable is created. */
%let pgm=%str(data exercise;                                                                                                            
 cardio=10;                                                                                                                             
 weights=20;                                                                                                                            
 totexer=cardio+weights;                                                                                                                
proc print;                                                                                                                             
run;);                                 

/* Generally when wanting to pass a macro variable to a macro definition
 one would say */
                                                                                                                     
options mprint symbolgen;                                                                                                               
%macro check2(val);                                                                                                                     
 &val          /* Notice 1 ampersand here */                                                                                                                        
%mend check2;                                                                                                                           
%check2(&pgm)  /* Notice the ampersand, causes &val to contain whole value */                                                                                                                         
                                                                                                                                      
/* The code below writes the same program as above, more efficiently */ 
  
options mprint symbolgen;                                                                                                                                     
%macro check2(val);                                                                                                                     
 &&&val       /* Notice 3 ampersands here */                                                                                                                           
%mend check2;                                                                                                                           
%check2(pgm)  /* Notice no ampersand, causes &val to contain only the string pgm */  
