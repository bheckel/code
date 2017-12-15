--Build file used for Vim/afiedt.buf tab-completion hack

--Run from ~/code/misccode/:  @desc
--When completed run this to lowercase:
-- perl -pi -e 's/(\w+)/\L$1/g' c:/temp/spool/*.LST

--must be ON to capture table names
set echo on;
set termout off;

spool c:/temp/spool/Samp
describe Samp
spool off

spool c:/temp/spool/LINKS_Material
describe LINKS_Material
spool off

spool c:/temp/spool/Tst_Rslt_Summary
describe Tst_Rslt_Summary
spool off

spool c:/temp/spool/Indvl_Tst_Rslt
describe Indvl_Tst_Rslt
spool off

spool c:/temp/spool/Tst_Parm
describe Tst_Parm
spool off

spool c:/temp/spool/PKS_Extraction_Control
describe PKS_Extraction_Control
spool off

spool c:/temp/spool/Links_Material_Genealogy
describe Links_Material_Genealogy
spool off
