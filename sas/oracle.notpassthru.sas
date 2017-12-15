
libname RDORACLE oracle user=pks password=pks path="usdev100";
proc sql noipassthru;
  UPDATE RDORACLE.Samp
  SET Prod_Grp ='solid', 
      Prod_Nm  ='testing'
  WHERE Samp_Id=144539 AND Matl_Nbr='4146344' AND Batch_Nbr='4ZM6609'
  ;
quit;
