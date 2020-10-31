
libname ORACLEDML oracle user=myid password=mypw path="mydb";
proc sql NOIPASSTHRU;
  UPDATE ORACLEDML.Samp
     SET Prod_Grp ='solid', 
         Prod_Nm  ='testing'
   WHERE Samp_Id=144539 AND Matl_Nbr='4146344'
  ;
quit;
