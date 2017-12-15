
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: LIMS parsing macro
 *  INPUT:            Product name
 *  PROCESSING:       Replace spaces with underscores
 *  OUTPUT:           None
 *******************************************************************************
 */                                                                                                                                                                                 /*}}}*/
%macro product;
  length product $20;

  product = translate("&prodnm", ' ', '_');
%mend product;
