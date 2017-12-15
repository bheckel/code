 /* Print special character list like vim's :dig */
data _null_ ;
  do k= 1 to 255 ;
    x=byte(k);
    put k + 10 x;
  end ;
run;


 /* Replace special chars with space */
do aa= 1 to 29 , 31 , 127 , 129 , 141 to 144 , 157 , 158;
  var1=tranwrd(var1,byte(aa), ' ');
end; 
