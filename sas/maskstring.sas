data hidesocialsecurity; 
  ssn = '123-45-6789'; 
  substr(ssn, 5, 2) = '##'; 
  put ssn=; 
run; 
