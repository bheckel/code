
/* Remove NC's trailing comma on prescribers with no middle name */
if substr(reverse(strip(prescriber_salutation)),1,1) eq ',' then
  do;
    len=length(prescriber_salutation);
    prescriber_salutation=substr(strip(prescriber_salutation),1,len-1);
  end;
