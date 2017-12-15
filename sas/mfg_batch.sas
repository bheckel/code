
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: LIMS parsing macro
 *  INPUT:            Method on which to manufacturing batch
 *  PROCESSING:       None
 *  OUTPUT:           None
 *******************************************************************************
 */
%macro mfg_batch(meth);
  length mfg_batch $40;

  /* SC01/008-25/60-48-01 */
  if &meth._SampleName eq: 'SC' then do;
    mfg_batch = '';
  end;
  /* 6ZM3225-040000254751-01 or X5ZM1022-040000182067-01 */
  else if NOT verify(substr(&meth._SampleName,1, 1), '0123456789X') then do;
    mfg_batch = scan(&meth._SampleName, 1, '-');
  end;
  else
    mfg_batch = '';  /* possibly filled later */

  if not index(mfg_batch, 'ZM') and mfg_batch ne '' then do;
    %print_warning(mfg_batch);
    delete;
  end;
%mend mfg_batch;
