-- catput delete.batch.sql or ,h to remove a sample from links db 
delete from links_material_genealogy where prod_batch_nbr='6ZM9444' and prod_matl_nbr='4130797';
delete from links_material_genealogy where comp_batch_nbr='6ZM9444' and comp_matl_nbr='4130797';
-- find related samples: select distinct samp_id from samp where batch_nbr='6ZM9444';
delete from tst_rslt_summary where samp_id in(192578,200472);
delete from indvl_tst_rslt where samp_id in(192578,200472);
delete from stage_translation where samp_id in(192578,200472);
delete from samp where samp_id in(192578,200472);
delete from links_material where batch_nbr='6ZM9444' and matl_nbr='4130797';
--commit;

-- only run these for a 2nd run:

---delete from links_material_genealogy where prod_batch_nbr='6ZM9444' and prod_matl_nbr='4130797';
---delete from links_material_genealogy where comp_batch_nbr='6ZM9444' and comp_matl_nbr='4130797';
---delete from links_material where batch_nbr='6ZM9444' and matl_nbr='4130797';
--commit;
