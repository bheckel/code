options obs=max;

 /* See better dynamic way of reading in files in readin_multiple_IIS_logfiles.sas */
data fnames;
  infile cards MISSOVER;
  input fn $ 1-50;
  cards;
X:\BPMS\VA\Data\Claims\Incoming\CLM_VA0501.TXT
X:\BPMS\VA\Data\Claims\Incoming\CLM_VA0502.TXT
X:\BPMS\VA\Data\Claims\Incoming\CLM_VA0503.TXT
X:\BPMS\VA\Data\Claims\Incoming\CLM_VA0504.TXT
X:\BPMS\VA\Data\Claims\Incoming\CLM_VA0505.TXT
X:\BPMS\VA\Data\Claims\Incoming\CLM_VA0505_2.TXT
  ;
run;
  

data claims_in (keep= claim_id provider_lic  rename=(provider_lic=pharmacy));
  length plan $3 claim_id $16 actioncode $1 ndc $11 id_number $12
         prescriber_id $9 provider_lic $9 rx_number $7 insured_name $40
         genavail 3 label_name $30 gbo $1 active $200 stren $20 unit $20 
         brand $100 ndcstring $112 f_name $19 l_name $12 phys_fname $19 
         phys_lname $12 phys_addr1 $40 phys_city $17 phys_state $2 
         phys_zip $10 phys_phone $10 phys_spec $3
         ;
  set fnames;
  length currinfile $50;

  infile TMP delimiter = '@' MISSOVER DSD lrecl=32767 
         FILEVAR=fn FILENAME=currinfile END=done; 
         
  do while ( not done );
    input claim_id $ actioncode $ ndc $ date_filled days quantity total_paid
          id_number $ prescriber_id $ provider_lic $ rx_number $ refill_number
          birthdate f_name $ l_name $ phys_fname $ phys_lname $ phys_addr1 $
          phys_city $ phys_state $ phys_zip $ phys_phone $ phys_spec $
          ;
    output;
  end;
run;


 /* Want to remove leading zeros */
data claims_in (drop=tmpnum);
  set claims_in;
  tmpnum=input(pharmacy, F10.);
  /* Implicit force back to char */
  pharmacy=tmpnum;
run;
***proc contents; run;


proc sort data=claims_in NODUPKEY;
  by claim_id pharmacy;
run;
proc print data=_LAST_(obs=50); run;


libname BPMS oledb provider=sqloledb.1 
        properties=("Persist Security Info"=True "Integrated Security"=SSPI 
        "Data Source"="wnetbpms1\production"
        "Initial Catalog"="SANDBOX") schema=rheckel 
        ignore_read_only_columns=yes
        ;

 /* Table must already exist and be empty 
    use sandbox  delete from vapharm 
  */
proc datasets;
  append base=BPMS.vapharm data=claims_in;
quit;
