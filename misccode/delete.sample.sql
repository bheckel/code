-- remove a sample from links db 
--sqlplus pks/dev123dba@usdev388 @c:/cygwin/home/bheckel/code/misccode/delete.sample.sql

delete from tst_rslt_summary where samp_id in(236420);

delete from indvl_tst_rslt where samp_id in(236420);

delete from stage_translation where samp_id in(236420);

delete from samp where samp_id in(236420);

delete from tst_parm where samp_id in(236420);

--commit;

exit;
