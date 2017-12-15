 /*----------------------------------------------------------------------------
  *     Name: random_sample_w_replace.sas
  *
  *  Summary: Demo of POINT and random sampling (with duplicate obs) 
  *           from SAS Programming.  Sample a random subset of a ds.
  *           Very efficient.
  *
  *  Created: Tue Jun 29 1999 16:08:47 (Bob Heckel)
  *  Adapted: Tue 25 May 2010 13:42:12 (Bob Heckel--SAS9 Advanced Certification)
  *----------------------------------------------------------------------------
  */

data sampler;
  do n=1 to 5;
    rndobsnum = ceil(ranuni(0)*nobs);
    set sashelp.shoes point=rndobsnum nobs=nobs;
    output;
  end;
  /* No EOF is detected in direct-access read mode. This STOP prevents the
   * data step from looping continuously.
   */
  stop;
run;

proc print; run;

