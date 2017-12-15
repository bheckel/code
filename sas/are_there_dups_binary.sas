
libname l 'C:\datapost\data\GSK\Zebulon\MDPI\AdvairDiskus';

 /* Want NOTE: 0 observations with duplicate key values were deleted. */
proc sort data=l.ols_0016t_advairdiskusPRD out=ignore NOdupkey;
  by long_product_name--work_cntr_cod;
run;
