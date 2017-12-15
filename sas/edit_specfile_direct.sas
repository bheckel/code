
data l.links_spec_fileTEMPBOB;
  set l.links_spec_fileTEMPBOB(where=(prod_family=:'Vent' and short_meth_nm=:'Cas'));

  if prod_family=:'Vent' and short_meth_nm=:'Cas' then do;
    if indvl_meth_stage_nm eq 'THROAT' and spec_group eq 'RELEASE' then do;
      output;  /* orig obs */
      reg_meth_name = 'Individual Particle Size Distribution per Actuation by Cascade Impaction - 0'; meth_ord_num = 101;
      short_meth_nm='Cascade Impaction-0'; indvl_meth_stage_nm='0'; spec_type='INDIVIDUAL'; low_limit=''; upr_limit=''; txt_limit_a='none'; txt_limit_b=''; txt_limit_c='';
      output;
    end;
    else if indvl_meth_stage_nm eq 'THROAT' and spec_group eq 'STABILITY' then do;
      output;  /* orig obs */
      reg_meth_name = 'Individual Particle Size Distribution per Actuation by Cascade Impaction - 0'; meth_ord_num = 101;
      short_meth_nm='Cascade Impaction-0'; indvl_meth_stage_nm='0'; spec_type='INDIVIDUAL'; low_limit=''; upr_limit=''; txt_limit_a='none'; txt_limit_b=''; txt_limit_c='';
      output;
    end;
    else
      output;  /* orig obs */
  end;
  else
    output;  /* orig obs */
run;
